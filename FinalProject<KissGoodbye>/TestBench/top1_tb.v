`timescale 1ns/1ps
module top1_tb;

 	parameter DATA_WIDTH=4;
	parameter ADDR_WIDTH=8;
	parameter DATA_DEPTH=150;
	parameter UP=2'b00;
	parameter DOWN=2'b01;
	parameter LEFT=2'b10;
	parameter RIGHT=2'b11;
	reg clk;
	reg rst;
	reg fire;
	reg [1:0] keyboard;
	reg sample;
	
	wire [DATA_WIDTH-1:0] ram_data_out;
	wire [DATA_WIDTH-1:0] ram_data_in;
	wire ram_wr;
	wire [ADDR_WIDTH-1:0] ram_addr;
	wire [9:0] score;
	wire game_over;
	

	
	top1 
	#(
	.DATA_WIDTH(DATA_WIDTH),
	.DATA_DEPTH(DATA_DEPTH),
	.ADDR_WIDTH(ADDR_WIDTH)
	)
	top1_inst(
		.rst(rst),
		.clk(clk),
		.fire(fire),
		.keyboard(keyboard),
		.sample(sample),
		.ram_data_out(ram_data_out),
		.ram_data_in(ram_data_in),
		.ram_wr(ram_wr),
		.ram_addr(ram_addr),
		.score(score),
		.game_over(game_over)		
	);
	
	ram 
	#(
		.DATA_WIDTH(DATA_WIDTH),
		.DATA_DEPTH(DATA_DEPTH),
		.ADDR_WIDTH(ADDR_WIDTH)
	)
	ram_inst(
		.clk(clk),
		.addr(ram_addr),
		.data_in(ram_data_in),
		.wr(ram_wr),
		.data_out(ram_data_out)
	);
	
	always #5 clk=~clk;
	initial begin
		clk=0;
		rst=1;
		sample=0;
	#100 rst=0;
	
	#1000 keyboard=RIGHT;
	#1050 sample=1;
	#1100 sample=0;
	
	#1250 sample=1;
	#1300 sample=0;
	
	#1450 sample=1;
	#1500 sample=0;
	
	#1650 sample=1;
	#1700 sample=0;
	
	#1850 sample=1;
	#1900 sample=0;
	
	#2050 sample=1;
	#2100 sample=0;
	

	#2250 sample=1;
	#2300 sample=0;
	
	#2450 sample=1;
	#2500 sample=0;
		#2450 sample=1;
	#2500 sample=0;
		#2450 sample=1;
	#2500 sample=0;
	#2200 keyboard=LEFT;
	#2650 sample=1;
	#2700 sample=0;
	
	#2850 sample=1;
	#2900 sample=0;
	
	end
endmodule
