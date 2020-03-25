`timescale 1ns / 1ps
`include "Adder.v"

module MUX_32_8(Out, I7, I6, I5, I4, I3, I2, I1, I0, OPctr);

	output reg [31:0]Out;
	input [31:0]I0;
	input [31:0]I1;
	input [31:0]I2;
	input [31:0]I3;
	input [31:0]I4;
	input [31:0]I5;
	input [31:0]I6;
	input [31:0]I7;
	input [2:0]OPctr;
	
	always @ (I0 or I1 or I2 or I3 or I4 or I5 or I6 or I7 or OPctr)
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

	output reg [2:0]OPctr;
	output reg SUBctr, OVctr, SIGctr;
	input [3:0]ALUctr;

	always @ (ALUctr)
	begin
		case (ALUctr)
			4'b0000:
			begin
				OPctr = 3'b000; SUBctr = 0; OVctr = 1; SIGctr = 0;
			end
			4'b0001:
			begin
				OPctr = 3'b000; SUBctr = 0; OVctr = 0; SIGctr = 0;
			end
			4'b0010:
			begin
				OPctr = 3'b000; SUBctr = 1; OVctr = 1; SIGctr = 0;
			end
			4'b0011:
			begin
				OPctr = 3'b000; SUBctr = 1; OVctr = 0; SIGctr = 0;
			end
			4'b0100:
			begin
				OPctr = 3'b100; SUBctr = 0; OVctr = 0; SIGctr = 0;
			end
			4'b0101:
			begin
				OPctr = 3'b101; SUBctr = 0; OVctr = 0; SIGctr = 0;
			end
			4'b0110:
			begin
				OPctr = 3'b110; SUBctr = 0; OVctr = 0; SIGctr = 0;
			end
			4'b0111:
			begin
				OPctr = 3'b111; SUBctr = 0; OVctr = 0; SIGctr = 0;
			end
			4'b1010:
			begin
				OPctr = 3'b010; SUBctr = 1; OVctr = 0; SIGctr = 1;
			end
			4'b1011:
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

	output wire [31:0]Res, Zero, Overfl;
	input [31:0]A;
	input [31:0]B;
	input [3:0]ALUctr;

endmodule
