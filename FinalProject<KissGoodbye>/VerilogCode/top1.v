module top1
#(
	parameter DATA_WIDTH=4,
	parameter ADDR_WIDTH=8,
	parameter DATA_DEPTH=150
)
(

//from global
	input clk,
	input rst,
	input fire,
	input [1:0] keyboard,
	input sample,

//from VGA ram
	input [DATA_WIDTH-1:0] ram_data_out,
	
//to VGA ram
	output [DATA_WIDTH-1:0] ram_data_in,
	output ram_wr,
	output [ADDR_WIDTH-1:0] ram_addr,

//score
	output [9:0] score,
//game over 
	output game_over,
	output [EXIST_WIDTH-1:0] mb0_exist,
	output [EXIST_WIDTH-1:0] mb1_exist,
	output [EXIST_WIDTH-1:0] mb2_exist,
	output [EXIST_WIDTH-1:0] mb3_exist,
	output [EXIST_WIDTH-1:0] mb4_exist	
    );
	
	parameter H_WIDTH=4;    //Bit width of the horizontal coordinate
	parameter V_WIDTH=4;    //Bit width of the vertical coordinate
	parameter TYPE_WIDTH=4; //Bit width of the width
	parameter DIR_WIDTH=2;  //Bit width of the direction
	parameter EXIST_WIDTH=2;//Bit width of the existence bit
	parameter REQ_TYPE_WIDTH=2;
	parameter REQ_TYPE_WIDTH_WIDTH=1;
	parameter REQ_CONTENT_WIDTH=8;
	parameter REQ_CONTENT_WIDTH_WIDTH=3;
	parameter STATUS_WIDTH=16; //status is concatenated as {exist,x,y,dir,type}
	parameter STATUS_WIDTH_WIDTH=4;
	parameter HMAX=14;
	parameter VMAX=9;
	parameter HMIN=0;
	parameter VMIN=0;
	parameter UP=2'b00;
	parameter DOWN=2'b01;
	parameter LEFT=2'b10;
	parameter RIGHT=2'b11;
	parameter NUMBER_OF_OBJECTS=16;
	parameter OBJECTS_INDEX_WIDTH=4;
	parameter DIAMOND_SCORE=5;
	parameter MONEYBAG_SCORE=20;
	parameter GOB_SCORE=15;
	parameter BULLET_SPEED=49999999;
	parameter GOB_DETECT_FREQ=99999999;
	parameter GOB_CREATE_TIME0=99999999;
	parameter GOB_CREATE_TIME1=999999999;
	parameter GOB_CREATE_TIME2=1999999999;
	parameter MONEYBAG_DROP_SPEED=49999999;
	
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
	
	
	//from FSM to rom
	wire [ADDR_WIDTH-1:0] rom_addr;
	//from rom to FSM
	wire [DATA_WIDTH-1:0] rom_data_out;
	wire [DATA_WIDTH-1:0] rom_data_out1;
	
	//from the objects to arbiter
	wire [NUMBER_OF_OBJECTS-1:0] obj_req;
	wire [REQ_TYPE_WIDTH*NUMBER_OF_OBJECTS-1:0] obj_req_type;
	wire [REQ_CONTENT_WIDTH*NUMBER_OF_OBJECTS-1:0] obj_req_content;
	//from arbiter to objects
	wire [NUMBER_OF_OBJECTS-1:0] obj_wr;
	wire [STATUS_WIDTH*NUMBER_OF_OBJECTS-1:0] obj_data_in;
	wire [NUMBER_OF_OBJECTS-1:0] obj_ACK;
	wire [NUMBER_OF_OBJECTS-1:0] obj_NACK;
	//from FSM to arbiter
	wire FSM_wr;
	wire [STATUS_WIDTH-1:0] FSM_data_in;
	wire FSM_ACK;
	wire FSM_NACK;
	wire [OBJECTS_INDEX_WIDTH-1:0] FSM_to_obj_index;
	//from arbiter to game FSM
	wire FSM_req;
	wire [REQ_TYPE_WIDTH-1:0] FSM_req_type;
	wire [REQ_CONTENT_WIDTH-1:0] FSM_req_content;
	wire [OBJECTS_INDEX_WIDTH-1:0] obj_to_FSM_index;
	
	//from bullet to arbiter
	wire [STATUS_WIDTH-1:0] bullet_status;
	wire bullet_req;
	wire [REQ_TYPE_WIDTH-1:0] bullet_req_type;
	wire [REQ_CONTENT_WIDTH-1:0] bullet_req_content;
	//from arbiter to bullet
	wire bullet_wr;
	wire [STATUS_WIDTH-1:0] bullet_data_in;
	wire bullet_ACK;
	wire bullet_NACK;
	
	//from digger to arbiter
	wire digger_req;
	wire [REQ_TYPE_WIDTH-1:0] digger_req_type;
	wire [REQ_CONTENT_WIDTH-1:0] digger_req_content;
	wire [STATUS_WIDTH-1:0] digger_status;
	//from arbiter to digger
	wire digger_ACK;
	wire digger_NACK;
	wire digger_wr;
	wire [STATUS_WIDTH-1:0] digger_data_in;
	//from digger to bullet
	wire [STATUS_WIDTH-1:0] digger_status_to_bullet;
	
	//from gob0 to arbiter 
	wire gob0_req;
	wire [REQ_TYPE_WIDTH-1:0] gob0_req_type;
	wire [REQ_CONTENT_WIDTH-1:0] gob0_req_content;
	wire [STATUS_WIDTH-1:0] gob0_status;
	//from arbiter to gob0
	wire gob0_wr;
	wire [STATUS_WIDTH-1:0] gob0_data_in;
	wire gob0_ACK;
	wire gob0_NACK;
	
	//from gob1 to arbiter 
	wire gob1_req;
	wire [REQ_TYPE_WIDTH-1:0] gob1_req_type;
	wire [REQ_CONTENT_WIDTH-1:0] gob1_req_content;
	wire [STATUS_WIDTH-1:0] gob1_status;
	//from arbiter to gob1
	wire gob1_wr;
	wire [STATUS_WIDTH-1:0] gob1_data_in;
	wire gob1_ACK;
	wire gob1_NACK;
	
	//from gob2 to arbiter 
	wire gob2_req;
	wire [REQ_TYPE_WIDTH-1:0] gob2_req_type;
	wire [REQ_CONTENT_WIDTH-1:0] gob2_req_content;
	wire [STATUS_WIDTH-1:0] gob2_status;
	//from arbiter to gob2
	wire gob2_wr;
	wire [STATUS_WIDTH-1:0] gob2_data_in;
	wire gob2_ACK;
	wire gob2_NACK;
	
	//from mb0 to arbiter 
	wire mb0_req;
	wire mb0_req_type;
	wire [REQ_CONTENT_WIDTH-1:0] mb0_req_content;
	wire [STATUS_WIDTH-1:0] mb0_status;
	//from arbiter to mb0
	wire mb0_wr;
	wire [STATUS_WIDTH-1:0] mb0_data_in;
	wire mb0_ACK;
	wire mb0_NACK;
	
	//from mb1 to arbiter 
	wire mb1_req;
	wire mb1_req_type;
	wire [REQ_CONTENT_WIDTH-1:0] mb1_req_content;
	wire [STATUS_WIDTH-1:0] mb1_status;
	//from arbiter to mb1
	wire mb1_wr;
	wire [STATUS_WIDTH-1:0] mb1_data_in;
	wire mb1_ACK;
	wire mb1_NACK;
	
	//from mb2 to arbiter 
	wire mb2_req;
	wire mb2_req_type;
	wire [REQ_CONTENT_WIDTH-1:0] mb2_req_content;
	wire [STATUS_WIDTH-1:0] mb2_status;
	//from arbiter to mb0
	wire mb2_wr;
	wire [STATUS_WIDTH-1:0] mb2_data_in;
	wire mb2_ACK;
	wire mb2_NACK;
	
	//from mb3 to arbiter 
	wire mb3_req;
	wire mb3_req_type;
	wire [REQ_CONTENT_WIDTH-1:0] mb3_req_content;
	wire [STATUS_WIDTH-1:0] mb3_status;
	//from arbiter to mb3
	wire mb3_wr;
	wire [STATUS_WIDTH-1:0] mb3_data_in;
	wire mb3_ACK;
	wire mb3_NACK;
	
	//from mb4 to arbiter 
	wire mb4_req;
	wire mb4_req_type;
	wire [REQ_CONTENT_WIDTH-1:0] mb4_req_content;
	wire [STATUS_WIDTH-1:0] mb4_status;
	//from arbiter to mb4
	wire mb4_wr;
	wire [STATUS_WIDTH-1:0] mb4_data_in;
	wire mb4_ACK;
	wire mb4_NACK;
	
	assign obj_req={1'b0,mb4_req,mb3_req,mb2_req,mb1_req,mb0_req,1'b0,gob2_req,gob1_req,gob0_req,bullet_req,3'b000,digger_req,1'b0};
	assign obj_req_type={2'b0,mb4_req_type,mb3_req_type,mb2_req_type,mb1_req_type,mb0_req_type,2'b0,gob2_req_type,gob1_req_type,gob0_req_type,bullet_req_type,6'b0,digger_req_type,2'b0};
	assign obj_req_content={8'b0,mb4_req_content,mb3_req_content,mb2_req_content,mb1_req_content,mb0_req_content,8'b0,gob2_req_content,gob1_req_content,gob0_req_content,bullet_req_content,24'b0,digger_req_content,8'b0};
	
	assign bullet_wr=obj_wr[OBJ_BULLET];
	assign bullet_ACK=obj_ACK[OBJ_BULLET];
	assign bullet_NACK=obj_NACK[OBJ_BULLET];
	assign bullet_data_in=obj_data_in[STATUS_WIDTH*OBJ_BULLET+STATUS_WIDTH-1:STATUS_WIDTH*OBJ_BULLET];

	assign digger_wr=obj_wr[OBJ_DIGGER_LEFT];
	assign digger_ACK=obj_ACK[OBJ_DIGGER_LEFT];
	assign ger_NACK=obj_NACK[OBJ_DIGGER_LEFT];
	assign digger_data_in=obj_data_in[STATUS_WIDTH*OBJ_DIGGER_LEFT+STATUS_WIDTH-1:STATUS_WIDTH*OBJ_DIGGER_LEFT];
	
	assign gob0_wr=obj_wr[OBJ_GOB0];
	assign gob0_ACK=obj_ACK[OBJ_GOB0];
	assign gob0_NACK=obj_NACK[OBJ_GOB0];
	assign gob0_data_in=obj_data_in[STATUS_WIDTH*OBJ_GOB0+STATUS_WIDTH-1:STATUS_WIDTH*OBJ_GOB0];

	assign gob1_wr=obj_wr[OBJ_GOB1];
	assign gob1_ACK=obj_ACK[OBJ_GOB1];
	assign gob1_NACK=obj_NACK[OBJ_GOB1];
	assign gob1_data_in=obj_data_in[STATUS_WIDTH*OBJ_GOB1+STATUS_WIDTH-1:STATUS_WIDTH*OBJ_GOB1];

	assign gob2_wr=obj_wr[OBJ_GOB2];
	assign gob2_ACK=obj_ACK[OBJ_GOB2];
	assign gob2_NACK=obj_NACK[OBJ_GOB2];
	assign gob2_data_in=obj_data_in[STATUS_WIDTH*OBJ_GOB2+STATUS_WIDTH-1:STATUS_WIDTH*OBJ_GOB2];

	assign mb0_wr=obj_wr[OBJ_MONEYBAG0];
	assign mb0_ACK=obj_ACK[OBJ_MONEYBAG0];
	assign mb0_NACK=obj_NACK[OBJ_MONEYBAG0];
	assign mb0_data_in=obj_data_in[STATUS_WIDTH*OBJ_MONEYBAG0+STATUS_WIDTH-1:STATUS_WIDTH*OBJ_MONEYBAG0];
	
	assign mb1_wr=obj_wr[OBJ_MONEYBAG1];
	assign mb1_ACK=obj_ACK[OBJ_MONEYBAG1];
	assign mb1_NACK=obj_NACK[OBJ_MONEYBAG1];
	assign mb1_data_in=obj_data_in[STATUS_WIDTH*OBJ_MONEYBAG1+STATUS_WIDTH-1:STATUS_WIDTH*OBJ_MONEYBAG1];
	
	assign mb2_wr=obj_wr[OBJ_MONEYBAG2];
	assign mb2_ACK=obj_ACK[OBJ_MONEYBAG2];
	assign mb2_NACK=obj_NACK[OBJ_MONEYBAG2];
	assign mb2_data_in=obj_data_in[STATUS_WIDTH*OBJ_MONEYBAG2+STATUS_WIDTH-1:STATUS_WIDTH*OBJ_MONEYBAG2];
	
	assign mb3_wr=obj_wr[OBJ_MONEYBAG3];
	assign mb3_ACK=obj_ACK[OBJ_MONEYBAG3];
	assign mb3_NACK=obj_NACK[OBJ_MONEYBAG3];
	assign mb3_data_in=obj_data_in[STATUS_WIDTH*OBJ_MONEYBAG3+STATUS_WIDTH-1:STATUS_WIDTH*OBJ_MONEYBAG3];
	
	assign mb4_wr=obj_wr[OBJ_MONEYBAG4];
	assign mb4_ACK=obj_ACK[OBJ_MONEYBAG4];
	assign mb4_NACK=obj_NACK[OBJ_MONEYBAG4];
	assign mb4_data_in=obj_data_in[STATUS_WIDTH*OBJ_MONEYBAG4+STATUS_WIDTH-1:STATUS_WIDTH*OBJ_MONEYBAG4];
	



		
