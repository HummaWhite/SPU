`timescale 1ns / 1ps

/*
	32位补码乘法器
	为了使乘法器的逻辑更清晰，将其主要部件分为三个模块：
	ALU、65位的寄存器组、控制逻辑单元
	ALU只负责加减运算
	寄存器组只负责数据的读写和移位
	控制器只负责输出控制信号
*/

module SimpleALU(ALUout, x, regHi, ALUop);
	//简易的ALU，只有补码加和减两种指令
	output wire[31:0] ALUout;
	input[31:0] x, regHi;
	input ALUop;

	assign ALUout = ALUop ? (regHi + x) : (regHi - x);

endmodule


module Register_65(regOut, ALUout, y, Write, Shift, Load, Clock);
	//简易的寄存器组，有读（清零，载入低位）、写（写入高位）、算术右移三种操作
	//并设置在时钟上升沿工作
	output wire[64:0] regOut;
	input[31:0] y, ALUout;
	input Write, Shift, Load, Clock;

	reg[64:0] register;

	always @ (posedge Clock)
	begin
		if (Load)
		begin
			register = 0;
			register[32:1] = y;
		end
		if (Write) register[64:33] = ALUout;
		if (Shift) register = {register[64], register[64:1]};
	end

	assign regOut = register;

	initial register = 0;

endmodule


module Controller(Ready, ALUop, Write, Shift, Load, Start, regIn, Clock);
	//控制逻辑
	output reg Ready, ALUop, Write, Shift, Load;
	input[1:0] regIn;
	input Clock, Start;

	reg restart, onCalculation;
	reg[5:0] count;

	always @ (!Start) restart = 1;

	always @ (posedge Clock)
	begin
		if (onCalculation)	//计算中
		begin
			Shift = 1;
			Write = (regIn[1] != regIn[0]) && (!Load);
			case (regIn)
				2'b10: ALUop = 0;
				2'b01: ALUop = 1;
			endcase
			if (Load) Load = 0;
			count = count + 1;
			if (count == 6'd34)	//计数器为34是因为考虑了寄存器载入被乘数的周期
			begin
				onCalculation = 0;
				Shift = 0; Write = 0; Load = 0; Ready = 1;
			end
			if (Start && restart)	//Start为低电平持续至少一个周期才能重启
			begin
				count = 6'd0;
				Load = 1; Ready = 0; Write = 0; Shift = 0;
				restart = 0;
			end
		end
		else begin
			if (Start && restart)	//启动信号
			begin
				count = 6'd0;
				Ready = 0; Write = 0; Shift = 0; Load = 1;
				onCalculation = 1;
			end
			else begin
				Shift = 0; Load = 0; Write = 0;
			end
		end
	end

	initial
	begin
		restart = 1;
		onCalculation = 0;
		count = 6'd0;
		ALUop = 0;
		Load = 0; Write = 0; Shift = 0; Ready = 0;
	end

endmodule


module MUL(x, y, Start, Hi, Lo, Ready, Clock);
	//将上述三个模块组合成乘法器
	input[31:0] x, y;
	input Start, Clock;
	output wire[31:0] Hi, Lo;
	output wire Ready;

	wire ALUop, Write, Shift, Load;
	wire[64:0] regOut;
	wire[31:0] ALUout;

	SimpleALU ALU(ALUout, x, regOut[64:33], ALUop);
	Register_65 register(regOut, ALUout, y, Write, Shift, Load, Clock);
	Controller controller(Ready, ALUop, Write, Shift, Load, Start, regOut[1:0], Clock);

	assign Hi = regOut[64:33];
	assign Lo = regOut[32: 1];

endmodule


module MUL_Test;
	//测试模块
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
		x = -32'd3; y = 32'd6;
		Start = 1;
		#20;
		#800
		Start = 0;
		x = 32'd1234; y = 32'd56;
		#20 Start = 1;
		#800 Start = 0;
		#60 Start = 1;
		#100 Start = 0;
		x = 32'd57483; y = -32'd2893745;
		#20 Start = 1;
	end

endmodule
