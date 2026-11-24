module dot_accelerator(

    input clk,
    input reset,

    input start,

    input [31:0] A0,
    input [31:0] A1,
    input [31:0] A2,
    input [31:0] A3,

    input [31:0] B0,
    input [31:0] B1,
    input [31:0] B2,
    input [31:0] B3,

    output reg done,

    output reg [63:0] result
);

//////////////////////////////////////////////////
// FSM STATES
//////////////////////////////////////////////////

reg [1:0] state;

localparam S_IDLE    = 2'b00;
localparam S_COMPUTE = 2'b01;
localparam S_DONE    = 2'b10;

//////////////////////////////////////////////////
// PARALLEL MULTIPLIERS
//////////////////////////////////////////////////

wire [63:0] mul0;
wire [63:0] mul1;
wire [63:0] mul2;
wire [63:0] mul3;

assign mul0 = A0 * B0;
assign mul1 = A1 * B1;
assign mul2 = A2 * B2;
assign mul3 = A3 * B3;

//////////////////////////////////////////////////
// ADDER TREE
//////////////////////////////////////////////////

wire [63:0] sum0;
wire [63:0] sum1;

assign sum0 = mul0 + mul1;
assign sum1 = mul2 + mul3;

wire [63:0] dot_result;

assign dot_result = sum0 + sum1;

//////////////////////////////////////////////////
// FSM
//////////////////////////////////////////////////

always @(posedge clk or posedge reset)
begin

    if(reset)
    begin

        state  <= S_IDLE;
        result <= 64'd0;
        done   <= 1'b0;

    end

    else
    begin

        case(state)

        //////////////////////////////////////////////////
        // IDLE
        //////////////////////////////////////////////////

        S_IDLE:
        begin

            done <= 1'b0;

            if(start)
                state <= S_COMPUTE;

        end

        //////////////////////////////////////////////////
        // COMPUTE
        //////////////////////////////////////////////////

        S_COMPUTE:
        begin

            result <= dot_result;

            state <= S_DONE;

        end

        //////////////////////////////////////////////////
        // DONE
        //////////////////////////////////////////////////

        S_DONE:
        begin

            done <= 1'b1;

            //////////////////////////////////////////////////
            // Start new job
            //////////////////////////////////////////////////

            if(start)
            begin

                done <= 1'b0;

                state <= S_COMPUTE;

            end

        end

        //////////////////////////////////////////////////
        // DEFAULT
        //////////////////////////////////////////////////

        default:
        begin

            state <= S_IDLE;

            result <= 64'd0;

            done <= 1'b0;

        end

        endcase

    end

end

endmodule