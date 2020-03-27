`timescale 1ns / 1ps
`include "Adder.v"

module MUX_32_8(Out, I7, I6, I5, I4, I3, I2, I1, I0, OPctr);

	output reg[31:0] Out;
	input[31:0] I7, I6, I5, I4, I3, I2, I1, I0;
	input[2:0] OPctr;
	
	always @ (I7 or I6 or I5 or I4 or I3 or I2 or I1 or I0 or OPctr)
	begin
		case (OPctr)
			3'b000: Out = I0;
			3'b010: Out = I2;
			3'b100: Out = I4;
			3'b101: Out = I5;
			3'b110: Out = I6;
			3'b111: Out = I7;
			default: Out = 32'b0;
		endcase
	end

endmodule


module ALU_Controller(OPctr, SUBctr, OVctr, SIGctr, ALUctr);

	output reg[2:0] OPctr;
	output reg SUBctr, OVctr, SIGctr;
	input[3:0] ALUctr;

	always @ (ALUctr)
	begin
		case (ALUctr)
			4'b0000:	//add
			begin
				OPctr = 3'b000; SUBctr = 0; OVctr = 1; SIGctr = 0;
			end
			4'b0001:	//addu
			begin
				OPctr = 3'b000; SUBctr = 0; OVctr = 0; SIGctr = 0;
			end
			4'b0010:	//sub
			begin
				OPctr = 3'b000; SUBctr = 1; OVctr = 1; SIGctr = 0;
			end
			4'b0011:	//subu
			begin
				OPctr = 3'b000; SUBctr = 1; OVctr = 0; SIGctr = 0;
			end
			4'b0100:	//and
			begin
				OPctr = 3'b100; SUBctr = 0; OVctr = 0; SIGctr = 0;
			end
			4'b0101:	//or
			begin
				OPctr = 3'b101; SUBctr = 0; OVctr = 0; SIGctr = 0;
			end
			4'b0110:	//xor
			begin
				OPctr = 3'b110; SUBctr = 0; OVctr = 0; SIGctr = 0;
			end
			4'b0111:	//nor
			begin
				OPctr = 3'b111; SUBctr = 0; OVctr = 0; SIGctr = 0;
			end
			4'b1010:	//slt
			begin
				OPctr = 3'b010; SUBctr = 1; OVctr = 0; SIGctr = 1;
			end
			4'b1011:	//sltu
			begin
				OPctr = 3'b010; SUBctr = 1; OVctr = 0; SIGctr = 0;
			end
			default:
			begin
				OPctr = 3'b000; SUBctr = 0; OVctr = 0; SIGctr = 0;
			end
		endcase
	end

endmodule


module ALU_32(Res, Zero, Overfl, A, B, ALUctr);

	output wire[31:0] Res;
	output wire Zero, Overfl;
	input[31:0] A, B;
	input[3:0] ALUctr;

	wire[2:0] OPctr;
	wire SUBctr, OVctr, SIGctr;
	ALU_Controller ALUCt(OPctr, SUBctr, OVctr, SIGctr, ALUctr);

	wire[31:0] MUX_B;
	assign MUX_B = SUBctr ? ~B : B;

	wire[31:0] AndRes;	//4
	wire[31:0] OrRes;	//5
	wire[31:0] XorRes;	//6
	wire[31:0] NorRes;	//7
	assign AndRes = A & B;
	assign OrRes = A | B;
	assign XorRes = A ^ B;
	assign NorRes = ~(A | B);

	wire [31:0]AddRes;	//0
	wire OF, SF, ZF, CF;
	wire Cout;
	Adder_32 Adder(AddRes, Cout, OF, SF, ZF, CF, A, MUX_B, SUBctr);
	assign Zero = ZF;
	assign Overfl = OF & OVctr;

	wire Less, MUX_SltOP;
	assign Less = OF ^ SF;
	assign MUX_SltOP = SIGctr ? Less : CF;

	wire [31:0]SltRes;	//2
	assign SltRes = MUX_SltOP ? 32'h1 : 32'h0;

	reg[31:0] I3;
	reg[31:0] I1;
	MUX_32_8 MUX_Res(Res, NorRes, XorRes, OrRes, AndRes, I3, SltRes, I1, AddRes, OPctr);

endmodule
