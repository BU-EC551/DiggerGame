`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:02:04 04/22/2015 
// Design Name: 
// Module Name:    bullet 
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
module bullet
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
	parameter HMIN=0,
	parameter VMIN=0,
	parameter UP=2'b00,
	parameter DOWN=2'b01,
	parameter LEFT=2'b10,
	parameter RIGHT=2'b11,
	parameter BULLET_SPEED=49999999
)
(
//global signal 
	input clk,  //100MHz
	input rst,

//from keyboard
	input fire,// fire or not (a pulse)
	
//from Arbiter
	input wr,
	input [STATUS_WIDTH-1:0] data_in,
	input ACK,
	input NACK,

//from Digger
	input [STATUS_WIDTH-1:0] digger_status,

//to Arbiter
	output wire [STATUS_WIDTH-1:0] bullet_status,
	output reg req,
	output reg [REQ_TYPE_WIDTH-1:0] req_type,
	output reg [REQ_CONTENT_WIDTH-1:0] req_content
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
  
  parameter BULLET_NOT_EXIST=2'b00;
  parameter BULLET_EXIST=2'b01;
  
  parameter REQ_MOVE=2'b00;
  parameter REQ_SHOOT=2'b01;
  parameter REQ_DISAPPEAR=2'b10;
  
  reg [EXIST_WIDTH-1:0] exist; //00 for not exist, 01 for exist
  reg [H_WIDTH-1:0] x;
  reg [V_WIDTH-1:0] y;
  reg [TYPE_WIDTH-1:0] obj_type;
  reg [DIR_WIDTH-1:0] dir;//direction
  reg [31:0] counter;
  
  
  //for req_type
  // 00 for move 01 for shoot (the emerging of the bullet)
  // 10 for disappear  
  assign bullet_status={exist, x, y, dir, obj_type};
  
  //block for exist
  always@(posedge clk) begin
    if(rst) begin
	  exist<=BULLET_NOT_EXIST;
	end
	else begin
	  if(wr) begin
	    exist<=data_in[STATUS_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH];
	  end
	  else begin
		if(exist==BULLET_NOT_EXIST) begin
	      if(req && req_type==REQ_SHOOT && ACK) begin
		    exist<=BULLET_EXIST;
		  end
		  else begin
		    exist<=BULLET_NOT_EXIST;
		  end
		end
		else if(exist==BULLET_EXIST) begin
		  if(req && req_type == REQ_MOVE && NACK) begin
		    exist<=BULLET_NOT_EXIST;
		  end
		  else if(req && req_type == REQ_DISAPPEAR && ACK) begin
		    exist<=BULLET_NOT_EXIST;
		  end
		  else begin
		    exist<=BULLET_EXIST;
		  end
		end
		else begin
		  exist<=BULLET_NOT_EXIST;//there is no case other than BULLET_EXIST and BULLET_NOT_EXIST
		end
	  end
	end
  end
  
  //block for x and y
  always@(posedge clk) begin
	if(exist==BULLET_NOT_EXIST) begin 
	  if(req && req_type==REQ_SHOOT && ACK) begin
		x<=req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH];
		y<=req_content[V_WIDTH-1:0];
      end
	  else begin
			//if status not exist or the fire button is not acknowledged, the bullet follows the digger position
	    x<=digger_status[STATUS_WIDTH-EXIST_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH];
		y<=digger_status[STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-V_WIDTH];
      end
	end
	else if(exist==BULLET_EXIST) begin
	  if(req && req_type==REQ_MOVE && ACK) begin
		x<=req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH];
		y<=req_content[V_WIDTH-1:0];
      end
	  else if(req && req_type==REQ_MOVE && NACK) begin
	    x<=digger_status[STATUS_WIDTH-EXIST_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH];
		y<=digger_status[STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-V_WIDTH];
	  end
	  else if(req && req_type == REQ_DISAPPEAR && ACK) begin
		x<=digger_status[STATUS_WIDTH-EXIST_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH];
		y<=digger_status[STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-V_WIDTH];
      end
      else begin
		x<=x;
		y<=y;
      end
	end
	else begin//there is no case other than BULLET_EXIST and BULLET_NOT_EXIST
	  x<=x;
	  y<=y;
	  
	end
  end
  
  //block for dir
  always@(posedge clk) begin
    if(exist==BULLET_NOT_EXIST) begin //if bullet does not exist, the direction always follows the digger direction
	  dir<=digger_status[DIR_WIDTH+TYPE_WIDTH-1:TYPE_WIDTH];
	end
	else begin
	  dir<=dir;
	end
  end
  
  always@(*) begin
    case(dir)
      UP:   begin req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH]<=x; req_content[V_WIDTH-1:0]<=y-1;  end//up
      DOWN: begin req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH]<=x; req_content[V_WIDTH-1:0]<=y+1;   end//down
      LEFT: begin req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH]<=x-1; req_content[V_WIDTH-1:0]<=y;   end//left
      RIGHT: begin req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH]<=x+1; req_content[V_WIDTH-1:0]<=y; end//right 
      default: begin req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH]<=x; req_content[V_WIDTH-1:0]<=y; end
    endcase 
  end
  
  //block for type
  always@(posedge clk) begin
    obj_type<=OBJ_BULLET;
  end
  
  //block for req
  always@(posedge clk) begin
  if(rst) begin
	  req_type<=0;
	  req<=0;
	end
	else if(exist==BULLET_NOT_EXIST) begin
	  if(req) begin
	    if(ACK || NACK) begin
		    req<=0;
		end
		else begin //the request holds until gets acknowledged
		    req<=1;
		end
	  end
	  else begin
	    if(fire) begin
		    if((dir==LEFT && x==HMIN) || (dir==RIGHT && x==HMAX) || (dir==UP && y==HMIN) || (dir==DOWN && y==HMAX)) begin 
		     req<=0;//if hit wall, the bullet module would not request=
		    end
		    else begin
		      req<=1;
			  req_type<=REQ_SHOOT;
		    end
		end
		else begin
		    req<=0;
		end
	  end
	end
	else if(exist==BULLET_EXIST) begin
	  if(req) begin
	    if(ACK || NACK) begin
		  req<=0;
		end
		else begin
		  req<=1;
		end
	  end
	  else begin
		if(counter!=BULLET_SPEED) begin
		  req<=0;
		end
		else begin
		  if((dir==LEFT && x==HMIN) || (dir==RIGHT && x==HMAX) || (dir==UP && y==VMIN) || (dir==DOWN && y==VMAX)) begin 
		  //hit the screen border, the bullet should disappear
		    req<=1;
			req_type<=REQ_DISAPPEAR;
		  end
		  else begin
		    req<=1;
			req_type<=REQ_MOVE;
		  end
		end
	  end
	end
	else begin //there is no case other than BULLET_EXIST and BULLET_NOT_EXIST
	  req<=0;
	end	    
 end
	
  always@(posedge clk)
  begin
	if(rst||ACK||NACK||exist==BULLET_NOT_EXIST)
		counter <= 32'b0;
	else
      counter <= (counter==BULLET_SPEED)? BULLET_SPEED:(counter+1);	
  end 
	
endmodule
