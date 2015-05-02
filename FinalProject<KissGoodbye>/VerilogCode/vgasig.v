`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:45:39 03/23/2015 
// Design Name: 
// Module Name:    vgasig 
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
module vgasig(clk25m, hcnt, vcnt, hsync, vsync, henable, venable);
   input       clk25m;
   input [10:0] hcnt;
   input [10:0] vcnt;
   output      hsync;
   reg         hsync;
   output      vsync;
   reg         vsync;
   output      henable;
   reg         henable;
   output      venable;
   reg         venable;

	
  always @(posedge clk25m)
      
      begin
         if (hcnt >= (800 + 20 + 20) & hcnt < (800 + 20 + 20 + 128))
            hsync <= 1'b0;
         else
            hsync <= 1'b1;

      end 
   
   always @(vcnt)
      if (vcnt >= (600 + 20 + 4) & vcnt < (600 + 20 + 4 + 4))
         vsync <= 1'b0;
      else
         vsync <= 1'b1; 
			

  always @(posedge clk25m)
      
      begin
         if ((hcnt > 800) | (vcnt > 600))
         begin
            henable <= 1'b0;
            venable <= 1'b0;
         end
         else
         begin
            henable <= 1'b1;
            venable <= 1'b1;
         end
      end
 
endmodule
