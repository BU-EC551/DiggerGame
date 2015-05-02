`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:29:22 03/26/2015 
// Design Name: 
// Module Name:    translator 
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
module translator(
	input clk_key,
	input  data,
	output sample,
	output reg [1:0] keyboard
    );

	wire [7:0] key_out;
    
    //the vga_id is the ascii code of the output character;
    //the posedge of the sample signal validate the vga_id

//wire [7:0] key_out;

// Instantiate the module
keyboardtest keykeykey (
    .clk(clk_key), 
    .data(data), 
    .key_out(key_out),
	 .sample(sample)
    );

	  
	always@(*)
	begin 
	case(key_out)
	 8'h72   : begin keyboard<=2'b01; end     // key 2 down
    8'h6B   : begin keyboard<=2'b10; end     // key 4 left
    8'h74   : begin keyboard<=2'b11; end     // key 6 right
    8'h75   : begin keyboard<=2'b00; end     // key 8 up
	default: begin keyboard<=2'b00;end
	endcase
end


endmodule
