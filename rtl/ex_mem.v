module ex_mem(

    input clk,
    input reset,

    // CONTROL
    input RegWrite_in,
    input MemRead_in,
    input MemWrite_in,
    input MemtoReg_in,

    input Branch_in,
    input BranchTaken_in,

    input Jump_in,
    input Jalr_in,

    // DATAPATH
    input [31:0] branch_target_in,
    input [31:0] alu_result_in,
    input [31:0] write_data_in,

    input [31:0] pc_plus4_in,

    input [4:0] rd_in,

    // OUTPUTS

    // CONTROL
    output reg RegWrite_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg MemtoReg_out,

    output reg Branch_out,
    output reg BranchTaken_out,

    output reg Jump_out,
    output reg Jalr_out,

    // DATAPATH
    output reg [31:0] branch_target_out,
    output reg [31:0] alu_result_out,
    output reg [31:0] write_data_out,

    output reg [31:0] pc_plus4_out,

    output reg [4:0] rd_out
);

always @(posedge clk or posedge reset) begin

    if(reset) begin

        RegWrite_out <= 0;
        MemRead_out <= 0;
        MemWrite_out <= 0;
        MemtoReg_out <= 0;

        Branch_out <= 0;
        BranchTaken_out <= 0;

        Jump_out <= 0;
        Jalr_out <= 0;

        branch_target_out <= 0;
        alu_result_out <= 0;
        write_data_out <= 0;

        pc_plus4_out <= 0;

        rd_out <= 0;

    end
    else begin

        RegWrite_out <= RegWrite_in;
        MemRead_out <= MemRead_in;
        MemWrite_out <= MemWrite_in;
        MemtoReg_out <= MemtoReg_in;

        Branch_out <= Branch_in;
        BranchTaken_out <= BranchTaken_in;

        Jump_out <= Jump_in;
        Jalr_out <= Jalr_in;

        branch_target_out <= branch_target_in;
        alu_result_out <= alu_result_in;
        write_data_out <= write_data_in;

        pc_plus4_out <= pc_plus4_in;

        rd_out <= rd_in;

    end

end

endmodule