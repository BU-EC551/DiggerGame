`timescale 1ns / 1ps

module display_7_segment(clk,in,an,out);
	output reg [3:0] an;
	output reg [7:0] out;
	input	 clk;
	input  [15:0] in;
	reg	[1:0] count = 0;
	wire	[3:0] one,ten,hundred;
	wire	[7:0] one_7,ten_7,hundred_7,thous_7;




//bcd M0(in,one_orig,ten_orig);
bcd bcd_scoresystem(
    .binary(in), 
    .one(one), 
    .ten(ten), 
    .hundred(hundred)
    );
	 

seven_segment M1(one,one_7);
seven_segment M2(ten,ten_7);
seven_segment M3(hundred,hundred_7);
seven_segment M4(4'd10,thous_7);



always @(posedge clk) begin
case(count)
2'b00: begin an = 4'b1110; out = one_7; end
2'b01: begin an = 4'b1101; out = ten_7; end
2'b10: begin an = 4'b1011; out = hundred_7; end
2'b11: begin an = 4'b0111; out = thous_7; end
endcase
count = count + 1;
end

endmodule




