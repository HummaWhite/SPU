`timescale 1ns / 1ps

module SimpleALU(ALUout, x, regHi, ALUop);

	output wire[31:0] ALUout;
	input[31:0] x, regHi;
	input ALUop;

	assign ALUout = ALUop ? (regHi + x) : (regHi - x);

endmodule


module Register_65(regOut, ALUout, y, Write, Shift, Load, Clock);

	output wire[64:0] regOut;
	input[31:0] y, ALUout;
	input Write, Shift, Load, Clock;

	reg[64:0] register;

	always @ (posedge Clock) begin
		if (Load)
		begin
			register = 0;
			register[32:1] = y;
		end
		if (Write) register[64:33] = ALUout;
		if (Shift) register = {register[64], register[64:1]};	//>>> is somehow useless here...
	end

	assign regOut = register;

	initial register = 0;

endmodule


module Controller(Ready, ALUop, Write, Shift, Load, Start, regIn, Clock);

	output reg Ready, ALUop, Write, Shift, Load;
	input[1:0] regIn;
	input Clock, Start;

	reg lastStart;
	reg[5:0] counter;

	always @ (posedge Clock)
	begin
		if (Start)
		begin
			if (lastStart)	//successive Start signal, just ignore and hang up the process
			begin
				Write = 0; Shift = 0; Load = 0;
			end
			else begin	//restart or initialize -> load Y to Lo
				counter = 1;
				Write = 0; Shift = 0; Load = 1; Ready = 0;
			end
		end
		else begin
			Load = 0;
			if (counter != 0)	//on calculation
			begin
				if (counter == 6'd34)	//finished, stop and keep output
				begin
					counter = 6'd0;
					Write = 0; Shift = 0; Ready = 1;
				end
				else begin	//not finished, continue
					Ready = 0; Shift = 1;
					case (regIn)
						2'b01:
						begin
							ALUop = 1; Write = 1;	//add
						end
						2'b10:
						begin
							ALUop = 0; Write = 1;	//sub
						end
						default:	//just shift right arithmetically
						begin
							Write = 0;
						end
					endcase
					counter = counter + 1;
				end
			end
			else begin	//finished or before start, keep status
				Write = 0; Shift = 0; Load = 0;
			end
		end
		lastStart = Start;	//setup lastStart to examine successive Starts
	end

	initial
	begin
		lastStart = 0;
		counter = 6'd0;
		Ready = 0;
	end

endmodule


module MUL(x, y, Start, Hi, Lo, Ready, Clock);

	input[31:0] x, y;
	input Start, Clock;
	output wire[31:0] Hi, Lo;
	output wire Ready;

	wire ALUop, Write, Shift, Load;
	wire[64:0] regOut;
	wire[31:0] ALUout;

	Register_65 register(regOut, ALUout, y, Write, Shift, Load, Clock);
	Controller controller(Ready, ALUop, Write, Shift, Load, Start, regOut[1:0], Clock);
	SimpleALU ALU(ALUout, x, regOut[64:33], ALUop);

	assign Hi = regOut[64:33];
	assign Lo = regOut[32: 1];

endmodule


module MUL_Test;

	reg[31:0] x, y;
	reg Start, Clock;
	wire[63:0] res;
	wire Ready;
	wire[31:0] Hi, Lo;

	MUL uut(x, y, Start, Hi, Lo, Ready, Clock);
	
	assign res = {Hi, Lo};

	always #10 Clock = ~Clock;

	initial
	begin
		Clock = 0;
		x = 32'd57483; y = -32'd2893745;
		Start = 1;
		#20 Start = 0;
	end

endmodule
