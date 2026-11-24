`timescale 1ns/1ps

module cpu_tb;

reg clk;
reg reset;

integer pass_count;

cpu_top DUT(
    .clk(clk),
    .reset(reset)
);

//////////////////////////////////////////////////
// CLOCK
//////////////////////////////////////////////////

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

//////////////////////////////////////////////////
// RESET
//////////////////////////////////////////////////

initial begin

    reset = 1;

    #20;
    reset = 0;

    #500;

    $finish;

end

//////////////////////////////////////////////////
// EXECUTION TIMELINE
//////////////////////////////////////////////////

always @(posedge clk) begin

    if(DUT.wb_RegWrite && DUT.wb_rd != 0) begin

        $display(
            "T=%0t ns | WB -> x%0d = %0d (0x%08h)",
            $time,
            DUT.wb_rd,
            DUT.wb_data,
            DUT.wb_data
        );

    end

end

//////////////////////////////////////////////////
// FINAL REPORT
//////////////////////////////////////////////////

initial begin

    pass_count = 0;

    #450;

    $display("");
    $display("==============================================================");
    $display("                A1 ARITHMETIC VALIDATION REPORT");
    $display("==============================================================");
    $display("");
    $display("Register | Expected | Actual(DEC) | Actual(HEX) | Status");
    $display("--------------------------------------------------------------");

    check_reg(1 ,10);
    check_reg(2 ,5);
    check_reg(3 ,15);
    check_reg(4 ,5);
    check_reg(5 ,0);
    check_reg(6 ,15);
    check_reg(7 ,15);
    check_reg(8 ,160);
    check_reg(9 ,5);
    check_reg(10,1);
    check_reg(11,2);
    check_reg(12,13);
    check_reg(13,2);
    check_reg(14,20);
    check_reg(15,5);
    check_reg(16,1);

    $display("--------------------------------------------------------------");
    $display("PASSED = %0d / 16", pass_count);

    $display("");
    $display("SUCCESS RATE = %0.2f%%",
             (pass_count*100.0)/16.0);

    $display("Total Cycles = %0d", cycle_count);

    $display("==============================================================");
    $display("");
    $display("instr[3] = %h", DUT.IMEM.memory[3]);
end

//////////////////////////////////////////////////
// CHECK TASK
//////////////////////////////////////////////////

task check_reg;

    input integer reg_num;
    input integer expected;

    begin

        if(DUT.REGFILE.regs[reg_num] === expected) begin

            pass_count = pass_count + 1;

            $display(
                "x%-2d      | %-8d   | %-11d | %08h   | PASS",
                reg_num,
                expected,
                DUT.REGFILE.regs[reg_num],
                DUT.REGFILE.regs[reg_num]
            );

        end
        else begin

            $display(
                "x%-2d      | %-8d | %-11d | %08h | FAIL",
                reg_num,
                expected,
                DUT.REGFILE.regs[reg_num],
                DUT.REGFILE.regs[reg_num]
            );

        end

    end

endtask
//////////////////////////////////////////////////
// REAL SUB DEBUG (rd = x4)
//////////////////////////////////////////////////

integer cycle_count;

always @(posedge clk) begin

    if(!reset)
        cycle_count = cycle_count + 1;

end

initial begin
    cycle_count = 0;
end


endmodule