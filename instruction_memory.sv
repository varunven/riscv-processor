module instruction_memory(
	input logic clk, reset,
	input logic [31:0] instruction_addr,
	output logic [31:0] instruction_read,
	output logic instruction_ready
);

	// keeps track of instruction memory
	logic [7:0] memory [31:0];
	
	logic [31:0] pc0,pc1,pc2,pc3;
	initial $readmemh("imem_ini.mem", memory);

	assign pc0 = (instruction_addr & 32'hfffffffc)+ 32'h00000000;
	assign pc1 = (instruction_addr & 32'hfffffffc)+ 32'h00000001;
	assign pc2 = (instruction_addr & 32'hfffffffc)+ 32'h00000002;
	assign pc3 = (instruction_addr & 32'hfffffffc)+ 32'h00000003;
	
	always @(*) begin
		// reset values
		if(reset) begin
			$readmemh("imem_ini.mem", memory);
		end
		else begin
			instruction_read = {memory[pc0],memory[pc1],memory[pc2],memory[pc3]};
			instruction_ready = 1;
		end
	end
endmodule

// testbench does not pass verilator lint
// module instruction_memory_testbench ();
// 	logic clk, reset;
// 	logic [31:0] instruction_addr, instruction_read;
// 	logic instruction_ready;
	
// 	instruction_memory dut (.clk, .reset, .instruction_addr, .instruction_read, .instruction_ready);
	
// 	parameter CLOCK_PERIOD=100;
// 	initial begin
// 		clk = 0;
// 		forever #(CLOCK_PERIOD/2) clk = ~clk;
// 	end

// 	initial begin
// 		reset = 1; #120
// 		reset = 0; instruction_addr = 0; #80
// 		reset = 0; instruction_addr = 1; #80
// 		reset = 0; instruction_addr = 2; #80
// 		reset = 0; instruction_addr = 3; #80
		
// 		reset = 0; instruction_addr = 4; #80
// 		reset = 0; instruction_addr = 5; #80
// 		reset = 0; instruction_addr = 6; #80
// 		reset = 0; instruction_addr = 7; #80
		
// 		reset = 0; instruction_addr = 8; #80
// 		reset = 0; instruction_addr = 9; #80
// 		reset = 0; instruction_addr = 10; #80
// 		reset = 0; instruction_addr = 11; #80
		
// 		reset = 0; instruction_addr = 12; #80
// 		reset = 0; instruction_addr = 13; #80
// 		reset = 0; instruction_addr = 14; #80
// 		reset = 0; instruction_addr = 15; #80
		
// 		reset = 0; instruction_addr = 16; #80
// 		reset = 0; instruction_addr = 17; #80
// 		reset = 0; instruction_addr = 18; #80
// 		reset = 0; instruction_addr = 19; #80
		
// 		reset = 0; instruction_addr = 20; #80
// 		reset = 0; instruction_addr = 21; #80
// 		reset = 0; instruction_addr = 22; #80
// 		reset = 0; instruction_addr = 23; #80
		
// 		reset = 0; instruction_addr = 24; #80
// 		reset = 0; instruction_addr = 25; #80
// 		reset = 0; instruction_addr = 26; #80
// 		reset = 0; instruction_addr = 27; #80
		
// 		reset = 0; instruction_addr = 28; #80
// 		reset = 0; instruction_addr = 29; #80
// 		reset = 0; instruction_addr = 30; #80
// 		reset = 0; instruction_addr = 31; #80
// 		$stop;
// 	end
// endmodule