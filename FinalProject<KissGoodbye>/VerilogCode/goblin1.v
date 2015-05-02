`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:55:05 04/27/2015 
// Design Name: 
// Module Name:    goblin 
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
module goblin1
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
	parameter HINIT=14,
	parameter VINIT=0,
	parameter HMIN=0,
	parameter VMIN=0,
	parameter UP=2'b00,
	parameter DOWN=2'b01,
	parameter LEFT=2'b10,
	parameter RIGHT=2'b11,
	parameter DETECT_FREQ=9,//9999999,
	parameter CREATION_TIME=19//99999999
)
(
	//global
	input clk,
	input rst,

	//from Arbiter
	input wr,
	input [STATUS_WIDTH-1:0] data_in,
	input ACK,
	input NACK,
	
	//from Digger
	input [STATUS_WIDTH-1:0] digger_status,

	//to Arbiter
	output reg req,
	output reg [REQ_TYPE_WIDTH-1:0] req_type,
	output reg [REQ_CONTENT_WIDTH-1:0] req_content,
	output wire [STATUS_WIDTH-1:0] status,
	output reg GameOver
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
	
	parameter GOB_NOT_EXIST=2'b00;		
    parameter GOB_EXIST=2'b01;
	
	parameter REQ_MOVE=2'b00;
	parameter REQ_DETECT=2'b01;
	parameter REQ_CREATE=2'b10;
	
	reg [EXIST_WIDTH-1:0] exist; //00 for not exist, 01 for exist
	reg [H_WIDTH-1:0] x;
	reg [V_WIDTH-1:0] y;
	reg [TYPE_WIDTH-1:0] obj_type;
	reg [DIR_WIDTH-1:0] dir;//direction
   reg [31:0] counter,cnt_create;
	reg [2:0] detect_dir;
	reg [1:0] dir_move;
	reg dir_up,dir_down,dir_left,dir_right;
	wire [3:0] Digx,Digy;
	wire ready_move;
	
	//status
	assign status={exist, x, y, dir, obj_type};
	assign Digx=digger_status[STATUS_WIDTH-EXIST_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH];
	assign Digy=digger_status[STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-V_WIDTH];
	
	//block for exist
	always@(posedge clk) begin
		if(rst) begin
			exist<=GOB_NOT_EXIST;			//first goblin is exist, others module not exist
		end
		else if(wr) begin
				exist<=data_in[STATUS_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH];
			end
			else if (req && req_type==REQ_CREATE && ACK)
				exist<=GOB_EXIST;
			else begin
				exist<=exist;
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
				//first gob no counter, others need checking exist
				if(req && req_type==REQ_MOVE && ACK) begin
					x<=req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH];
					y<=req_content[V_WIDTH-1:0];
	 			end
				else if (cnt_create==CREATION_TIME) begin
					x<=HINIT;//4'd0;
					y<=VINIT;//4'd14;
				end else
				begin
					x<=x;
					y<=y;
				end
			end
		end
	end


	//block for req_content
	always@(*) begin
		if (exist==GOB_NOT_EXIST) begin
			req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH]<=HINIT; req_content[REQ_CONTENT_WIDTH-H_WIDTH-1:0]<=VINIT;  
		end 
		else if (req && req_type==REQ_DETECT)
		case(detect_dir) 
			UP:   begin req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH]<=x; req_content[V_WIDTH-1:0]<=y-1;  end//up
			DOWN: begin req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH]<=x; req_content[V_WIDTH-1:0]<=y+1;   end//down
			LEFT: begin req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH]<=x-1; req_content[V_WIDTH-1:0]<=y;   end//left
			RIGHT: begin req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH]<=x+1; req_content[V_WIDTH-1:0]<=y; end//right 
			default: begin req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH]<=x; req_content[V_WIDTH-1:0]<=y; end
		endcase 
		else if (req && req_type==REQ_MOVE)
		case(dir_move)
			UP: begin req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH]<=x; req_content[REQ_CONTENT_WIDTH-H_WIDTH-1:0]<=y-1;  end//up
			DOWN: begin req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH]<=x; req_content[REQ_CONTENT_WIDTH-H_WIDTH-1:0]<=y+1;   end//down
			LEFT: begin req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH]<=x-1; req_content[REQ_CONTENT_WIDTH-H_WIDTH-1:0]<=y;   end//left
			RIGHT: begin req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH]<=x+1; req_content[REQ_CONTENT_WIDTH-H_WIDTH-1:0]<=y; end//right 
			default: begin req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH]<=x; req_content[REQ_CONTENT_WIDTH-H_WIDTH-1:0]<=y; end
		endcase 
		else begin
			req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH]<=x; req_content[REQ_CONTENT_WIDTH-H_WIDTH-1:0]<=y;
		end
	end
	
	//block for req and req_type
	always@(posedge clk) begin
		if(rst) begin
			req<=0;
		end
		else if(req) begin
				if(ACK || NACK) begin
					req<=0;
				end
				else begin
					case (exist)  		//req=0
						2'b00: begin
							if (cnt_create==CREATION_TIME) begin
								req<=1;
								req_type<=REQ_CREATE;
							end 
							else begin 
								req<=0;
							end
						end
						2'b01: begin
							if (ready_move) begin			//EXIST 
									req<=1;
									req_type<=REQ_MOVE;
							end
							else if(counter==DETECT_FREQ) begin		
									req<=1;
									req_type<=REQ_DETECT;
							end				
							else begin
								req<=0;
							end
						end
					endcase
				end
			end
			else begin 
				case (exist)  		//req=0
				2'b00: begin
					if (cnt_create==CREATION_TIME) begin
						req<=1;
						req_type<=REQ_CREATE;
					end 
					else begin 
						req<=0;
					end
				end
				2'b01: begin
				if (ready_move) begin			//EXIST 
						req<=1;
						req_type<=REQ_MOVE;
				end
				else if(counter==DETECT_FREQ) begin		
						req<=1;
						req_type<=REQ_DETECT;
				end				
				else begin
					req<=0;
				end
				end
				endcase
			end
	end	
	
	//block for detecting four direction
	always@(posedge clk) begin
		if (rst||(req&&req_type==REQ_MOVE && ACK)) begin
			detect_dir<=0;
			dir_up<=0;				//1 for accessible, 0 for blocked
			dir_down<=0;
			dir_left<=0;
			dir_right<=0;
		end
		else if ((detect_dir>=4)&&(dir_up==0)&&(dir_down==0)&&(dir_left==0)&&(dir_right)) begin
			detect_dir<=0;
		end
		else if (req && req_type==REQ_DETECT && ACK) begin
			case (detect_dir)
				UP: dir_up<=(data_in[TYPE_WIDTH-1:0]<6);
				DOWN: dir_down<=(data_in[TYPE_WIDTH-1:0]<6);
				LEFT: dir_left<=(data_in[TYPE_WIDTH-1:0]<6);
				RIGHT: dir_right<=(data_in[TYPE_WIDTH-1:0]<6);
				default: ;
			endcase
			detect_dir<=detect_dir+1;
		end
		else if (req && req_type==REQ_DETECT && NACK) begin
			case (detect_dir)
				UP: dir_up<=0;
				DOWN: dir_down<=0;
				LEFT: dir_left<=0;
				RIGHT: dir_right<=0;
				default: ;
			endcase
			detect_dir<=detect_dir+1;
		end
	end

	//block for AI
	always@(posedge clk) begin
		if (detect_dir>=4) begin
			case (dir)
				UP: if ((Digy<y)&&(dir_up)) dir_move<=UP;
					else if ((Digx<x)&&(dir_left)) dir_move<=LEFT;
					else if ((Digx>x)&&(dir_right)) dir_move<=RIGHT; 
					else if (dir_up) dir_move<=UP;
					else if (dir_left) dir_move<=LEFT;
					else if (dir_right) dir_move<=RIGHT;
					else if (dir_down) dir_move<=DOWN; 
				DOWN: if ((Digy>y)&&(dir_down)) dir_move<=DOWN; 
					else if ((Digx<x)&&(dir_left)) dir_move<=LEFT;
					else if ((Digx>x)&&(dir_right)) dir_move<=RIGHT; 
					else if (dir_down) dir_move<=DOWN;
					else if (dir_left) dir_move<=LEFT;
					else if (dir_right) dir_move<=RIGHT;
					else if (dir_up) dir_move<=UP; 
				LEFT: if ((Digx<x)&&(dir_left)) dir_move<=LEFT; 
					else if ((Digy<y)&&(dir_up)) dir_move<=UP; 
					else if ((Digy>y)&&(dir_down)) dir_move<=DOWN;
					else if (dir_left) dir_move<=LEFT;
					else if (dir_up) dir_move<=UP; 
					else if (dir_down) dir_move<=DOWN; 
					else if (dir_right) dir_move<=RIGHT; 
				RIGHT: if ((Digx>x)&&(dir_right)) dir_move<=RIGHT; 
					else if ((Digy<y)&&(dir_up)) dir_move<=UP; 
					else if ((Digy>y)&&(dir_down)) dir_move<=DOWN; 
					else if (dir_right) dir_move<=RIGHT; 
					else if (dir_up) dir_move<=UP; 
					else if (dir_down) dir_move<=DOWN; 
					else if (dir_left) dir_move<=LEFT; 
				default: ;
			endcase
		end
		
	end
	
	assign ready_move=(detect_dir>=4);
	//block for counter
	always@(posedge clk) begin
		if(rst||exist==GOB_NOT_EXIST||(req&&req_type==REQ_MOVE&&ACK))
			counter <= 32'b0;
		else
			counter <= (counter==DETECT_FREQ)? DETECT_FREQ:(counter+1);	
		if (rst || exist==GOB_EXIST)		// or died
			cnt_create<=0;
		else if (exist==GOB_NOT_EXIST) cnt_create <= (cnt_create==CREATION_TIME)?CREATION_TIME:(cnt_create+1);
	end 
	
	//blocks for obj_type
	always@(posedge clk) begin
		obj_type<=OBJ_GOB1;
	end
	
	//block for Gameover
	always @(posedge clk) begin			
		if (rst)	GameOver<=1'b0;
		else if ((Digx==x)&&(Digy==y)) GameOver<=1'b1;
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
				if(req && req_type==REQ_MOVE && ACK) begin
					dir<=dir_move;
				end
				else begin
					dir<=dir;
				end
			end
		end
	end	 
endmodule
