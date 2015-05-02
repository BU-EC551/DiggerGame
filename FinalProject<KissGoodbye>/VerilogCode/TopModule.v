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
		//output led0,
		input ps2_clk,
		input ps2_data,
		input rst_key_n,
		input key0, key1, key2,
		input rst,
		input fire
		
    );
	 
	wire clk_vgaram;
	wire clk_key;

	
	wire vga_clk;
	wire vga40m;

	wire sys_clk;
	wire [1:0] keyboard;
	//assign keyboard = {key1,key0};
	wire rst;
	wire sample;
	
	wire game_over;
///////////////////////////////////////////////
///////////////////wires to game ctl logic/////
///////////////////////////////////////////////
	wire logic_clk;
	wire [9:0] 	dig_posx;
	wire [9:0] 	dig_posy;
	wire [9:0] 	gob_posx;
	wire [9:0] 	gob_posy;
	wire [2:0]  gmov;
	
	wire [9:0] score;
	
	wire ram_wr;
	wire [3:0] ram_data_out;
	wire [3:0] ram_data_in;
	wire [7:0] ram_addr;
	wire [1:0] mb0_exist;
	wire [1:0] mb1_exist;
		wire [1:0] mb2_exist;
	wire [1:0] mb3_exist;
	wire [1:0] mb4_exist;

	/*
	 .CLK_OUT1 100mhz
    .CLK_OUT2 25.18mhz
    .CLK_OUT3 100mhz
    .CLK_OUT4 100mhz
	 .CLK_OUT5 40mhz
	 */
	 
  clk_gen system_clk
   (// Clock in ports
    .CLK_IN1(clk100mhz),      // IN
    // Clock out ports
    .CLK_OUT1(vga_clk),     // OUT
    .CLK_OUT2(clk_vgaram),     // OUT
    .CLK_OUT3(clk_key),
    .CLK_OUT4(logic_clk),
	 .CLK_OUT5(vga40m)
	 );    // OUT
	 
	top1 instance_name (
    .clk(logic_clk), 
    .rst(rst), 
    .fire(fire), 
    .keyboard(keyboard), 
    .sample(sample), 
    .ram_data_out(ram_data_out), 
    .ram_data_in(ram_data_in), 
    .ram_wr(ram_wr), 
    .ram_addr(ram_addr), 
    .score(score), 
    .game_over(game_over),
	 .mb0_exist(mb0_exist),
	 .mb1_exist(mb1_exist),
	 .mb2_exist(mb2_exist),
	 .mb3_exist(mb3_exist),
	 .mb4_exist(mb4_exist)
    );
 
	 //VGA	
	vgacontroller vga0 (
    .clk100m(vga_clk),
	 .clk40m(vga40m),
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
	 .dig_posx(dig_posx),
	 .dig_posy(dig_posy),
	 .gob_posx(gob_posx),
	 .gob_posy(gob_posy),
    .dmov(Key),
	 .gmov(gmov),
	 .vgaram_we(ram_wr),
	 .vgaram_addra(ram_addr),
	 .vgaram_dina(ram_data_in),
	 .vgaram_douta(ram_data_out),
	 .score(score),
	 .game_over(game_over),
	 .mb0_exist(mb0_exist),
	 .mb1_exist(mb1_exist),
	 .mb2_exist(mb2_exist),
	 .mb3_exist(mb3_exist),
	 .mb4_exist(mb4_exist)
	 );
	 
	// keyboard
/*	ps2_key key0 (
    .clk100mhz(clk_key), 
    .rst_n(rst_key_n), 
    .ps2_clk(ps2_clk), 
    .ps2_data(ps2_data), 
    .key_pressed(key_pressed), 
    .reset(rst), //rst
    .key_val(Key)
    );*/
	 
	 translator ps2 (
    .clk_key(ps2_clk), 
    .data(ps2_data), 
    .sample(sample), 
    .keyboard(keyboard)
    );
	 
endmodule
