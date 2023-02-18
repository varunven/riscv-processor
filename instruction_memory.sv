module instruction_memory(
	input logic [31:0] instruction_addr,
	output logic [31:0] instruction_read
);
	reg [7:0] memory[0:31];
	initial $readmemh("imem_ini.mem", memory);

	assign instruction_read = memory[instruction_addr[31:2]];
endmodule

module instruction_memory_testbench ();	
	logic [31:0] instruction_addr, instruction_read;
	
	instruction_memory dut (.instruction_addr, .instruction_read);
endmodule