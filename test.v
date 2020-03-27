`timescale 1ns / 1ps
`include "Adder.v"

module ALU_Test;
	
	wire[31:0] Res;
	wire Zero, Overfl;
	reg[31:0] A, B;
	reg[3:0] ALUctr;

	ALU_32 ALU(Res, Zero, Overfl, A, B, ALUctr);

	initial begin

		ALUctr = 4'b0000;	//add (), A, B
		A = 32'd12345; B = 32'd67899;

		#20
		A = 32'h7fffffff; B = 32'h1;

		#20
		ALUctr = 4'b0001;	//addu (), A, B
		
		#20
		A = 32'd12345; B = 32'd67899;

		#20
		ALUctr = 4'b0010;	//sub (), A, B
		A = 32'd10; B = 32'd10542;

		#20
		A = 32'h80000000; B = 32'd16;

		#20
		ALUctr = 4'b0011;	//subu (), A, B;

		#20
		A = 32'd10; B = 32'd10542;

		#20
		ALUctr = 4'b0110;	//xor (), A, B;

		#20
		ALUctr = 4'b1010;	//slt (), A, B;

		#20
		A = 32'd1783467; B = 32'd9278;

		#20
		ALUctr = 4'b1011;	//sltu (), A, B;
		A = 32'h80000000; B = 32'h1;
	
	end

endmodule

/*module Vr74x283_Test;

	// Inputs
	reg [31:0]A;
	reg [31:0]B;
	reg Cin;

	// Outputs
	wire Cout, OF, SF, ZF, CF;
	wire [31:0]F;

	// Instantiate the Unit Under Test (UUT)
	Adder_32 uut(F, Cout, OF, SF, ZF, CF, A, B, Cin);

	initial begin
		// Initialize Inputs
		A = 32'h00000001;
		B = 32'h7fffffff;
		Cin = 0;

		// Wait 100 ns for global reset to finish
		#20;
		A = 32'h0a103012;
		B = 32'h0202fc8b;
		
		#20;
		A = 32'hffffffff;
		B = 32'h00000010;
		
		#20;
		A = 32'hff0f0000;
		B = 32'h00f0ffff;
		Cin = 1;
		
		#20;
		A = 32'h0fffffff;
		B = 32'h7fffffff;

		#20;
		A = 32'd12345678;
		B = -32'd12345680;
        
		// Add stimulus here

	end
      
endmodule*/