// Instantiate the module
arbiter 
#(
	.H_WIDTH  (H_WIDTH),    //Bit width of the horizontal coordinate
	.V_WIDTH  (V_WIDTH),    //Bit width of the vertical coordinate
	.TYPE_WIDTH(TYPE_WIDTH), //Bit width of the width
	.DIR_WIDTH (DIR_WIDTH),  //Bit width of the direction
	.EXIST_WIDTH (EXIST_WIDTH),//Bit width of the existence bit
	.REQ_TYPE_WIDTH(REQ_TYPE_WIDTH),
	.REQ_TYPE_WIDTH_WIDTH(REQ_CONTENT_WIDTH_WIDTH),
	.REQ_CONTENT_WIDTH(REQ_CONTENT_WIDTH),
	.REQ_CONTENT_WIDTH_WIDTH(REQ_CONTENT_WIDTH_WIDTH),
	.STATUS_WIDTH(STATUS_WIDTH), //status is concatenated as {exist,x,y,dir,type}
	.STATUS_WIDTH_WIDTH(STATUS_WIDTH_WIDTH),
	.NUMBER_OF_OBJECTS(NUMBER_OF_OBJECTS),
	.OBJECTS_INDEX_WIDTH(OBJECTS_INDEX_WIDTH)
)arbiter_inst 
(
    .clk(clk), 
    .rst(rst), 
    .obj_req(obj_req), 
    .obj_req_type(obj_req_type), 
    .obj_req_content(obj_req_content), 
    .FSM_wr(FSM_wr), 
    .FSM_data_in(FSM_data_in), 
    .FSM_ACK(FSM_ACK), 
    .FSM_NACK(FSM_NACK), 
    .FSM_to_obj_index(FSM_to_obj_index), 
    .FSM_req(FSM_req), 
    .FSM_req_type(FSM_req_type), 
    .FSM_req_content(FSM_req_content), 
    .obj_to_FSM_index(obj_to_FSM_index), 
    .obj_wr(obj_wr), 
    .obj_data_in(obj_data_in), 
    .obj_ACK(obj_ACK), 
    .obj_NACK(obj_NACK)
    );

