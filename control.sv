module control	#(parameter reset_pc=32'h00010000)(
	input logic clk, reset,
	input logic [31:0] instruction_read,
	input logic [31:0] read_data1, read_data2,
	input logic [31:0] data_read,
	output logic [4:0] read_reg1, read_reg2, write_reg,
	output logic [31:0] instruction_addr,
	output logic [31:0] reg_write_data,
	output logic data_read_valid, data_write_valid, register_write_valid,
	output logic [3:0] data_write_byte,
	output logic [31:0] data_write, data_addr,
	output logic zero_flag, negative_flag, overflow_flag
);

	logic [31:0] imm;
	logic [31:0] offset;
	
	logic [3:0] alu_control; // used to mux into operation
	logic [3:0] input_type; // 0:R, 1:I, 2:L, 3:S, 4:B, 5:JALR, 6:JAL, 7:AUIPC, 8:LUI
	
	logic [31:0] pc;
	always@(posedge reset or posedge clk) begin
		if(reset)
		  instruction_addr = reset_pc;
		else
		  instruction_addr = pc;
	end

	//data_write only used for S
	// ALU
	ALU ALU_module (.read_data1, .read_data2, .imm, .alu_control, .input_type,
	.data_read,	.reg_write_data, .data_write, .data_addr, .instruction_addr,
	.zero_flag, .negative_flag, .overflow_flag);

	always @(*)
	begin	
		if (instruction_read[6:0] == 7'b0110011) begin // R-type instructions
			read_reg1 = instruction_read[19:15];
			read_reg2 = instruction_read[24:20];
			write_reg = instruction_read[11:7];
			imm = 0;
			
			data_write_valid = 0;
			data_write_byte = 4'b0;
			data_read_valid = 1;
			register_write_valid = 1;
			
			input_type = 0;
			
			case (instruction_read[14:12])
				 0: begin
					  if(instruction_read[31:25] == 0)
					  alu_control = 4'b0000; // ADD
					  else if(instruction_read[31:25] == 32)
					  alu_control = 4'b0001; // SUB
				 end
				 1: alu_control = 4'b0010; // SLL
				 2: alu_control = 4'b0011; // SLT
				 3: alu_control = 4'b0100; // SLTU
				 4: alu_control = 4'b0101; // XOR
				 5: 
					if(instruction_read[31:25] == 0)
					alu_control = 4'b0110; // SRL
					else if(instruction_read[31:25] == 32)
					alu_control = 4'b0111; // SRA
				 6: alu_control = 4'b1000; // OR
				 7: alu_control = 4'b1001; // AND
				 default: alu_control = 4'b1111; // DEFAULT
			endcase
			pc = instruction_addr+4; 
		end
		
		else if (instruction_read[6:0] == 7'b0010011) begin // I-type instructions
			read_reg1 = instruction_read[19:15];
			write_reg = instruction_read[11:7];
			imm = {{20{instruction_read[31]}},instruction_read[31:20]};
			
			data_write_valid = 0;
			data_write_byte = 4'b0;
			data_read_valid = 1;
			register_write_valid = 1;
			
			input_type = 1;
			
			case (instruction_read[14:12])				 
				 0: alu_control = 4'b0000; // ADDI
				 1: alu_control = 4'b0001; // SLLI
				 2: alu_control = 4'b0010; // SLTI
				 3: alu_control = 4'b0011; // SLTIU
				 4: alu_control = 4'b0100; // XORI
				 5: 
					if(instruction_read[31:25] == 0)
					alu_control = 4'b0101; // SRLI
					else if(instruction_read[31:25] == 32)
					alu_control = 4'b0110; // SRAI
				 6: alu_control = 4'b0111; // ORI
				 7: alu_control = 4'b1000; // ANDI
				 default: alu_control = 4'b1111; // DEFAULT
			endcase
			pc = instruction_addr+4;
		end
		
		else if (instruction_read[6:0] == 7'b0000011) begin // LOAD
			read_reg1 = instruction_read[19:15];
			write_reg = instruction_read[11:7];
			imm = {{20{instruction_read[31]}},instruction_read[31:20]};
			
			data_write_valid = 0;
			data_write_byte = 4'b0;
			data_read_valid = 1;
			register_write_valid = 1;
			
			data_addr = read_data1+imm; 
			input_type = 2;
			
			case (instruction_read[14:12])				 
				 0: alu_control = 4'b0000; // LB
				 1: alu_control = 4'b0001; // LH
				 2: alu_control = 4'b0010; // LW
				 4: alu_control = 4'b0011; // LBU
				 5: alu_control = 4'b0100; // LHU
				 default: alu_control = 4'b1111; // DEFAULT
			endcase
			pc = instruction_addr+4; 
		end
		
		else if (instruction_read[6:0] == 7'b0100011) begin // STORE
			read_reg1 = instruction_read[19:15];
			read_reg2 = instruction_read[24:20];
			imm = {{20{instruction_read[31]}},instruction_read[31:25],instruction_read[11:7]};
			
			data_write_valid = 1;
			data_read_valid = 0;
			register_write_valid = 0;
			
			data_addr = read_data1+imm; 
			input_type = 3;
			
			case (instruction_read[14:12])			 
				 0: alu_control = 4'b0000; // SB
				 1: alu_control = 4'b0001; // SH
				 2: alu_control = 4'b0010; // SW
				 default: alu_control = 4'b1111; // DEFAULT
			endcase
			pc = instruction_addr+4; 
		end
		
		else if (instruction_read[6:0] == 7'b1100011) begin // BRANCH
			read_reg1 = instruction_read[19:15];
			read_reg2 = instruction_read[24:20];
			imm = {{20{instruction_read[31]}},instruction_read[31],instruction_read[7],instruction_read[30:25],instruction_read[11:8],1'b0};
			
			data_write_valid = 0;
			data_write_byte = 4'b0;
			data_read_valid = 0;
			register_write_valid = 0;
			
			input_type = 4;
			
			case (instruction_read[14:12])				 
				 0: alu_control = 4'b0000; // BEQ
				 1: alu_control = 4'b0001; // BNE
				 4: alu_control = 4'b0100; // BLT
				 5: alu_control = 4'b0110; // BGE
				 6: alu_control = 4'b0111; // BLTU
				 7: alu_control = 4'b1000; // BGEU
				 default: alu_control = 4'b1111; // DEFAULT
			endcase
			pc = reg_write_data; // = PC+imm or = PC + 4
		end
		
		else if (instruction_read[6:0] == 7'b1100111) begin // JALR
			read_reg1 = instruction_read[19:15];
			write_reg = instruction_read[11:7];
			imm = {{20{instruction_read[31]}},instruction_read[31:20]};
			
			data_write_valid = 0;
			data_write_byte = 4'b0;
			data_read_valid = 1;
			register_write_valid = 1;
			
			input_type = 5;
			
			pc = (read_data1+imm)&32'hfffffffe;
		end
		
		else if (instruction_read[6:0] == 7'b1101111) begin // JAL
			write_reg = instruction_read[11:7];
			imm = {{11{instruction_read[31]}},instruction_read[31],instruction_read[19:12],instruction_read[20],instruction_read[30:21],1'b0};
			
			pc = instruction_addr+imm;
			
			data_write_valid = 0;
			data_write_byte = 4'b0;
			data_read_valid = 1;
			register_write_valid = 1;
			
			input_type = 6;
		end
		else if (instruction_read[6:0] == 7'b0010111) begin // AUPIC
			write_reg = instruction_read[11:7];
			imm = {instruction_read[31:12],12'b0};
			
			data_write_valid = 0;
			data_write_byte = 4'b0;
			data_read_valid = 1;
			register_write_valid = 1;
			
			input_type = 7;
			pc = instruction_addr+4;
		end
		else if (instruction_read[6:0] == 7'b0110111) begin // LUI
			write_reg = instruction_read[11:7];
			imm = {instruction_read[31:12],12'b0};
			data_write_valid = 0;
			data_write_byte = 4'b0;
			data_read_valid = 1;
			register_write_valid = 1;
			input_type = 8;
			pc = instruction_addr+4;
		end
	end
endmodule

module control_testbench ();
	logic clk, reset;
	logic [31:0] instruction_read;
	logic [31:0] read_data1, read_data2;
	logic [31:0] data_read;
	logic [4:0] read_reg1, read_reg2, write_reg;
	logic [31:0] instruction_addr;
	logic [31:0] reg_write_data;
	logic data_read_valid, data_write_valid, register_write_valid;
	logic [3:0] data_write_byte;
	logic [31:0] data_write, data_addr;
	logic zero_flag, negative_flag, overflow_flag;

	// Instantiating modules
	control dut(.clk, .reset, .instruction_read, .read_data1, .read_data2, .data_read,
	.read_reg1, .read_reg2, .write_reg, .instruction_addr, .reg_write_data,
	.data_read_valid, .data_write_valid, .register_write_valid, .data_write_byte,
	.data_write, .data_addr, .zero_flag, .negative_flag, .overflow_flag);


endmodule