/*
Uses ALU control to perform operation on two operands and provide output
*/

module ALU (
	input logic clk, reset,
	input logic [31:0] read_data1, read_data2, imm, 
	input logic [3:0] alu_control, input_type,
	input logic [31:0] data_read, instruction_addr, data_addr,
	output logic [31:0] reg_write_data, data_write,
	output logic [3:0] data_write_byte,
	output logic zero_flag,	negative_flag,	overflow_flag,
	output logic data_write_valid, data_read_valid, register_write_valid,
	output logic [31:0] iaddr_val
);
	logic [31:0] alu_result;
	logic [31:0] temp1, temp2, offset;
	
	always @(*) begin
		// R type
		data_write_valid = 0;
		data_read_valid = 0;
		register_write_valid = 0;
		if(input_type == 0) begin
			temp1 = read_data1;
			temp2 = read_data2;

			case(alu_control)
				4'b0000: begin
					alu_result = read_data1+read_data2; // ADD
					overflow_flag = (read_data1[31] == read_data2[31] && read_data1[31] != alu_result[31]);
				end
				4'b0001: begin
					alu_result = read_data1-read_data2; // SUB (read_data1-read_data2)
					overflow_flag = (read_data1[31] != read_data2[31] && read_data1[31] != alu_result[31]);
				end
				4'b0010: alu_result = read_data1<<read_data2[4:0]; // SLL read_data1 by read_data2
				4'b0011: alu_result = 32'(read_data1<read_data2); // SLT read_data1 by read_data2
				4'b0100: alu_result = 32'(temp1<temp2); // SLTU read_data1 by read_data2
				4'b0101: alu_result = read_data1^read_data2; // XOR read_data1 by read_data2
				4'b0110: alu_result = read_data1>>read_data2[4:0]; // SRL read_data1 by read_data2
				4'b0111: alu_result = read_data1>>>read_data2[4:0]; // SRL read_data1 by read_data2
				4'b1000: alu_result = read_data1|read_data2; // OR
				4'b1001: alu_result = read_data1&read_data2; // AND
				default: begin end
			endcase
				
			reg_write_data = alu_result[31:0];
			data_write_byte = 0;
			data_write = 0;
			zero_flag = (reg_write_data == 0);
			negative_flag = (reg_write_data[31] == 1);
			
			data_write_valid = 0;
			data_read_valid = 1;
			register_write_valid = 1;
		end
		
		// I type
		else if(input_type == 1) begin			
			temp1 = read_data1;
			temp2 = imm;
			case(alu_control)
				 4'b0000: begin 
					alu_result = read_data1+imm; // ADDI
					overflow_flag = (read_data1[31] == imm[31] && read_data1[31] != alu_result[31]);
				 end
				 4'b0001: alu_result = read_data1<<imm[4:0]; // SLLI
				 4'b0010: alu_result = 32'(read_data1<imm); // SLTI
				 4'b0011: alu_result = 32'(temp1<temp2); // SLTIU
				 4'b0100: alu_result = read_data1^imm; // XORI
				 4'b0101: alu_result = read_data1>>imm[4:0]; // SRLI
				 4'b0110: alu_result = read_data1>>>imm[4:0]; // SRAI
				 4'b0111: alu_result = read_data1|imm; // ORI
				 4'b1000: alu_result = read_data1&imm; // ANDI
				 default: begin end
			endcase
				
			reg_write_data = alu_result[31:0];
			data_write_byte = 0;
			data_write = 0;
			zero_flag = (reg_write_data == 0);
			negative_flag = ($signed(reg_write_data) < 0);
			
			data_write_valid = 0;
			data_read_valid = 1;
			register_write_valid = 1;
		end
		
		// LOAD
		else if(input_type == 2) begin			
			offset = 32'(data_addr[1:0]<<3);
			case(alu_control)
				 4'b0000: alu_result = {{24{data_read[offset+7]}}, data_read[offset +: 8]}; //LB
				 4'b0001: alu_result = {{16{data_read[offset+15]}}, data_read[offset +: 16]}; // LH
				 4'b0010: alu_result = data_read; // LW
				 4'b0011: alu_result = {24'b0, data_read[offset +: 8]}; // LBU
				 4'b0100: alu_result = {16'b0, data_read[offset +: 16]}; // LHU
				 default: begin end
			endcase
				
			reg_write_data = alu_result[31:0];
			data_write_byte = 0;
			data_write = 0;
			zero_flag = (reg_write_data == 0);
			negative_flag = ($signed(reg_write_data) < 0);
			
			data_write_valid = 0;
			data_read_valid = 1;
			register_write_valid = 1;
		end
		
		// STORE
		else if(input_type == 3) begin			
			case(alu_control)
				 4'b0000: begin
					data_write_byte = 4'b0001; // SB
					data_write = {read_data2[7:0],read_data2[7:0],read_data2[7:0],read_data2[7:0]};
				 end
				 4'b0001: begin
					data_write_byte = 4'b0011; // SH
					data_write = {read_data2[15:0], read_data2[15:0]};
				 end
				 4'b0010: begin
					data_write_byte = 4'b1111; // SW
					data_write = read_data2;
				 end
				 default: begin end
			endcase
			
			reg_write_data = 0;
			zero_flag = 0;
			negative_flag = 0;
			
			data_write_valid = 1;
			data_read_valid = 0;
			register_write_valid = 0;
		end
		
		// BRANCH
		else if(input_type == 4) begin			
			temp1 = read_data1;
			temp2 = read_data2;
			case(alu_control)
				 0: begin // BEQ
					if(read_data1==read_data2) alu_result = instruction_addr+imm;
					else alu_result = instruction_addr+4;
				 end
				 1: begin // BNE
					if(read_data1!=read_data2) alu_result = instruction_addr+imm;
					else alu_result = instruction_addr+4;
				 end
				 4: begin // BLT
					if(read_data1<read_data2) alu_result = instruction_addr+imm;
					else alu_result = instruction_addr+4;
				 end
				 5: begin // BGE
					if(read_data1>=read_data2) alu_result = instruction_addr+imm;
					else alu_result = instruction_addr+4;
				 end
				 6: begin // BLTU
					if(temp1<temp2) alu_result = instruction_addr+imm;
					else alu_result = instruction_addr+4;
				 end
				 7: begin // BGEU
					if(temp1>=temp2) alu_result = instruction_addr+imm;
					else alu_result = instruction_addr+4;
				 end
				 default: begin end
			endcase
			
			iaddr_val = alu_result[31:0];
			data_write_byte = 0;
			data_write = 0;
			zero_flag = (reg_write_data == 0);
			negative_flag = ($signed(reg_write_data) < 0);

			data_write_valid = 0;
			data_read_valid = 0;
			register_write_valid = 0;
		end
		
		// JALR and JAL
		else if(input_type == 5 || input_type == 6) begin			
			reg_write_data = instruction_addr + 4;
			data_write_byte = 0;
			data_write = 0;
			zero_flag = (reg_write_data == 0);
			negative_flag = ($signed(reg_write_data) < 0);
			
			data_write_valid = 0;
			data_read_valid = 1;
			register_write_valid = 1;
		end
		
		// AUIPIC
		else if(input_type == 7) begin			
			reg_write_data = instruction_addr + imm;
			data_write_byte = 0;
			data_write = 0;			
			zero_flag = (reg_write_data == 0);
			negative_flag = ($signed(reg_write_data) < 0);

			data_write_valid = 0;
			data_read_valid = 1;
			register_write_valid = 1;
		end
		
		// LUI
		else if(input_type == 8) begin			
			reg_write_data = imm;
			data_write_byte = 0;
			data_write = 0;			
			zero_flag = (reg_write_data == 0);
			negative_flag = ($signed(reg_write_data) < 0);

			data_write_valid = 0;
			data_read_valid = 1;
			register_write_valid = 1;
		end
	end