// Instantiate the module
bullet 
#(
	.H_WIDTH  (H_WIDTH),    //Bit width of the horizontal coordinate
	.V_WIDTH  (V_WIDTH),    //Bit width of the vertical coordinate
	.TYPE_WIDTH(TYPE_WIDTH), //Bit width of the width
	.DIR_WIDTH (DIR_WIDTH),  //Bit width of the direction
	.EXIST_WIDTH (EXIST_WIDTH),//Bit width of the existence bit
	.REQ_TYPE_WIDTH(REQ_TYPE_WIDTH),
	.REQ_CONTENT_WIDTH(REQ_CONTENT_WIDTH),
	.STATUS_WIDTH(STATUS_WIDTH), //status is concatenated as {exist,x,y,dir,type}
	.HMAX(HMAX),
	.VMAX(VMAX),
	.HMIN(HMIN),
	.VMIN(VMIN),
	.UP(UP),
	.DOWN(DOWN),
	.LEFT(LEFT),
	.RIGHT(RIGHT),
	.BULLET_SPEED(BULLET_SPEED)
)
bullet_inst (
    .clk(clk), 
    .rst(rst), 
    .fire(fire), 
    .wr(bullet_wr), 
    .data_in(bullet_data_in), 
    .ACK(bullet_ACK), 
    .NACK(bullet_NACK), 
    .digger_status(digger_status_to_bullet), 
    .bullet_status(bullet_status), 
    .req(bullet_req), 
    .req_type(bullet_req_type), 
    .req_content(bullet_req_content)
    );
	 
