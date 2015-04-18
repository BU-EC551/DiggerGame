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
                clk5m, clk25m, clk100hz, 
					 hen, ven,
					 hpos, vpos,
                dmov,
                gmov,					 
					 colors
					 );
					 
	input        clk5m;				 
   input        clk25m;
   input        clk100hz;

   input [9:0]  hpos;
   input [9:0]  vpos;
	input        hen;
	input        ven;
	input wire [2:0]  dmov;
	input [2:0]  gmov;

   output [11:0] colors;
	
   reg [9:0]        hmov;
   reg [9:0]        vmov;
	reg [9:0]        hmov1;
   reg [9:0]        vmov1;
	reg [9:0]        hmov2;
   reg [9:0]        vmov2;	
	
	reg [11:0]   bgcolors;
   reg [11:0]   usercolors;
	reg [11:0]   syscolors1;

	integer i;
	integer j;
	integer ij;
	wire  [3:0]  doutb;
	reg  [6:0]  addrb;
	
	initial begin 
		hmov=10'd320;
		vmov=10'd475;
		hmov1 = 10'd624;
      vmov1 = 10'd24;
	end
	
/////////////////////////////////////////////////////////////////////
/*******************back ground ram instantiation ******************/  
/////////////////////////////////////////////////////////////////////
	
bg_ram ram0 (
  .clka(), // input clka
  .wea(), // input [0 : 0] wea
  .addra(), // input [6 : 0] addra
  .dina(), // input [3 : 0] dina
  .clkb(clk25m), // input clkb
  .addrb(addrb), // input [6 : 0] addrb
  .doutb(doutb) // output [3 : 0] doutb
);

/////////////////////////////////////////////////////////////////////
/*********************** roms instantiation ************************/  
/////////////////////////////////////////////////////////////////////
	reg [9:0] digrom_addr;
	wire [2:0] digrom_data;

	reg [9:0] gobrom_addr;
	wire [2:0] gobrom_data;
	
	reg [11:0] bgrom_addr;
	wire [11:0] bgrom1_data;
	wire [11:0] bgrom2_data;
	wire [11:0] bgrom3_data;
	wire [11:0] bgrom4_data;
	wire [11:0] bgrom5_data;
	wire [11:0] bgrom6_data;
	wire [11:0] bgrom7_data;
	wire [11:0] bgrom8_data;
	wire [11:0] bgrom9_data;
	
