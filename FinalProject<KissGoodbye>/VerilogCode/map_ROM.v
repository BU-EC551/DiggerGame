module map_ROM
#(
	parameter DATA_WIDTH=4,
	parameter DATA_DEPTH=150,
	parameter ADDR_WIDTH=8
)
(
	input [ADDR_WIDTH-1:0] addr,
	output [DATA_WIDTH-1:0] data_out
);

	reg [DATA_WIDTH-1:0] data[DATA_DEPTH-1:0];
	assign data_out=data[addr];
	initial begin
		$readmemh("map.txt",data);
	end
endmodule