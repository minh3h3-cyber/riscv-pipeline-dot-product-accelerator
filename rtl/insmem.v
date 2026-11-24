module imem(

    input [31:0] addr,
    output [31:0] instr
);

reg [31:0] memory [0:255];

integer i;

initial begin

// x1 = base address = 100
memory[0]  = 32'h06400093; // addi x1,x0,100

// x2 = count = 0
memory[1]  = 32'h00000113; // addi x2,x0,0

// x3 = index = 0
memory[2]  = 32'h00000193; // addi x3,x0,0

// x4 = loop limit = 8
memory[3]  = 32'h00800213; // addi x4,x0,8

// x6 = threshold = 20
memory[4]  = 32'h01400313; // addi x6,x0,20

// LOOP:
memory[5]  = 32'h0000A283; // lw x5,0(x1)

// if (x5 >= 20) goto SKIP
memory[6]  = 32'h0062D463; // bge x5,x6,+8

// count++
memory[7]  = 32'h00110113; // addi x2,x2,1

// SKIP:
memory[8]  = 32'h00408093; // addi x1,x1,4

memory[9]  = 32'h00118193; // addi x3,x3,1

// if (x3 < x4) goto LOOP
memory[10] = 32'hFE41C6E3; // blt x3,x4,-20

// x10 = count
memory[11] = 32'h00010533; // add x10,x2,x0

// NOPs
memory[12] = 32'h00000013;
memory[13] = 32'h00000013;
memory[14] = 32'h00000013;


end

assign instr = memory[addr[9:2]];

endmodule