diggerrom digrom0 (
  .a(digrom_addr), // input [9 : 0] a
  .spo(digrom_data) // output [2 : 0] spo
);
gobrom gobrom0 (
  .a(gobrom_addr), // input [9 : 0] a
  .spo(gobrom_data) // output [2 : 0] spo
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

bgrom6 bgrom6 (
  .a(bgrom_addr), // input [11 : 0] a
  .spo(bgrom6_data) // output [2 : 0] spo
);

bgrom7 bgrom7 (
  .a(bgrom_addr), // input [11 : 0] a
  .spo(bgrom7_data) // output [2 : 0] spo
);

bgrom8 bgrom8 (
  .a(bgrom_addr), // input [11 : 0] a
  .spo(bgrom8_data) // output [2 : 0] spo
);

bgrom9 bgrom9 (
  .a(bgrom_addr), // input [11 : 0] a
  .spo(bgrom9_data) // output [2 : 0] spo
);
/////////////////////////////////////////////////////////////////////
/***************** bgcolors -- to draw the background **************/  
/////////////////////////////////////////////////////////////////////
reg   [5:0]  row;
reg   [5:0]  col;
reg   [5:0]  sub_row;
reg   [5:0]  sub_col;

   always @(posedge clk25m) begin		
		row <= (vpos/48);
		col <= (hpos/64);
		sub_row <= (vpos % 48);
		sub_col <= (hpos % 64);
			addrb <= {1'b0,row}*10+{1'b0,col};
			bgrom_addr <= (sub_row*64)+sub_col;						
			case(doutb)
				4'd1 : bgcolors <= {bgrom1_data[11], bgrom1_data[10], bgrom1_data[9], bgrom1_data[8],
													  bgrom1_data[7], bgrom1_data[6], bgrom1_data[5], bgrom1_data[4], 
													  bgrom1_data[3], bgrom1_data[2], bgrom1_data[1], bgrom1_data[0]};				
				4'd2 : bgcolors <= {bgrom2_data[11], bgrom2_data[10], bgrom2_data[9], bgrom2_data[8],
													  bgrom2_data[7], bgrom2_data[6], bgrom2_data[5], bgrom2_data[4], 
													  bgrom2_data[3], bgrom2_data[2], bgrom2_data[1], bgrom2_data[0]};			
				4'd3 : bgcolors <= {bgrom3_data[11], bgrom3_data[10], bgrom3_data[9], bgrom3_data[8],
													  bgrom3_data[7], bgrom3_data[6], bgrom3_data[5], bgrom3_data[4], 
													  bgrom3_data[3], bgrom3_data[2], bgrom3_data[1], bgrom3_data[0]};		
				4'd4 : bgcolors <= {bgrom4_data[11], bgrom4_data[10], bgrom4_data[9], bgrom4_data[8],
													  bgrom4_data[7], bgrom4_data[6], bgrom4_data[5], bgrom4_data[4], 
													  bgrom4_data[3], bgrom4_data[2], bgrom4_data[1], bgrom4_data[0]};		
			   4'd5 : bgcolors <= {bgrom5_data[11], bgrom5_data[10], bgrom5_data[9], bgrom5_data[8],
													  bgrom5_data[7], bgrom5_data[6], bgrom5_data[5], bgrom5_data[4], 
													  bgrom5_data[3], bgrom5_data[2], bgrom5_data[1], bgrom5_data[0]};	
				4'd6 : bgcolors <= {bgrom6_data[11], bgrom6_data[10], bgrom6_data[9], bgrom6_data[8],
													  bgrom6_data[7], bgrom6_data[6], bgrom6_data[5], bgrom6_data[4], 
													  bgrom6_data[3], bgrom6_data[2], bgrom6_data[1], bgrom6_data[0]};		
				4'd7 : bgcolors <= {bgrom7_data[11], bgrom7_data[10], bgrom7_data[9], bgrom7_data[8],
													  bgrom7_data[7], bgrom7_data[6], bgrom7_data[5], bgrom7_data[4], 
													  bgrom7_data[3], bgrom7_data[2], bgrom7_data[1], bgrom7_data[0]};		
				4'd8 : bgcolors <= {bgrom8_data[11], bgrom8_data[10], bgrom8_data[9], bgrom8_data[8],
													  bgrom8_data[7], bgrom8_data[6], bgrom8_data[5], bgrom8_data[4], 
													  bgrom8_data[3], bgrom8_data[2], bgrom8_data[1], bgrom8_data[0]};		
				4'd9 : bgcolors <= {bgrom9_data[11], bgrom9_data[10], bgrom9_data[9], bgrom9_data[8],
													  bgrom9_data[7], bgrom9_data[6], bgrom9_data[5], bgrom9_data[4], 
													  bgrom9_data[3], bgrom9_data[2], bgrom9_data[1], bgrom9_data[0]};																							
				endcase	
	end
/////////////////////////////////////////////////////////////////////
/***************** Usercolors -- to draw the digger ****************/  
/////////////////////////////////////////////////////////////////////	
  //draw a rectangle
   always @(posedge clk25m)      
      begin		
		   if ((hpos > (hmov - 16)) & 
				 (hpos < (hmov + 16)) & 
				 (vpos > (vmov - 15)) & 
				 (vpos < (vmov + 15))) begin
				 
              digrom_addr <= (vpos+15-vmov)*32+(hpos+16-hmov);    
			     usercolors <= {digrom_data[2], digrom_data[2], digrom_data[2], digrom_data[2],
         						   digrom_data[1], digrom_data[1], digrom_data[1], digrom_data[1], 
									   digrom_data[0], digrom_data[0], digrom_data[0], digrom_data[0]};					
            	end			
			else
			   usercolors <= 12'b0;
      end
		
  //rectangle movement 
   always @(posedge clk100hz)    
      begin
            if ((hmov > 624) | (vmov > 465) | (hmov < 16) | (vmov < 15))
            begin
               hmov <= 10'd320;
               vmov <= 10'd465;
            end
            else begin
               case (dmov)
                  3'b011 :begin
                     hmov <= hmov - 1;
                  end
						3'b100 :begin
                     hmov <= hmov + 1;
                  end
						3'b010 :begin
                     vmov <= vmov - 1;
                  end
						3'b001 :begin
                     vmov <= vmov + 1;
                  end
						default : begin
						   vmov <= vmov;
							hmov <= hmov;
                  end
               endcase
				end		   
      end	

