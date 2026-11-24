`timescale 1ns/1ps

module cpu_tb;

reg clk;
reg reset;

integer pass_count;
integer cycle_count;

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
// CYCLE COUNTER
//////////////////////////////////////////////////

initial begin
    cycle_count = 0;
end

always @(posedge clk) begin

    if(!reset)
        cycle_count = cycle_count + 1;

end

//////////////////////////////////////////////////
// WRITEBACK MONITOR
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
    $display("=================================================================");
    $display("                 A2.1 BASIC MEMORY VALIDATION");
    $display("=================================================================");
    $display("");

    //////////////////////////////////////////////////
    // REGISTER CHECK
    //////////////////////////////////////////////////

    $display("REGISTER RESULTS");
    $display("-----------------------------------------------------------------");
    $display("Register | Expected | Actual(DEC) | Actual(HEX) | Status");
    $display("-----------------------------------------------------------------");

    check_reg(1,100);
    check_reg(2,25);
    check_reg(3,50);
    check_reg(4,25);
    check_reg(5,50);

    //////////////////////////////////////////////////
    // MEMORY CHECK
    //////////////////////////////////////////////////

    $display("");
    $display("MEMORY RESULTS");
    $display("-----------------------------------------------------------------");
    $display("Address | Expected | Actual(DEC) | Actual(HEX) | Status");
    $display("-----------------------------------------------------------------");

    check_mem(100,25);
    check_mem(104,50);

    //////////////////////////////////////////////////
    // SUMMARY
    //////////////////////////////////////////////////

    $display("-----------------------------------------------------------------");
    $display("PASSED = %0d / 7", pass_count);

    $display("");

    $display(
        "SUCCESS RATE = %0.2f%%",
        (pass_count * 100.0)/7.0
    );

    $display("");

    $display("Total Cycles = %0d", cycle_count);

    $display("=================================================================");
    $display("");

end

//////////////////////////////////////////////////
// REGISTER CHECK
//////////////////////////////////////////////////

task check_reg;

    input integer reg_num;
    input integer expected;

    begin

        if(DUT.REGFILE.regs[reg_num] === expected) begin

            pass_count = pass_count + 1;

            $display(
                "x%-2d      | %-8d | %-11d | %08h | PASS",
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
// MEMORY CHECK
//////////////////////////////////////////////////

task check_mem;

    input integer addr;
    input integer expected;

    begin

        if(DUT.DMEM.memory[addr >> 2] === expected) begin

            pass_count = pass_count + 1;

            $display(
                "%-7d | %-8d | %-11d | %08h | PASS",
                addr,
                expected,
                DUT.DMEM.memory[addr >> 2],
                DUT.DMEM.memory[addr >> 2]
            );

        end
        else begin

            $display(
                "%-7d | %-8d | %-11d | %08h | FAIL",
                addr,
                expected,
                DUT.DMEM.memory[addr >> 2],
                DUT.DMEM.memory[addr >> 2]
            );

        end

    end

endtask

endmodule