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
	
	always @(*) begin
		// reset values
		if(reset) begin
			$readmemh("dmem_ini.mem", memory);
		end
		else begin
			// write the data_write to memory
			if(data_write_valid) begin
				if(data_write_byte[0]==1)
					memory[pc0] <= data_write[7:0];
				if(data_write_byte[1]==1)
					memory[pc1] <= data_write[15:8];
				if(data_write_byte[2]==1)
					memory[pc2] <= data_write[23:16];
				if(data_write_byte[3]==1)
					memory[pc3] <= data_write[31:24];
			end
			if(data_read_valid) begin
				data_read <= {memory[pc0],memory[pc1],memory[pc2],memory[pc3]};
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
	
	parameter CLOCK_PERIOD=10;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	initial begin
		reset = 1; #80
		
		reset = 0; data_write_valid = 1; data_read_valid = 0; 
		data_write = 32'h12345678;
		
		data_write_byte = 4'b0001; data_addr = 0; #80
		data_write_byte = 4'b0011; data_addr = 1; #80
		data_write_byte = 4'b0111; data_addr = 2; #80
		data_write_byte = 4'b1111; data_addr = 3; #80
		
		data_write_byte = 4'b0001; data_addr = 4; #80
		data_write_byte = 4'b0011; data_addr = 5; #80
		data_write_byte = 4'b0111; data_addr = 6; #80
		data_write_byte = 4'b1111; data_addr = 7; #80
		
		data_write_byte = 4'b0001; data_addr = 8; #80
		data_write_byte = 4'b0011; data_addr = 9; #80
		data_write_byte = 4'b0111; data_addr = 10; #80
		data_write_byte = 4'b1111; data_addr = 11; #80
		
		data_write_byte = 4'b0001; data_addr = 12; #80
		data_write_byte = 4'b0011; data_addr = 13; #80
		data_write_byte = 4'b0111; data_addr = 14; #80
		data_write_byte = 4'b1111; data_addr = 15; #80
		
		data_write_byte = 4'b0001; data_addr = 16; #80
		data_write_byte = 4'b0011; data_addr = 17; #80
		data_write_byte = 4'b0111; data_addr = 18; #80
		data_write_byte = 4'b1111; data_addr = 19; #80
		
		data_write_byte = 4'b0001; data_addr = 20; #80
		data_write_byte = 4'b0011; data_addr = 21; #80
		data_write_byte = 4'b0111; data_addr = 22; #80
		data_write_byte = 4'b1111; data_addr = 23; #80
		
		data_write_byte = 4'b0001; data_addr = 24; #80
		data_write_byte = 4'b0011; data_addr = 25; #80
		data_write_byte = 4'b0111; data_addr = 26; #80
		data_write_byte = 4'b1111; data_addr = 27; #80
		
		data_write_byte = 4'b0001; data_addr = 28; #80
		data_write_byte = 4'b0011; data_addr = 29; #80
		data_write_byte = 4'b0111; data_addr = 30; #80
		data_write_byte = 4'b1111; data_addr = 31; #80
		
		reset = 1; #80
		
		reset = 0; data_write_valid = 0; data_read_valid = 1; 
		
		data_addr = 0; #80
		data_addr = 1; #80
		data_addr = 2; #80
		data_addr = 3; #80
		
		data_addr = 4; #80
		data_addr = 5; #80
		data_addr = 6; #80
		data_addr = 7; #80
		
		data_addr = 8; #80
		data_addr = 9; #80
		data_addr = 10; #80
		data_addr = 11; #80
		
		data_addr = 12; #80
		data_addr = 13; #80
		data_addr = 14; #80
		data_addr = 15; #80
		
		data_addr = 16; #80
		data_addr = 17; #80
		data_addr = 18; #80
		data_addr = 19; #80
		
		data_addr = 20; #80
		data_addr = 21; #80
		data_addr = 22; #80
		data_addr = 23; #80
		
		data_addr = 24; #80
		data_addr = 25; #80
		data_addr = 26; #80
		data_addr = 27; #80
		
		data_addr = 28; #80
		data_addr = 29; #80
		data_addr = 30; #80
		data_addr = 31; #80
		$stop;
	end
endmodule