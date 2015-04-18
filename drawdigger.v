module usermode(clk25m, clk100hz, hpos, vpos, button, usercolors);
   //inputs
   input            clk25m;
   input            clk100hz;
   input [9:0]      hpos;
   input [9:0]      vpos;
   input [4:0]      button;
   
   //outputs
   output [11:0]     usercolors;
   reg [11:0]        usercolors;
   
   reg [9:0]        hmov;
   reg [9:0]        vmov;
	reg [9:0]        hmov1;
   reg [9:0]        vmov1;


  //draw a rectangle  ��ͼ�� 
   always @(posedge clk25m)      
      begin
         if ((hpos > (hmov - 10)) & (hpos < (hmov + 10)) & (vpos > (vmov - 10)) & (vpos < (vmov + 10)))            
            usercolors <= 12'b01100010; //�����Ǿ��Σ����Ե�������parameter�ļ��ѿ󹤵�ͼ����Ϊ����
         else
            usercolors <= 12'b0;
      end
  
  //rectangle movement 
   always @(posedge clk100hz)    
      begin
            if ((hmov > 630) | (vmov > 470) | (hmov < 10) | (vmov < 10))
            begin
               hmov <= 10'b0101000000;
               vmov <= 10'b0011110000;
            end
            else
               case (button)
                  5'b01000 :begin
                     hmov <= hmov - 1;
                  end
						5'b00100 :begin
                     hmov <= hmov + 1;
                  end
						5'b00010 :begin
                     vmov <= vmov - 1;
                  end
						5'b00001 :begin
                     vmov <= vmov + 1;
                  end
						default :
                     ;
               endcase
      end
endmodule
