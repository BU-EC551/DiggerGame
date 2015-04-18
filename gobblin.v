`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:16:10 03/22/2015 
// Design Name: 
// Module Name:    gobblin 
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
module gobblin(Clk,rst, Digx, Digy, GameOver,x,y, pmove,up,down,left,right
    );
	 input Clk,rst;
	 input [3:0] Digx,Digy;
	 input [2:0] up,down,left,right;
	 output reg [3:0] x,y;	//location
	 output reg GameOver;
	 output reg [2:0] pmove;
	 reg [3:0] xtar,ytar;
	 

	 initial x=4'd0;
	 initial y=4'd14;
	 initial xtar=4'd0;
	 initial ytar=4'd14;
	 initial GameOver=1'b0;
	 
	 always @(posedge Clk) begin			//Gameover condition, same spot
		if (rst)	GameOver<=1'b0;
		else if ((Digx==x)&&(Digy==y)) GameOver<=1'b1;
	 end 
	
//moving logic
	 always @(posedge Clk) begin 
		if (rst) begin
	  		xtar<=4'd0;
			ytar<=4'd14;
		end else 
//	  if (GameOver==0)
	  case (pmove)
		// first consider 3 direction to reduce distance, prefer previous direction
		3'b000: if ((Digx<x)&&(up==0)) begin xtar<=x-1; pmove<=3'b000; end
			else if ((Digy<y)&&(left==0)) begin ytar<=y-1;pmove<=3'b010; end
			else if ((Digy>y)&&(right==0)) begin ytar<=y+1;pmove<=3'b011; end
			//else if ((Digx>x)&&(down==0)) begin xtar<=x+1; pmove<=3'b001; end
			//no path towards digger, find any available path
			else if (up==0) begin xtar<=x-1;pmove<=3'b000; end
			else if (left==0) begin ytar<=y-1;pmove<=3'b010; end
			else if (right==0) begin ytar<=y+1;pmove<=3'b011; end
			else if (down==0) begin xtar<=x+1; pmove<=3'b001; end  //turn back least wanted
			else begin xtar<=x;			//initial condition
						ytar<=y;
			end
		3'b001: if ((Digx>x)&&(down==0)) begin xtar<=x+1; pmove<=3'b001; end
			else if ((Digy<y)&&(left==0)) begin ytar<=y-1;pmove<=3'b010; end
			else if ((Digy>y)&&(right==0)) begin ytar<=y+1;pmove<=3'b011; end
//			else if ((Digx<x)&&(up==0)) begin xtar<=x-1;pmove<=3'b000; end
			//no path towards digger, find any available path
			else if (down==0) begin xtar<=x+1; pmove<=3'b001; end
			else if (left==0) begin ytar<=y-1;pmove<=3'b010; end
			else if (right==0) begin ytar<=y+1;pmove<=3'b011; end
			else if (up==0) begin xtar<=x-1;pmove<=3'b000; end
			else begin xtar<=x;			//initial condition
						ytar<=y;
			end
		3'b010: if ((Digy<y)&&(left==0)) begin ytar<=y-1; pmove<=3'b010; end
			else if ((Digx<x)&&(up==0)) begin xtar<=x-1;pmove<=3'b000; end
			else if ((Digx>x)&&(down==0)) begin xtar<=x+1; pmove<=3'b001; end
//			else if ((Digy>y)&&(right==0)) begin ytar<=y+1;pmove<=3'b011; end
			//no path towards digger, find any available path
			else if (left==0) begin ytar<=y-1;pmove<=3'b010; end
			else if (up==0) begin xtar<=x-1;pmove<=3'b000; end
			else if (down==0) begin xtar<=x+1; pmove<=3'b001; end
			else if (right==0) begin ytar<=y+1;pmove<=3'b011; end
			else begin xtar<=x;			//initial condition
						ytar<=y;
			end
		3'b011: if ((Digy>y)&&(right==0)) begin ytar<=y+1; pmove<=3'b011; end
				else 	if ((Digx<x)&&(up==0)) begin xtar<=x-1;pmove<=3'b000; end
			else if ((Digx>x)&&(down==0)) begin xtar<=x+1; pmove<=3'b001; end
//			else if ((Digy<y)&&(left==0)) begin ytar<=y-1;pmove<=3'b010; end
			//no path towards digger, find any available path
			else if (right==0) begin ytar<=y+1;pmove<=3'b011; end
			else if (up==0) begin xtar<=x-1;pmove<=3'b000; end
			else if (down==0) begin xtar<=x+1; pmove<=3'b001; end
			else if (left==0) begin ytar<=y-1;pmove<=3'b010; end
			else begin xtar<=x;			//initial condition
						ytar<=y;
			end
		default: 
			if ((Digx<x)&&(up==0)) begin xtar<=x-1;pmove<=3'b000; end
			else if ((Digx>x)&&(down==0)) begin xtar<=x+1; pmove<=3'b001; end
			else if ((Digy<y)&&(left==0)) begin ytar<=y-1;pmove<=3'b010; end
			else if ((Digy>y)&&(right==0)) begin ytar<=y+1;pmove<=3'b011; end
			//no path towards digger, find any available path
			else if (up==0) begin xtar<=x-1;pmove<=3'b000; end
			else if (down==0) begin xtar<=x+1; pmove<=3'b001; end
			else if (left==0) begin ytar<=y-1;pmove<=3'b010; end
			else if (right==0) begin ytar<=y+1;pmove<=3'b011; end
			else begin xtar<=x;			//initial condition
						  ytar<=y;
			end
	  endcase
	 end
	 
	 always @(negedge Clk) begin
	 	if (rst) begin
			x<=4'd0;
			y<=4'd14;
		end else if (GameOver==0)
		begin
			x<=xtar;
			y<=ytar;
		end
	 end
	 


endmodule
