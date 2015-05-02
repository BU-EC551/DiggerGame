`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:04:02 04/29/2015 
// Design Name: 
// Module Name:    ltest 
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
module ltest(
		input    test_clk,
		input    [2:0]      key,
	   input    [3:0]      vgaram_douta,		
		output              vgaram_we,
		output   [7:0]		  vgaram_addra,
	   output   [3:0]      vgaram_dina

	
    );

		reg   [7:0]   curr_digpos;
		
/*		reg   [3:0]   dig_up;
		reg   [3:0]   dig_down;
		reg   [3:0]   dig_left;
		reg   [3:0]   dig_right;*/
		
		always @ (posedge test_clk) begin
			for(vgaram_adda =0; vgaram_adda <150; vgaram_adda = vgaram_adda +1) begin
					if(vgaram_douta == 1 | vgaram_douta == 2 | vgaram_douta == 3 | vgaram_douta == 4) begin
						curr_digpos <= vgaram_adda;
					end
			end
			
			dig_up <= 1;
			if (key == 3'b001) begin
				
			end
			else if (key == 3'b010) begin
			
			end
			else if (key == 3'b011) begin
			
			end
			else if (key == 3'b100) begin
			
			end
			
			
		end
endmodule
