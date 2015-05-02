module game_FSM
#(  parameter H_WIDTH=4,    //Bit width of the horizontal coordinate
	parameter V_WIDTH=4,    //Bit width of the vertical coordinate
	parameter TYPE_WIDTH=4, //Bit width of the width
	parameter DIR_WIDTH=2,  //Bit width of the direction
	parameter EXIST_WIDTH=2,//Bit width of the existence bit
	parameter REQ_TYPE_WIDTH=2,
	parameter REQ_CONTENT_WIDTH=8,
	parameter STATUS_WIDTH=16, //status is concatenated as {exist,x,y,dir,type}
	parameter HMAX=14,
	parameter VMAX=9,
	parameter HMIN=0,
	parameter VMIN=0,
	parameter UP=2'b00,
	parameter DOWN=2'b01,
	parameter LEFT=2'b10,
	parameter RIGHT=2'b11,
	parameter NUMBER_OF_OBJECTS=16,
	parameter OBJECTS_INDEX_WIDTH=4,
	parameter ADDR_WIDTH=8,
	parameter DIAMOND_SCORE=5,
	parameter MONEYBAG_SCORE=20,
	parameter GOB_SCORE=50
)
(	
	//from global
	input clk,
	input rst,
	//from objects
	input [STATUS_WIDTH-1:0] digger_status,
	input [STATUS_WIDTH-1:0] gob0_status,
	input [STATUS_WIDTH-1:0] gob1_status,
	input [STATUS_WIDTH-1:0] gob2_status,
	input [STATUS_WIDTH-1:0] bullet_status,
	input [STATUS_WIDTH-1:0] mb0_status,
	input [STATUS_WIDTH-1:0] mb1_status,
	input [STATUS_WIDTH-1:0] mb2_status,
	input [STATUS_WIDTH-1:0] mb3_status,
	input [STATUS_WIDTH-1:0] mb4_status,
	//from Arbiter
	input [REQ_TYPE_WIDTH-1:0] req_type,
	input [REQ_CONTENT_WIDTH-1:0] req_content,
	input req,
	input [OBJECTS_INDEX_WIDTH-1:0] obj_to_FSM_index,
	//from VGA
	input [TYPE_WIDTH-1:0] ram_data_out,
	//from map ROM
	input [TYPE_WIDTH-1:0] rom_data_out,
	input [TYPE_WIDTH-1:0] rom_data_out1,
	//to map ROM
	output reg [ADDR_WIDTH-1:0] rom_addr,
	//to VGA
	output reg ram_wr,
	output reg [TYPE_WIDTH-1:0] ram_data_in,
	output reg [ADDR_WIDTH-1:0] ram_addr,
	//to arbiter
	output reg obj_wr,
	output reg [STATUS_WIDTH-1:0] obj_data_in,
	output reg obj_ACK,
	output reg obj_NACK,
	output reg [OBJECTS_INDEX_WIDTH-1:0] FSM_to_obj_index,
	
	//to LED
	output reg [9:0] score,
	
	output reg game_over,
	output [EXIST_WIDTH-1:0] mb0_exist,
	output [EXIST_WIDTH-1:0] mb1_exist,
	output [EXIST_WIDTH-1:0] mb2_exist,
	output [EXIST_WIDTH-1:0] mb3_exist,
	output [EXIST_WIDTH-1:0] mb4_exist
	
	
	
	
);

	parameter OBJ_DIGGER=1;//LEFT and RIGHT and UP and DOWN are all combined into 1

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
	parameter DIGGER_NOT_EXIST=2'b00;
	parameter DIGGER_EXIST=2'b01;
	parameter GOB_EXIST=2'b01;
	parameter GOB_NOT_EXIST=2'b00;
	parameter MB_NOT_EXIST=2'b00;
	parameter MB_STATIC=2'b01; 
	parameter MB_DROPPING=2'b10;//falling through two empty blocks continuously, the money bag will transform into gold
	parameter MB_GOLDEN=2'b11;
	
	parameter DIGGER_REQ_MOVE=2'b00;
	parameter DIGGER_REQ_ROTATE=2'b01;
	parameter BULLET_REQ_MOVE=2'b00;
	parameter BULLET_REQ_SHOOT=2'b01;
	parameter BULLET_REQ_DISAPPEAR=2'b10;
	parameter GOB_REQ_MOVE=2'b00;
	parameter GOB_REQ_DETECT=2'b01;
	parameter GOB_REQ_CREATE=2'b10;
	parameter MB_REQ_DROP=2'b00;
	parameter MB_REQ_TRANSFORM=2'b01;
		
	parameter STATE_INIT=0;
	parameter STATE_HANDLING_REQ=1;
	parameter STATE_GAME_OVER=2;
	
	
	parameter WAITING_REQ=4'd0;
	parameter READING_REQ_CONTENT=4'd1;
	parameter WRITING_ORIG_POS=4'd2;
	parameter WRITING_REQ_POS=4'd3;

	reg [3:0] state;
	reg reset_done_tmp;
	reg reset_done;
	wire game_win;
	reg [4:0] level;
	reg [3:0] state_req_handle;
	
	reg [3:0] init_x_walker;
	reg [3:0] init_y_walker;
	reg [3:0] init_x_walker_delay;
	reg [3:0] init_y_walker_delay;
	reg [3:0] last_object_index;
	
	reg ram_read_done;
	reg [TYPE_WIDTH-1:0] ram_data_out_latch;
	
	wire [H_WIDTH-1:0] req_x;
	wire [H_WIDTH-1:0] req_y;
	
	wire [H_WIDTH-1:0] digger_x;
	wire [V_WIDTH-1:0] digger_y;
	wire [DIR_WIDTH-1:0]digger_dir;
	wire [EXIST_WIDTH-1:0] digger_exist;
	wire [TYPE_WIDTH-1:0] digger_type;
	
		wire [H_WIDTH-1:0] bullet_x;
	wire [V_WIDTH-1:0] bullet_y;
	wire [DIR_WIDTH-1:0]bullet_dir;
	wire [EXIST_WIDTH-1:0] bullet_exist;
	wire [TYPE_WIDTH-1:0] bullet_type;
	
	wire [H_WIDTH-1:0] gob0_x;
	wire [V_WIDTH-1:0] gob0_y;
	wire [DIR_WIDTH-1:0] gob0_dir;
	wire [EXIST_WIDTH-1:0] gob0_exist;
	
	wire [H_WIDTH-1:0] gob1_x;
	wire [V_WIDTH-1:0] gob1_y;
	wire [DIR_WIDTH-1:0] gob1_dir;
	wire [EXIST_WIDTH-1:0] gob1_exist;
	
	wire [H_WIDTH-1:0] gob2_x;
	wire [V_WIDTH-1:0] gob2_y;
	wire [DIR_WIDTH-1:0] gob2_dir;
	wire [EXIST_WIDTH-1:0] gob2_exist;
	
	wire [H_WIDTH-1:0] mb0_x;
	wire [V_WIDTH-1:0] mb0_y;
	wire [DIR_WIDTH-1:0] mb0_dir;
	//wire [EXIST_WIDTH-1:0] mb0_exist;
	
	wire [H_WIDTH-1:0] mb1_x;
	wire [V_WIDTH-1:0] mb1_y;
	wire [DIR_WIDTH-1:0] mb1_dir;
	//wire [EXIST_WIDTH-1:0] mb1_exist;
	
	wire [H_WIDTH-1:0] mb2_x;
	wire [V_WIDTH-1:0] mb2_y;
	wire [DIR_WIDTH-1:0] mb2_dir;
	//wire [EXIST_WIDTH-1:0] mb2_exist;
	
	wire [H_WIDTH-1:0] mb3_x;
	wire [V_WIDTH-1:0] mb3_y;
	wire [DIR_WIDTH-1:0] mb3_dir;
	//wire [EXIST_WIDTH-1:0] mb3_exist;
	
	wire [H_WIDTH-1:0] mb4_x;
	wire [V_WIDTH-1:0] mb4_y;
	wire [DIR_WIDTH-1:0] mb4_dir;

	
	assign digger_exist=digger_status[STATUS_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH];
	assign digger_x=digger_status[STATUS_WIDTH-EXIST_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH];
	assign digger_y=digger_status[STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-V_WIDTH];
	assign digger_dir=digger_status[DIR_WIDTH+TYPE_WIDTH-1:TYPE_WIDTH];
	assign digger_type=digger_status[TYPE_WIDTH-1:0];
	
	assign bullet_exist=bullet_status[STATUS_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH];
	assign bullet_x=bullet_status[STATUS_WIDTH-EXIST_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH];
	assign bullet_y=bullet_status[STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-V_WIDTH];
	assign bullet_dir=bullet_status[DIR_WIDTH+TYPE_WIDTH-1:TYPE_WIDTH];
	assign bullet_type=bullet_status[TYPE_WIDTH-1:0];
	
	assign gob0_exist=gob0_status[STATUS_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH];
	assign gob0_x=gob0_status[STATUS_WIDTH-EXIST_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH];
	assign gob0_y=gob0_status[STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-V_WIDTH];
	assign gob0_dir=gob0_status[DIR_WIDTH+TYPE_WIDTH-1:TYPE_WIDTH];
	
	assign gob1_exist=gob1_status[STATUS_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH];
	assign gob1_x=gob1_status[STATUS_WIDTH-EXIST_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH];
	assign gob1_y=gob1_status[STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-V_WIDTH];
	assign gob1_dir=gob1_status[DIR_WIDTH+TYPE_WIDTH-1:TYPE_WIDTH];
	
	assign gob2_exist=gob2_status[STATUS_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH];
	assign gob2_x=gob2_status[STATUS_WIDTH-EXIST_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH];
	assign gob2_y=gob2_status[STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-V_WIDTH];
	assign gob2_dir=gob2_status[DIR_WIDTH+TYPE_WIDTH-1:TYPE_WIDTH];
	
	assign mb0_exist=mb0_status[STATUS_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH];
	assign mb0_x=mb0_status[STATUS_WIDTH-EXIST_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH];
	assign mb0_y=mb0_status[STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-V_WIDTH];
	assign mb0_dir=mb0_status[DIR_WIDTH+TYPE_WIDTH-1:TYPE_WIDTH];
	
	assign mb1_exist=mb1_status[STATUS_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH];
	assign mb1_x=mb1_status[STATUS_WIDTH-EXIST_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH];
	assign mb1_y=mb1_status[STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-V_WIDTH];
	assign mb1_dir=mb1_status[DIR_WIDTH+TYPE_WIDTH-1:TYPE_WIDTH];
	
	assign mb2_exist=mb2_status[STATUS_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH];
	assign mb2_x=mb2_status[STATUS_WIDTH-EXIST_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH];
	assign mb2_y=mb2_status[STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-V_WIDTH];
	assign mb2_dir=mb2_status[DIR_WIDTH+TYPE_WIDTH-1:TYPE_WIDTH];
	
	assign mb3_exist=mb3_status[STATUS_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH];
	assign mb3_x=mb3_status[STATUS_WIDTH-EXIST_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH];
	assign mb3_y=mb3_status[STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-V_WIDTH];
	assign mb3_dir=mb3_status[DIR_WIDTH+TYPE_WIDTH-1:TYPE_WIDTH];	

	assign mb4_exist=mb4_status[STATUS_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH];
	assign mb4_x=mb4_status[STATUS_WIDTH-EXIST_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH];
	assign mb4_y=mb4_status[STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-1:STATUS_WIDTH-EXIST_WIDTH-H_WIDTH-V_WIDTH];
	assign mb4_dir=mb4_status[DIR_WIDTH+TYPE_WIDTH-1:TYPE_WIDTH];
	
	assign req_x=req_content[REQ_CONTENT_WIDTH-1:REQ_CONTENT_WIDTH-H_WIDTH];
	assign req_y=req_content[V_WIDTH-1:0];
	assign game_win=(score>=300);
	always@(posedge clk) begin
		if(rst||~reset_done) begin
			state<=STATE_INIT;
			level<=0;
		end
		else if(digger_exist==DIGGER_EXIST) begin
			if(~game_win) begin
				state<=STATE_HANDLING_REQ;
			end
			else begin
				state<=STATE_INIT;
				level<=level+1;
			end
		end
		else begin
			state<=STATE_GAME_OVER;
		end
	end
	
	always@(posedge clk) begin
		if(rst||game_win) begin
			init_x_walker<=0;
			init_y_walker<=0;
			init_x_walker_delay<=0;
			init_x_walker_delay<=0;
		end
		else begin
			if(state==STATE_INIT) begin
				init_x_walker<=(init_x_walker==HMAX)? ((init_y_walker==VMAX)?HMAX:0) : (init_x_walker+1);
				init_x_walker_delay<=init_x_walker;
				init_y_walker<=(init_y_walker==VMAX)?VMAX:((init_x_walker==HMAX)?(init_y_walker+1):init_y_walker);
				init_y_walker_delay<=init_y_walker;
			end
			else begin
				init_x_walker<=init_x_walker;
				init_y_walker<=init_y_walker;
			end
		end
	end
	always@(posedge clk) begin
		//reset_done<=reset_done_tmp;
		reset_done<=(init_x_walker==HMAX) && (init_y_walker==VMAX);
	end
	always@(posedge clk) begin
		if(state==STATE_INIT) begin
			last_object_index<=0;
			game_over<=0;
			score<=0;
			rom_addr<=init_y_walker*(HMAX+1)+init_x_walker;
			ram_addr<=rom_addr;
			ram_wr<=1;
			ram_data_in<=(level==0)?rom_data_out:rom_data_out1;
			ram_read_done<=0;
			state_req_handle<=WAITING_REQ;
			case(rom_data_out)
				OBJ_DIGGER_LEFT,OBJ_DIGGER_RIGHT,OBJ_DIGGER_UP,OBJ_DIGGER_DOWN: begin
					obj_wr<=1;
					//obj_data_in<={DIGGER_EXIST,init_x_walker,init_y_walker,RIGHT,OBJ_DIGGER_RIGHT}; // digger is initialized as right
					obj_data_in[15:14]<=DIGGER_EXIST;
					obj_data_in[13:10]<=init_x_walker_delay;
					obj_data_in[9:6]<=init_y_walker_delay;
					obj_data_in[5:4]<=RIGHT;
					obj_data_in[3:0]<=OBJ_DIGGER_RIGHT;
					FSM_to_obj_index<=OBJ_DIGGER_RIGHT;
				end
				OBJ_GOB0: begin
					obj_wr<=1;
					//obj_data_in<={GOB_EXIST,init_x_walker,init_y_walker,LEFT,OBJ_GOB0};
					obj_data_in[15:14]<=GOB_EXIST;
					obj_data_in[13:10]<=init_x_walker_delay;
					obj_data_in[9:6]<=init_y_walker_delay;
					obj_data_in[5:4]<=LEFT;
					obj_data_in[3:0]<=OBJ_GOB0;					
