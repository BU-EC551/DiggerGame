`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:27:33 04/28/2015
// Design Name:   goblin1
// Module Name:   X:/Desktop/courses/EC551/project/test/tb_goblin.v
// Project Name:  blk_mem_gen_v7_3
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: goblin1
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_goblin;

	// Inputs
	reg clk;
	reg rst;
	reg wr;
	reg [15:0] data_in;
	reg ACK;
	reg NACK;
	reg [15:0] digger_status;

	// Outputs
	wire req;
	wire [1:0] req_type;
	wire [7:0] req_content;
	wire GameOver;

	// Instantiate the Unit Under Test (UUT)
	goblin1 uut (
		.clk(clk), 
		.rst(rst), 
		.wr(wr), 
		.data_in(data_in), 
		.ACK(ACK), 
		.NACK(NACK), 
		.digger_status(digger_status), 
		.req(req), 
		.req_type(req_type), 
		.req_content(req_content), 
		.GameOver(GameOver)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		wr = 0;
		data_in = 0;
		ACK = 0;
		NACK = 0;
		digger_status = 16'b0101110111001111;

		// Wait 100 ns for global reset to finish
		#10;
		rst=0;
		
		#50;
		NACK=1;
		#10;
		NACK=0;
		#10;
		ACK=1;
		data_in=16'b0111100000100100;
		wr=1;
		#2;
		ACK=0;
		wr=0;
		#20;
		NACK=1;
		#2; NACK=0;
		#10;
		ACK=1;
		data_in=16'b0011100001001111;
		#2;ACK=0;
		#3;
		ACK=1;
		data_in=16'b0000000000000000;
		#2;ACK=0;
		#3; NACK=1;
		#2 NACK=0;
		#10 ACK=1;wr=1;data_in=16'b0111010000100100;
		#2 ACK=0;wr=0;
		
		#50 ACK=1;wr=1;data_in=16'b0000000000000000;
		#2 ACK=0;wr=0;
        
		// Add stimulus here

	end
      
	always begin
			#1 clk = ~clk;
	end
endmodule

