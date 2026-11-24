module mem_wb(

    input clk,
    input reset,

    // CONTROL
    input RegWrite_in,
    input MemtoReg_in,

    input Jump_in,

    // DATAPATH
    input [31:0] read_data_in,
    input [31:0] alu_result_in,

    input [31:0] pc_plus4_in,

    input [4:0] rd_in,

    // OUTPUTS

    output reg RegWrite_out,
    output reg MemtoReg_out,

    output reg Jump_out,

    output reg [31:0] read_data_out,
    output reg [31:0] alu_result_out,

    output reg [31:0] pc_plus4_out,

    output reg [4:0] rd_out
);

always @(posedge clk or posedge reset) begin

    if(reset) begin

        RegWrite_out <= 0;
        MemtoReg_out <= 0;

        Jump_out <= 0;

        read_data_out <= 0;
        alu_result_out <= 0;

        pc_plus4_out <= 0;

        rd_out <= 0;

    end

    else begin

        RegWrite_out <= RegWrite_in;
        MemtoReg_out <= MemtoReg_in;

        Jump_out <= Jump_in;

        read_data_out <= read_data_in;
        alu_result_out <= alu_result_in;

        pc_plus4_out <= pc_plus4_in;

        rd_out <= rd_in;

    end

end

endmodule