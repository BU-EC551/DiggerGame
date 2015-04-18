`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:47:32 03/23/2015 
// Design Name: 
// Module Name:    scoreSystem 
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
module scoreSystem(
	input clk,rst,
	input  [1:0] unit,
	output [15:0] score
    );
	 
	reg [9:0] cal=10'd0;
	
	always@(posedge clk)
		begin
			if (rst) cal<=10'd0;
			else 
			case(unit)
				2'b00: cal <= cal;
				2'b01: cal <= ((cal + 5)>999) ? (cal+5-999) : (cal + 5); //diamond
				2'b10: cal <= ((cal + 10)>999) ? (cal+10-999) : (cal + 10); //money bag
				2'b11: cal <= ((cal + 15)>999) ? (cal+15-999) : (cal + 15); //goblin
				default: cal<=cal;
			endcase
		end
		
   assign score = {6'b0,cal};
	
	// Instantiate the module
/*display_7_segment display_seven (
    
	 .clk(clk), 
    .in(score),
    .an(an), 
    .out(out)
	 
	  );*/
	
endmodule