// Instantiate the module
digger  
#(
	.H_WIDTH  (H_WIDTH),    //Bit width of the horizontal coordinate
	.V_WIDTH  (V_WIDTH),    //Bit width of the vertical coordinate
	.TYPE_WIDTH(TYPE_WIDTH), //Bit width of the width
	.DIR_WIDTH (DIR_WIDTH),  //Bit width of the direction
	.EXIST_WIDTH (EXIST_WIDTH),//Bit width of the existence bit
	.REQ_TYPE_WIDTH(REQ_TYPE_WIDTH),
	.REQ_CONTENT_WIDTH(REQ_CONTENT_WIDTH),
	.STATUS_WIDTH(STATUS_WIDTH), //status is concatenated as {exist,x,y,dir,type}
	.HMAX(HMAX),
	.VMAX(VMAX),
	.HINIT(HMIN),
	.VINIT(VMIN),
	.HMIN(HMIN),
	.VMIN(VMIN),
	.UP(UP),
	.DOWN(DOWN),
	.LEFT(LEFT),
	.RIGHT(RIGHT))
	digger_inst
	 (
    .clk(clk), 
    .rst(rst), 
    .keyboard(keyboard), 
    .sample(sample), 
    .ACK(digger_ACK), 
    .NACK(digger_NACK), 
    .wr(digger_wr), 
    .data_in(digger_data_in), 
    .req(digger_req), 
    .req_type(digger_req_type), 
    .req_content(digger_req_content), 
    .status(digger_status), 
    .status_to_bullet(digger_status_to_bullet)
    );

