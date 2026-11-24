module cpu_top(

    input clk,
    input reset
    
    output [31:0] debug_out
);

//////////////////////////////////////////////////
// IF STAGE
//////////////////////////////////////////////////

wire [31:0] pc_current;
wire [31:0] pc_next;
wire [31:0] pc_plus4;

wire [31:0] instr;

wire stall;

assign pc_plus4 = pc_current + 4;

pc PC(
    .clk(clk),
    .reset(reset),

    .stall(stall),

    .pc_next(pc_next),

    .pc(pc_current)
);

imem IMEM(
    .addr(pc_current),
    .instr(instr)
);

//////////////////////////////////////////////////
// IF/ID PIPELINE REGISTER
//////////////////////////////////////////////////

wire [31:0] ifid_pc;
wire [31:0] ifid_instr;

if_id IF_ID(
    .clk(clk),
    .reset(reset),

    .stall(stall),
    .flush(flush),

    .pc_in(pc_current),
    .instr_in(instr),

    .pc_out(ifid_pc),
    .instr_out(ifid_instr)
);

//////////////////////////////////////////////////
// ID STAGE
//////////////////////////////////////////////////

wire [6:0] opcode;
wire [4:0] rs1;
wire [4:0] rs2;
wire [4:0] rd;

wire [2:0] funct3;
wire [6:0] funct7;

assign opcode = ifid_instr[6:0];

assign rd     = ifid_instr[11:7];
assign funct3 = ifid_instr[14:12];

assign rs1    = ifid_instr[19:15];
assign rs2    = ifid_instr[24:20];

assign funct7 = ifid_instr[31:25];

//////////////////////////////////////////////////
// CONTROL UNIT
//////////////////////////////////////////////////

wire RegWrite;
wire ALUSrc;
wire MemRead;
wire MemWrite;
wire MemtoReg;
wire Branch;
wire BranchNotEqual;
wire Jump;
wire Jalr;

wire [1:0] ALUOp;

controlunit CONTROL(

    .opcode(opcode),

    .RegWrite(RegWrite),
    .ALUSrc(ALUSrc),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .MemtoReg(MemtoReg),

    .Branch(Branch),
    .BranchNotEqual(BranchNotEqual),

    .Jump(Jump),
    .Jalr(Jalr),

    .ALUOp(ALUOp)
);

//////////////////////////////////////////////////
// REGISTER FILE
//////////////////////////////////////////////////

wire [31:0] rd1;
wire [31:0] rd2;

wire wb_RegWrite;
wire [4:0] wb_rd;
wire [31:0] wb_data;

regfile REGFILE(

    .clk(clk),

    .we(wb_RegWrite),

    .rs1(rs1),
    .rs2(rs2),

    .rd(wb_rd),

    .wd(wb_data),

    .rd1(rd1),
    .rd2(rd2)
);

//////////////////////////////////////////////////
// IMMEDIATE GENERATOR
//////////////////////////////////////////////////

wire [31:0] imm_out;

immgen IMMGEN(
    .instr(ifid_instr),
    .imm_out(imm_out)
);

//////////////////////////////////////////////////
// ID/EX PIPELINE REGISTER
//////////////////////////////////////////////////

wire ex_RegWrite;
wire ex_MemRead;
wire ex_MemWrite;
wire ex_MemtoReg;
wire ex_ALUSrc;

wire ex_Branch;
wire ex_BranchNotEqual;

wire ex_Jump;
wire ex_Jalr;

wire [31:0] ex_pc_plus4;

wire [1:0] ex_ALUOp;

wire [31:0] ex_pc;
wire [31:0] ex_rd1;
wire [31:0] ex_rd2;
wire [31:0] ex_imm;

wire [4:0] ex_rs1;
wire [4:0] ex_rs2;
wire [4:0] ex_rd;

wire [2:0] ex_funct3;
wire [6:0] ex_funct7;

