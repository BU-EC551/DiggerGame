module clockdivider(
  input clk_in,
  output clk_out,
  output clk100hz,
  output clk_7seg);
  
  reg [31:0] counter1=0;
  reg [31:0] counter2=0;
  reg [31:0] counter3=0;
  
  always@(posedge clk_in)
  begin
    counter1 <= (counter1==100000000)? 0:(counter1+1);
	 // for simulation
	 //counter1 <=(counter1==1)? 0:1;
	 counter2 <= (counter2==204000)? 0:(counter2+1);
	 counter3<=(counter3==1000000)?0:(counter3+1);
  end
  
  assign clk_out = (counter1>=50000000);
  //assign clk_out = counter1;
  assign clk_7seg=(counter2>=102000);
  assign clk100hz=(counter3>=500000);
  

endmodule