map_ROM 
#(
	.DATA_DEPTH(DATA_DEPTH),
	.DATA_WIDTH(DATA_WIDTH),
	.ADDR_WIDTH(ADDR_WIDTH)
	)
map_ROM_inst0(
	.addr(rom_addr),
	.data_out(rom_data_out)
);

map_ROM_1
#(
	.DATA_DEPTH(DATA_DEPTH),
	.DATA_WIDTH(DATA_WIDTH),
	.ADDR_WIDTH(ADDR_WIDTH)
)
map_ROM_inst1(
	.addr(rom_addr),
	.data_out(rom_data_out1)
);

// Instantiate the module
game_FSM #(
	.H_WIDTH  (H_WIDTH),    //Bit width of the horizontal coordinate
	.V_WIDTH  (V_WIDTH),    //Bit width of the vertical coordinate
	.TYPE_WIDTH(TYPE_WIDTH), //Bit width of the width
	.DIR_WIDTH (DIR_WIDTH),  //Bit width of the direction
	.EXIST_WIDTH (EXIST_WIDTH),//Bit width of the existence bit
	.REQ_TYPE_WIDTH(REQ_TYPE_WIDTH),
	.REQ_CONTENT_WIDTH(REQ_CONTENT_WIDTH),
	.STATUS_WIDTH(STATUS_WIDTH), //status is concatenated as {exist,x,y,dir,type}
	.HMAX(HMAX),
	.VMAX(VMAX),
	.HMIN(HMIN),
	.VMIN(VMIN),
	.UP(UP),
	.DOWN(DOWN),
	.LEFT(LEFT),
	.RIGHT(RIGHT),
	.NUMBER_OF_OBJECTS(NUMBER_OF_OBJECTS),
	.OBJECTS_INDEX_WIDTH(OBJECTS_INDEX_WIDTH),
	.ADDR_WIDTH(ADDR_WIDTH),
	.DIAMOND_SCORE(5),
	.MONEYBAG_SCORE(20),
	.GOB_SCORE(15)
)
game_FSM_inst (
    .clk(clk), 
    .rst(rst), 
    .digger_status(digger_status), 
    .gob0_status(gob0_status), 
    .gob1_status(gob1_status), 
    .gob2_status(gob2_status), 
    .bullet_status(bullet_status), 
    .mb0_status(mb0_status), 
    .mb1_status(mb1_status), 
    .mb2_status(mb2_status), 
    .mb3_status(mb3_status), 
    .mb4_status(mb4_status), 
    .req_type(FSM_req_type), 
    .req_content(FSM_req_content), 
    .req(FSM_req), 
    .obj_to_FSM_index(obj_to_FSM_index), 
    .ram_data_out(ram_data_out), 
    .rom_data_out(rom_data_out), 
	 .rom_data_out1(rom_data_out1),
    .rom_addr(rom_addr), 
    .ram_wr(ram_wr), 
    .ram_data_in(ram_data_in), 
    .ram_addr(ram_addr), 
    .obj_wr(FSM_wr), 
    .obj_data_in(FSM_data_in), 
    .obj_ACK(FSM_ACK), 
    .obj_NACK(FSM_NACK), 
    .FSM_to_obj_index(FSM_to_obj_index),
	.score(score),
	.game_over(game_over),
	.mb0_exist(mb0_exist),
	.mb1_exist(mb1_exist),
	.mb2_exist(mb2_exist),
	.mb3_exist(mb3_exist),
	.mb4_exist(mb4_exist)
    );


