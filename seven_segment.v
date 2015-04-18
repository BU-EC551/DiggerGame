`timescale 1ns/1ps
module seven_segment(in,out);
	input[3:0] in;
	output[7:0] out;
	
	reg[7:0] out;
	always@(in)
		case(in)
		4'd0: out <= 8'h03;
		4'd1: out <= 8'h9F;
		4'd2: out <= 8'h25;
		4'd3: out <= 8'h0D;
		4'd4: out <= 8'h99;
		4'd5: out <= 8'h49;
		4'd6: out <= 8'h41;
		4'd7: out <= 8'h1F;
		4'd8: out <= 8'h01;
		4'd9: out <= 8'h09;
		default: out<=8'hff;
		endcase
endmodule
