`timescale 1ns / 1ps

module Half_Adder(F, C, A, B);

	output wire F, C;
	input A, B;

	and (C, A, B);
	xor (F, A, B);

endmodule

module Half_Adder_S(F, C, A, B);

	output wire F, C;
	input A, B;
	
	assign C = A & B;
	assign F = A ^ B;

endmodule

module Full_Adder(F, Cout, A, B, Cin);

	output wire F, Cout;
	input A, B, Cin;
	wire AB, ACin, BCin;
	
	and (AB, A, B);
	and (ACin, A, Cin);
	and (BCin, B, Cin);

	or (Cout, AB, ACin, BCin);
	xor (F, A, B, Cin);

endmodule

module Full_Adder_S(F, Cout, A, B, Cin);

	output wire F, Cout;
	input A, B, Cin;
	
	assign Cout = (A & B) | (A & Cin) | (B & Cin);
	assign F = A ^ B ^ Cin;

endmodule

module AC_Adder_4(F, Cout, A, B, Cin);

	output wire [3:0]F, Cout;
	input [3:0]A;
	input [3:0]B;
	input Cin;
	wire C3, C2, C1;
	wire P3, G3, P2, G2, P1, G1, P0, G0;
	wire hs3, hs2, hs1, hs0;
	
	assign P3 = A[3] | B[3], G3 = A[3] & B[3];
	assign P2 = A[2] | B[2], G2 = A[2] & B[2];
	assign P1 = A[1] | B[1], G1 = A[1] & B[1];
	assign P0 = A[0] | B[0], G0 = A[0] & B[0];
	
	assign C1 = P0 & (G0 | Cin);
	assign C2 = P1 & (G1 | P0) & (G1 | G0 | Cin);
	assign C3 = P2 & (G2 | P1) & (G2 | G1 | P0) & (G2 | G1 | G0 | Cin);
	assign Cout = P3 & (G3 | P2) & (G3 | G2 | P1) & (G3 | G2 | G1 | P0) & (G3 | G2 | G1 | G0 | Cin);
	
	assign hs3 = P3 & (~G3);
	assign hs2 = P2 & (~G2);
	assign hs1 = P1 & (~G1);
	assign hs0 = P0 & (~G0);
	
	assign F[3] = hs3 ^ C3;
	assign F[2] = hs2 ^ C2;
	assign F[1] = hs1 ^ C1;
	assign F[0] = hs0 ^ Cin;

endmodule


module S_Adder_16(F, Cout, A, B, Cin);

	output wire [15:0]F, Cout;
	input [15:0]A;
	input [15:0]B;
	input Cin;
	
	wire [14:0]C;
	Full_Adder_S U0(F[0], C[0], A[0], B[0], Cin);
	Full_Adder_S U1(F[1], C[1], A[1], B[1], C[0]);
	Full_Adder_S U2(F[2], C[2], A[2], B[2], C[1]);
	Full_Adder_S U3(F[3], C[3], A[3], B[3], C[2]);
	Full_Adder_S U4(F[4], C[4], A[4], B[4], C[3]);
	Full_Adder_S U5(F[5], C[5], A[5], B[5], C[4]);
	Full_Adder_S U6(F[6], C[6], A[6], B[6], C[5]);
	Full_Adder_S U7(F[7], C[7], A[7], B[7], C[6]);
	Full_Adder_S U8(F[8], C[8], A[8], B[8], C[7]);
	Full_Adder_S U9(F[9], C[9], A[9], B[9], C[8]);
	Full_Adder_S UA(F[10], C[10], A[10], B[10], C[9]);
	Full_Adder_S UB(F[11], C[11], A[11], B[11], C[10]);
	Full_Adder_S UC(F[12], C[12], A[12], B[12], C[11]);
	Full_Adder_S UD(F[13], C[13], A[13], B[13], C[12]);
	Full_Adder_S UE(F[14], C[14], A[14], B[14], C[13]);
	Full_Adder_S UF(F[15], Cout, A[15], B[15], C[14]);

endmodule


module Adder_16(F, Cout, A, B, Cin);

	output wire [15:0]F, Cout;
	input [15:0]A;
	input [15:0]B;
	input Cin;

	wire [2:0]C;
	AC_Adder_4 U0(F[3:0], C[0], A[3:0], B[3:0], Cin);
	AC_Adder_4 U1(F[7:4], C[1], A[7:4], B[7:4], C[0]);
	AC_Adder_4 U2(F[11:8], C[2], A[11:8], B[11:8], C[1]);
	AC_Adder_4 U3(F[15:12], Cout, A[15:12], B[15:12], C[2]);

endmodule


module Adder_16_S(F, Cout, A, B, Cin);

	output wire [15:0]F, Cout;
	input [15:0]A;
	input [15:0]B;
	input Cin;
	
	assign {Cin, F} = A + B + Cin;

endmodule


module C_Adder_16(F, Cout, A, B, Sub);

	output wire [15:0]F, Cout;
	input [15:0]A;
	input [15:0]B;
	input Sub;

	wire [15:0]TB;
	assign TB = (Sub) ? ~B : B;
	
	Adder_16_S U1(F, Cout, A, TB, Sub);

endmodule


module Adder_32(F, Cout, OF, SF, ZF, CF, A, B, Cin);

	output wire [31:0]F, Cout, OF, SF, ZF, CF;
	input [31:0]A;
	input [31:0]B;
	input Cin;

	assign {Cout, F} = A + B + Cin;
	assign OF = (A[31] & B[31] & (!F[31])) | ((!A[31]) & (!B[31]) & F[31]);
	assign SF = F[31];
	assign ZF = (F == 0);
	assign CF = Cout ^ Cin;

endmodule
