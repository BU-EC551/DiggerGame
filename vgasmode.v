`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:46:58 03/23/2015 
// Design Name: 
// Module Name:    vgasmode 
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
module vgasmode(clk25m,hen, ven,colors3, colors);
   input            clk25m;

   input            hen;
   input            ven;

   input [11:0]      colors3;
   output [11:0]     colors;
   
   
   reg [11:0]        colorstmp;

   always @(posedge clk25m)
      colorstmp <= colors3;

   assign colors[0] = colorstmp[0] & ven & hen;
   assign colors[1] = colorstmp[1] & ven & hen;
   assign colors[2] = colorstmp[2] & ven & hen;
   assign colors[3] = colorstmp[3] & ven & hen;
   assign colors[4] = colorstmp[4] & ven & hen;
   assign colors[5] = colorstmp[5] & ven & hen;
	assign colors[6] = colorstmp[6] & ven & hen;
   assign colors[7] = colorstmp[7] & ven & hen;
   assign colors[8] = colorstmp[8] & ven & hen;
   assign colors[9] = colorstmp[9] & ven & hen;
   assign colors[10] = colorstmp[10] & ven & hen;
   assign colors[11] = colorstmp[11] & ven & hen;
   
endmodule
