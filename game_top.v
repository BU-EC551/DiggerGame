`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:25:05 04/11/2015 
// Design Name: 
// Module Name:    game_top 
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
module game_top(
			input clk100mhz,
			output r0,r1,r2,r3,
			output g0,g1,g2,g3,
			output b0,b1,b2,b3,
			output vga_vs,
			output vga_hs,
			input  ps2_clk, 
			input  ps2_data, 
			input  rst_key_n,
			output key_pressed,
			input  dmov,
			input  gmov
    );

// wire declarations
wire vga_clk;
//wire key_clk;
wire sys_clk;
//wire [2:0] key;
//reg [2:0] dmov;
wire key_pressed;

// Instantiate the module

//always @ (posedge sys_clk) begin
//	if(key_pressed) begin
//		dmov <= key;
//	end
//	else 
//		dmov <= 3'b0;
//end

clk_gen system_clk
   (// Clock in ports
    .CLK_IN1(clk100mhz),      // IN
    // Clock out ports
    .CLK_OUT1(vga_clk),     // OUT
    .CLK_OUT2(),     // OUT
    .CLK_OUT3(sys_clk)
	 );    // OUT
	 
	 
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
    .dmov(dmov),
	 .gmov(gmov)
    );

endmodule
