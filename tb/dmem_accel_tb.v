`timescale 1ns / 1ps

module dmem_accel_tb;

reg clk;

reg MemRead;
reg MemWrite;

reg [31:0] addr;
reg [31:0] write_data;

wire [31:0] read_data;

//////////////////////////////////////////////////
// DUT
//////////////////////////////////////////////////

dmem DUT(

    .clk(clk),

    .MemRead(MemRead),
    .MemWrite(MemWrite),

    .addr(addr),
    .write_data(write_data),

    .read_data(read_data)

);

//////////////////////////////////////////////////
// CLOCK
//////////////////////////////////////////////////

initial begin

    clk = 0;

    forever #5 clk = ~clk;

end

//////////////////////////////////////////////////
// TEST
//////////////////////////////////////////////////

initial begin

    MemRead  = 0;
    MemWrite = 0;

    addr = 0;
    write_data = 0;

    //////////////////////////////////////////////////
    // LOAD TEST VECTORS
    //////////////////////////////////////////////////

    DUT.memory[25] = 1;
    DUT.memory[26] = 2;
    DUT.memory[27] = 3;
    DUT.memory[28] = 4;

    DUT.memory[29] = 5;
    DUT.memory[30] = 6;
    DUT.memory[31] = 7;
    DUT.memory[32] = 8;

    $display("");
    $display("====================================");
    $display("LOAD VECTOR DATA");
    $display("====================================");

    $display("A = [%0d %0d %0d %0d]",
        DUT.memory[25],
        DUT.memory[26],
        DUT.memory[27],
        DUT.memory[28]);

    $display("B = [%0d %0d %0d %0d]",
        DUT.memory[29],
        DUT.memory[30],
        DUT.memory[31],
        DUT.memory[32]);

    #20;

    //////////////////////////////////////////////////
    // WRITE BASE A
    //////////////////////////////////////////////////

    $display("");
    $display("WRITE BASE A");

    addr       = 32'hFFFF0000;
    write_data = 32'h00000064;
    MemWrite   = 1;

    #10;

    MemWrite = 0;

    #10;

    $display("base_a_reg = %h", DUT.base_a_reg);

    //////////////////////////////////////////////////
    // WRITE BASE B
    //////////////////////////////////////////////////

    $display("");
    $display("WRITE BASE B");

    addr       = 32'hFFFF0004;
    write_data = 32'h00000074;
    MemWrite   = 1;

    #10;

    MemWrite = 0;

    #10;

    $display("base_b_reg = %h", DUT.base_b_reg);

    //////////////////////////////////////////////////
    // START ACCELERATOR
    //////////////////////////////////////////////////

    $display("");
    $display("START ACCELERATOR");

    addr       = 32'hFFFF0008;
    write_data = 32'h00000001;
    MemWrite   = 1;

    #10;

    MemWrite = 0;

    //////////////////////////////////////////////////
    // DEBUG WAIT
    //////////////////////////////////////////////////

    #50;

    $display("");
    $display("====================================");
    $display("ACCELERATOR INTERNAL STATE");
    $display("====================================");

    $display("base_a_reg  = %h", DUT.base_a_reg);
    $display("base_b_reg  = %h", DUT.base_b_reg);
    $display("start_reg   = %b", DUT.start_reg);

    $display("accel_done  = %b", DUT.accel_done);
    $display("accel_result= %d", DUT.accel_result);

    //////////////////////////////////////////////////
    // READ DONE REGISTER
    //////////////////////////////////////////////////

    addr = 32'hFFFF0014;
    MemRead = 1;

    #10;

    $display("");
    $display("DONE REGISTER = %d", read_data);

    MemRead = 0;

    //////////////////////////////////////////////////
    // READ RESULT LOW
    //////////////////////////////////////////////////

    addr = 32'hFFFF000C;
    MemRead = 1;

    #10;

    $display("RESULT LOW REGISTER = %d", read_data);

    MemRead = 0;

    //////////////////////////////////////////////////
    // FINAL CHECK
    //////////////////////////////////////////////////

    $display("");
    $display("====================================");
    $display("FINAL RESULT");
    $display("====================================");

    if(read_data == 32'd70)
    begin
        $display("PASS");
        $display("Result = %d", read_data);
    end
    else
    begin
        $display("FAIL");
        $display("Result = %d", read_data);
    end

    $display("====================================");

    #20;

    $finish;

end

endmodule