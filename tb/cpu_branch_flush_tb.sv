`timescale 1ns/1ps
module cpu_branch_flush_tb;
    reg clk = 0;
    reg reset = 1;
    wire [31:0] pc;
    integer i;
    integer errors = 0;
    reg saw_redirect_with_hazard = 0;
    localparam [31:0] SENTINEL = 32'hCAFE_F00D;

    cpu_top dut (.clk(clk), .reset(reset), .debug_out(pc));
    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (!reset && dut.mem_BranchTaken && dut.HAZARD.stall)
            saw_redirect_with_hazard <= 1;
    end

    task automatic check_value(input string label_text,
                               input logic [31:0] actual, expected);
        if (actual !== expected) begin
            $display("FAIL %s: expected %h, got %h", label_text, expected, actual);
            errors = errors + 1;
        end
    endtask

    initial begin
        // At time zero the DUT initializes its built-in example. Replace it
        // during reset, after initialization and away from a rising clock edge.
        @(negedge clk);
        for (i = 0; i < 256; i = i + 1)
            dut.IMEM.memory[i] = 32'h00000013;  // nop

        dut.DMEM.memory[0] = SENTINEL;
        dut.DMEM.memory[1] = 32'd37;
        dut.DMEM.memory[2] = 0;

        dut.IMEM.memory[0]  = 32'h00100093; // addi x1,x0,1
        dut.IMEM.memory[1]  = 32'h05A00113; // addi x2,x0,90
        dut.IMEM.memory[2]  = 32'h00108863; // beq  x1,x1,+16 -> word 6
        dut.IMEM.memory[3]  = 32'h00202023; // sw   x2,0(x0)   [wrong path, EX]
        dut.IMEM.memory[4]  = 32'h06300293; // addi x5,x0,99  [wrong path, ID]
        dut.IMEM.memory[5]  = 32'h04D00313; // addi x6,x0,77  [wrong path, IF]
        dut.IMEM.memory[6]  = 32'h00150513; // addi x10,x10,1 [target]
        dut.IMEM.memory[7]  = 32'h00109663; // bne  x1,x1,+12 [not taken]
        dut.IMEM.memory[8]  = 32'h00B00593; // addi x11,x0,11
        dut.IMEM.memory[9]  = 32'h00B02423; // sw   x11,8(x0)
        dut.IMEM.memory[10] = 32'h00108863; // beq  x1,x1,+16 -> word 14
        dut.IMEM.memory[11] = 32'h00402383; // lw   x7,4(x0)  [wrong path]
        dut.IMEM.memory[12] = 32'h00738433; // add  x8,x7,x7  [load-use hazard]
        dut.IMEM.memory[13] = 32'h00900493; // addi x9,x0,9   [wrong path]
        dut.IMEM.memory[14] = 32'h00160613; // addi x12,x12,1 [target]
        dut.IMEM.memory[15] = 32'h010006EF; // jal  x13,+16 -> word 19, link = 64
        dut.IMEM.memory[16] = 32'h00202023; // sw   x2,0(x0)  [wrong path]
        dut.IMEM.memory[17] = 32'h00E00713; // addi x14,x0,14 [wrong path]
        dut.IMEM.memory[18] = 32'h00F00793; // addi x15,x0,15 [wrong path]
        dut.IMEM.memory[19] = 32'h00168813; // addi x16,x13,1 [target]
        dut.IMEM.memory[20] = 32'h00100893; // addi x17,x0,1  [completion marker]

        @(negedge clk);
        reset = 0;
        repeat (60) @(negedge clk);

        check_value("wrong-path stores", dut.DMEM.memory[0], SENTINEL);
        check_value("killed x5", dut.REGFILE.regs[5], 0);
        check_value("killed x6", dut.REGFILE.regs[6], 0);
        check_value("first target executed once", dut.REGFILE.regs[10], 1);
        check_value("untaken branch fall-through", dut.REGFILE.regs[11], 11);
        check_value("fall-through store", dut.DMEM.memory[2], 11);
        check_value("wrong-path load", dut.REGFILE.regs[7], 0);
        check_value("wrong-path load consumer", dut.REGFILE.regs[8], 0);
        check_value("wrong-path x9", dut.REGFILE.regs[9], 0);
        check_value("redirect and load-use overlapped", {31'b0, saw_redirect_with_hazard}, 1);
        check_value("second target executed once", dut.REGFILE.regs[12], 1);
        check_value("jal link", dut.REGFILE.regs[13], 64);
        check_value("killed x14", dut.REGFILE.regs[14], 0);
        check_value("killed x15", dut.REGFILE.regs[15], 0);
        check_value("jump target used link", dut.REGFILE.regs[16], 65);
        check_value("completion", dut.REGFILE.regs[17], 1);
        if (errors != 0)
            $fatal(1, "FAIL cpu_branch_flush_tb: %0d checks failed (PC %h)", errors, pc);
        $display("PASS cpu_branch_flush_tb");
        $finish;
    end
endmodule
