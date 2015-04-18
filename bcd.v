`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:07:22 03/23/2015 
// Design Name: 
// Module Name:    bcd 
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
module bcd( 
	input [15:0] binary,
	output reg [3:0] one,
	output reg [3:0] ten,
	output reg [3:0] hundred
	);

	integer i;


	always@(binary)
	begin

		hundred=4'd0;
		ten=4'd0;
		one=4'd0;
	
		for (i=15; i>=0; i=i-1)
		begin
			if (hundred >=5)
				hundred = hundred + 3;
			if (ten >=5)
				ten = ten +3;
			if (one >=5)
				one = one + 3;
		
			hundred = hundred << 1;
			hundred[0] = ten[3];
			ten = ten << 1;
			ten[0] = one[3];
			one = one << 1;
			one[0] = binary[i];
		
		end
	end
	
	
endmodule
	
		