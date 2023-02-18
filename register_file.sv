module register_file(
    input logic clk, reset,
    input logic [4:0] read_reg1, // rs1
    input logic [4:0] read_reg2, // rs2
	 input logic register_write_valid,
	 input logic [4:0] write_reg, //rd (destination reg)
    input logic [31:0] reg_write_data,
	 output logic [31:0] read_data1,
    output logic [31:0] read_data2
);

	reg [31:0] reg_memory [31:0]; // 32 memory locations each 32 bits wide

	assign read_data1 = reg_memory[read_reg1];
	assign read_data2 = reg_memory[read_reg2];

	always @(posedge clk) begin
	  if (register_write_valid && !reset && write_reg != 0) begin
			reg_memory[write_reg] = reg_write_data;
	  end
	  else if(reset) begin
			reg_memory[0] = 32'h0;
			reg_memory[1] = 32'h1;
			reg_memory[2] = 32'h2;
			reg_memory[3] = 32'h3;
			reg_memory[4] = 32'h4;
			reg_memory[5] = 32'h5;
			reg_memory[6] = 32'h6;
			reg_memory[7] = 32'h7;
			reg_memory[8] = 32'h8;
			reg_memory[9] = 32'h9;
			reg_memory[10] = 32'h10;
			reg_memory[11] = 32'h11;
			reg_memory[12] = 32'h12;
			reg_memory[13] = 32'h13;
			reg_memory[14] = 32'h14;
			reg_memory[15] = 32'h15;
			reg_memory[16] = 32'h16;
			reg_memory[17] = 32'h17;
			reg_memory[18] = 32'h18;
			reg_memory[19] = 32'h19;
			reg_memory[20] = 32'h20;
			reg_memory[21] = 32'h21;
			reg_memory[22] = 32'h22;
			reg_memory[23] = 32'h23;
			reg_memory[24] = 32'h24;
			reg_memory[25] = 32'h25;
			reg_memory[26] = 32'h26;
			reg_memory[27] = 32'h27;
			reg_memory[28] = 32'h28;
			reg_memory[29] = 32'h29;
			reg_memory[30] = 32'h30;
			reg_memory[31] = 32'h31;
	  end
	end
endmodule

module register_file_testbench ();
    logic clk;
    logic reset;
    logic [4:0] read_reg1;
    logic [4:0] read_reg2;
	 logic register_write_valid;
	 logic [4:0] write_reg;
    logic [31:0] reg_write_data;
	 logic [31:0] read_data1;
    logic [31:0] read_data2;

	// Instantiating modules
	register_file dut(
    .clk, .reset, .read_reg1, .read_reg2, .register_write_valid, .write_reg, .reg_write_data,
	 .read_data1, .read_data2);

	// Test conditions
	initial
	begin
		clk = 1; forever #20 clk = ~clk;
	end
	
	initial
	begin
		read_reg1 = 4;
		read_reg2 = 8;
		reg_write_data = 1;
		reset = 1; #20
		
		read_reg1 = 4;
		read_reg2 = 8;
		reg_write_data = 1;
		reset = 0; #200
		
		read_reg1 = 4;
		read_reg2 = 8;
		reg_write_data = 0;
		reset = 1; #20
		
		read_reg1 = 4;
		read_reg2 = 8;
		reg_write_data = 0;
		reset = 0;
	end
endmodule