endmodule

// testbench does not pass verilator lint
// module ALU_testbench ();
// 	logic clk, reset;
// 	logic [31:0] read_data1, read_data2, imm;
// 	logic [3:0] alu_control, input_type;
// 	logic [31:0] data_read, instruction_addr, data_addr;
	
// 	logic [31:0] reg_write_data, data_write;
// 	logic [3:0] data_write_byte;
// 	logic zero_flag, negative_flag, overflow_flag;

// 	// Instantiating modules
// 	ALU dut(.clk, .reset, .read_data1, .read_data2, .imm, .alu_control, .input_type, .data_read,
// 	.instruction_addr, .data_addr, .reg_write_data, .data_write, .data_write_byte,
// 	.zero_flag, .negative_flag, .overflow_flag);

	
// 	// Test conditions
// 	parameter CLOCK_PERIOD=10;
// 	initial begin
// 		clk <= 0;
// 		forever #(CLOCK_PERIOD/2) clk <= ~clk;
// 	end
	
// 	initial
// 	begin
// 		/*
// 		reset = 1; #5
// 		reset = 0;
// 		input_type = 0;
// 		data_read = 0;
// 		instruction_addr = 0;
// 		data_addr = 0;
// 		read_data1 = 23;
// 		read_data2 = 42;*/
		
