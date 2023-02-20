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
//make under control of if alu is complete or not?
	reg [31:0] reg_memory [0:31]; // 32 memory locations each 32 bits wide
	
	integer i;
	initial begin
		reg_memory[31] = 0;
		for(i=0; i<31; i = i+1)
			reg_memory[i]=i;
	end

	assign read_data1 = reg_memory[read_reg1];
	assign read_data2 = reg_memory[read_reg2];

	always @(posedge clk) begin
		if(reset) begin
			reg_memory[0] = 0;
			reg_memory[1] = 1;
			reg_memory[2] = 2;
			reg_memory[3] = 3;
			reg_memory[4] = 4;
			reg_memory[5] = 5;
			reg_memory[6] = 6;
			reg_memory[7] = 7;
			reg_memory[8] = 8;
			reg_memory[9] = 9;
			reg_memory[10] = 10;
			reg_memory[11] = 11;
			reg_memory[12] = 12;
			reg_memory[13] = 13;
			reg_memory[14] = 14;
			reg_memory[15] = 15;
			reg_memory[16] = 16;
			reg_memory[17] = 17;
			reg_memory[18] = 18;
			reg_memory[19] = 19;
			reg_memory[20] = 20;
			reg_memory[21] = 21;
			reg_memory[22] = 22;
			reg_memory[23] = 23;
			reg_memory[24] = 24;
			reg_memory[25] = 25;
			reg_memory[26] = 26;
			reg_memory[27] = 27;
			reg_memory[28] = 28;
			reg_memory[29] = 29;
			reg_memory[30] = 30;
			reg_memory[31] = 31;
	  end
	  else if (register_write_valid && write_reg!=31 && !reset) begin
			reg_memory[write_reg] = reg_write_data;
	  end
	end
endmodule
// testbench does not pass verilator lint
// module register_file_testbench ();
//     logic clk;
//     logic reset;
//     logic [4:0] read_reg1;
//     logic [4:0] read_reg2;
// 	 logic register_write_valid;
// 	 logic [4:0] write_reg;
//     logic [31:0] reg_write_data;
// 	 logic [31:0] read_data1;
//     logic [31:0] read_data2;
	 
// 	// Instantiating modules
// 	register_file dut(
//     .clk, .reset, .read_reg1, .read_reg2, .register_write_valid, .write_reg, .reg_write_data,
// 	 .read_data1, .read_data2);

// 	// Test conditions
// 	parameter CLOCK_PERIOD=10;
// 	initial begin
// 		clk <= 0;
// 		forever #(CLOCK_PERIOD/2) clk <= ~clk;
// 	end
	
// 	initial
// 	begin
// 		reset = 1; #20
		
// 		reset = 0;
// 		read_reg1 = 4;
// 		read_reg2 = 8;
// 		register_write_valid = 0; #20
		
// 		register_write_valid = 1;
// 		write_reg = 0;
// 		reg_write_data = 32'h10; #20
		
// 		register_write_valid = 1;
// 		write_reg = 10;
// 		reg_write_data = 32'h20; #20
		
// 		register_write_valid = 1;
// 		write_reg = 11;
// 		reg_write_data = 32'h21; #20
		
// 		read_reg1 = 11;
// 		read_reg2 = 10;
// 		register_write_valid = 0; #20
		
// 		reset = 1; #20
		
// 		reset = 0;
// 		register_write_valid = 1;
// 		write_reg = 20;
// 		reg_write_data = 32'h15; #20
// 		$stop;
// 	end
// endmodule