/////////////////////////////////////////////////////////////////////
/***************** Systemcolors -- to draw the goblins**************/  
/////////////////////////////////////////////////////////////////////	
  //draw a rectangle
   always @(posedge clk25m)      
      begin
        if ((hpos > (hmov1 - 16)) & (hpos < (hmov1 + 16)) & (vpos > (vmov1 - 15)) & (vpos < (vmov1 + 15))) begin
				gobrom_addr <= (vpos+15-vmov1)*32+(hpos+16-hmov1);
			   syscolors1 <= {gobrom_data[2], gobrom_data[2], gobrom_data[2], gobrom_data[2],
         						gobrom_data[1], gobrom_data[1], gobrom_data[1], gobrom_data[1], 
									gobrom_data[0], gobrom_data[0], gobrom_data[0], gobrom_data[0]};			
//	   			 gobrom_addr <= gobrom_addr + 1;	
	   			 end
        else begin
            syscolors1 <= 12'b0;
        end
      end
  //rectangle movement 
   always @(posedge clk100hz)    
      begin
           if ((hmov1 > 624) | (vmov1 > 465) | (hmov1 < 16) | (vmov1 < 5))
				begin
               hmov1 <= 10'd624;
               vmov1 <= 10'd24;
            end
            else 
               case (gmov)
                  3'b000 :begin
						    vmov1 <= vmov1 - 1;                     
                  end
						3'b001 :begin
                      vmov1 <= vmov1 + 1;
                  end
						3'b010 :begin
						    hmov1 <= hmov1 - 1;
                  end
						3'b011 :begin
						    hmov1 <= hmov1 + 1;
                  end
						default :
                     ;
               endcase
      end	

		
/////////////////////////////////////////////////////////////////////
/************************* Colors output ***************************/  
/////////////////////////////////////////////////////////////////////

    assign colors[0] = (usercolors[0] & ven & hen)| (syscolors1[0] & ven & hen)| (bgcolors[0] & ven & hen);
    assign colors[1] = (usercolors[1] & ven & hen)| (syscolors1[1] & ven & hen)| (bgcolors[1] & ven & hen);
    assign colors[2] = (usercolors[2] & ven & hen)| (syscolors1[2] & ven & hen)| (bgcolors[2] & ven & hen);
    assign colors[3] = (usercolors[3] & ven & hen)| (syscolors1[3] & ven & hen)| (bgcolors[3] & ven & hen);
    assign colors[4] = (usercolors[4] & ven & hen)| (syscolors1[4] & ven & hen)| (bgcolors[4] & ven & hen);
    assign colors[5] = (usercolors[5] & ven & hen)| (syscolors1[5] & ven & hen)| (bgcolors[5] & ven & hen);
	 assign colors[6] = (usercolors[6] & ven & hen)| (syscolors1[6] & ven & hen)| (bgcolors[6] & ven & hen);
    assign colors[7] = (usercolors[7] & ven & hen)| (syscolors1[7] & ven & hen)| (bgcolors[7] & ven & hen);
    assign colors[8] = (usercolors[8] & ven & hen)| (syscolors1[8] & ven & hen)| (bgcolors[8] & ven & hen);
    assign colors[9] = (usercolors[9] & ven & hen)| (syscolors1[9] & ven & hen)| (bgcolors[9] & ven & hen);
    assign colors[10] = (usercolors[10] & ven & hen)| (syscolors1[10] & ven & hen)| (bgcolors[10] & ven & hen);
    assign colors[11] = (usercolors[11] & ven & hen)| (syscolors1[11] & ven & hen)| (bgcolors[11] & ven & hen);

endmodule
