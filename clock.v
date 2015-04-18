`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:45:47 03/23/2015 
// Design Name: 
// Module Name:    clock 
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
module clock(clk50m, clk1hz, clk100hz, clk25m, clk5m);
   input      clk50m;
   output      clk1hz;
   output      clk100hz;
   output      clk25m;
	output      clk5m;
   
   parameter  max0 = 1;
   parameter  max1 = 24999999;
   parameter  max2 = 24000;
  // parameter  max3 = 2;	
   reg [1:0]  counter0;
   reg [24:0] counter1;
   reg [17:0] counter2;
	//reg [17:0] counter3;
   reg div0;
	reg div1;
	reg div2;
 	reg div3;  
  
  always @(posedge clk50m) 
      begin
         if (counter0 == max0)
         begin
            counter0 <= 0;
            div0 <= ~div0;
         end
         else
            counter0 <= counter0 + 1'b1;
      end

   
/*   always @(posedge clk50m)
      
      begin
            div3 <= ~div3;
      end 
*/		
		
   always @(posedge clk50m)
      
      begin
         if (counter1 == max1)
         begin
            counter1 <= 0;
            div1 <= ~div1;
         end
         else
            counter1 <= counter1 + 1'b1;
      end
   
   
   always @(posedge clk50m)
      
      begin
         if (counter2 == max2)
         begin
            counter2 <= 0;
            div2 <= ~div2;
         end
         else
            counter2 <= counter2 + 1'b1;
      end
   
	assign clk25m = div0;
	assign clk1hz = div1;
	assign clk100hz = div2;
	assign clk5m = clk50m;
	
endmodule
