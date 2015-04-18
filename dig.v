`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:59:42 03/21/2015 
// Design Name: 
// Module Name:    dig 
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
 module dig(Clk, rst, Key, x, y, GameOver,  EnScore, move,tar
    );
	 input Clk, rst, GameOver;
	 input [2:0] Key;
	 input [2:0] tar;
	 output reg [3:0] x,y;	//location
	 output reg [1:0] EnScore;
	 output reg [2:0] move;
	 reg [2:0] val;
	 
	 reg [3:0] xtar,ytar;
	 
	 initial x=4'd6;
	 initial y=4'd7;
//	 initial val=3'd0;
	 initial xtar=4'd6;
	 initial ytar=4'd7;
	 
	 always @(posedge Clk) begin
		if (rst) begin
			xtar<=4'd6;
			ytar<=4'd7;
		end else	if ((Key==3'b001) && (x>0)) begin xtar<=x-1; move<=1;end	//up 1
		else if ((Key==3'b010) && (x<9)) begin xtar<=x+1;move<=2;end	//down 2
		else if ((Key==3'b011) && (y>0)) begin ytar<=y-1;move<=3;end	//left 3
		else if ((Key==3'b100) && (y<14)) begin ytar<=y+1;	move<=4;end//right 4
		else begin
			xtar<=x;
			ytar<=y;
			move<=3'b0;
		end
	 end
	 
	 always @(*) begin					//set EnScore, score module to add up
		if (GameOver==0) begin 
			if (tar==4) EnScore<=2'd1;			// diamond
			else if (tar==6) EnScore<=2'd2;		//money bag
			else EnScore<=2'd0;					//nothing, do not add score
		end else EnScore<=2'd0;
	 end
	 
	 always @(negedge Clk) begin		//update new location
		if (rst) begin
			x<=4'd6;
			y<=4'd7;
		end else	if (GameOver==0) begin
			x<=xtar;
			y<=ytar;
		end
	 end
	 
endmodule
