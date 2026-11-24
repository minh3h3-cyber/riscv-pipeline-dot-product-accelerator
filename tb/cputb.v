`timescale 1ns / 1ps

module cputb;

    reg clk;
    reg reset;

    cpu_top DUT (
        .clk(clk),
        .reset(reset)
    );

    // Clock 10ns
    always #5 clk = ~clk;

    // Reset
    initial begin
        clk = 0;
        reset = 1;

        #20;
        reset = 0;
    end

    // Trace toàn bộ CPU
    always @(posedge clk) begin
        if(!reset) begin

            $display("=================================================");
            $display("TIME = %0t", $time);

            $display("PC    = %h", DUT.pc_current);
            $display("INSTR = %h", DUT.instr);

            $display("x1  = %0d", DUT.REGFILE.regs[1]);
            $display("x2  = %0d", DUT.REGFILE.regs[2]);
            $display("x3  = %0d", DUT.REGFILE.regs[3]);
            $display("x4  = %0d", DUT.REGFILE.regs[4]);
            $display("x5  = %0d", DUT.REGFILE.regs[5]);
            $display("x6  = %0d", DUT.REGFILE.regs[6]);
            $display("x10 = %0d", DUT.REGFILE.regs[10]);

        end
    end

    // Bắt riêng lệnh branch cuối
    always @(posedge clk) begin
        if(!reset && DUT.instr == 32'hFE41C6E3) begin

            $display("");
            $display("######## BLT DETECTED ########");

            $display("TIME = %0t", $time);
            $display("PC   = %h", DUT.pc_current);

            $display("x3   = %0d", DUT.REGFILE.regs[3]);
            $display("x4   = %0d", DUT.REGFILE.regs[4]);

            $display("##############################");
            $display("");

        end
    end

    // Kết thúc simulation
    initial begin

        #2000;

        $display("");
        $display("====================================");
        $display("FINAL RESULT");
        $display("====================================");

        $display("x1  = %0d", DUT.REGFILE.regs[1]);
        $display("x2  = %0d", DUT.REGFILE.regs[2]);
        $display("x3  = %0d", DUT.REGFILE.regs[3]);
        $display("x4  = %0d", DUT.REGFILE.regs[4]);
        $display("x5  = %0d", DUT.REGFILE.regs[5]);
        $display("x6  = %0d", DUT.REGFILE.regs[6]);
        $display("x10 = %0d", DUT.REGFILE.regs[10]);

        if(DUT.REGFILE.regs[10] == 8)
            $display("PASS");
        else
            $display("FAIL");

        $display("====================================");

        $finish;
    end

endmodule