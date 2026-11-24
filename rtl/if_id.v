module if_id(

    input clk,
    input reset,

    input stall,
    input flush,

    input [31:0] pc_in,
    input [31:0] instr_in,

    output reg [31:0] pc_out,
    output reg [31:0] instr_out
);

always @(posedge clk or posedge reset) begin

    if(reset) begin

        pc_out    <= 32'd0;
        instr_out <= 32'd0;

    end

    else if(flush) begin

        pc_out    <= 32'd0;
        instr_out <= 32'h00000013;   // NOP

    end

    else if(!stall) begin

        pc_out    <= pc_in;
        instr_out <= instr_in;

    end

end

endmodule