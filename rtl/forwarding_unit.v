module forwarding_unit(

    input mem_RegWrite,
    input wb_RegWrite,

    input [4:0] mem_rd,
    input [4:0] wb_rd,

    input [4:0] ex_rs1,
    input [4:0] ex_rs2,

    output reg [1:0] forwardA,
    output reg [1:0] forwardB
);

always @(*) begin

    // default = no forwarding
    forwardA = 2'b00;
    forwardB = 2'b00;

    //////////////////////////////////////////////////
    // EX hazard
    //////////////////////////////////////////////////

    if(mem_RegWrite &&
       (mem_rd != 0) &&
       (mem_rd == ex_rs1))

        forwardA = 2'b10;

    if(mem_RegWrite &&
       (mem_rd != 0) &&
       (mem_rd == ex_rs2))

        forwardB = 2'b10;

    //////////////////////////////////////////////////
    // MEM hazard
    //////////////////////////////////////////////////

    if(wb_RegWrite &&
       (wb_rd != 0) &&
       !(mem_RegWrite &&
         (mem_rd != 0) &&
         (mem_rd == ex_rs1)) &&
       (wb_rd == ex_rs1))

        forwardA = 2'b01;

    if(wb_RegWrite &&
       (wb_rd != 0) &&
       !(mem_RegWrite &&
         (mem_rd != 0) &&
         (mem_rd == ex_rs2)) &&
       (wb_rd == ex_rs2))

        forwardB = 2'b01;

end

endmodule