module arbiter
#(
	parameter H_WIDTH=4,    //Bit width of the horizontal coordinate
	parameter V_WIDTH=4,    //Bit width of the vertical coordinate
	parameter TYPE_WIDTH=4, //Bit width of the width
	parameter DIR_WIDTH=2,  //Bit width of the direction
	parameter EXIST_WIDTH=2,//Bit width of the existence bit
	parameter REQ_TYPE_WIDTH=2,
	parameter REQ_TYPE_WIDTH_WIDTH=1,
	parameter REQ_CONTENT_WIDTH=8,
	parameter REQ_CONTENT_WIDTH_WIDTH=3,
	parameter STATUS_WIDTH=16, //status is concatenated as {exist,x,y,dir,type}
	parameter STATUS_WIDTH_WIDTH=4,
	parameter NUMBER_OF_OBJECTS=16,
	parameter OBJECTS_INDEX_WIDTH=4
)
(//from global
	input clk,
	input rst,
//from objects
	input [NUMBER_OF_OBJECTS-1:0] obj_req,
	input [REQ_TYPE_WIDTH*NUMBER_OF_OBJECTS-1:0] obj_req_type,
	input [REQ_CONTENT_WIDTH*NUMBER_OF_OBJECTS-1:0] obj_req_content,
//	input [STATUS_WIDTH*NUMBER_OF_OBJECTS-1:0] obj_status,

//from Game FSM
	input FSM_wr,
	input [STATUS_WIDTH-1:0] FSM_data_in,
	input FSM_ACK,
	input FSM_NACK,
	input [OBJECTS_INDEX_WIDTH-1:0] FSM_to_obj_index,

//to game FSM
	output reg FSM_req,
	output reg [REQ_TYPE_WIDTH-1:0] FSM_req_type,
	output reg [REQ_CONTENT_WIDTH-1:0] FSM_req_content,
//	output reg [STATUS_WIDTH-1:0] FSM_status,
	output reg [OBJECTS_INDEX_WIDTH-1:0] obj_to_FSM_index,
	
//to objects
	output reg [NUMBER_OF_OBJECTS-1:0] obj_wr,
	output reg [STATUS_WIDTH*NUMBER_OF_OBJECTS-1:0] obj_data_in,
	output reg [NUMBER_OF_OBJECTS-1:0] obj_ACK,
	output reg [NUMBER_OF_OBJECTS-1:0] obj_NACK
 );
 
	integer i1,i2,i3;
	always@(posedge clk) begin
		if(rst) begin
			obj_to_FSM_index<=0;
			FSM_req<=0;
			FSM_req_type<=0;
			FSM_req_content<=0;
			//FSM_status<=0;
		end
		else begin
			if(obj_req[obj_to_FSM_index]) begin
				FSM_req<=obj_req[obj_to_FSM_index];
				FSM_req_type<={obj_req_type[{obj_to_FSM_index,1'b1}],obj_req_type[{obj_to_FSM_index,1'b0}]};
//				FSM_req_type<=obj_req_type[(obj_to_FSM_index<<REQ_TYPE_WIDTH_WIDTH)+REQ_TYPE_WIDTH-1:(obj_to_FSM_index<<REQ_TYPE_WIDTH_WIDTH)];
        FSM_req_content<={obj_req_content[{obj_to_FSM_index,3'd7}],obj_req_content[{obj_to_FSM_index,3'd6}],
                          obj_req_content[{obj_to_FSM_index,3'd5}],obj_req_content[{obj_to_FSM_index,3'd4}],
                          obj_req_content[{obj_to_FSM_index,3'd3}],obj_req_content[{obj_to_FSM_index,3'd2}],
                          obj_req_content[{obj_to_FSM_index,3'd1}],obj_req_content[{obj_to_FSM_index,3'd0}]};
				//FSM_req_content<=obj_req_content[(obj_to_FSM_index<<REQ_CONTENT_WIDTH_WIDTH)+REQ_CONTENT_WIDTH-1:(obj_to_FSM_index<<REQ_CONTENT_WIDTH_WIDTH)];
			//	FSM_status<=obj_status[(obj_to_FSM_index<<REQ_CONTENT_WIDTH_WIDTH)+REQ_CONTENT_WIDTH-1:(obj_to_FSM_index<<REQ_CONTENT_WIDTH_WIDTH)];
			end
			else begin
				obj_to_FSM_index<=obj_to_FSM_index+1;
				FSM_req<=0;
				FSM_req_type<=0;
				FSM_req_content<=0;
			//	FSM_status<=0;
			end
		end
	end
	
	always@(*) begin
			case(FSM_to_obj_index)
				4'd0: begin obj_data_in<={240'd0,FSM_data_in}; end
				4'd1: begin obj_data_in<={224'd0,FSM_data_in,16'd0}; end
				4'd2: begin obj_data_in<={208'd0,FSM_data_in,32'd0}; end
				4'd3: begin obj_data_in<={192'd0,FSM_data_in,48'd0}; end
				4'd4: begin obj_data_in<={176'd0,FSM_data_in,64'd0}; end
				4'd5: begin obj_data_in<={160'd0,FSM_data_in,80'd0}; end
				4'd6: begin obj_data_in<={144'd0,FSM_data_in,96'd0}; end
				4'd7: begin obj_data_in<={128'd0,FSM_data_in,112'd0}; end
				4'd8: begin obj_data_in<={112'd0,FSM_data_in,128'd0}; end
				4'd9: begin obj_data_in<={96'd0,FSM_data_in,144'd0}; end
				4'd10: begin obj_data_in<={80'd0,FSM_data_in,160'd0}; end
				4'd11: begin obj_data_in<={64'd0,FSM_data_in,176'd0}; end
				4'd12: begin obj_data_in<={48'd0,FSM_data_in,192'd0}; end
				4'd13: begin obj_data_in<={32'd0,FSM_data_in,208'd0}; end
				4'd14: begin obj_data_in<={16'd0,FSM_data_in,224'd0}; end
				default: begin obj_data_in<={FSM_data_in,240'd0}; end
			endcase
	end
	
	always@(*) begin
		if(FSM_wr) begin
			for(i1=0;i1<NUMBER_OF_OBJECTS;i1=i1+1) begin
				obj_wr[i1]<=(i1==FSM_to_obj_index);
			end
		end
		else begin
			obj_wr<=0;
		end
	end
	
	always@(*) begin
		if(FSM_ACK) begin
			for(i2=0;i2<NUMBER_OF_OBJECTS;i2=i2+1) begin
				obj_ACK[i2]<=(i2==FSM_to_obj_index);
			end
		end
		else begin
			obj_ACK<=0;
		end
	end
	
	always@(*) begin
		if(FSM_NACK) begin
			for(i3=0;i3<NUMBER_OF_OBJECTS;i3=i3+1) begin
				obj_NACK[i3]<=(i3==FSM_to_obj_index);
			end
		end
		else begin
			obj_NACK<=0;
		end
	end
endmodule
	
					
	