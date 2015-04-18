`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:18:57 03/23/2015 
// Design Name: 
// Module Name:    TopModule 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module TopModule(
		
		//input clk_in, //out,an, rst,
		input clk100mhz,
		output r0,r1,r2,r3,
		output g0,g1,g2,g3,
		output b0,b1,b2,b3,
		output vga_vs,
		output vga_hs,
		input ps2_clk,
		input ps2_data,
		input rst_key_n
		
    );
	 
	wire clk_in;
	wire clk_key;
	//input [2:0] Key;
	//output [3:0] an;
	//output [7:0] out;
	
	wire vga_clk;
	//wire key_clk;
	wire sys_clk;
	
	wire [3:0] Digx,Digy,Gobx,Goby;
	wire GameOver;
	wire [1:0] EnScore;
	wire Clk,Clk_7seg;
	wire [15:0] score;
	wire [2:0] Gmove,Dmove;
	wire [2:0] tar;
	wire [2:0] up,down,left,right;
	wire [2:0] Key;
	wire clk100;
	wire [2:0] Gmov,Dmov;
	reg NewClk,LongF1,LongF2;
	
	//Clk divider	comment for simulation only. 
	clockdivider ClkDiv (
    .clk_in(clk_in), 
    .clk_out(Clk), 
	 .clk100hz(clk100),
    .clk_7seg(Clk_7seg)
    );
	 
	//
  clk_gen system_clk
   (// Clock in ports
    .CLK_IN1(clk100mhz),      // IN
    // Clock out ports
    .CLK_OUT1(vga_clk),     // OUT
    .CLK_OUT2(clk_in),     // OUT
    .CLK_OUT3(clk_key)
	 );    // OUT
	 
	//reducing frequency of MOVE signals feeding to VGA display
	always@(posedge clk100) begin			//100hz for VGA???
		LongF1<=Clk;
		LongF2<=LongF1;
		NewClk<=LongF1&(~LongF2);
	end
	
	assign Gmov={NewClk,NewClk,NewClk}&&Gmove;
	assign Dmov={NewClk,NewClk,NewClk}&&Dmove;

	 //memory
	map memory (
	 .rst(rst),
    .Clk(Clk), 
    .Digx(Digx), 
    .Digy(Digy), 
    .Gobx(Gobx), 
    .Goby(Goby), 
    .out(tar), 
    .up(up), 
    .down(down), 
    .left(left), 
    .right(right), 
    .value(value)
    );
	 
	//Digger
	dig Digger (
	 .rst(rst),
    .Clk(Clk), 
    .Key(Key), 
    .x(Digx), 
    .y(Digy),
	 .move(Dmove),
    .GameOver(GameOver), 
    .EnScore(EnScore),
	 .tar(tar)
    );
	 
	//only 1 gob currently, need to implement a gob create (or activate) module for multi-gob (+EnGob1,2,3 wire)
	gobblin Gob1 (
	 .rst(rst),
    .Clk(Clk), 
    .Digx(Digx), 
    .Digy(Digy), 
	 .up(up), 
    .down(down), 
    .left(left), 
    .right(right), 	 
	 .pmove(Gmove),
    .GameOver(GameOver), 
    .x(Gobx), 			//location to sent to VGA, might change the output to direction
    .y(Goby)
    );
	 	 
	 //Score
	 scoreSystem Score (
    .clk(Clk), 
	 .rst(rst),
    .unit(EnScore), 
    .score(score) 
    );
	 
	 //Money bag
	 
	 
	 //7Seg
	 display_7_segment Segment7 (
	 .clk(Clk_7seg), 
    .in(score),
	 //.in({14'd0,EnScore}),
    .an(an), 
    .out(out)
	  );
	  
	 //VGA	
	vgacontroller vga0 (
    .clk100m(vga_clk),
    .hs(vga_hs), 
    .vs(vga_vs), 
    .r0(r0), 
    .r1(r1), 
    .r2(r2), 
    .r3(r3), 
    .g0(g0), 
    .g1(g1), 
    .g2(g2), 
    .g3(g3), 
    .b0(b0), 
    .b1(b1), 
    .b2(b2), 
    .b3(b3), 
    .dmov(Dmov),
	 .gmov(Gmov)
    );
	 
	// keyboard
	ps2_key key0 (
    .clk100mhz(clk_key), 
    .rst_n(rst_key_n), 
    .ps2_clk(ps2_clk), 
    .ps2_data(ps2_data), 
    .key_pressed(key_pressed), 
    .reset(), //rst
    .key_val(Key)
    );
	 
endmodule
