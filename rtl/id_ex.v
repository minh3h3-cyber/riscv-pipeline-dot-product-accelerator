module id_ex(

    input clk,
    input reset,

    input stall,
    input flush,
    // CONTROL SIGNALS
    input RegWrite_in,
    input MemRead_in,
    input MemWrite_in,
    input MemtoReg_in,
    input ALUSrc_in,
    input Branch_in,
    input BranchNotEqual_in,
    input Jump_in,
    input Jalr_in,

    input [1:0] ALUOp_in,

    // DATAPATH SIGNALS
    input [31:0] pc_in,
    input [31:0] pc_plus4_in,

    input [31:0] rd1_in,
    input [31:0] rd2_in,
    input [31:0] imm_in,

    input [4:0] rs1_in,
    input [4:0] rs2_in,
    input [4:0] rd_in,

    input [2:0] funct3_in,
    input [6:0] funct7_in,

    // OUTPUTS

    // CONTROL
    output reg RegWrite_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg MemtoReg_out,
    output reg ALUSrc_out,
    output reg Branch_out,
    output reg BranchNotEqual_out,
    output reg Jump_out,
    output reg Jalr_out,

    output reg [1:0] ALUOp_out,

    // DATAPATH
    output reg [31:0] pc_out,
    output reg [31:0] pc_plus4_out,

    output reg [31:0] rd1_out,
    output reg [31:0] rd2_out,
    output reg [31:0] imm_out,

    output reg [4:0] rs1_out,
    output reg [4:0] rs2_out,
    output reg [4:0] rd_out,

    output reg [2:0] funct3_out,
    output reg [6:0] funct7_out
);

always @(posedge clk or posedge reset) begin

    if(reset) begin

        RegWrite_out <= 0;
        MemRead_out <= 0;
        MemWrite_out <= 0;
        MemtoReg_out <= 0;
        ALUSrc_out <= 0;
        Branch_out <= 0;
        BranchNotEqual_out <= 0;
        Jump_out <= 0;
        Jalr_out <= 0;

        ALUOp_out <= 0;

        pc_out <= 0;
        pc_plus4_out <= 0;

        rd1_out <= 0;
        rd2_out <= 0;
        imm_out <= 0;

        rs1_out <= 0;
        rs2_out <= 0;
        rd_out <= 0;

        funct3_out <= 0;
        funct7_out <= 0;

    end

    //////////////////////////////////////////////////
    // HAZARD DETECTED -> INSERT BUBBLE
    //////////////////////////////////////////////////

    else if(stall) begin

        RegWrite_out <= 0;
        MemRead_out <= 0;
        MemWrite_out <= 0;
        MemtoReg_out <= 0;

        ALUSrc_out <= 0;

        Branch_out <= 0;
        BranchNotEqual_out <= 0;

        Jump_out <= 0;
        Jalr_out <= 0;

        ALUOp_out <= 0;

        // giữ nguyên datapath hoặc don't care
        pc_out <= pc_out;
        pc_plus4_out <= pc_plus4_out;

        rd1_out <= rd1_out;
        rd2_out <= rd2_out;
        imm_out <= imm_out;

        rs1_out <= rs1_out;
        rs2_out <= rs2_out;
        rd_out <= rd_out;

        funct3_out <= funct3_out;
        funct7_out <= funct7_out;
    
    end
    else if(flush) begin

    RegWrite_out <= 0;
    MemRead_out <= 0;
    MemWrite_out <= 0;
    MemtoReg_out <= 0;

    ALUSrc_out <= 0;

    Branch_out <= 0;
    BranchNotEqual_out <= 0;

    Jump_out <= 0;
    Jalr_out <= 0;

    ALUOp_out <= 0;

    pc_out <= 0;
    pc_plus4_out <= 0;

    rd1_out <= 0;
    rd2_out <= 0;
    imm_out <= 0;

    rs1_out <= 0;
    rs2_out <= 0;
    rd_out <= 0;

    funct3_out <= 0;
    funct7_out <= 0;

    end
    //////////////////////////////////////////////////
    // NORMAL PIPELINE OPERATION
    //////////////////////////////////////////////////

    else begin

        RegWrite_out <= RegWrite_in;
        MemRead_out <= MemRead_in;
        MemWrite_out <= MemWrite_in;
        MemtoReg_out <= MemtoReg_in;

        ALUSrc_out <= ALUSrc_in;

        Branch_out <= Branch_in;
        BranchNotEqual_out <= BranchNotEqual_in;

        Jump_out <= Jump_in;
        Jalr_out <= Jalr_in;

        ALUOp_out <= ALUOp_in;

        pc_out <= pc_in;
        pc_plus4_out <= pc_plus4_in;

        rd1_out <= rd1_in;
        rd2_out <= rd2_in;
        imm_out <= imm_in;

        rs1_out <= rs1_in;
        rs2_out <= rs2_in;
        rd_out <= rd_in;

        funct3_out <= funct3_in;
        funct7_out <= funct7_in;

    end

end

endmodule