// Instantiate the module
goblin1 
#(
	.H_WIDTH  (H_WIDTH),    //Bit width of the horizontal coordinate
	.V_WIDTH  (V_WIDTH),    //Bit width of the vertical coordinate
	.TYPE_WIDTH(TYPE_WIDTH), //Bit width of the width
	.DIR_WIDTH (DIR_WIDTH),  //Bit width of the direction
	.EXIST_WIDTH (EXIST_WIDTH),//Bit width of the existence bit
	.REQ_TYPE_WIDTH(REQ_TYPE_WIDTH),
	.REQ_CONTENT_WIDTH(REQ_CONTENT_WIDTH),
	.STATUS_WIDTH(STATUS_WIDTH), //status is concatenated as {exist,x,y,dir,type}
	.HMAX(HMAX),
	.VMAX(VMAX),
	.HINIT(HMAX),
	.VINIT(VMIN),
	.HMIN(HMIN),
	.VMIN(VMIN),
	.UP(UP),
	.DOWN(DOWN),
	.LEFT(LEFT),
	.RIGHT(RIGHT),
	.DETECT_FREQ(GOB_DETECT_FREQ),
	.CREATION_TIME(GOB_CREATE_TIME0)
)
gob0_inst
 (
    .clk(clk), 
    .rst(rst), 
    .wr(gob0_wr), 
    .data_in(gob0_data_in), 
    .ACK(gob0_ACK), 
    .NACK(gob0_NACK), 
    .digger_status(digger_status), 
    .req(gob0_req), 
    .req_type(gob0_req_type), 
    .req_content(gob0_req_content), 
	.status(gob0_status),
    .GameOver(go0)
    );

// Instantiate the module
goblin1 
#(
	.H_WIDTH  (H_WIDTH),    //Bit width of the horizontal coordinate
	.V_WIDTH  (V_WIDTH),    //Bit width of the vertical coordinate
	.TYPE_WIDTH(TYPE_WIDTH), //Bit width of the width
	.DIR_WIDTH (DIR_WIDTH),  //Bit width of the direction
	.EXIST_WIDTH (EXIST_WIDTH),//Bit width of the existence bit
	.REQ_TYPE_WIDTH(REQ_TYPE_WIDTH),
	.REQ_CONTENT_WIDTH(REQ_CONTENT_WIDTH),
	.STATUS_WIDTH(STATUS_WIDTH), //status is concatenated as {exist,x,y,dir,type}
	.HMAX(HMAX),
	.VMAX(VMAX),
	.HINIT(HMAX),
	.VINIT(VMIN),
	.HMIN(HMIN),
	.VMIN(VMIN),
	.UP(UP),
	.DOWN(DOWN),
	.LEFT(LEFT),
	.RIGHT(RIGHT),
	.DETECT_FREQ(GOB_DETECT_FREQ),
	.CREATION_TIME(GOB_CREATE_TIME1)
)
 gob1_inst(
    .clk(clk), 
    .rst(rst), 
    .wr(gob1_wr), 
    .data_in(gob1_data_in), 
    .ACK(gob1_ACK), 
    .NACK(gob1_NACK), 
    .digger_status(digger_status), 
    .req(gob1_req), 
    .req_type(gob1_req_type), 
    .req_content(gob1_req_content), 
	.status(gob1_status),
    .GameOver(go1)
    );
	
