`timescale 1ns / 1ps

module dmem(

    input clk,

    input MemRead,
    input MemWrite,

    input [31:0] addr,
    input [31:0] write_data,

    output reg [31:0] read_data
);

//////////////////////////////////////////////////
// DATA MEMORY
//////////////////////////////////////////////////

reg [31:0] memory [0:255];

//////////////////////////////////////////////////
// ACCELERATOR REGISTERS
//////////////////////////////////////////////////

reg [31:0] base_a_reg;
reg [31:0] base_b_reg;
reg        start_reg;

wire       accel_done;
wire [63:0] accel_result;

//////////////////////////////////////////////////
// INITIAL DATA
//////////////////////////////////////////////////

initial begin

    // Prime Verification Data

    memory[25] = 2;
    memory[26] = 3;
    memory[27] = 5;
    memory[28] = 7;
    memory[29] = 11;
    memory[30] = 13;
    memory[31] = 17;
    memory[32] = 19;

    base_a_reg = 32'd0;
    base_b_reg = 32'd0;
    start_reg  = 1'b0;

end

//////////////////////////////////////////////////
// DOT PRODUCT ACCELERATOR
//////////////////////////////////////////////////

dot_accelerator ACCEL(

    .clk(clk),
    .reset(1'b0),

    .start(start_reg),

    .A0(memory[base_a_reg[9:2] + 0]),
    .A1(memory[base_a_reg[9:2] + 1]),
    .A2(memory[base_a_reg[9:2] + 2]),
    .A3(memory[base_a_reg[9:2] + 3]),

    .B0(memory[base_b_reg[9:2] + 0]),
    .B1(memory[base_b_reg[9:2] + 1]),
    .B2(memory[base_b_reg[9:2] + 2]),
    .B3(memory[base_b_reg[9:2] + 3]),

    .done(accel_done),

    .result(accel_result)

);

//////////////////////////////////////////////////
// WRITE LOGIC
//////////////////////////////////////////////////

always @(posedge clk)
begin

    //////////////////////////////////////////////////
    // START PULSE AUTO CLEAR
    //////////////////////////////////////////////////

    start_reg <= 1'b0;

    if(MemWrite)
    begin

        case(addr)

            //////////////////////////////////////////////////
            // MMIO REGISTERS
            //////////////////////////////////////////////////

            32'hFFFF0000:
                base_a_reg <= write_data;

            32'hFFFF0004:
                base_b_reg <= write_data;

            32'hFFFF0008:
                start_reg <= write_data[0];

            //////////////////////////////////////////////////
            // NORMAL MEMORY
            //////////////////////////////////////////////////

            default:
                memory[addr[9:2]] <= write_data;

        endcase

    end

end

//////////////////////////////////////////////////
// READ LOGIC
//////////////////////////////////////////////////

always @(*)
begin

    if(MemRead)
    begin

        case(addr)

            //////////////////////////////////////////////////
            // RESULT LOW
            //////////////////////////////////////////////////

            32'hFFFF000C:
                read_data = accel_result[31:0];

            //////////////////////////////////////////////////
            // RESULT HIGH
            //////////////////////////////////////////////////

            32'hFFFF0010:
                read_data = accel_result[63:32];

            //////////////////////////////////////////////////
            // DONE FLAG
            //////////////////////////////////////////////////

            32'hFFFF0014:
                read_data = {31'd0, accel_done};

            //////////////////////////////////////////////////
            // NORMAL MEMORY
            //////////////////////////////////////////////////

            default:
                read_data = memory[addr[9:2]];

        endcase

    end
    else
    begin

        read_data = 32'd0;

    end

end

endmodule