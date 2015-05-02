`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:14:06 04/28/2015
// Design Name:   bullet
// Module Name:   X:/Desktop/courses/EC551/project/test/tb_bullet.v
// Project Name:  blk_mem_gen_v7_3
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: bullet
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_bullet;

	// Inputs
	reg clk;
	reg rst;
	reg fire;
	reg wr;
	reg [15:0] data_in;
	reg ACK;
	reg NACK;
	reg [15:0] digger_status;

	// Outputs
	wire [15:0] bullet_status;
	wire req;
	wire [1:0] req_type;
	wire [7:0] req_content;

	// Instantiate the Unit Under Test (UUT)
	bullet uut (
		.clk(clk), 
		.rst(rst), 
		.fire(fire), 
		.wr(wr), 
		.data_in(data_in), 
		.ACK(ACK), 
		.NACK(NACK), 
		.digger_status(digger_status), 
		.bullet_status(bullet_status), 
		.req(req), 
		.req_type(req_type), 
		.req_content(req_content)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		fire = 0;
		wr = 0;
		data_in = 0;
		ACK = 0;
		NACK = 0;
		digger_status = 16'b0101110111001111;

		// Wait 100 ns for global reset to finish
		#10;
		rst=0;
		#10;
      fire=1;
		#2 fire=0;
		#2 ACK=1; wr=1;data_in=16'b0101110110000000;
		#2 ACK=0;wr=0;
		#15 ACK=1; data_in=16'b0101110110000000;
		#2 ACK=0;wr=0;
		#15 ACK=1; data_in=16'b0101110000000000;
		#2 ACK=0;wr=0;
				#15 ACK=1; data_in=16'b0101110000000000;
		#2 ACK=0;wr=0;
				#15 ACK=1; data_in=16'b0101110000000000;
		#2 ACK=0;wr=0;
				#15 ACK=1; data_in=16'b0101110000000000;
		#2 ACK=0;wr=0;
				#15 ACK=1; data_in=16'b0101110000000000;
		#2 ACK=0;wr=0;
		#15 ACK=1;
		#2 ACK=0;

		// Add stimulus here

	end
   	always begin
			#1 clk = ~clk;
	end
endmodule

