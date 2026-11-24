module alucontrol(

    input [1:0] ALUOp,
    input [2:0] funct3,
    input [6:0] funct7,

    output reg [3:0] ALUCtrl
);

always @(*) begin

    case(ALUOp)

        // LW / SW
        2'b00:
            ALUCtrl = 4'b0010; // ADD

        // Branch
        2'b01:
            ALUCtrl = 4'b0110; // SUB

        // R-type
        2'b10: begin

            case({funct7, funct3})

                {7'b0000000, 3'b000}:
                    ALUCtrl = 4'b0010; // ADD

                {7'b0100000, 3'b000}:
                    ALUCtrl = 4'b0110; // SUB

                {7'b0000000, 3'b111}:
                    ALUCtrl = 4'b0000; // AND

                {7'b0000000, 3'b110}:
                    ALUCtrl = 4'b0001; // OR

                {7'b0000000, 3'b100}:
                    ALUCtrl = 4'b0011; // XOR

                {7'b0000000, 3'b001}:
                    ALUCtrl = 4'b0100; // SLL

                {7'b0000000, 3'b101}:
                    ALUCtrl = 4'b0101; // SRL

                {7'b0000000, 3'b010}:
                    ALUCtrl = 4'b0111; // SLT

                default:
                    ALUCtrl = 4'b0010;

            endcase
        end

        // I-type arithmetic
        2'b11: begin

            case(funct3)

                3'b000:
                    ALUCtrl = 4'b0010; // ADDI

                3'b111:
                    ALUCtrl = 4'b0000; // ANDI

                3'b110:
                    ALUCtrl = 4'b0001; // ORI

                3'b100:
                    ALUCtrl = 4'b0011; // XORI

                3'b001:
                    ALUCtrl = 4'b0100; // SLLI

                3'b101:
                    ALUCtrl = 4'b0101; // SRLI

                3'b010:
                    ALUCtrl = 4'b0111; // SLTI

                default:
                    ALUCtrl = 4'b0010;

            endcase
        end

        default:
            ALUCtrl = 4'b0010;

    endcase
end

endmodule