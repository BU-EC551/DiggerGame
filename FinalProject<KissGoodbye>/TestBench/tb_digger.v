`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:36:27 04/28/2015
// Design Name:   digger
// Module Name:   X:/Desktop/courses/EC551/project/test/tb_digger.v
// Project Name:  blk_mem_gen_v7_3
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: digger
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_digger;

	// Inputs
	reg clk;
	reg rst;
	reg [1:0] keyboard;
	reg sample;
	reg ACK;
	reg NACK;
	reg wr;
	reg [15:0] data_in;

	// Outputs
	wire req;
	wire req_type;
	wire [7:0] req_content;
	wire [15:0] status;
	wire [15:0] status_to_bullet;

	// Instantiate the Unit Under Test (UUT)
	digger uut (
		.clk(clk), 
		.rst(rst), 
		.keyboard(keyboard), 
		.sample(sample), 
		.ACK(ACK), 
		.NACK(NACK), 
		.wr(wr), 
		.data_in(data_in), 
		.req(req), 
		.req_type(req_type), 
		.req_content(req_content), 
		.status(status), 
		.status_to_bullet(status_to_bullet)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		keyboard = 0;
		sample = 0;
		ACK = 0;
		NACK = 0;
		wr = 0;
		data_in = 0;

		// Wait 100 ns for global reset to finish
		#10;
		rst=0;
		#20;
		keyboard = 2'b00;
		sample=1;
		#10 sample=0;
		#20
		ACK=1;
		wr=1;
		data_in=16'b0101111000001111;
		#10 sample=1; ACK=0; wr=0;
		#20
		sample=0;
		ACK=1;
		wr=1;
		data_in=16'b0101111000001111;
		#10;
		sample=1; ACK=0;wr=0;
		keyboard=2'b11;
		data_in=0;
		#10 
		ACK=1;
		wr=1;
		data_in=16'b0101110111001111;
		
        
		// Add stimulus here

	end
	
	always begin
			#1 clk = ~clk;
	end
      
endmodule