//					obj_data_in<=16'hffff;
					FSM_to_obj_index<=OBJ_GOB0;
				end
				OBJ_GOB1: begin
					obj_wr<=1;
					obj_data_in[15:14]<=GOB_EXIST;
					obj_data_in[13:10]<=init_x_walker_delay;
					obj_data_in[9:6]<=init_y_walker_delay;
					obj_data_in[5:4]<=LEFT;
					obj_data_in[3:0]<=OBJ_GOB1;
					//obj_data_in<={GOB_EXIST,init_x_walker,init_y_walker,LEFT,OBJ_GOB1};
					FSM_to_obj_index<=OBJ_GOB1;
				end
				OBJ_GOB2: begin
					obj_wr<=1;
					obj_data_in[15:14]<=GOB_EXIST;
					obj_data_in[13:10]<=init_x_walker_delay;
					obj_data_in[9:6]<=init_y_walker_delay;
					obj_data_in[5:4]<=LEFT;
					obj_data_in[3:0]<=OBJ_GOB2;
					//obj_data_in<={GOB_EXIST,init_x_walker,init_y_walker,LEFT,OBJ_GOB2};
					FSM_to_obj_index<=OBJ_GOB2;
				end
				OBJ_MONEYBAG0: begin
					obj_wr<=1;
					obj_data_in[15:14]<=MB_STATIC;
					obj_data_in[13:10]<=init_x_walker_delay;
					obj_data_in[9:6]<=init_y_walker_delay;
					obj_data_in[5:4]<=DOWN;
					obj_data_in[3:0]<=OBJ_MONEYBAG0;
					//obj_data_in<={MB_STATIC,init_x_walker,init_y_walker,DOWN,OBJ_MONEYBAG0};
					FSM_to_obj_index<=OBJ_MONEYBAG0;
				end
				OBJ_MONEYBAG1: begin
					obj_wr<=1;
					obj_data_in[15:14]<=MB_STATIC;
					obj_data_in[13:10]<=init_x_walker_delay;
					obj_data_in[9:6]<=init_y_walker_delay;
					obj_data_in[5:4]<=DOWN;
					obj_data_in[3:0]<=OBJ_MONEYBAG1;
					//obj_data_in<={MB_STATIC,init_x_walker,init_y_walker,DOWN,OBJ_MONEYBAG1};
					FSM_to_obj_index<=OBJ_MONEYBAG1;
				end
				OBJ_MONEYBAG2: begin
					obj_wr<=1;
					obj_data_in[15:14]<=MB_STATIC;
					obj_data_in[13:10]<=init_x_walker_delay;
					obj_data_in[9:6]<=init_y_walker_delay;
					obj_data_in[5:4]<=DOWN;
					obj_data_in[3:0]<=OBJ_MONEYBAG2;
					//obj_data_in<={MB_STATIC,init_x_walker,init_y_walker,DOWN,OBJ_MONEYBAG2};
					FSM_to_obj_index<=OBJ_MONEYBAG2;
				end
				OBJ_MONEYBAG3: begin
					obj_wr<=1;
					obj_data_in[15:14]<=MB_STATIC;
					obj_data_in[13:10]<=init_x_walker_delay;
					obj_data_in[9:6]<=init_y_walker_delay;
					obj_data_in[5:4]<=DOWN;
					obj_data_in[3:0]<=OBJ_MONEYBAG3;
					//obj_data_in<={MB_STATIC,init_x_walker,init_y_walker,DOWN,OBJ_MONEYBAG3};
					FSM_to_obj_index<=OBJ_MONEYBAG3;
				end
				OBJ_MONEYBAG4: begin
					obj_wr<=1;
					obj_data_in[15:14]<=MB_STATIC;
					obj_data_in[13:10]<=init_x_walker_delay;
					obj_data_in[9:6]<=init_y_walker_delay;
					obj_data_in[5:4]<=DOWN;
					obj_data_in[3:0]<=OBJ_MONEYBAG4;
					//obj_data_in<={MB_STATIC,init_x_walker,init_y_walker,DOWN,OBJ_MONEYBAG4};
					FSM_to_obj_index<=OBJ_MONEYBAG4;
				end
				default: begin
					obj_wr<=0;
					obj_data_in<=0;
					FSM_to_obj_index<=0;
				end
			endcase
		end
		else if(state==STATE_HANDLING_REQ) begin
			case(state_req_handle) 
				WAITING_REQ: begin
					if(req && obj_to_FSM_index!=last_object_index) begin
						state_req_handle<=READING_REQ_CONTENT;
						ram_addr<=req_x+req_y*(HMAX+1);
						last_object_index<=obj_to_FSM_index;
					end
					else if(~req) begin
						last_object_index<=0;
					end
					obj_ACK<=0;
					obj_NACK<=0;
					ram_wr<=0;
					ram_data_out_latch<=0;
					obj_wr<=0;
					
				end
				READING_REQ_CONTENT: begin
					if((obj_to_FSM_index==OBJ_DIGGER && req_type==DIGGER_REQ_ROTATE) ||
					   (obj_to_FSM_index==OBJ_MONEYBAG0 && req_type==MB_REQ_TRANSFORM) ||
					   (obj_to_FSM_index==OBJ_MONEYBAG1 && req_type==MB_REQ_TRANSFORM) ||
					   (obj_to_FSM_index==OBJ_MONEYBAG2 && req_type==MB_REQ_TRANSFORM) ||
					   (obj_to_FSM_index==OBJ_MONEYBAG3 && req_type==MB_REQ_TRANSFORM) ||
					   (obj_to_FSM_index==OBJ_MONEYBAG4 && req_type==MB_REQ_TRANSFORM))begin
						state_req_handle<=WRITING_REQ_POS;
					end
					else begin
						
						state_req_handle<=WRITING_ORIG_POS;
					end
				end
				WRITING_ORIG_POS:begin//writing the original position of the objects, and also write the requested objects content
					ram_data_out_latch<=ram_data_out;
					case(obj_to_FSM_index)
						OBJ_DIGGER: begin
							case(req_type)
								DIGGER_REQ_MOVE: begin
									case(ram_data_out)
										OBJ_GOB0,OBJ_GOB1,OBJ_GOB2,OBJ_BULLET: begin 
											obj_NACK<=1;
											FSM_to_obj_index<=OBJ_DIGGER;
											state_req_handle<=WAITING_REQ;
										end
										OBJ_MONEYBAG0: begin
											if(mb0_exist!=MB_GOLDEN) begin
												obj_NACK<=1;
												FSM_to_obj_index<=OBJ_DIGGER;
												state_req_handle<=WAITING_REQ;
											end
											else begin
												score<=score+MONEYBAG_SCORE;
												ram_wr<=1;
												ram_addr<=digger_x+digger_y*(HMAX+1);
												ram_data_in<=OBJ_EMPTY;
												state_req_handle<=WRITING_REQ_POS;
												FSM_to_obj_index<=OBJ_MONEYBAG0;
												obj_wr<=1;
												obj_data_in[15:14]<=MB_NOT_EXIST;
												obj_data_in[13:10]<=HMAX;
												obj_data_in[9:6]<=VMAX;
												obj_data_in[5:4]<=DOWN;
												obj_data_in[3:0]<=OBJ_MONEYBAG0;
											end
										end
										OBJ_MONEYBAG1: begin
											if(mb1_exist!=MB_GOLDEN) begin
												obj_NACK<=1;
												FSM_to_obj_index<=OBJ_DIGGER;
												state_req_handle<=WAITING_REQ;
												
											end
											else begin
												score<=score+MONEYBAG_SCORE;
												ram_wr<=1;
												ram_addr<=digger_x+digger_y*(HMAX+1);
												ram_data_in<=OBJ_EMPTY;
												state_req_handle<=WRITING_REQ_POS;
												FSM_to_obj_index<=OBJ_MONEYBAG1;
												obj_wr<=1;
												obj_data_in[15:14]<=MB_NOT_EXIST;
												obj_data_in[13:10]<=HMAX;
												obj_data_in[9:6]<=VMAX;
												obj_data_in[5:4]<=DOWN;
												obj_data_in[3:0]<=OBJ_MONEYBAG1;
											end
										end
										OBJ_MONEYBAG2: begin
											if(mb2_exist!=MB_GOLDEN) begin
												obj_NACK<=1;
												FSM_to_obj_index<=OBJ_DIGGER;
												state_req_handle<=WAITING_REQ;
												
											end
											else begin
												score<=score+MONEYBAG_SCORE;
												ram_wr<=1;
												ram_addr<=digger_x+digger_y*(HMAX+1);
												ram_data_in<=OBJ_EMPTY;
												state_req_handle<=WRITING_REQ_POS;
												FSM_to_obj_index<=OBJ_MONEYBAG2;
												obj_wr<=1;
												obj_data_in[15:14]<=MB_NOT_EXIST;
												obj_data_in[13:10]<=HMAX;
												obj_data_in[9:6]<=VMAX;
												obj_data_in[5:4]<=DOWN;
												obj_data_in[3:0]<=OBJ_MONEYBAG2;
											end
										end
										OBJ_MONEYBAG3: begin
											if(mb3_exist!=MB_GOLDEN) begin
												obj_NACK<=1;
												FSM_to_obj_index<=OBJ_DIGGER;
												state_req_handle<=WAITING_REQ;
											end
											else begin
												score<=score+MONEYBAG_SCORE;
												ram_wr<=1;
												ram_addr<=digger_x+digger_y*(HMAX+1);
												ram_data_in<=OBJ_EMPTY;
												state_req_handle<=WRITING_REQ_POS;
												FSM_to_obj_index<=OBJ_MONEYBAG3;
												obj_wr<=1;
												obj_data_in[15:14]<=MB_NOT_EXIST;
												obj_data_in[13:10]<=HMAX;
												obj_data_in[9:6]<=VMAX;
												obj_data_in[5:4]<=DOWN;
												obj_data_in[3:0]<=OBJ_MONEYBAG3;
											end
										end
										OBJ_MONEYBAG4: begin
											if(mb4_exist!=MB_GOLDEN) begin
												obj_NACK<=1;
												FSM_to_obj_index<=OBJ_DIGGER;
												state_req_handle<=WAITING_REQ;
											end
											else begin
												score<=score+MONEYBAG_SCORE;
												ram_wr<=1;
												ram_addr<=digger_x+digger_y*(HMAX+1);
												ram_data_in<=OBJ_EMPTY;
												state_req_handle<=WRITING_REQ_POS;
												FSM_to_obj_index<=OBJ_MONEYBAG4;
												obj_wr<=1;
												obj_data_in[15:14]<=MB_NOT_EXIST;
												obj_data_in[13:10]<=HMAX;
												obj_data_in[9:6]<=VMAX;
												obj_data_in[5:4]<=DOWN;
												obj_data_in[3:0]<=OBJ_MONEYBAG4;
											end
										end
										OBJ_DIAMOND: begin//remove the current position of digger
											score<=score+DIAMOND_SCORE;
											ram_wr<=1;
											ram_addr<=digger_x+digger_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
										end
										default: begin//empty block, solid block are both allowed
											ram_wr<=1;
											ram_addr<=digger_x+digger_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
											
										end					
									endcase
								end
								DIGGER_REQ_ROTATE: begin
									state_req_handle<=WRITING_ORIG_POS;
								end
								default: begin
									obj_NACK<=1;
									FSM_to_obj_index<=OBJ_DIGGER;
									state_req_handle<=WAITING_REQ;
								end
							endcase
						end
						OBJ_BULLET: begin
							case(req_type) 
								BULLET_REQ_SHOOT: begin
									case(ram_data_out)
										OBJ_GOB0: begin
											FSM_to_obj_index<=OBJ_GOB0;
											obj_wr<=1;
											obj_data_in[15:14]<=GOB_NOT_EXIST;
											obj_data_in[13:10]<=HMAX;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=RIGHT;
											obj_data_in[3:0]<=OBJ_GOB0;
											//obj_data_in<={GOB_NOT_EXIST,HMAX,VMIN,RIGHT,OBJ_GOB0};
											state_req_handle<=WRITING_REQ_POS;
											score<=score+GOB_SCORE;
										end
										OBJ_GOB1: begin
											FSM_to_obj_index<=OBJ_GOB1;
											obj_wr<=1;
											obj_data_in[15:14]<=GOB_NOT_EXIST;
											obj_data_in[13:10]<=HMAX;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=RIGHT;
											obj_data_in[3:0]<=OBJ_GOB1;
											//obj_data_in<={GOB_NOT_EXIST,HMAX,VMIN,RIGHT,OBJ_GOB1};
											state_req_handle<=WRITING_REQ_POS;
											score<=score+GOB_SCORE;
										end
										OBJ_GOB2: begin
											FSM_to_obj_index<=OBJ_GOB2;
											obj_wr<=1;
											obj_data_in[15:14]<=GOB_NOT_EXIST;
											obj_data_in[13:10]<=HMAX;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=RIGHT;
											obj_data_in[3:0]<=OBJ_GOB2;
											//obj_data_in<={GOB_NOT_EXIST,HMAX,VMIN,RIGHT,OBJ_GOB2};
											state_req_handle<=WRITING_REQ_POS;
											score<=score+GOB_SCORE;
										end
										OBJ_EMPTY: begin
											state_req_handle<=WRITING_REQ_POS;
										end
										default: begin
											obj_NACK<=1;
											FSM_to_obj_index<=OBJ_BULLET;
											state_req_handle<=WAITING_REQ;
										end
									endcase
								end
								BULLET_REQ_MOVE: begin
									case(ram_data_out)
										OBJ_GOB0: begin
											FSM_to_obj_index<=OBJ_GOB0;
											obj_wr<=1;
											obj_data_in[15:14]<=GOB_NOT_EXIST;
											obj_data_in[13:10]<=HMAX;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=RIGHT;
											obj_data_in[3:0]<=OBJ_GOB0;
											//obj_data_in<={GOB_NOT_EXIST,HMAX,VMIN,RIGHT,OBJ_GOB0};
											ram_wr<=1;
											ram_addr<=bullet_x+bullet_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
											score<=score+GOB_SCORE;
										end
										OBJ_GOB1: begin
											FSM_to_obj_index<=OBJ_GOB1;
											obj_wr<=1;
											obj_data_in[15:14]<=GOB_NOT_EXIST;
											obj_data_in[13:10]<=HMAX;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=RIGHT;
											obj_data_in[3:0]<=OBJ_GOB1;
											//obj_data_in<={GOB_NOT_EXIST,HMAX,VMIN,RIGHT,OBJ_GOB1};
											ram_wr<=1;
											ram_addr<=bullet_x+bullet_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
											score<=score+GOB_SCORE;
										end
										OBJ_GOB2: begin
											FSM_to_obj_index<=OBJ_GOB2;
											obj_wr<=1;
											obj_data_in[15:14]<=GOB_NOT_EXIST;
											obj_data_in[13:10]<=HMAX;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=RIGHT;
											obj_data_in[3:0]<=OBJ_GOB2;
											//obj_data_in<={GOB_NOT_EXIST,HMAX,VMIN,RIGHT,OBJ_GOB2};
											ram_wr<=1;
											ram_addr<=bullet_x+bullet_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
											score<=score+GOB_SCORE;
										end
										OBJ_EMPTY: begin
											ram_wr<=1;
											ram_addr<=bullet_x+bullet_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
										end
										default: begin
											obj_NACK<=1;
											FSM_to_obj_index<=OBJ_BULLET;
											ram_wr<=1;
											ram_addr<=bullet_x+bullet_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WAITING_REQ;
										end
									endcase
								end
								BULLET_REQ_DISAPPEAR: begin
									ram_wr<=1;
									ram_addr<=bullet_x+bullet_y*(HMAX+1);
									ram_data_in<=OBJ_EMPTY;
									obj_ACK<=1;
									FSM_to_obj_index<=OBJ_BULLET;
									state_req_handle<=WAITING_REQ;
								end
								default: begin
									obj_NACK<=1;
									FSM_to_obj_index<=OBJ_BULLET;
									state_req_handle<=WAITING_REQ;
								end
							endcase
						end
						OBJ_GOB0: begin
							case(req_type) 
								GOB_REQ_MOVE: begin
									case(ram_data_out)
										OBJ_EMPTY: begin
											ram_wr<=1;
											ram_addr<=gob0_x+gob0_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
										end
										OBJ_DIGGER_LEFT,OBJ_DIGGER_RIGHT,OBJ_DIGGER_UP,OBJ_DIGGER_DOWN: begin
											obj_wr<=1;
											FSM_to_obj_index<=OBJ_DIGGER;
											obj_data_in[15:14]<=DIGGER_NOT_EXIST;
											obj_data_in[13:10]<=HMIN;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=LEFT;
											obj_data_in[3:0]<=OBJ_DIGGER_RIGHT;
											//obj_data_in<={DIGGER_NOT_EXIST,HMIN,VMIN,LEFT,OBJ_DIGGER_RIGHT};
											ram_wr<=1;
											ram_addr<=gob0_x+gob0_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
										end
										OBJ_BULLET: begin
											obj_wr<=1;
											FSM_to_obj_index<=OBJ_BULLET;
											obj_data_in[15:14]<=BULLET_NOT_EXIST;
											obj_data_in[13:10]<=digger_x;
											obj_data_in[9:6]<=digger_y;
											obj_data_in[5:4]<=digger_dir;
											obj_data_in[3:0]<=OBJ_BULLET;
											//obj_data_in<={BULLET_NOT_EXIST,digger_x,digger_y,digger_dir,OBJ_BULLET};
											ram_wr<=1;
											ram_addr<=gob0_x+gob0_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
											score<=score+GOB_SCORE;
										end
										default: begin
											obj_NACK<=1;
											FSM_to_obj_index<=OBJ_GOB0;
											state_req_handle<=WAITING_REQ;											
										end
										
									endcase
								end
								GOB_REQ_DETECT: begin
									if(req_x<HMIN || req_x>HMAX || req_y < VMIN || req_y > VMAX) begin
										obj_NACK<=1;
									end
									else begin
										obj_data_in<={12'd0,ram_data_out};
										obj_ACK<=1;
									end
									FSM_to_obj_index<=OBJ_GOB0;
									state_req_handle<=WAITING_REQ;
								end
								GOB_REQ_CREATE: begin
									if(ram_data_out!=OBJ_EMPTY) begin
										obj_NACK<=1;
									end
									else begin
										obj_ACK<=1;
										ram_wr<=1;
										ram_data_in<=OBJ_GOB0;
										ram_addr<=req_x+req_y*(HMAX+1);
									end
									FSM_to_obj_index<=OBJ_GOB0;
									state_req_handle<=WAITING_REQ;
								end
								default: begin
									obj_NACK<=1;
									FSM_to_obj_index<=OBJ_GOB0;
									state_req_handle<=WAITING_REQ;
								end
							endcase
						end
						OBJ_GOB1: begin
							case(req_type) 
								GOB_REQ_MOVE: begin
									case(ram_data_out)
										OBJ_EMPTY: begin
											ram_wr<=1;
											ram_addr<=gob1_x+gob1_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
										end
										OBJ_DIGGER_LEFT,OBJ_DIGGER_RIGHT,OBJ_DIGGER_UP,OBJ_DIGGER_DOWN: begin
											obj_wr<=1;
											FSM_to_obj_index<=OBJ_DIGGER;
											obj_data_in[15:14]<=DIGGER_NOT_EXIST;
											obj_data_in[13:10]<=HMIN;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=LEFT;
											obj_data_in[3:0]<=OBJ_DIGGER_RIGHT;
											//obj_data_in<={DIGGER_NOT_EXIST,HMIN,VMIN,LEFT,OBJ_DIGGER_RIGHT};
											ram_wr<=1;
											ram_addr<=gob1_x+gob1_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
										end
										OBJ_BULLET: begin
											obj_wr<=1;
											FSM_to_obj_index<=OBJ_BULLET;
											obj_data_in[15:14]<=BULLET_NOT_EXIST;
											obj_data_in[13:10]<=digger_x;
											obj_data_in[9:6]<=digger_y;
											obj_data_in[5:4]<=digger_dir;
											obj_data_in[3:0]<=OBJ_BULLET;
											//obj_data_in<={BULLET_NOT_EXIST,digger_x,digger_y,digger_dir,OBJ_BULLET};
											ram_wr<=1;
											ram_addr<=gob1_x+gob1_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
											score<=score+GOB_SCORE;
										end
										default: begin
											obj_NACK<=1;
											FSM_to_obj_index<=OBJ_GOB1;
											state_req_handle<=WAITING_REQ;											
										end
										
									endcase
								end
								GOB_REQ_DETECT: begin
									if(req_x<HMIN || req_x>HMAX || req_y < VMIN || req_y > VMAX) begin
										obj_NACK<=1;
									end
									else begin
										obj_data_in<={12'd0,ram_data_out};
										obj_ACK<=1;
									end
									FSM_to_obj_index<=OBJ_GOB1;
									state_req_handle<=WAITING_REQ;
								end
								GOB_REQ_CREATE: begin
									if(ram_data_out!=OBJ_EMPTY) begin
										obj_NACK<=1;
									end
									else begin
										obj_ACK<=1;
										ram_wr<=1;
										ram_data_in<=OBJ_GOB1;
										ram_addr<=req_x+req_y*(HMAX+1);
									end
									FSM_to_obj_index<=OBJ_GOB1;
									state_req_handle<=WAITING_REQ;
								end
								default: begin
									obj_NACK<=1;
									FSM_to_obj_index<=OBJ_GOB1;
									state_req_handle<=WAITING_REQ;
								end
							endcase
						end
						OBJ_GOB2: begin
							case(req_type) 
								GOB_REQ_MOVE: begin
									case(ram_data_out)
										OBJ_EMPTY: begin
											ram_wr<=1;
											ram_addr<=gob2_x+gob2_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
										end
										OBJ_DIGGER_LEFT,OBJ_DIGGER_RIGHT,OBJ_DIGGER_UP,OBJ_DIGGER_DOWN: begin
											obj_wr<=1;
											FSM_to_obj_index<=OBJ_DIGGER;
											obj_data_in[15:14]<=DIGGER_NOT_EXIST;
											obj_data_in[13:10]<=HMIN;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=LEFT;
											obj_data_in[3:0]<=OBJ_DIGGER_RIGHT;
											//obj_data_in<={DIGGER_NOT_EXIST,HMIN,VMIN,LEFT,OBJ_DIGGER_RIGHT};
											ram_wr<=1;
											ram_addr<=gob2_x+gob2_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
										end
										OBJ_BULLET: begin
											obj_wr<=1;
											FSM_to_obj_index<=OBJ_BULLET;
											obj_data_in[15:14]<=BULLET_NOT_EXIST;
											obj_data_in[13:10]<=digger_x;
											obj_data_in[9:6]<=digger_y;
											obj_data_in[5:4]<=digger_dir;
											obj_data_in[3:0]<=OBJ_BULLET;
											//obj_data_in<={BULLET_NOT_EXIST,digger_x,digger_y,digger_dir,OBJ_BULLET};
											ram_wr<=1;
											ram_addr<=gob2_x+gob2_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
											score<=score+GOB_SCORE;
										end
										default: begin
											obj_NACK<=1;
											FSM_to_obj_index<=OBJ_GOB2;
											state_req_handle<=WAITING_REQ;											
										end
										
									endcase
								end
								GOB_REQ_DETECT: begin
									if(req_x<HMIN || req_x>HMAX || req_y < VMIN || req_y > VMAX) begin
										obj_NACK<=1;
									end
									else begin
										obj_data_in<={12'd0,ram_data_out};
										obj_ACK<=1;
									end
									FSM_to_obj_index<=OBJ_GOB2;
									state_req_handle<=WAITING_REQ;
								end
								GOB_REQ_CREATE: begin
									if(ram_data_out!=OBJ_EMPTY) begin
										obj_NACK<=1;
									end
									else begin
										obj_ACK<=1;
										ram_wr<=1;
										ram_data_in<=OBJ_GOB2;
										ram_addr<=req_x+req_y*(HMAX+1);
									end
									FSM_to_obj_index<=OBJ_GOB2;
									state_req_handle<=WAITING_REQ;
								end
								default: begin
									obj_NACK<=1;
									FSM_to_obj_index<=OBJ_GOB2;
									state_req_handle<=WAITING_REQ;
								end
							endcase
						end
						OBJ_MONEYBAG0: begin
							case(req_type)
								MB_REQ_DROP: begin
									case(ram_data_out)
										OBJ_EMPTY: begin
											ram_wr<=1;
											ram_addr<=mb0_x+mb0_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
										end
										OBJ_GOB0: begin
											FSM_to_obj_index<=OBJ_GOB0;
											obj_wr<=1;
											obj_data_in[15:14]<=GOB_NOT_EXIST;
											obj_data_in[13:10]<=HMAX;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=RIGHT;
											obj_data_in[3:0]<=OBJ_GOB0;
											//obj_data_in<={GOB_NOT_EXIST,HMAX,VMIN,RIGHT,OBJ_GOB0};
											ram_wr<=1;
											ram_addr<=mb0_x+mb0_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
											score<=score+GOB_SCORE;
										end
										OBJ_GOB1: begin
											FSM_to_obj_index<=OBJ_GOB1;
											obj_wr<=1;
											obj_data_in[15:14]<=GOB_NOT_EXIST;
											obj_data_in[13:10]<=HMAX;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=RIGHT;
											obj_data_in[3:0]<=OBJ_GOB1;
											//obj_data_in<={GOB_NOT_EXIST,HMAX,VMIN,RIGHT,OBJ_GOB1};
											ram_wr<=1;
											ram_addr<=mb0_x+mb0_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
											score<=score+GOB_SCORE;
										end
										OBJ_GOB2: begin
											FSM_to_obj_index<=OBJ_GOB2;
											obj_wr<=1;
											obj_data_in[15:14]<=GOB_NOT_EXIST;
											obj_data_in[13:10]<=HMAX;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=RIGHT;
											obj_data_in[3:0]<=OBJ_GOB2;
											//obj_data_in<={GOB_NOT_EXIST,HMAX,VMIN,RIGHT,OBJ_GOB2};
											ram_wr<=1;
											ram_addr<=mb0_x+mb0_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
											score<=score+GOB_SCORE;
										end
										default: begin
											obj_NACK<=1;
											FSM_to_obj_index<=OBJ_MONEYBAG0;
											state_req_handle<=WAITING_REQ;
										end										
									endcase
								end
								MB_REQ_TRANSFORM: begin
									obj_ACK<=1;
									FSM_to_obj_index<=OBJ_MONEYBAG0;
									state_req_handle<=WAITING_REQ;
								end
								default: begin
									obj_NACK<=1;
									FSM_to_obj_index<=OBJ_MONEYBAG0;
									state_req_handle<=WAITING_REQ;
								end
							endcase
						end
						OBJ_MONEYBAG1: begin
							case(req_type)
								MB_REQ_DROP: begin
									case(ram_data_out)
										OBJ_EMPTY: begin
											ram_wr<=1;
											ram_addr<=mb1_x+mb1_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
										end
										OBJ_GOB0: begin
											FSM_to_obj_index<=OBJ_GOB0;
											obj_wr<=1;
											obj_data_in[15:14]<=GOB_NOT_EXIST;
											obj_data_in[13:10]<=HMAX;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=RIGHT;
											obj_data_in[3:0]<=OBJ_GOB0;
											//obj_data_in<={GOB_NOT_EXIST,HMAX,VMIN,RIGHT,OBJ_GOB0};
											ram_wr<=1;
											ram_addr<=mb1_x+mb1_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
											score<=score+GOB_SCORE;
										end
										OBJ_GOB1: begin
											FSM_to_obj_index<=OBJ_GOB1;
											obj_wr<=1;
											obj_data_in[15:14]<=GOB_NOT_EXIST;
											obj_data_in[13:10]<=HMAX;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=RIGHT;
											obj_data_in[3:0]<=OBJ_GOB1;
											//obj_data_in<={GOB_NOT_EXIST,HMAX,VMIN,RIGHT,OBJ_GOB1};
											ram_wr<=1;
											ram_addr<=mb1_x+mb1_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
											score<=score+GOB_SCORE;
										end
										OBJ_GOB2: begin
											FSM_to_obj_index<=OBJ_GOB2;
											obj_wr<=1;
											obj_data_in[15:14]<=GOB_NOT_EXIST;
											obj_data_in[13:10]<=HMAX;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=RIGHT;
											obj_data_in[3:0]<=OBJ_GOB2;
											//obj_data_in<={GOB_NOT_EXIST,HMAX,VMIN,RIGHT,OBJ_GOB2};
											ram_wr<=1;
											ram_addr<=mb1_x+mb1_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
											score<=score+GOB_SCORE;
										end
										default: begin
											obj_NACK<=1;
											FSM_to_obj_index<=OBJ_MONEYBAG1;
											state_req_handle<=WAITING_REQ;
										end										
									endcase
								end
								MB_REQ_TRANSFORM: begin
									obj_ACK<=1;
									FSM_to_obj_index<=OBJ_MONEYBAG1;
									state_req_handle<=WAITING_REQ;
								end
								default: begin
									obj_NACK<=1;
									FSM_to_obj_index<=OBJ_MONEYBAG1;
									state_req_handle<=WAITING_REQ;
								end
							endcase
						end
						OBJ_MONEYBAG2: begin
							case(req_type)
								MB_REQ_DROP: begin
									case(ram_data_out)
										OBJ_EMPTY: begin
											ram_wr<=1;
											ram_addr<=mb2_x+mb2_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
										end
										OBJ_GOB0: begin
											FSM_to_obj_index<=OBJ_GOB0;
											obj_wr<=1;
											obj_data_in[15:14]<=GOB_NOT_EXIST;
											obj_data_in[13:10]<=HMAX;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=RIGHT;
											obj_data_in[3:0]<=OBJ_GOB0;
											//obj_data_in<={GOB_NOT_EXIST,HMAX,VMIN,RIGHT,OBJ_GOB0};
											ram_wr<=1;
											ram_addr<=mb2_x+mb2_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
											score<=score+GOB_SCORE;
										end
										OBJ_GOB1: begin
											FSM_to_obj_index<=OBJ_GOB1;
											obj_wr<=1;
											obj_data_in[15:14]<=GOB_NOT_EXIST;
											obj_data_in[13:10]<=HMAX;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=RIGHT;
											obj_data_in[3:0]<=OBJ_GOB1;
											//obj_data_in<={GOB_NOT_EXIST,HMAX,VMIN,RIGHT,OBJ_GOB1};
											ram_wr<=1;
											ram_addr<=mb2_x+mb2_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
											score<=score+GOB_SCORE;
										end
										OBJ_GOB2: begin
											FSM_to_obj_index<=OBJ_GOB2;
											obj_wr<=1;
											obj_data_in[15:14]<=GOB_NOT_EXIST;
											obj_data_in[13:10]<=HMAX;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=RIGHT;
											obj_data_in[3:0]<=OBJ_GOB2;
											//obj_data_in<={GOB_NOT_EXIST,HMAX,VMIN,RIGHT,OBJ_GOB2};
											ram_wr<=1;
											ram_addr<=mb2_x+mb2_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
											score<=score+GOB_SCORE;
										end
										default: begin
											obj_NACK<=1;
											FSM_to_obj_index<=OBJ_MONEYBAG2;
											state_req_handle<=WAITING_REQ;
										end										
									endcase
								end
								MB_REQ_TRANSFORM: begin
									obj_ACK<=1;
									FSM_to_obj_index<=OBJ_MONEYBAG2;
									state_req_handle<=WAITING_REQ;
								end
								default: begin
									obj_NACK<=1;
									FSM_to_obj_index<=OBJ_MONEYBAG2;
									state_req_handle<=WAITING_REQ;
								end
							endcase
						end
						OBJ_MONEYBAG3: begin
							case(req_type)
								MB_REQ_DROP: begin
									case(ram_data_out)
										OBJ_EMPTY: begin
											ram_wr<=1;
											ram_addr<=mb3_x+mb3_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
										end
										OBJ_GOB0: begin
											FSM_to_obj_index<=OBJ_GOB0;
											obj_wr<=1;
											obj_data_in[15:14]<=GOB_NOT_EXIST;
											obj_data_in[13:10]<=HMAX;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=RIGHT;
											obj_data_in[3:0]<=OBJ_GOB0;
											//obj_data_in<={GOB_NOT_EXIST,HMAX,VMIN,RIGHT,OBJ_GOB0};
											ram_wr<=1;
											ram_addr<=mb3_x+mb3_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
											score<=score+GOB_SCORE;
										end
										OBJ_GOB1: begin
											FSM_to_obj_index<=OBJ_GOB1;
											obj_wr<=1;
											obj_data_in[15:14]<=GOB_NOT_EXIST;
											obj_data_in[13:10]<=HMAX;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=RIGHT;
											obj_data_in[3:0]<=OBJ_GOB1;
											//obj_data_in<={GOB_NOT_EXIST,HMAX,VMIN,RIGHT,OBJ_GOB1};
											ram_wr<=1;
											ram_addr<=mb3_x+mb3_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
											score<=score+GOB_SCORE;
										end
										OBJ_GOB2: begin
											FSM_to_obj_index<=OBJ_GOB2;
											obj_wr<=1;
											obj_data_in[15:14]<=GOB_NOT_EXIST;
											obj_data_in[13:10]<=HMAX;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=RIGHT;
											obj_data_in[3:0]<=OBJ_GOB2;
											//obj_data_in<={GOB_NOT_EXIST,HMAX,VMIN,RIGHT,OBJ_GOB2};
											ram_wr<=1;
											ram_addr<=mb3_x+mb3_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
											score<=score+GOB_SCORE;
										end
										default: begin
											obj_NACK<=1;
											FSM_to_obj_index<=OBJ_MONEYBAG3;
											state_req_handle<=WAITING_REQ;
										end										
									endcase
								end
								MB_REQ_TRANSFORM: begin
									obj_ACK<=1;
									FSM_to_obj_index<=OBJ_MONEYBAG3;
									state_req_handle<=WAITING_REQ;
								end
								default: begin
									obj_NACK<=1;
									FSM_to_obj_index<=OBJ_MONEYBAG3;
									state_req_handle<=WAITING_REQ;
								end
							endcase
						end
						OBJ_MONEYBAG4: begin
							case(req_type)
								MB_REQ_DROP: begin
									case(ram_data_out)
										OBJ_EMPTY: begin
											ram_wr<=1;
											ram_addr<=mb4_x+mb4_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
										end
										OBJ_GOB0: begin
											FSM_to_obj_index<=OBJ_GOB0;
											obj_wr<=1;
											obj_data_in[15:14]<=GOB_NOT_EXIST;
											obj_data_in[13:10]<=HMAX;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=RIGHT;
											obj_data_in[3:0]<=OBJ_GOB0;
											//obj_data_in<={GOB_NOT_EXIST,HMAX,VMIN,RIGHT,OBJ_GOB0};
											ram_wr<=1;
											ram_addr<=mb4_x+mb4_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
											score<=score+GOB_SCORE;
										end
										OBJ_GOB1: begin
											FSM_to_obj_index<=OBJ_GOB1;
											obj_wr<=1;
											obj_data_in[15:14]<=GOB_NOT_EXIST;
											obj_data_in[13:10]<=HMAX;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=RIGHT;
											obj_data_in[3:0]<=OBJ_GOB1;
											//obj_data_in<={GOB_NOT_EXIST,HMAX,VMIN,RIGHT,OBJ_GOB1};
											ram_wr<=1;
											ram_addr<=mb4_x+mb4_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
											score<=score+GOB_SCORE;
										end
										OBJ_GOB2: begin
											FSM_to_obj_index<=OBJ_GOB2;
											obj_wr<=1;
											obj_data_in[15:14]<=GOB_NOT_EXIST;
											obj_data_in[13:10]<=HMAX;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=RIGHT;
											obj_data_in[3:0]<=OBJ_GOB2;
											//obj_data_in<={GOB_NOT_EXIST,HMAX,VMIN,RIGHT,OBJ_GOB2};
											ram_wr<=1;
											ram_addr<=mb4_x+mb4_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WRITING_REQ_POS;
											score<=score+GOB_SCORE;
										end
										default: begin
											obj_NACK<=1;
											FSM_to_obj_index<=OBJ_MONEYBAG4;
											state_req_handle<=WAITING_REQ;
										end										
									endcase
								end
								MB_REQ_TRANSFORM: begin
									obj_ACK<=1;
									FSM_to_obj_index<=OBJ_MONEYBAG4;
									state_req_handle<=WAITING_REQ;
								end
								default: begin
									obj_NACK<=1;
									FSM_to_obj_index<=OBJ_MONEYBAG4;
									state_req_handle<=WAITING_REQ;
								end
							endcase
						end
						default: begin
							obj_NACK<=1;
							FSM_to_obj_index<=obj_to_FSM_index;
							state_req_handle<=WAITING_REQ;
						end
					endcase
				end
				WRITING_REQ_POS: begin
					
					case(obj_to_FSM_index)
						OBJ_DIGGER: begin
							obj_wr<=0;
							case(req_type)
								DIGGER_REQ_MOVE: begin
									obj_ACK<=1;
									FSM_to_obj_index<=OBJ_DIGGER;
									ram_wr<=1;
									ram_addr<=req_x+req_y*(HMAX+1);
									ram_data_in<=digger_type;
									state_req_handle<=WAITING_REQ;
								end
								DIGGER_REQ_ROTATE: begin
									obj_ACK<=1;
									FSM_to_obj_index<=OBJ_DIGGER;
									ram_wr<=1;
									ram_addr<=digger_x+digger_y*(HMAX+1);
									state_req_handle<=WAITING_REQ;
									case(req_y[1:0])
										UP: ram_data_in<=OBJ_DIGGER_UP;
										DOWN: ram_data_in<=OBJ_DIGGER_DOWN;
										LEFT: ram_data_in<=OBJ_DIGGER_LEFT;
										default: ram_data_in<=OBJ_DIGGER_RIGHT;//right
									endcase
								end
								default: begin
									state_req_handle<=WAITING_REQ;
								end
							endcase						
						end
						OBJ_BULLET: begin
							obj_wr<=0;
							case(req_type)
								BULLET_REQ_SHOOT,BULLET_REQ_MOVE: begin
									case(ram_data_out_latch)
										OBJ_GOB0,OBJ_GOB1,OBJ_GOB2: begin
											obj_NACK<=1;
											FSM_to_obj_index<=OBJ_BULLET;
											ram_wr<=1;
											ram_addr<=req_x+req_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WAITING_REQ;
										end
										OBJ_EMPTY: begin
										    obj_ACK<=1;
											FSM_to_obj_index<=OBJ_BULLET;
											ram_wr<=1;
											ram_addr<=req_x+req_y*(HMAX+1);
											ram_data_in<=OBJ_BULLET;
											state_req_handle<=WAITING_REQ;
										end
										default: begin
											obj_NACK<=1;
											FSM_to_obj_index<=OBJ_BULLET;
											state_req_handle<=WAITING_REQ;
										end
									endcase									
								end
								default: begin
									obj_NACK<=1;
									FSM_to_obj_index<=OBJ_BULLET;
									state_req_handle<=WAITING_REQ;
								end								
							endcase
						end
						
						OBJ_GOB0: begin							
							case(req_type) 
								GOB_REQ_MOVE: begin
									case(ram_data_out_latch)
										OBJ_EMPTY: begin
											obj_ACK<=1;
											FSM_to_obj_index<=OBJ_GOB0;
											ram_wr<=1;
											ram_addr<=req_x+req_y*(HMAX+1);
											ram_data_in<=OBJ_GOB0;
											state_req_handle<=WAITING_REQ;	
										end
										OBJ_DIGGER_LEFT,OBJ_DIGGER_RIGHT,OBJ_DIGGER_UP,OBJ_DIGGER_DOWN: begin
											obj_wr<=0;
											obj_ACK<=1;
											FSM_to_obj_index<=OBJ_GOB0;
											ram_wr<=1;
											ram_addr<=req_x+req_y*(HMAX+1);
											ram_data_in<=OBJ_GOB0;
											state_req_handle<=WAITING_REQ;											
										end
										OBJ_BULLET: begin
											obj_wr<=1;
											obj_data_in[15:14]<=GOB_NOT_EXIST;
											obj_data_in[13:10]<=HMAX;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=LEFT;
											obj_data_in[3:0]<=OBJ_GOB0;
											//obj_data_in={GOB_NOT_EXIST,HMAX,VMIN,LEFT,OBJ_GOB0};
											obj_NACK<=1;
											FSM_to_obj_index<=OBJ_GOB0;
											ram_wr<=1;
											ram_addr<=req_x+req_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WAITING_REQ;	
										
										end
										default: begin
											obj_wr<=0;
											obj_NACK<=1;
											FSM_to_obj_index<=OBJ_GOB0;
											state_req_handle<=WAITING_REQ;
										end
									endcase
								end	
							endcase
						end
						OBJ_GOB1: begin							
							case(req_type) 
								GOB_REQ_MOVE: begin
									case(ram_data_out_latch)
										OBJ_EMPTY: begin
											obj_ACK<=1;
											FSM_to_obj_index<=OBJ_GOB1;
											ram_wr<=1;
											ram_addr<=req_x+req_y*(HMAX+1);
											ram_data_in<=OBJ_GOB1;
											state_req_handle<=WAITING_REQ;	
										end
										OBJ_DIGGER_LEFT,OBJ_DIGGER_RIGHT,OBJ_DIGGER_UP,OBJ_DIGGER_DOWN: begin
											obj_wr<=0;
											obj_ACK<=1;
											FSM_to_obj_index<=OBJ_GOB1;
											ram_wr<=1;
											ram_addr<=req_x+req_y*(HMAX+1);
											ram_data_in<=OBJ_GOB1;
											state_req_handle<=WAITING_REQ;											
										end
										OBJ_BULLET: begin
											obj_wr<=1;
											obj_data_in[15:14]<=GOB_NOT_EXIST;
											obj_data_in[13:10]<=HMAX;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=LEFT;
											obj_data_in[3:0]<=OBJ_GOB1;
											//obj_data_in={GOB_NOT_EXIST,HMAX,VMIN,LEFT,OBJ_GOB1};
											obj_NACK<=1;
											FSM_to_obj_index<=OBJ_GOB1;
											ram_wr<=1;
											ram_addr<=req_x+req_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WAITING_REQ;	
										
										end
										default: begin
											obj_wr<=0;
											obj_NACK<=1;
											FSM_to_obj_index<=OBJ_GOB1;
											state_req_handle<=WAITING_REQ;
										end
									endcase
								end	
							endcase
						end
						OBJ_GOB2: begin							
							case(req_type) 
								GOB_REQ_MOVE: begin
									case(ram_data_out_latch)
										OBJ_EMPTY: begin
											obj_ACK<=1;
											FSM_to_obj_index<=OBJ_GOB2;
											ram_wr<=1;
											ram_addr<=req_x+req_y*(HMAX+1);
											ram_data_in<=OBJ_GOB2;
											state_req_handle<=WAITING_REQ;	
										end
										OBJ_DIGGER_LEFT,OBJ_DIGGER_RIGHT,OBJ_DIGGER_UP,OBJ_DIGGER_DOWN: begin
											obj_wr<=0;
											obj_ACK<=1;
											FSM_to_obj_index<=OBJ_GOB2;
											ram_wr<=1;
											ram_addr<=req_x+req_y*(HMAX+1);
											ram_data_in<=OBJ_GOB2;
											state_req_handle<=WAITING_REQ;											
										end
										OBJ_BULLET: begin
											obj_wr<=1;
											obj_data_in[15:14]<=GOB_NOT_EXIST;
											obj_data_in[13:10]<=HMAX;
											obj_data_in[9:6]<=VMIN;
											obj_data_in[5:4]<=LEFT;
											obj_data_in[3:0]<=OBJ_GOB2;
											//obj_data_in={GOB_NOT_EXIST,HMAX,VMIN,LEFT,OBJ_GOB2};
											obj_NACK<=1;
											FSM_to_obj_index<=OBJ_GOB2;
											ram_wr<=1;
											ram_addr<=req_x+req_y*(HMAX+1);
											ram_data_in<=OBJ_EMPTY;
											state_req_handle<=WAITING_REQ;	
										
										end
										default: begin
											obj_wr<=0;
											obj_NACK<=1;
											FSM_to_obj_index<=OBJ_GOB2;
											state_req_handle<=WAITING_REQ;
										end
									endcase
								end	
							endcase
						end
						OBJ_MONEYBAG0: begin
							obj_wr<=0;
							case(req_type)
								MB_REQ_DROP: begin
									case(ram_data_out_latch)
										OBJ_EMPTY,OBJ_GOB0,OBJ_GOB1,OBJ_GOB2: begin
											obj_ACK<=1;
											FSM_to_obj_index<=OBJ_MONEYBAG0;
											ram_wr<=1;
											ram_addr<=req_x+req_y*(HMAX+1);
											ram_data_in<=OBJ_MONEYBAG0;
											state_req_handle<=WAITING_REQ;
										end
										default: begin
											obj_NACK<=1;
											FSM_to_obj_index<=OBJ_MONEYBAG0;
											state_req_handle<=WAITING_REQ;
										end
							
									endcase
								end
								MB_REQ_TRANSFORM: begin
									obj_ACK<=1;
									FSM_to_obj_index<=OBJ_MONEYBAG0;
									state_req_handle<=WAITING_REQ;
								end
							endcase
						end
						OBJ_MONEYBAG1: begin
							obj_wr<=0;
							case(req_type)
								MB_REQ_DROP: begin
									case(ram_data_out_latch)
										OBJ_EMPTY,OBJ_GOB0,OBJ_GOB1,OBJ_GOB2: begin
											obj_ACK<=1;
											FSM_to_obj_index<=OBJ_MONEYBAG1;
											ram_wr<=1;
											ram_addr<=req_x+req_y*(HMAX+1);
											ram_data_in<=OBJ_MONEYBAG1;
											state_req_handle<=WAITING_REQ;
										end
										default: begin
											obj_NACK<=1;
											FSM_to_obj_index<=OBJ_MONEYBAG1;
											state_req_handle<=WAITING_REQ;
										end
							
									endcase
								end
								MB_REQ_TRANSFORM: begin
									obj_ACK<=1;
									FSM_to_obj_index<=OBJ_MONEYBAG1;
									state_req_handle<=WAITING_REQ;
								end
							endcase
						end
						OBJ_MONEYBAG2: begin
							obj_wr<=0;
							case(req_type)
								MB_REQ_DROP: begin
									case(ram_data_out_latch)
										OBJ_EMPTY,OBJ_GOB0,OBJ_GOB1,OBJ_GOB2: begin
											obj_ACK<=1;
											FSM_to_obj_index<=OBJ_MONEYBAG2;
											ram_wr<=1;
											ram_addr<=req_x+req_y*(HMAX+1);
											ram_data_in<=OBJ_MONEYBAG2;
											state_req_handle<=WAITING_REQ;
										end
										default: begin
											obj_NACK<=1;
											FSM_to_obj_index<=OBJ_MONEYBAG2;
											state_req_handle<=WAITING_REQ;
										end
							
									endcase
								end
								MB_REQ_TRANSFORM: begin
									obj_ACK<=1;
									FSM_to_obj_index<=OBJ_MONEYBAG2;
									state_req_handle<=WAITING_REQ;
								end
							endcase
						end
						OBJ_MONEYBAG3: begin
							obj_wr<=0;
							case(req_type)
								MB_REQ_DROP: begin
									case(ram_data_out_latch)
										OBJ_EMPTY,OBJ_GOB0,OBJ_GOB1,OBJ_GOB2: begin
											obj_ACK<=1;
											FSM_to_obj_index<=OBJ_MONEYBAG3;
											ram_wr<=1;
											ram_addr<=req_x+req_y*(HMAX+1);
											ram_data_in<=OBJ_MONEYBAG3;
											state_req_handle<=WAITING_REQ;
										end
										default: begin
											obj_NACK<=1;
											FSM_to_obj_index<=OBJ_MONEYBAG3;
											state_req_handle<=WAITING_REQ;
										end
							
									endcase
								end
								MB_REQ_TRANSFORM: begin
									obj_ACK<=1;
									FSM_to_obj_index<=OBJ_MONEYBAG3;
									state_req_handle<=WAITING_REQ;
								end
							endcase
						end
						OBJ_MONEYBAG4: begin
							obj_wr<=0;
							case(req_type)
								MB_REQ_DROP: begin
									case(ram_data_out_latch)
										OBJ_EMPTY,OBJ_GOB0,OBJ_GOB1,OBJ_GOB2: begin
											obj_ACK<=1;
											FSM_to_obj_index<=OBJ_MONEYBAG4;
											ram_wr<=1;
											ram_addr<=req_x+req_y*(HMAX+1);
											ram_data_in<=OBJ_MONEYBAG4;
											state_req_handle<=WAITING_REQ;
										end
										default: begin
											obj_NACK<=1;
											FSM_to_obj_index<=OBJ_MONEYBAG4;
											state_req_handle<=WAITING_REQ;
										end
							
									endcase
								end
								MB_REQ_TRANSFORM: begin
									obj_ACK<=1;
									FSM_to_obj_index<=OBJ_MONEYBAG4;
									state_req_handle<=WAITING_REQ;
								end
							endcase
						end
						default: begin
							obj_NACK<=1;
							FSM_to_obj_index<=obj_to_FSM_index;
							state_req_handle<=WAITING_REQ;
						end
					endcase
				end
				default: begin
					state_req_handle<=WAITING_REQ;
				end
			endcase
		end
		else if(state==STATE_GAME_OVER) begin
			game_over<=1;
		end
	end
endmodule	
		
	
	
				
				
				
					
					
				
					
				
				
		
			
	
