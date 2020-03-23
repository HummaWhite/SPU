`timescale 1ns / 1ps
`include "Adder.v"

module Vr74x283_Test;

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
      
endmodule
