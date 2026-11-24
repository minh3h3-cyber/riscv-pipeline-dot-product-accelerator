module regfile(
    input clk,
    input we,
    input [4:0] rs1, rs2, rd,
    input [31:0] wd,
    output [31:0] rd1, rd2
);

reg [31:0] regs[31:0];

integer i;

initial begin
    for(i=0;i<32;i=i+1)
        regs[i] = 32'd0;
end

assign rd1 =
    (rs1 == 0) ? 32'd0 :
    (we && (rd != 0) && (rd == rs1)) ? wd :
    regs[rs1];

assign rd2 =
    (rs2 == 0) ? 32'd0 :
    (we && (rd != 0) && (rd == rs2)) ? wd :
    regs[rs2];

always @(posedge clk) begin
    if(we && rd != 0)
        regs[rd] <= wd;
end

endmodule