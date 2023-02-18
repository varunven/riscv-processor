module riscv32#(parameter reset_pc=32'h00010000)  // On reset, set the PC to this value
(
	clk,
	reset,
	zero_flag,
	negative_flag,
	overflow_flag
);
	/* missing parameters:  
 	 logic           instruction_valid;
    logic           instruction_ready;
    logic           instruction_ack;

    logic           data_ready;
    logic           data_ack;*/

	input logic clk, reset;
	output logic zero_flag, negative_flag, overflow_flag;
   
	logic [31:0] instruction_addr; // address to read from - should follow PC
	logic [31:0] instruction_read; // holds value at instruction_addr
	logic register_write_valid; // if register should update write - updated in control
	logic [31:0] read_data1, read_data2, imm; // rv1, rv2, imm
	logic [31:0] reg_write_data; // data to write to register

	logic [31:0] data_addr; // address to read data from - updated in control
	logic [31:0] data_read; // data that was read from memory
	logic [31:0] data_write; // data that is to be written in memory
	
	logic [3:0] data_write_byte; // bytes of instruction to read - updated in control
	logic data_read_valid; // if memory should be read - updated in control
	logic data_write_valid; // if memory should update write - updated in control
		
	// register_file
	logic [4:0] read_reg1, read_reg2, write_reg;
	
	// control	
	control #(.reset_pc(reset_pc)) control_module (.clk, .reset, .instruction_read,
	.read_reg1, .read_reg2, .write_reg, .read_data1, .read_data2, .instruction_addr,
	.reg_write_data, .data_read_valid, .data_write_valid, .register_write_valid, .data_write_byte,
	.data_write, .data_addr, .data_read, .zero_flag, .negative_flag, .overflow_flag);
	
	// instruction memory
	instruction_memory instruction_memory_module (.instruction_addr, .instruction_read);
	
	register_file register_file_module (.clk, .reset, .read_reg1, .read_reg2,
	.register_write_valid, .write_reg, .reg_write_data, .read_data1, .read_data2);
	
	// data memory
	memory memory_module (.clk, .reset, .data_write_byte,
	.data_addr, .data_read, .data_write, .data_read_valid, .data_write_valid);

endmodule

module riscv32_testbench();
	logic clk, reset;
	logic zero_flag, negative_flag, overflow_flag;

	riscv32 dut (.clk, .reset, .zero_flag, .negative_flag, .overflow_flag);

	parameter CLOCK_PERIOD=100;
	initial begin
	clk <= 0;
	forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	initial begin
	reset <= 0; repeat (10) @(posedge clk);
	reset <= 1; repeat(10) @(posedge clk);
	reset <= 0; repeat(200) @(posedge clk);
	reset <= 1; repeat(10) @(posedge clk);
	reset <= 0; repeat(300) @(posedge clk);
	$stop;
	end
endmodule
