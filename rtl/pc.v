module pc(

    input clk,
    input reset,

    input stall,

    input [31:0] pc_next,

    output reg [31:0] pc
);

always @(posedge clk or posedge reset) begin

    if(reset)
        pc <= 32'd0;

    else if(!stall)
        pc <= pc_next;

end

endmodule