// Instantiate the module
goblin1 
#(
	.H_WIDTH  (H_WIDTH),    //Bit width of the horizontal coordinate
	.V_WIDTH  (V_WIDTH),    //Bit width of the vertical coordinate
	.TYPE_WIDTH(TYPE_WIDTH), //Bit width of the width
	.DIR_WIDTH (DIR_WIDTH),  //Bit width of the direction
	.EXIST_WIDTH (EXIST_WIDTH),//Bit width of the existence bit
	.REQ_TYPE_WIDTH(REQ_TYPE_WIDTH),
	.REQ_CONTENT_WIDTH(REQ_CONTENT_WIDTH),
	.STATUS_WIDTH(STATUS_WIDTH), //status is concatenated as {exist,x,y,dir,type}
	.HMAX(HMAX),
	.VMAX(VMAX),
	.HINIT(HMAX),
	.VINIT(VMIN),
	.HMIN(HMIN),
	.VMIN(VMIN),
	.UP(UP),
	.DOWN(DOWN),
	.LEFT(LEFT),
	.RIGHT(RIGHT),
	.DETECT_FREQ(GOB_DETECT_FREQ),
	.CREATION_TIME(GOB_CREATE_TIME2)
)
 gob2_inst(
    .clk(clk), 
    .rst(rst), 
    .wr(gob2_wr), 
    .data_in(gob2_data_in), 
    .ACK(gob2_ACK), 
    .NACK(gob2_NACK), 
    .digger_status(digger_status), 
    .req(gob2_req), 
    .req_type(gob2_req_type), 
    .req_content(gob2_req_content), 
	.status(gob2_status),
    .GameOver(go2)
    );

money_bag #(
	.H_WIDTH  (H_WIDTH),    //Bit width of the horizontal coordinate
	.V_WIDTH  (V_WIDTH),    //Bit width of the vertical coordinate
	.TYPE_WIDTH(TYPE_WIDTH), //Bit width of the width
	.DIR_WIDTH (DIR_WIDTH),  //Bit width of the direction
	.EXIST_WIDTH (EXIST_WIDTH),//Bit width of the existence bit
	.REQ_TYPE_WIDTH(REQ_TYPE_WIDTH),
	.REQ_CONTENT_WIDTH(REQ_CONTENT_WIDTH),
	.STATUS_WIDTH(STATUS_WIDTH), //status is concatenated as {exist,x,y,dir,type}
	.HMAX(HMAX),
	.VMAX(VMAX),
	.HINIT(),
	.VINIT(),
	.HMIN(HMIN),
	.VMIN(VMIN),
	.UP(UP),
	.DOWN(DOWN),
	.LEFT(LEFT),
	.RIGHT(RIGHT),
	.MONEYBAG_ID(OBJ_MONEYBAG0),
	.MONEYBAG_DROP_SPEED(MONEYBAG_DROP_SPEED)
)
mb0_inst(
	.clk(clk), 
    .rst(rst), 
    .wr(mb0_wr), 
    .data_in(mb0_data_in), 
    .ACK(mb0_ACK), 
    .NACK(mb0_NACK), 
    .req(mb0_req), 
    .req_type(mb0_req_type), 
    .req_content(mb0_req_content), 
	.status(mb0_status)
);

money_bag #(
	.H_WIDTH  (H_WIDTH),    //Bit width of the horizontal coordinate
	.V_WIDTH  (V_WIDTH),    //Bit width of the vertical coordinate
	.TYPE_WIDTH(TYPE_WIDTH), //Bit width of the width
	.DIR_WIDTH (DIR_WIDTH),  //Bit width of the direction
	.EXIST_WIDTH (EXIST_WIDTH),//Bit width of the existence bit
	.REQ_TYPE_WIDTH(REQ_TYPE_WIDTH),
	.REQ_CONTENT_WIDTH(REQ_CONTENT_WIDTH),
	.STATUS_WIDTH(STATUS_WIDTH), //status is concatenated as {exist,x,y,dir,type}
	.HMAX(HMAX),
	.VMAX(VMAX),
	.HINIT(),
	.VINIT(),
	.HMIN(HMIN),
	.VMIN(VMIN),
	.UP(UP),
	.DOWN(DOWN),
	.LEFT(LEFT),
	.RIGHT(RIGHT),
	.MONEYBAG_ID(OBJ_MONEYBAG1),
	.MONEYBAG_DROP_SPEED(MONEYBAG_DROP_SPEED)
)
mb1_inst(
	.clk(clk), 
    .rst(rst), 
    .wr(mb1_wr), 
    .data_in(mb1_data_in), 
    .ACK(mb1_ACK), 
    .NACK(mb1_NACK), 
    .req(mb1_req), 
    .req_type(mb1_req_type), 
    .req_content(mb1_req_content), 
	.status(mb1_status)
);