// 		// R type
// 		reset = 1; #50
		
// 		reset = 0; input_type = 0;	data_read = 0;	instruction_addr = 0;
// 		data_addr = 0;
	
// 		read_data1 = 23;
// 		read_data2 = 42;
// 		alu_control = 4'b0000; #50
// 		alu_control = 4'b0001; #50
// 		alu_control = 4'b0010; #50
// 		alu_control = 4'b0011; #50
// 		alu_control = 4'b0100; #50
// 		alu_control = 4'b0101; #50
// 		alu_control = 4'b0110; #50
// 		alu_control = 4'b0111; #50
// 		alu_control = 4'b1000; #50
// 		alu_control = 4'b1001; #50
// 		read_data1 = 2147483647; read_data2 = 10; alu_control = 4'b0000; #50
// 		read_data1 = 2147483647; read_data2 = -10; alu_control = 4'b0001; #50 
				
// 		// I type
// 		input_type = 1;
// 		read_data1 = 23;
// 		imm = 42;
		
// 		alu_control = 4'b0000; #50
// 		alu_control = 4'b0001; #50
// 		alu_control = 4'b0010; #50
// 		alu_control = 4'b0011; #50
// 		alu_control = 4'b0100; #50
// 		alu_control = 4'b0101; #50
// 		alu_control = 4'b0110; #50
// 		alu_control = 4'b0111; #50
// 		alu_control = 4'b1000; #50
// 		alu_control = 4'b1001; #50
		
// 		// LOAD type
// 		input_type = 2;
// 		data_read = 20;
// 		data_addr = 20;

// 		alu_control = 4'b0000; #50
// 		alu_control = 4'b0001; #50
// 		alu_control = 4'b0010; #50
// 		alu_control = 4'b0100; #50
// 		alu_control = 4'b0101; #50
		
// 		// STORE type
// 		input_type = 3;
// 		data_addr = 20;
// 		read_data2 = 20;
		
// 		alu_control = 4'b0000; #50
// 		alu_control = 4'b0001; #50
// 		alu_control = 4'b0010; #50
		
// 		// BRANCH type
// 		input_type = 4;
// 		read_data1 = 20;
// 		read_data2 = 20;
		
// 		alu_control = 4'b0000; #50
// 		alu_control = 4'b0001; #50
// 		alu_control = 4'b0010; #50
		
// 		// JALR type
// 		input_type = 5;
// 		instruction_addr = 20; #50
		
// 		// JAL type
// 		input_type = 6;
// 		instruction_addr = 20; #50
		
// 		// AUIPIC type
// 		input_type = 7;
// 		instruction_addr = 20;
// 		imm = 15; #50
		
// 		// LUI type
// 		input_type = 8;
// 		imm = 15; #50
		
// 		$stop;
// 	end
// endmodule