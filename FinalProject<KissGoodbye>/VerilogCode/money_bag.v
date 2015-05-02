`timescale 1ns / 1ps
module money_bag
#(
	parameter H_WIDTH=4,    //Bit width of the horizontal coordinate
	parameter V_WIDTH=4,    //Bit width of the vertical coordinate
	parameter TYPE_WIDTH=4, //Bit width of the width
	parameter DIR_WIDTH=2,  //Bit width of the direction
	parameter EXIST_WIDTH=2,//Bit width of the existence bit
	parameter REQ_TYPE_WIDTH=2,
	parameter REQ_CONTENT_WIDTH=8,
	parameter STATUS_WIDTH=16, //status is concatenated as {exist,x,y,dir,type}
	parameter HMAX=15,
	parameter VMAX=10,
	parameter HINIT=10,
	parameter VINIT=11,
	parameter HMIN=0,
	parameter VMIN=0,
	parameter UP=2'b00,
	parameter DOWN=2'b01,
	parameter LEFT=2'b10,
	parameter RIGHT=2'b11,
	parameter MONEYBAG_ID=7,
	parameter MONEYBAG_DROP_SPEED=4//9999999
)
(
//from global
	input clk,
	input rst,
//from Arbiter
	input wr,
	input [STATUS_WIDTH-1:0] data_in,
	input ACK,
	input NACK,
	
//output to Arbiter
	output reg req,
	output reg req_type,
	output reg [REQ_CONTENT_WIDTH-1:0] req_content,
	output wire [STATUS_WIDTH-1:0] status
);

parameter OBJ_EMPTY = 0;
parameter OBJ_DIGGER_LEFT = 1;
parameter OBJ_DIGGER_RIGHT = 2;
parameter OBJ_DIGGER_UP = 3;
parameter OBJ_DIGGER_DOWN = 4;
parameter OBJ_BULLET = 5;
parameter OBJ_GOB0 = 6;
parameter OBJ_GOB1 = 7;
parameter OBJ_GOB2 = 8;
parameter OBJ_DIAMOND = 9;
parameter OBJ_MONEYBAG0 =10;
parameter OBJ_MONEYBAG1 =11;
parameter OBJ_MONEYBAG2 =12;
parameter OBJ_MONEYBAG3 =13;
parameter OBJ_MONEYBAG4 =14;
parameter OBJ_BLOCK =15;
	
	parameter MB_NOT_EXIST=2'b00;
	parameter MB_STATIC=2'b01; 
	parameter MB_DROPPING=2'b10;//falling through two empty blocks continuously, the money bag will transform into gold
	parameter MB_GOLDEN=2'b11;
	
	parameter REQ_DROP=2'b00;
	parameter REQ_TRANSFORM=2'b01;
	
	reg [EXIST_WIDTH-1:0] exist; //00 for not exist, 01 for static, 10 for dropping, 11 for gold form
	reg [H_WIDTH-1:0] x;
	reg [V_WIDTH-1:0] y;
	reg [TYPE_WIDTH-1:0] obj_type;
	reg [DIR_WIDTH-1:0] dir;//direction
	
	reg [V_WIDTH-1:0] drop_distance;
	reg [31:0] counter;
	
	
	//status
	assign status={exist, x, y, dir, obj_type};
	
	//blocks for exist 
	always@(posedge clk) begin
		if(rst) begin
			exist<=MB_NOT_EXIST;
		end
		else begin
			if(wr) begin
				exist<=data_in[STATUS_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH];
			end
			else 
				if(exist==MB_NOT_EXIST) begin
					exist<=exist;
				end
				else if(exist==MB_STATIC) begin
					if(req && req_type==REQ_DROP && ACK) begin
						exist<=MB_DROPPING;
					end
					else begin
						exist<=MB_STATIC;
					end
				end
				else if(exist==MB_DROPPING) begin
					if (req_type==REQ_DROP && y>=VMAX) begin // modified 
						if(drop_distance<2) begin
							exist<=MB_STATIC;
						end
						else begin
							exist<=MB_GOLDEN;
						end
					end
					else if(req && req_type==REQ_DROP && ACK) 
						exist<=MB_DROPPING;
					else if(req && req_type==REQ_DROP && NACK) begin
						if(drop_distance<2) begin
							exist<=MB_STATIC;
						end
						else begin
							exist<=MB_GOLDEN;
						end
					end
					else begin
						exist<=MB_DROPPING;
					end
				end
				else begin //money bag is golden form now
					exist<=MB_GOLDEN;
				end
			end
		end

	
	//blocks for x and y
	always@(posedge clk) begin
		if(rst) begin
			x<=HINIT;
			y<=VINIT;
		end
		else begin
			if(wr) begin
				x<=data_in[STATUS_WIDTH-EXIST_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH];
				y<=data_in[STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-V_WIDTH];
			end
			else begin
				if(req && req_type==REQ_DROP && ACK) begin
					x<=req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH];
					y<=req_content[V_WIDTH-1:0];
				end
				else begin
					x<=x;
					y<=y;
				end
			end
		end
	end
	
	//blocks for dir
	always@(posedge clk) begin
		dir<=DOWN;
	end
	
	//blocks for obj_type
	always@(posedge clk) begin
		obj_type<=MONEYBAG_ID;
	end
	
	always@(posedge clk) begin
		if(rst||ACK||NACK||exist!=MB_DROPPING)
			counter <= 32'b0;
		else
			counter <= (counter==MONEYBAG_DROP_SPEED)? MONEYBAG_DROP_SPEED:(counter+1);	
	end 
	
	always@(posedge clk) begin
		if (rst||exist!=MB_DROPPING)
			drop_distance<=4'b1;
		else if (req && req_type==REQ_DROP && ACK) drop_distance<=drop_distance+1;
		else drop_distance<=drop_distance;
   end
	
	//block for req and req_type
	always@(posedge clk) begin
		if(rst) begin
			req<=0;
			req_type<=0;
		end
		else begin
			if(req) begin
				if(ACK || NACK) begin
					req<=0;
				end
				else begin
					req<=1;
				end
			end
			else begin
				if(exist==MB_NOT_EXIST) begin
					req<=0;
				end
				else if(exist==MB_STATIC) begin
					if(y!=VMAX) begin
						req<=1;
						req_type<=REQ_DROP;
					end
					else begin
						req<=0;
					end
				end
				else if(exist==MB_DROPPING) begin
					if (y>=VMAX) begin			//here
						req<=0;
					end
					else if(counter==MONEYBAG_DROP_SPEED) begin
						req<=1;
						req_type<=REQ_DROP;
					end
					else begin
						req<=0;
					end
				end
				else begin //golden state
					req<=0;
				end
			end
		end
	end
	
  always@(*) begin
      begin req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH]<=x; req_content[V_WIDTH-1:0]<=y+1;   end//down     
  end
  

endmodule
				
					
					
			
				
		
				
				
		
	
	
	


	