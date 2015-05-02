`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:47:02 03/23/2015 
// Design Name: 
// Module Name:    vgacolor 
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

module vgacolor(
                clk5m, clk100m, clk25m, clk100hz, clk_vgaram,
					 vgaram_we,
					 vgaram_addra,
					 vgaram_dina,
					 vgaram_douta,
					 
					 hen, ven,
					 hpos, vpos,
                dmov,
                gmov,					 
					 colors,
					 dig_posx,
					 dig_posy,
					 gob_posx,
					 gob_posy,
					 score,
					 game_over,
					 		mb0_exist,
							mb1_exist,
							mb2_exist,
							mb3_exist,
							mb4_exist
					 );
					 
	input        clk5m;	
	input        clk100m;
   input        clk25m;
   input        clk100hz;
	input        clk_vgaram;
	input    	 vgaram_we;
	input [7:0]	 vgaram_addra;
	input [3:0]	 vgaram_dina;
	input [9:0]  score;
	input        game_over;
	input [1:0] mb0_exist;
	input [1:0] mb1_exist;
	input [1:0] mb2_exist;
	input [1:0] mb3_exist;
	input [1:0] mb4_exist;
	
   input [10:0]  hpos;
   input [10:0]  vpos;
	input        hen;
	input        ven;
	input wire [2:0]  dmov;
	input [2:0]  gmov;

   output [11:0] colors;
	output [3:0]  vgaram_douta;		
	////////////////////////////////////////////
	////////////output for game ctl logic///////
	////////////////////////////////////////////
	output  reg	[9:0]   dig_posx;
	output  reg [9:0]   dig_posy;
	output  reg	[9:0]   gob_posx;
	output  reg [9:0]   gob_posy;
	
	always @ (posedge clk25m) begin
			dig_posx <= hmov;
			dig_posy <= vmov;
			gob_posx <= hmov1;
			gob_posy <= vmov1;			
	end
	
	
	reg [10:0]  main_hpos;
   reg [10:0]  main_vpos;
	
	reg [10:0]  bn_hpos;
   reg [10:0]  bn_vpos;
	
   reg [9:0]        hmov;
   reg [9:0]        vmov;
	reg [9:0]        hmov1;
   reg [9:0]        vmov1;

	reg [11:0]   bgcolors;
   reg [11:0]   usercolors;
	reg [11:0]   syscolors1;

	integer i;
	integer j;
	integer ij;
	wire  [3:0]  doutb;
	reg  [7:0]  addrb;
	
	initial begin 
		hmov=10'd400;
		vmov=10'd585;
		hmov1 = 10'd784;
      vmov1 = 10'd24;
		main_hpos = 10'd0;
		main_vpos = 10'd0;
		bn_hpos = 10'd0;
		bn_vpos = 10'd0;
	end
	
/////////////////////////////////////////////////////////////////////
/*******************back ground ram instantiation ******************/  
/////////////////////////////////////////////////////////////////////
bg_ram ram0 (
  .clka(clk100m), // input clka
  .rsta(), // input rsta
  .wea(vgaram_we), // input [0 : 0] wea
  .addra(vgaram_addra), // input [7 : 0] addra
  .dina(vgaram_dina), // input [3 : 0] dina
  .douta(vgaram_douta), // output [3 : 0] douta
  .clkb(clk25m), // input clkb
  .rstb(), // input rstb
  .web(), // input [0 : 0] web
  .addrb(addrb), // input [7 : 0] addrb
  .dinb(), // input [3 : 0] dinb
  .doutb(doutb) // output [3 : 0] doutb
);
/////////////////////////////////////////////////////////////////////
/*********************** roms instantiation ************************/  
/////////////////////////////////////////////////////////////////////	
	reg [11:0] bgrom_addr;
	wire [11:0] bgrom0_data;
	wire [11:0] bgrom1_data;
	wire [11:0] bgrom2_data;
	wire [11:0] bgrom3_data;
	wire [11:0] bgrom4_data;
	wire [11:0] bgrom5_data;
	wire [11:0] bgrom68_data;
	wire [11:0] bgrom9_data;
	wire [11:0] bgrom14_data;
	wire [11:0] bgrom15_data;
	
	reg  [15:0] bannerom_addr;
	wire [11:0] bannerom_data;

	wire [11:0] gorom_data;
	wire [11:0] winrom_data;
	
	reg [3:0] number1;
	reg [3:0] number2;
	reg [3:0] number3;
	
	reg [10:0]  num_hpos;
	reg [10:0]  num_vpos;
	reg [12:0]  num_addr;
	wire [11:0] digitrom;		
	wire [11:0] bgromshit_data;
bgrom0 bgrom0 (
  .a(bgrom_addr), // input [11 : 0] a
  .spo(bgrom0_data) // output [11 : 0] spo
);

bgrom1 bgrom1 (
  .a(bgrom_addr), // input [11 : 0] a
  .spo(bgrom1_data) // output [11 : 0] spo
);

bgrom2 bgrom2 (
  .a(bgrom_addr), // input [11 : 0] a
  .spo(bgrom2_data) // output [2 : 0] spo
);

bgrom3 bgrom3 (
  .a(bgrom_addr), // input [11 : 0] a
  .spo(bgrom3_data) // output [2 : 0] spo
);

bgrom4 bgrom4 (
  .a(bgrom_addr), // input [11 : 0] a
  .spo(bgrom4_data) // output [2 : 0] spo
);

bgrom5 bgrom5 (
  .a(bgrom_addr), // input [11 : 0] a
  .spo(bgrom5_data) // output [2 : 0] spo
);

bgrom68 bgrom68 (
  .a(bgrom_addr), // input [11 : 0] a
  .spo(bgrom68_data) // output [2 : 0] spo
);

bgrom9 bgrom9 (
  .a(bgrom_addr), // input [11 : 0] a
  .spo(bgrom9_data) // output [2 : 0] spo
);

bgrom14 bgrom14 (
  .a(bgrom_addr), // input [11 : 0] a
  .spo(bgrom14_data) // output [2 : 0] spo
);

bgrom15 bgrom15 (
  .a(bgrom_addr), // input [11 : 0] a
  .spo(bgrom15_data) // output [2 : 0] spo
);

bannerom bnrom0 (
  .a(bannerom_addr), // input [15 : 0] a
  .spo(bannerom_data) // output [11 : 0] spo
);

digit_rom dgrom0 (
  .a(num_addr), // input [12 : 0] a
  .spo(digitrom) // output [11 : 0] spo
);

gorom gorom0 (
  .a(bannerom_addr), // input [15 : 0] a
  .spo(gorom_data) // output [11 : 0] spo
);

winrom winrom0 (
  .a(bannerom_addr), // input [15 : 0] a
  .spo(winrom_data) // output [11 : 0] spo
);

shitrom shitrom0(
  .a(bgrom_addr), // input [10 : 0] a
  .spo(bgromshit_data) // output [11 : 0] spo
);
/////////////////////////////////////////////////////////////////////
/***************** bgcolors -- to draw the background **************/  
/////////////////////////////////////////////////////////////////////
reg   [5:0]  row;
reg   [5:0]  col;
reg   [5:0]  sub_row;
reg   [5:0]  sub_col;

reg   [5:0]  bnrow;
reg   [5:0]  bncol;

always @(posedge clk25m) begin

////////////////////////////////////////////////////
//////////////   Map and objects ///////////////////
////////////////////////////////////////////////////

/*****************************
 0 --	blank (leave black)
 1 -- left digger
 2 -- right digger
 3 -- up digger
 4 -- down digger
 5 -- bullet
 6~8 -- goblin (bgrom68)
 9 -- diamond
 10~14 -- money bag (bgrom14)
 15 -- wall
 ****************************/
 
	if ((hpos > 85) & 
		 (hpos < 716) & 
		 (vpos > 119) & 
		 (vpos < 540)) begin
				 
		main_hpos <= (hpos - 85);
		main_vpos <= (vpos - 120);
		
		row <= (main_vpos/42);
		col <= (main_hpos/42);
		sub_row <= (main_vpos%42);
		sub_col <= (main_hpos%42);
		
			addrb <= {2'b00,row}*15+{2'b00,col};
			bgrom_addr <= (sub_row*42)+sub_col;	
			
			case(doutb)
				4'd0 : bgcolors <= bgrom0_data;
				4'd1 : bgcolors <= bgrom1_data;				
				4'd2 : bgcolors <= bgrom2_data;			
				4'd3 : bgcolors <= bgrom3_data;		
				4'd4 : bgcolors <= bgrom4_data;		
			   4'd5 : bgcolors <= bgrom5_data;	
				4'd6 : bgcolors <= bgrom68_data;		
				4'd7 : bgcolors <= bgrom68_data;		
				4'd8 : bgcolors <= bgrom68_data;		
				4'd9 : bgcolors <= bgrom9_data;	
				4'd10 : begin if (mb0_exist==2'b11) bgcolors<=bgromshit_data; else 
							bgcolors <= bgrom14_data;end
				4'd11 : begin if (mb1_exist==2'b11) bgcolors<=bgromshit_data; else 
							bgcolors <= bgrom14_data;end			
				4'd12 : begin if (mb2_exist==2'b11) bgcolors<=bgromshit_data; else 
							bgcolors <= bgrom14_data;end			
				4'd13 : begin if (mb3_exist==2'b11) bgcolors<=bgromshit_data; else 
							bgcolors <= bgrom14_data;end		
				4'd14 : begin if (mb4_exist==2'b11) bgcolors<=bgromshit_data; else 
							bgcolors <= bgrom14_data;end		
			   4'd15 : bgcolors <= bgrom15_data;	
				endcase	
	end
	
///////////////////////////////////////////////////
///////////////  display frames ///////////////////
///////////////////////////////////////////////////

////////////// left frame /////////////////////////

	else if (((hpos > 75) & (hpos < 725) & (vpos > 110) & (vpos < 120)) |
				((hpos > 75) & (hpos < 725) & (vpos > 540) & (vpos < 550)) |
				((hpos > 75) & (hpos < 85) & (vpos > 110) & (vpos < 550)) |
				((hpos > 715) & (hpos < 725) & (vpos > 110) & (vpos < 550))) 
 
		  begin
				bgcolors <= 12'b101000001010;			
	     end

/////////////////////////////////////////////////
//////////////  display banner     //////////////
/////////////////////////////////////////////////
  else if ((hpos > 85) & (hpos < 600) & (vpos > 40) & (vpos < 101)) begin
			bn_hpos <= (hpos - 86);
			bn_vpos <= (vpos - 41);
			bannerom_addr <= (bn_vpos*600+bn_hpos);
			if (game_over) begin
				bgcolors <= gorom_data;
			end
			else if (score>=300) begin
				bgcolors <=winrom_data;
			end
			else begin
					bgcolors <= bannerom_data;
			end
	     end
		  
//////////////////////////////////////////////////
//////////////  Score Display 			 //////////
//////////////////////////////////////////////////
	else if ((hpos > 621) & (hpos < 645) & (vpos > 60) & (vpos < 84)) begin
		number1<=(score/10'd100);
		num_hpos<= (hpos-621);
		num_vpos<= (vpos-60);
		num_addr<= 576*number1+num_vpos*24+num_hpos;
		bgcolors <= digitrom;
	end
	else if ((hpos > 651) & (hpos < 675) & (vpos > 60) & (vpos < 84)) begin
		number2<=((score/10'd10)%10'd10);
		num_hpos<= (hpos-651);
		num_vpos<= (vpos-60);
		num_addr<= 576*number2+num_vpos*24+num_hpos;
		bgcolors <= digitrom;
	end
	else if ((hpos > 681) & (hpos < 705) & (vpos > 60) & (vpos < 84)) begin
		number3<=(score%10'd10);
		num_hpos<= (hpos-681);
		num_vpos<= (vpos-60);
		num_addr<= 576*number3+num_vpos*24+num_hpos;
		bgcolors <= digitrom;
	end
	
//////////////////////////////////////////////////
//////////////  other black backgrounds //////////
//////////////////////////////////////////////////
	else
		bgcolors <= 12'd0;
end

		
/////////////////////////////////////////////////////////////////////
/************************* Colors output ***************************/  
/////////////////////////////////////////////////////////////////////

    assign colors[0] = (bgcolors[0] & ven & hen);
    assign colors[1] = (bgcolors[1] & ven & hen);
    assign colors[2] = (bgcolors[2] & ven & hen);
    assign colors[3] = (bgcolors[3] & ven & hen);
    assign colors[4] = (bgcolors[4] & ven & hen);
    assign colors[5] = (bgcolors[5] & ven & hen);
	 assign colors[6] = (bgcolors[6] & ven & hen);
    assign colors[7] = (bgcolors[7] & ven & hen);
    assign colors[8] = (bgcolors[8] & ven & hen);
    assign colors[9] = (bgcolors[9] & ven & hen);
    assign colors[10] = (bgcolors[10] & ven & hen);
    assign colors[11] = (bgcolors[11] & ven & hen);

endmodule
