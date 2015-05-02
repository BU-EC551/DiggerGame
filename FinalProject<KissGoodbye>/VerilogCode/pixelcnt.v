`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:46:24 03/23/2015 
// Design Name: 
// Module Name:    pixelcnt 
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
module pixelcnt(clk25m, hcntout, vcntout);
   input        clk25m;
   output [10:0] hcntout;
   output [10:0] vcntout;
   
   
   reg [10:0]    hcnt;
   reg [10:0]    vcnt;
   
   assign hcntout = hcnt;
   assign vcntout = vcnt;
   
   always @(posedge clk25m)
      
      begin
         if (hcnt < 1056)
            hcnt <= hcnt + 1'b1;
         else
            hcnt <= {10{1'b0}};
      end
   
   
   always @(posedge clk25m)
      
      begin
         if (hcnt == 1056)
         begin
            if (vcnt < 628)
               vcnt <= vcnt + 1'b1;
            else
               vcnt <= {10{1'b0}};
         end
      end
   
endmodule
