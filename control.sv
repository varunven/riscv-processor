module control	(
	input logic clk, reset,
	input logic [31:0] instruction_read,
	input logic [31:0] read_data1, read_data2,
	input logic [31:0] data_read,
	input logic instruction_ready,
	output logic [31:0] instruction_addr,
	output logic [4:0] read_reg1, read_reg2, write_reg,
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
	logic [31:0] next_pc;
	
	initial pc = 32'h0;
	initial next_pc = 32'h0;
	
	always@(posedge clk) begin
		if(reset) pc <= 32'h0;
		else pc <= next_pc;
	end

	//data_write only used for S
	
	// ALU
	ALU ALU_module (.clk, .reset, .read_data1, .read_data2, .imm, .alu_control,
	.input_type, .data_read,	.reg_write_data, .data_write,	.data_write_byte,
	.data_addr, .instruction_addr, .zero_flag, .negative_flag, .overflow_flag,
	.data_write_valid, .data_read_valid, .register_write_valid);

	always @(*) begin
		instruction_addr <= pc;
		if(instruction_ready) begin
			if (instruction_read[6:0] == 7'b0110011) begin // R-type instructions
				read_reg1 <= instruction_read[19:15];
				read_reg2 <= instruction_read[24:20];
				write_reg <= instruction_read[11:7];
				
				input_type <= 0;
				
				case (instruction_read[14:12])
					 0: begin
						  if(instruction_read[31:25] == 0)
						  alu_control <= 4'b0000; // ADD
						  else if(instruction_read[31:25] == 32)
						  alu_control <= 4'b0001; // SUB
					 end
					 1: alu_control <= 4'b0010; // SLL
					 2: alu_control <= 4'b0011; // SLT
					 3: alu_control <= 4'b0100; // SLTU
					 4: alu_control <= 4'b0101; // XOR
					 5: 
						if(instruction_read[31:25] == 0)
						alu_control <= 4'b0110; // SRL
						else if(instruction_read[31:25] == 32)
						alu_control <= 4'b0111; // SRA
					 6: alu_control <= 4'b1000; // OR
					 7: alu_control <= 4'b1001; // AND
				endcase
				next_pc <= instruction_addr+4; 
			end
			
			else if (instruction_read[6:0] == 7'b0010011) begin // I-type instructions
				read_reg1 <= instruction_read[19:15];
				write_reg <= instruction_read[11:7];
				imm <= {{20{instruction_read[31]}},instruction_read[31:20]};
				
				input_type <= 1;
				
				case (instruction_read[14:12])				 
					 0: alu_control <= 4'b0000; // ADDI
					 1: alu_control <= 4'b0001; // SLLI
					 2: alu_control <= 4'b0010; // SLTI
					 3: alu_control <= 4'b0011; // SLTIU
					 4: alu_control <= 4'b0100; // XORI
					 5: 
						if(instruction_read[31:25] == 0)
						alu_control <= 4'b0101; // SRLI
						else if(instruction_read[31:25] == 32)
						alu_control <= 4'b0110; // SRAI
					 6: alu_control <= 4'b0111; // ORI
					 7: alu_control <= 4'b1000; // ANDI
				endcase
				next_pc <= instruction_addr+4;
			end
			
			else if (instruction_read[6:0] == 7'b0000011) begin // LOAD
				read_reg1 <= instruction_read[19:15];
				write_reg <= instruction_read[11:7];
				imm <= {{20{instruction_read[31]}},instruction_read[31:20]};
				
				data_addr <= read_data1+imm; 
				input_type <= 2;
				
				case (instruction_read[14:12])				 
					 0: alu_control <= 4'b0000; // LB
					 1: alu_control <= 4'b0001; // LH
					 2: alu_control <= 4'b0010; // LW
					 4: alu_control <= 4'b0011; // LBU
					 5: alu_control <= 4'b0100; // LHU
				endcase
				next_pc <= instruction_addr+4; 
			end
			
			else if (instruction_read[6:0] == 7'b0100011) begin // STORE
				read_reg1 <= instruction_read[19:15];
				read_reg2 <= instruction_read[24:20];
				imm <= {{20{instruction_read[31]}},instruction_read[31:25],instruction_read[11:7]};
				
				data_addr <= read_data1+imm; 
				input_type <= 3;
				
				case (instruction_read[14:12])			 
					 0: alu_control <= 4'b0000; // SB
					 1: alu_control <= 4'b0001; // SH
					 2: alu_control <= 4'b0010; // SW
				endcase
				next_pc <= instruction_addr+4; 
			end
			
			else if (instruction_read[6:0] == 7'b1100011) begin // BRANCH
				read_reg1 <= instruction_read[19:15];
				read_reg2 <= instruction_read[24:20];
				imm <= {{20{instruction_read[31]}},instruction_read[31],instruction_read[7],instruction_read[30:25],instruction_read[11:8]};
				
				input_type <= 4;
				
				case (instruction_read[14:12])				 
					 0: alu_control <= 4'b0000; // BEQ
					 1: alu_control <= 4'b0001; // BNE
					 4: alu_control <= 4'b0100; // BLT
					 5: alu_control <= 4'b0110; // BGE
					 6: alu_control <= 4'b0111; // BLTU
					 7: alu_control <= 4'b1000; // BGEU
				endcase
				next_pc <=reg_write_data; // = PC+imm or = PC + 4
			end
			
			else if (instruction_read[6:0] == 7'b1100111) begin // JALR
				read_reg1 <= instruction_read[19:15];
				write_reg <= instruction_read[11:7];
				imm <= {{20{instruction_read[31]}},instruction_read[31:20]};
				
				input_type <= 5;
				
				next_pc <=(read_data1+imm)&32'hfffffffe;
			end
			
			else if (instruction_read[6:0] == 7'b1101111) begin // JAL
				write_reg <= instruction_read[11:7];
				imm <= {{11{instruction_read[31]}},instruction_read[31],instruction_read[19:12],instruction_read[20],instruction_read[30:21],1'b0};
				
				next_pc <= instruction_addr+imm;
				
				input_type <= 6;
			end
			else if (instruction_read[6:0] == 7'b0010111) begin // AUPIC
				write_reg <= instruction_read[11:7];
				imm <= {instruction_read[31:12],12'b0};
				
				input_type <= 7;
				next_pc <= instruction_addr+4;
			end
			else if (instruction_read[6:0] == 7'b0110111) begin // LUI
				write_reg <= instruction_read[11:7];
				imm <= {instruction_read[31:12],12'b0};
				
				input_type <= 8;
				next_pc <= instruction_addr+4;
			end
		end
	end
endmodule

module control_testbench ();
	logic clk, reset;
	logic [31:0] instruction_read;
	logic [31:0] read_data1, read_data2;
	logic [31:0] data_read;
	logic instruction_ready;
	logic [4:0] read_reg1, read_reg2, write_reg;
	logic [31:0] instruction_addr;
	logic [31:0] reg_write_data;
	logic data_read_valid, data_write_valid, register_write_valid;
	logic [3:0] data_write_byte;
	logic [31:0] data_write, data_addr;
	logic zero_flag, negative_flag, overflow_flag;

	// Instantiating modules
	control dut(.clk, .reset, .instruction_read, .read_data1, .read_data2, .data_read,
	.read_reg1, .read_reg2, .write_reg, .instruction_addr, .reg_write_data, .instruction_ready,
	.data_read_valid, .data_write_valid, .register_write_valid, .data_write_byte,
	.data_write, .data_addr, .zero_flag, .negative_flag, .overflow_flag);

		// Test conditions
	parameter CLOCK_PERIOD=10;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
		reset = 0;
		read_data1 = 11;
		read_data2 = 22;
		data_read = 20;
		instruction_ready=0;
		instruction_read = 32'h00940333; #50
		
		instruction_ready=1; #50
		
		// R type
		instruction_read = 32'h00940333; #50
		instruction_read = 32'h413903b3; #50
		instruction_read = 32'h015a12b3; #50
		instruction_read = 32'h017b2e33; #50
		instruction_read = 32'h019c4eb3; #50
		instruction_read = 32'h013a53b3; #50
		instruction_read = 32'h4154de33; #50
		instruction_read = 32'h00d5e7b3; #50
		instruction_read = 32'h00d77533; #50
		
		// I type
		instruction_read = 32'h00040313; #50
		instruction_read = 32'h00091393; #50
		instruction_read = 32'h000a2293; #50
		instruction_read = 32'h000b3e13; #50
		instruction_read = 32'h000b4e13; #50
		instruction_read = 32'h000c5e93; #50
		instruction_read = 32'h400a5393; #50
		instruction_read = 32'h0005e793; #50
		instruction_read = 32'h00077513; #50
		
		// L type
		instruction_read = 32'h005e8e03; #50
		instruction_read = 32'h005e9e03; #50
		instruction_read = 32'h005eae03; #50
		instruction_read = 32'h005ece03; #50
		instruction_read = 32'h005ede03; #50
		
		// S type
		instruction_read = 32'h00c702a3; #50
		instruction_read = 32'h00c712a3; #50
		instruction_read = 32'h00c722a3; #50
		$stop;
	end
endmodule