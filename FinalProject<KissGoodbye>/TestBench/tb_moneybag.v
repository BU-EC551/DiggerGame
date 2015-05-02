`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   00:06:05 04/29/2015
// Design Name:   money_bag
// Module Name:   X:/Desktop/courses/EC551/project/test/tb_moneybag.v
// Project Name:  blk_mem_gen_v7_3
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: money_bag
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_moneybag;

	// Inputs
	reg clk;
	reg rst;
	reg wr;
	reg [15:0] data_in;
	reg ACK;
	reg NACK;

	// Outputs
	wire req;
	wire req_type;
	wire [7:0] req_content;
	wire [15:0] status;

	// Instantiate the Unit Under Test (UUT)
	money_bag uut (
		.clk(clk), 
		.rst(rst), 
		.wr(wr), 
		.data_in(data_in), 
		.ACK(ACK), 
		.NACK(NACK), 
		.req(req), 
		.req_type(req_type), 
		.req_content(req_content), 
		.status(status)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		wr = 0;
		data_in = 0;
		ACK = 0;
		NACK = 0;

		// Wait 100 ns for global reset to finish
		#10;
		rst=0;
		#10;
		wr=1; data_in=16'b0110101011010111;
		#2 wr=0;
		#4 NACK=1;
		#2 NACK=0;
		#20 ACK=1;
		#2 ACK=0;
		#20 ACK=1;
		#2 ACK=0;
		#20 NACK=1;
		#2 NACK=0;


		// Add stimulus here

	end
   	always begin
			#1 clk = ~clk;
	end
      
endmodule

