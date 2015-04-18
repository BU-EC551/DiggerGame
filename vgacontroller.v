`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:47:45 03/23/2015 
// Design Name: 
// Module Name:    vgacontroller 
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
module vgacontroller(clk100m, 
							hs, vs, 
							r0, r1, r2, r3, 
							g0, g1, g2, g3,
							b0, b1, b2, b3,
							dmov, gmov
							);
							
   input      clk100m;
	input  [2:0] dmov;
	input  [2:0] gmov;
   output     hs;
   output     vs;
	//12-bit rgb
   output     r0;
   output     r1;
   output     r2;
   output     r3;
   output     g0;
   output     g1;
   output     g2;
   output     g3;
   output     b0;
   output     b1;
   output     b2;
   output     b3;
   
   wire       clk25m;
   wire       clk1hz;
   wire       clk100hz;
	wire       clk5m;
   wire [9:0] vcnt;
   wire [9:0] hcnt;
   wire       ven;
   wire       hen;
   wire [11:0] colors;
   wire [5:0] colors3;
   wire [4:0] bt;
	
   //assign bt = {bt4, bt3, bt2, bt1, bt0};
   assign {r3, r2, r1, r0, g3, g2, g1, g0, b3, b2, b1, b0} = colors;
	
   
	clock clock_port_map(.clk50m(clk100m), 
	                     .clk25m(clk25m), 
								.clk100hz(clk100hz), 
								.clk1hz(clk1hz), 
								.clk5m(clk5m)
								);
   
   
   pixelcnt pixelcnt_port_map(.clk25m(clk25m), 
	                           .hcntout(hcnt), 
										.vcntout(vcnt)
										);
   
   
   vgasig vgasig_port_map(.clk25m(clk25m), 
	                       .hcnt(hcnt), 
								  .vcnt(vcnt), 
								  .hsync(hs), 
								  .vsync(vs), 
								  .henable(hen), 
								  .venable(ven)
								  );
   
   
   vgacolor vgacolor_port_map(.clk5m(clk5m), .clk25m(clk25m), .clk100hz(clk100m), 
	                           .hen(hen), .ven(ven), .hpos(hcnt), .vpos(vcnt),
										.dmov(dmov), .gmov(gmov), 
										.colors(colors));
   
endmodule


