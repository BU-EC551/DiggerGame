`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:21:11 04/24/2015 
// Design Name: 
// Module Name:    digger
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
module digger
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
	parameter HINIT=0,
	parameter VINIT=0,
	parameter HMIN=0,
	parameter VMIN=0,
	parameter UP=2'b00,
	parameter DOWN=2'b01,
	parameter LEFT=2'b10,
	parameter RIGHT=2'b11
)
(
	//global
	input clk,
	input rst,
	
	//from keyboard
	input [1:0] keyboard,
	input sample, //The posedge of sample means the keyboard is valid
	
	//from arbitrator
	input ACK,
	input NACK,
	input wr,
	input [STATUS_WIDTH-1:0] data_in,
	
	//to arbitrator
	output reg req,
	output reg [REQ_TYPE_WIDTH-1:0] req_type,
	output reg [REQ_CONTENT_WIDTH-1:0] req_content,
	output wire [STATUS_WIDTH-1:0] status,
	
	//to bullet
  output [STATUS_WIDTH-1:0] status_to_bullet
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
	 
	parameter DIGGER_NOT_EXIST=2'b00;
	parameter DIGGER_EXIST=2'b01;
	parameter REQ_MOVE=2'b00;
	parameter REQ_ROTATE=2'b01;
	
	reg [EXIST_WIDTH-1:0] exist; //00 for not exist, 01 for exist
	reg [H_WIDTH-1:0] x;
	reg [V_WIDTH-1:0] y;
	reg [TYPE_WIDTH-1:0] obj_type;
	reg [DIR_WIDTH-1:0] dir;//direction
	reg [2:0] keyboard_real;
	reg sample_n;
	
	
    //for req_type
    // 00 for move 
    assign status={exist, x, y, dir, obj_type};
	assign status_to_bullet=status;
	
	//block for exist
	always@(posedge clk) begin
		if(rst) begin
			exist<=DIGGER_EXIST;
		end
		else begin
			if(wr) begin
				exist<=data_in[STATUS_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH];
			end
			else begin
				exist<=exist;
			end
		end
	end
	
	//block for x and y
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
				if(req && req_type==REQ_MOVE && ACK) begin
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
	
	//block for req and req_type
	always@(posedge clk) begin
		if(rst) begin
			req<=0;
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
				if(keyboard_real[2]) begin
					if(keyboard_real[1:0]!=dir) begin
						req<=1;
						req_type<=REQ_ROTATE;
					end
					else begin
					   	req<=1;
							req_type<=REQ_MOVE;
					end
				end
				else begin
					req<=0;
				end
			end
		end
	end
					
					
	always@(posedge clk) begin
		if(rst) begin
			sample_n<=0;
		end
		else begin
			sample_n<=sample;
		end
	end
	
	//block for keyboard_real
	//if there is no request, keyboard_real will be updated whenever one posedge of sample signal
	//if there is request, the keyboard_real will not be updated until the request is handled
	always@(posedge clk) begin
		if(rst) begin
			keyboard_real<=3'b000;
		end
		else begin
			if(keyboard_real[2]) begin
				if(req && (ACK||NACK)) begin
					keyboard_real<={1'b0,keyboard};
				end
				else begin
					keyboard_real<=keyboard_real;
				end
			end
			else begin
				if(sample && (~sample_n)) begin
					if ((keyboard_real[1:0]==LEFT&&x<=HMIN)||(keyboard_real[1:0]==RIGHT&&x>=HMAX)||(keyboard_real[1:0]==UP&&y<=VMIN)||(keyboard_real[1:0]==DOWN&&y>=VMAX)) begin
						keyboard_real<={1'b0,keyboard};
					end 
					else begin
						keyboard_real<={1'b1,keyboard};
					end
				end
				else begin
					keyboard_real<={1'b0,keyboard};
				end
			end
		end
	end
			



	
	//block for req_content
	always@(*) begin
		if(req_type==REQ_ROTATE) begin
			req_content<={6'b0,keyboard_real[1:0]};
		end
		else begin
			case(keyboard_real)
				{1'b1,UP}:   begin req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH]<=x; req_content[V_WIDTH-1:0]<=y-1;  end//up
				{1'b1,DOWN}: begin req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH]<=x; req_content[V_WIDTH-1:0]<=y+1;  end//down
				{1'b1,LEFT}: begin req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH]<=x-1; req_content[V_WIDTH-1:0]<=y;  end//left
				{1'b1,RIGHT}: begin req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH]<=x+1; req_content[V_WIDTH-1:0]<=y; end//right 
				default: begin req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH]<=x; req_content[V_WIDTH-1:0]<=y; end
			endcase 
		end
	end
	
	//blocks for dir
	always@(posedge clk) begin
		if(rst) begin
			dir<=LEFT;
		end
		else begin
			if(wr) begin
				dir<=data_in[DIR_WIDTH+TYPE_WIDTH-1:TYPE_WIDTH];
			end
			else begin
				if(req && req_type==REQ_ROTATE && ACK) begin
					dir<=keyboard;
				end
				else begin
					dir<=dir;
				end
			end
		end
	end
	
	//blocks for obj_type
	always@(*) begin
		case(dir)
			UP: obj_type<=OBJ_DIGGER_UP;
			DOWN: obj_type<=OBJ_DIGGER_DOWN;
			LEFT: obj_type<=OBJ_DIGGER_LEFT;
			default: obj_type<=OBJ_DIGGER_RIGHT;
		endcase
	end
	



endmodule
