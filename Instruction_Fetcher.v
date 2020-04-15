`timescale 1ns / 1ps
`include "adder.v"

module Extender_Imm16(Out, Imm16);

	output wire[31:0] Out;
	input [15:0] Imm16;

	assign Out[31:18] = Imm16[15] ? 14'b11111111111111 : 14'b00000000000000;
	assign Out[17: 2] = Imm16;
	assign Out[ 1: 0] = 2'b00;

endmodule


module Extender_Imm26(Out, PC_p4, Imm26);

	output wire[31:0] Out;
	input [31:0] PC_p4;
	input [25:0] Imm26;

	assign Out[31:28] = PC_p4[31:28];
	assign Out[27: 2] = Imm26;
	assign Out[ 1: 0] = 2'b00;

endmodule


module Instruction_Fetcher(InsAddr, Branch, BrcEq, Zero, Imm16, Jmp, Jr, Imm26, RegOut, Reset, CLK);

	output wire[31:0] InsAddr;
	input Branch, BrcEq, Zero;
	input [15:0] Imm16;
	input Jmp, Jr;
	input [25:0] Imm26;
	input [31:0] RegOut;
	input Reset, CLK;

	reg[31:0] PC;
	assign InsAddr = PC;

	wire [31:0] jmpRes, brcJmpRes, newPC, imm16ex, imm26ex, PC_p4, PC_p4_pImm16ex;

	assign PC_p4 = PC + 32'd4;
	Extender_Imm16 Ex16(imm16ex, Imm16);
	assign PC_p4_pImm16ex = PC_p4 + imm16ex;
	assign brcJmp = Branch & (BrcEq ^ Zero);
	assign brcJmpRes = brcJmp ? PC_p4_pImm16ex : PC_p4;
	Extender_Imm26 Ex26(imm26ex, PC_p4, Imm26);
	assign jmpRes = Jr ? RegOut : imm26ex;
	assign newPC = Jmp ? jmpRes : brcJmpRes;

	always @ (posedge CLK)
	begin
		if (Reset) PC <= 32'b0;
		else PC <= newPC;
	end

endmodule


module Instruction_Fetcher_Test;

	wire[31:0] InsAddr;
	reg Branch, BrcEq, Zero;
	reg[15:0] Imm16;
	reg Jmp, Jr;
	reg[26:0] Imm26;
	reg[31:0] RegOut;
	reg Reset, CLK;

	Instruction_Fetcher uut(InsAddr, Branch, BrcEq, Zero, Imm16, Jmp, Jr, Imm26, RegOut, Reset, CLK);

	always #10 CLK = ~CLK;

	initial
	begin
		#60
		Reset = 1;	//重置
		CLK = 0;

		#20
		Reset = 0;
		Branch = 0; BrcEq = 0; Zero = 0;	//R-type
		Jmp = 0; Jr = 0;

		#100
		Branch = 1; BrcEq = 1; Zero = 0;	//bne成立
		Imm16 = 16'h10fc;

		#20
		BrcEq = 0;	//bne不成立

		#20
		Branch = 0;
		Jmp = 1; Jr = 1;
		RegOut = 32'hfedcba00;	//jr

		#20
		Jr = 0;
		Imm26 = 26'h1000;	//j

		#20
		Jmp = 0;	//R-type
	end

endmodule
