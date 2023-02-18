/*
Uses ALU control to perform operation on two operands and provide output
*/

module ALU (
	input logic [31:0] read_data1, read_data2, imm, 
	input logic [3:0] alu_control, input_type,
	input logic [31:0] data_read, instruction_addr, data_addr,
	output logic [31:0] reg_write_data, data_write,
	output logic [3:0] data_write_byte,
	output logic zero_flag,	negative_flag,	overflow_flag
);
	logic [32:0] alu_result;
	logic [31:0] temp1, temp2, offset;
	
	always @(*)
	begin
		zero_flag = 0;
		negative_flag = 0;
		overflow_flag = 0;
		alu_result = 32'b0;
		temp1 = read_data1;
		temp2 = read_data2;
		offset = 32'b0;
		reg_write_data = 32'b0;
		data_write_byte = 4'b0;
		data_write = 4'b0;
		
		// R type
      if(input_type == 0) begin
			temp1 = read_data1;
			temp2 = read_data2;
			case(alu_control)
				4'b0000: begin
					alu_result = read_data1+read_data2; // ADD
					overflow_flag = (read_data1[31] == read_data2[31] && read_data1[31] != alu_result[31]);
				end
				4'b0001: begin
					alu_result = read_data1-read_data2; // SUBTRACT (read_data1-read_data2)
					overflow_flag = (read_data1[31] != read_data2[31] && read_data1[31] != alu_result[31]);
				end
				4'b0010: alu_result = read_data1<<read_data2[4:0]; // SLL read_data1 by read_data2
				4'b0011: alu_result = read_data1<read_data2; // SLT read_data1 by read_data2
				4'b0100: alu_result = temp1<temp2; // SLTU read_data1 by read_data2
				4'b0101: alu_result = read_data1^read_data2; // XOR read_data1 by read_data2
				4'b0110: alu_result = read_data1>>read_data2[4:0]; // SRL read_data1 by read_data2
				4'b0111: alu_result = read_data1>>>read_data2[4:0]; // SRL read_data1 by read_data2
				4'b1000: alu_result = read_data1|read_data2; // OR
				4'b1001: alu_result = read_data1&read_data2; // AND
				default: alu_result = 0; // never occurs, default
			endcase
				
			reg_write_data = alu_result[31:0];

			zero_flag = (reg_write_data == 0);
			negative_flag = (reg_write_data < 0);
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
				 4'b0010: alu_result = read_data1<imm; // SLTI
				 4'b0011: alu_result = temp1<temp2; // SLTIU
				 4'b0100: alu_result = read_data1^imm; // XORI
				 4'b0101: alu_result = read_data1>>imm[4:0]; // SRLI
				 4'b0110: alu_result = read_data1>>>imm[4:0]; // SRAI
				 4'b0111: alu_result = read_data1|imm; // ORI
				 4'b1000: alu_result = read_data1&imm; // ANDI
				 default: alu_result = 0; // never occurs, default
			endcase
				
			reg_write_data = alu_result[31:0];

			zero_flag = (reg_write_data == 0);
			negative_flag = (reg_write_data < 0);
		end
		
		// LOAD
		else if(input_type == 2) begin
			offset = (data_addr[1:0]<<3);
			case(alu_control)
				 4'b0000: alu_result = {{24{data_read[offset+7]}}, data_read[offset +: 8]}; //LB
				 4'b0001: alu_result = {{16{data_read[offset+15]}}, data_read[offset +: 16]}; // LH
				 4'b0010: alu_result = data_read; // LW
				 4'b0011: alu_result = {24'b0, data_read[offset +: 8]}; // LBU
				 4'b0100: alu_result = {16'b0, data_read[offset +: 16]}; // LHU
				 default: alu_result = 0; // never occurs, default
			endcase
				
			reg_write_data = alu_result[31:0];
			zero_flag = (reg_write_data == 0);
			negative_flag = (reg_write_data < 0);
		end
		
		// STORE
		else if(input_type == 3) begin
			offset = (data_addr[1:0]<<3);
			case(alu_control)
				 4'b0000: begin
					data_write_byte = (4'b0001)<<data_addr[1:0]; //SB
					data_write = {read_data2[7:0],read_data2[7:0],read_data2[7:0],read_data2[7:0]};
				 end
				 4'b0001: begin
					data_write_byte = (4'b0011)<<data_addr[1:0]; // SH
					data_write = {read_data2[15:0], read_data2[15:0]};
				 end
				 4'b0010: begin
					data_write_byte = 4'b1111; // SW
					data_write = read_data2;
				 end
				 default: alu_result = 0; // never occurs, default
			endcase
			
			zero_flag = 0;
			negative_flag = 0;
		end
		
		// BRANCH
		else if(input_type == 4) begin
			temp1 = read_data1;
			temp2 = read_data2;
			case(alu_control)
				 0: alu_result = (read_data1==read_data2)?(instruction_addr+imm):(instruction_addr+4); // BEQ
				 1: alu_result = (read_data1!=read_data2)?(instruction_addr+imm):(instruction_addr+4); // BNE
				 4: alu_result = (read_data1<read_data2)?(instruction_addr+imm):(instruction_addr+4); // BLT
				 5: alu_result = (read_data1>=read_data2)?(instruction_addr+imm):(instruction_addr+4); // BGE
				 6: alu_result = (temp1<temp2)?(instruction_addr+imm):(instruction_addr+4); // BLTU
				 7: alu_result = (temp1>=temp2)?(instruction_addr+imm):(instruction_addr+4); // BGEU
				 default: alu_result = 0; // never occurs, default
			endcase
			reg_write_data = alu_result[31:0];
			
			zero_flag = (reg_write_data == 0);
			negative_flag = (reg_write_data < 0);
		end
		
		// JALR and JAL
		else if(input_type == 5 || input_type == 6) begin
			reg_write_data = instruction_addr + 4;
			
			zero_flag = (reg_write_data == 0);
			negative_flag = (reg_write_data < 0);
		end
		
		// AUIPIC
		else if(input_type == 7) begin
			reg_write_data = instruction_addr + imm;
			
			zero_flag = (reg_write_data == 0);
			negative_flag = (reg_write_data < 0);
		end
		
		// LUI
		else if(input_type == 8) begin
			reg_write_data = imm;
			
			zero_flag = (reg_write_data == 0);
			negative_flag = (reg_write_data < 0);
		end
	end
endmodule

module ALU_testbench ();
	logic [31:0] read_data1, read_data2, imm;
	logic [3:0] alu_control, input_type;
	logic [31:0] data_read, instruction_addr;
	logic [31:0] reg_write_data, data_write, data_addr;
	logic [3:0] data_write_byte;
	logic zero_flag,	negative_flag,	overflow_flag;

	// Instantiating modules
	ALU dut(.read_data1, .read_data2, .imm, .alu_control, .input_type, .data_read,
	.instruction_addr, .reg_write_data, .data_write, .data_addr, .data_write_byte,
	.zero_flag, .negative_flag, .overflow_flag);

	// Test conditions
	initial
	begin
		read_data1 = 23; read_data2 = 42;  alu_control = 4'b0000;
		#20 read_data1 = 23; read_data2 = 42;  alu_control = 4'b0001;
		#20 read_data1 = 23; read_data2 = 42;  alu_control = 4'b0010;
		#20 read_data1 = 23; read_data2 = 42;  alu_control = 4'b0100;
		#20 read_data1 = 23; read_data2 = 42;  alu_control = 4'b1000;
		#20 read_data1 = 42; read_data2 = 23;  alu_control = 4'b1000;
		#20 read_data1 = 42; read_data2 = 23;  alu_control = 4'b0100;
		#20 read_data1 = 2147483647; read_data2 = 10; alu_control = 4'b0010;
		#20 read_data1 = 2147483647; read_data2 = -10; alu_control = 4'b0100;
		#20 read_data1 = 2147483647; read_data2 = -10; alu_control = 4'b0100;
	end
endmodule