id_ex ID_EX(

    .clk(clk),
    .reset(reset),
    .stall(stall),
    .flush(flush),

    // control
    .RegWrite_in(RegWrite),
    .MemRead_in(MemRead),
    .MemWrite_in(MemWrite),
    .MemtoReg_in(MemtoReg),
    .ALUSrc_in(ALUSrc),

    .Branch_in(Branch),
    .BranchNotEqual_in(BranchNotEqual),

    .Jump_in(Jump),
    .Jalr_in(Jalr),
    
    .ALUOp_in(ALUOp),

    // datapath
    .pc_in(ifid_pc),
    .pc_plus4_in(ifid_pc + 32'd4),
    .rd1_in(rd1),
    .rd2_in(rd2),
    .imm_in(imm_out),

    .rs1_in(rs1),
    .rs2_in(rs2),
    .rd_in(rd),

    .funct3_in(funct3),
    .funct7_in(funct7),

    // outputs
    .RegWrite_out(ex_RegWrite),
    .MemRead_out(ex_MemRead),
    .MemWrite_out(ex_MemWrite),
    .MemtoReg_out(ex_MemtoReg),
    .ALUSrc_out(ex_ALUSrc),

    .Branch_out(ex_Branch),
    .BranchNotEqual_out(ex_BranchNotEqual),
    .Jump_out(ex_Jump),
    .Jalr_out(ex_Jalr),

    .ALUOp_out(ex_ALUOp),

    .pc_out(ex_pc),
    .pc_plus4_out(ex_pc_plus4),
    .rd1_out(ex_rd1),
    .rd2_out(ex_rd2),
    .imm_out(ex_imm),

    .rs1_out(ex_rs1),
    .rs2_out(ex_rs2),
    .rd_out(ex_rd),

    .funct3_out(ex_funct3),
    .funct7_out(ex_funct7)
);

//////////////////////////////////////////////////
// EX STAGE
//////////////////////////////////////////////////

wire [3:0] alu_ctrl;

alucontrol ALUCTRL(

    .ALUOp(ex_ALUOp),
    .funct3(ex_funct3),
    .funct7(ex_funct7),

    .ALUCtrl(alu_ctrl)
);

wire [31:0] alu_b;

wire [31:0] alu_srcA;
wire [31:0] alu_srcB;
wire [31:0] forwarded_b;

//////////////////////////////////////////////////
// Forward A
//////////////////////////////////////////////////

assign alu_srcA =
    (forwardA == 2'b10) ? mem_alu_result :

    (forwardA == 2'b01) ? wb_data :

    ex_rd1;

//////////////////////////////////////////////////
// Forward B
//////////////////////////////////////////////////

assign forwarded_b =
    (forwardB == 2'b10) ? mem_alu_result :

    (forwardB == 2'b01) ? wb_data :

    ex_rd2;

//////////////////////////////////////////////////
// ALUSrc MUX
//////////////////////////////////////////////////

assign alu_srcB =
    (ex_ALUSrc) ?
    ex_imm :
    forwarded_b;

wire [31:0] alu_result;
wire zero;

alu ALU(

    .a(alu_srcA),
    .b(alu_srcB),

    .alu_ctrl(alu_ctrl),

    .result(alu_result),
    .zero(zero)
);

wire [1:0] forwardA;
wire [1:0] forwardB;

forwarding_unit FORWARD(

    .mem_RegWrite(mem_RegWrite),
    .wb_RegWrite(wb_RegWrite),

    .mem_rd(mem_rd),
    .wb_rd(wb_rd),

    .ex_rs1(ex_rs1),
    .ex_rs2(ex_rs2),

    .forwardA(forwardA),
    .forwardB(forwardB)
);

wire signed_less;

assign signed_less =
    ($signed(alu_srcA) < $signed(forwarded_b));

//////////////////////////////////////////////////
// BRANCH LOGIC
//////////////////////////////////////////////////

wire branch_taken;

wire is_beq;
wire is_bne;
wire is_blt;
wire is_bge;

assign is_beq =
    ex_Branch &&
    (ex_funct3 == 3'b000);

assign is_bne =
    ex_Branch &&
    (ex_funct3 == 3'b001);

assign is_blt =
    ex_Branch &&
    (ex_funct3 == 3'b100);

assign is_bge =
    ex_Branch &&
    (ex_funct3 == 3'b101);

assign branch_taken =

    (is_beq && zero) ||

    (is_bne && !zero) ||

    (is_blt && signed_less) ||

    (is_bge && !signed_less);
    
wire [31:0] jump_target;

assign jump_target =
    (ex_Jalr) ?
        (alu_srcA + ex_imm) :
        (ex_pc + ex_imm);
    

wire mem_Jump;
wire mem_Jalr;

wire [31:0] mem_pc_plus4;
//////////////////////////////////////////////////
// EX/MEM PIPELINE REGISTER
//////////////////////////////////////////////////

wire mem_RegWrite;
wire mem_MemRead;
wire mem_MemWrite;
wire mem_MemtoReg;

wire mem_Branch;
wire mem_BranchTaken;

wire [31:0] mem_branch_target;
wire [31:0] mem_alu_result;
wire [31:0] mem_write_data;

wire [4:0] mem_rd;

ex_mem EX_MEM(

    .clk(clk),
    .reset(reset),

    // control
    .RegWrite_in(ex_RegWrite),
    .MemRead_in(ex_MemRead),
    .MemWrite_in(ex_MemWrite),
    .MemtoReg_in(ex_MemtoReg),

    .Branch_in(ex_Branch),
    .BranchTaken_in(branch_taken),
    .Jump_in(ex_Jump),
    .Jalr_in(ex_Jalr),

    // datapath
    .branch_target_in(jump_target),
    .alu_result_in(alu_result),
    .write_data_in(forwarded_b),
    .pc_plus4_in(ex_pc_plus4),

    .rd_in(ex_rd),

    // outputs
    .RegWrite_out(mem_RegWrite),
    .MemRead_out(mem_MemRead),
    .MemWrite_out(mem_MemWrite),
    .MemtoReg_out(mem_MemtoReg),

    .Branch_out(mem_Branch),
    .BranchTaken_out(mem_BranchTaken),
    
    .Jump_out(mem_Jump),
    .Jalr_out(mem_Jalr),

    .branch_target_out(mem_branch_target),
    .alu_result_out(mem_alu_result),
    .write_data_out(mem_write_data),
    .pc_plus4_out(mem_pc_plus4),

    .rd_out(mem_rd)
);

//////////////////////////////////////////////////
// MEM STAGE
//////////////////////////////////////////////////

wire [31:0] mem_read_data;

dmem DMEM(

    .clk(clk),

    .MemRead(mem_MemRead),
    .MemWrite(mem_MemWrite),

    .addr(mem_alu_result),
    .write_data(mem_write_data),

    .read_data(mem_read_data)
);

wire wb_Jump;
wire [31:0] wb_pc_plus4;
//////////////////////////////////////////////////
// MEM/WB PIPELINE REGISTER
//////////////////////////////////////////////////

wire [31:0] wb_read_data;
wire [31:0] wb_alu_result;

wire wb_MemtoReg;

mem_wb MEM_WB(

    .clk(clk),
    .reset(reset),

    // control
    .RegWrite_in(mem_RegWrite),
    .MemtoReg_in(mem_MemtoReg),
    .Jump_in(mem_Jump),

    // datapath
    .read_data_in(mem_read_data),
    .alu_result_in(mem_alu_result),
    .pc_plus4_in(mem_pc_plus4),

    .rd_in(mem_rd),

    // outputs
    .RegWrite_out(wb_RegWrite),
    .MemtoReg_out(wb_MemtoReg),
    .Jump_out(wb_Jump),

    .read_data_out(wb_read_data),
    .alu_result_out(wb_alu_result),
    .pc_plus4_out(wb_pc_plus4),

    .rd_out(wb_rd)
);

//////////////////////////////////////////////////
// WB STAGE
//////////////////////////////////////////////////

assign wb_data =
    (wb_Jump)      ? wb_pc_plus4 :
    (wb_MemtoReg)  ? wb_read_data :
                     wb_alu_result;

//////////////////////////////////////////////////
// NEXT PC LOGIC
//////////////////////////////////////////////////

assign pc_next =
    (mem_Jump) ?
        mem_branch_target :
    (mem_BranchTaken) ?
        mem_branch_target :
        pc_plus4;

//////////////////////////////////////////////////
//Hazard detection
//////////////////////////////////////////////////
hazard_detection_unit HAZARD(
    .MemRead_ex(ex_MemRead),
    .rd_ex(ex_rd),
    .rs1_id(rs1),
    .rs2_id(rs2),
    .stall(stall)
);


assign debug_out = pc_current;

endmodule