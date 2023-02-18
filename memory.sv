module memory(
	input logic clk, reset,
	input logic [31:0] data_addr,
	input logic [31:0] data_write,
	input logic [3:0] data_write_byte,
	input logic data_read_valid,
	input logic data_write_valid,
	output logic [31:0] data_read
);
	
	// keeps track of data memory
	logic [7:0] memory [31:0];
	
	logic [31:0] pc0,pc1,pc2,pc3;
	initial $readmemh("dmem_ini.mem", memory);

	assign pc0 = (data_addr & 32'hfffffffc)+ 32'h00000000;
	assign pc1 = (data_addr & 32'hfffffffc)+ 32'h00000001;
	assign pc2 = (data_addr & 32'hfffffffc)+ 32'h00000002;
	assign pc3 = (data_addr & 32'hfffffffc)+ 32'h00000003;
	
	always @(posedge reset or posedge clk) begin
		// reset values
		if(reset) begin
			$readmemh("dmem_ini.mem", memory);
		end
		else begin
			// write the data_write to memory
			if(data_write_valid) begin
				if(data_write_byte[0]==1)
					memory[pc0] = data_write[7:0];
				if(data_write_byte[1]==1)
					memory[pc1] = data_write[15:8];
				if(data_write_byte[2]==1)
					memory[pc2] = data_write[23:16];
				if(data_write_byte[3]==1)
					memory[pc3] = data_write[31:24];
			end
			else if(data_read_valid) begin
				data_read = {memory[pc3],memory[pc2],memory[pc1],memory[pc0]};
			end
		end
	end
endmodule

module memory_testbench ();	
	logic clk, reset;
	logic [31:0] data_addr;
	logic [31:0] data_write;
	logic [3:0] data_write_byte;
	logic data_read_valid;
	logic data_write_valid;
	logic [31:0] data_read;
	
	memory dut (.clk, .reset, .data_addr, .data_write, .data_write_byte,
	.data_read_valid, .data_write_valid, .data_read);

	// Test conditions
	initial
	begin
		clk = 1; forever #20 clk = ~clk;
	end
endmodule