money_bag #(
	.H_WIDTH  (H_WIDTH),    //Bit width of the horizontal coordinate
	.V_WIDTH  (V_WIDTH),    //Bit width of the vertical coordinate
	.TYPE_WIDTH(TYPE_WIDTH), //Bit width of the width
	.DIR_WIDTH (DIR_WIDTH),  //Bit width of the direction
	.EXIST_WIDTH (EXIST_WIDTH),//Bit width of the existence bit
	.REQ_TYPE_WIDTH(REQ_TYPE_WIDTH),
	.REQ_CONTENT_WIDTH(REQ_CONTENT_WIDTH),
	.STATUS_WIDTH(STATUS_WIDTH), //status is concatenated as {exist,x,y,dir,type}
	.HMAX(HMAX),
	.VMAX(VMAX),
	.HINIT(),
	.VINIT(),
	.HMIN(HMIN),
	.VMIN(VMIN),
	.UP(UP),
	.DOWN(DOWN),
	.LEFT(LEFT),
	.RIGHT(RIGHT),
	.MONEYBAG_ID(OBJ_MONEYBAG2),
	.MONEYBAG_DROP_SPEED(MONEYBAG_DROP_SPEED)
)
mb2_inst(
	.clk(clk), 
    .rst(rst), 
    .wr(mb2_wr), 
    .data_in(mb2_data_in), 
    .ACK(mb2_ACK), 
    .NACK(mb2_NACK), 
    .req(mb2_req), 
    .req_type(mb2_req_type), 
    .req_content(mb2_req_content), 
	.status(mb2_status)
);

money_bag #(
	.H_WIDTH  (H_WIDTH),    //Bit width of the horizontal coordinate
	.V_WIDTH  (V_WIDTH),    //Bit width of the vertical coordinate
	.TYPE_WIDTH(TYPE_WIDTH), //Bit width of the width
	.DIR_WIDTH (DIR_WIDTH),  //Bit width of the direction
	.EXIST_WIDTH (EXIST_WIDTH),//Bit width of the existence bit
	.REQ_TYPE_WIDTH(REQ_TYPE_WIDTH),
	.REQ_CONTENT_WIDTH(REQ_CONTENT_WIDTH),
	.STATUS_WIDTH(STATUS_WIDTH), //status is concatenated as {exist,x,y,dir,type}
	.HMAX(HMAX),
	.VMAX(VMAX),
	.HINIT(),
	.VINIT(),
	.HMIN(HMIN),
	.VMIN(VMIN),
	.UP(UP),
	.DOWN(DOWN),
	.LEFT(LEFT),
	.RIGHT(RIGHT),
	.MONEYBAG_ID(OBJ_MONEYBAG3),
	.MONEYBAG_DROP_SPEED(MONEYBAG_DROP_SPEED)
)
mb3_inst(
	.clk(clk), 
    .rst(rst), 
    .wr(mb3_wr), 
    .data_in(mb3_data_in), 
    .ACK(mb3_ACK), 
    .NACK(mb3_NACK), 
    .req(mb3_req), 
    .req_type(mb3_req_type), 
    .req_content(mb3_req_content), 
	.status(mb3_status)
);

money_bag #(
	.H_WIDTH  (H_WIDTH),    //Bit width of the horizontal coordinate
	.V_WIDTH  (V_WIDTH),    //Bit width of the vertical coordinate
	.TYPE_WIDTH(TYPE_WIDTH), //Bit width of the width
	.DIR_WIDTH (DIR_WIDTH),  //Bit width of the direction
	.EXIST_WIDTH (EXIST_WIDTH),//Bit width of the existence bit
	.REQ_TYPE_WIDTH(REQ_TYPE_WIDTH),
	.REQ_CONTENT_WIDTH(REQ_CONTENT_WIDTH),
	.STATUS_WIDTH(STATUS_WIDTH), //status is concatenated as {exist,x,y,dir,type}
	.HMAX(HMAX),
	.VMAX(VMAX),
	.HINIT(),
	.VINIT(),
	.HMIN(HMIN),
	.VMIN(VMIN),
	.UP(UP),
	.DOWN(DOWN),
	.LEFT(LEFT),
	.RIGHT(RIGHT),
	.MONEYBAG_ID(OBJ_MONEYBAG4),
	.MONEYBAG_DROP_SPEED(MONEYBAG_DROP_SPEED)
)
mb4_inst(
	.clk(clk), 
    .rst(rst), 
    .wr(mb4_wr), 
    .data_in(mb4_data_in), 
    .ACK(mb4_ACK), 
    .NACK(mb4_NACK), 
    .req(mb4_req), 
    .req_type(mb4_req_type), 
    .req_content(mb4_req_content), 
	.status(mb4_status)
);


endmodule



