`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:36:54 04/02/2015 
// Design Name: 
// Module Name:    ps2_key 
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
module ps2_key(
  input            clk100mhz,           // ʱ���ź�
  input            rst_n,               // ��λ�ź�
  //
  input            ps2_clk,             // PS2�ӿ�ʱ���ź�
  input            ps2_data,             // PS2�ӿ������ź�
  //
  output reg       key_pressed,         // ���̰��±�־
  output reg       reset,
  output reg [2:0] key_val              
);

//++++++++++++++++++++++++++++++++++++++
// ���PS2_CLK���½��� ��ʼ
//++++++++++++++++++++++++++++++++++++++
reg ps2_clk_r0, ps2_clk_r1;

always @ (posedge clk100mhz, negedge rst_n) 
begin
  if (!rst_n) 
  begin
    ps2_clk_r0 <= 1'b0;
    ps2_clk_r1 <= 1'b0;
  end
  else 
  begin
    ps2_clk_r0 <= ps2_clk;
    ps2_clk_r1 <= ps2_clk_r0;
  end
end 

/*              _____       _____       _
 *  ps2_clk_r0:      |_____|     |_____|
 *                    _____       _____
 * ~ps2_clk_r0: _____|     |_____|     |_
 *                _____       _____
 * ps2_clk_r1 : _|     |_____|     |_____
 *                    _           _
 * ps2_clk_n  : _____| |_________| |_____
 */
 //���� ps2_clk_r0 <= ps2_clk;ps2_clk_r1 <= ps2_clk_r0;
 //���ڷ�������ֵ�����ԣ�ps2_clk_r0��ֵ����һ����ʱ֮�󸳸�ps2_clk_r1
 //��ps2_clk_r1�������ps2_clk����ʱ���ʴ˵ó�ps2_clk_n
 
wire ps2_clk_n = (~ps2_clk_r0) & ps2_clk_r1;
//ps2_clk_n��ʾ�ĸߵ�ƽ��ʾʱ�ӵ��½���
//--------------------------------------
// ���PS2_CLK���½��� ����
//--------------------------------------


//++++++++++++++++++++++++++++++++++++++
// ��PS2�ɼ����� ��ʼ
//++++++++++++++++++++++++++++++++++++++
reg [3:0] cnt;                          // ������ 0x0 ~ 0xA

/*1 start bit.  This is always 0. 
8 data bits, least significant bit first. 
1 parity bit (odd parity). 
1 stop bit.  This is always 1. 
                 _     _     _     _     _     _     _     _     _     _     _        
 ps2_clk_n : ___| |___| |___| |___| |___| |___| |___| |___| |___| |___| |___| |__
             ___    _____________________________________________________________
    data   :    \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  
                start bit0  bit1  bit2  bit3  bit4  bit5  bit6  bit7  parity stop  
 
*/


always @ (posedge clk100mhz, negedge rst_n)
begin
  if (!rst_n)
    cnt <= 0;
  else if (ps2_clk_n)                   // ps2_clk���½���
  begin
    if (cnt >= 4'hA)
      cnt <= 0;
    else
      cnt <= cnt + 1'b1;
  end
end

reg [7:0] ps2_byte_buf;                 // �ɼ������ֽڵĻ���

always @ (posedge clk100mhz, negedge rst_n)
begin
  if(!rst_n) 
      ps2_byte_buf <= 8'h0;
  else if (ps2_clk_n)                   // ps2_clk���½���
    case (cnt)
      4'h1    : ps2_byte_buf[0] <= ps2_data;  // bit0
      4'h2    : ps2_byte_buf[1] <= ps2_data;  // bit1
      4'h3    : ps2_byte_buf[2] <= ps2_data;  // bit2
      4'h4    : ps2_byte_buf[3] <= ps2_data;  // bit3
      4'h5    : ps2_byte_buf[4] <= ps2_data;  // bit4
      4'h6    : ps2_byte_buf[5] <= ps2_data;  // bit5
      4'h7    : ps2_byte_buf[6] <= ps2_data;  // bit6
      4'h8    : ps2_byte_buf[7] <= ps2_data;  // bit7
      default : ;
    endcase
end
//--------------------------------------
// ��PS2�ɼ����� ����
//--------------------------------------


//++++++++++++++++++++++++++++++++++++++
// ��ֵ���� ��ʼ
//++++++++++++++++++++++++++++++++++++++
reg key_released;                       // ���յ�����F0���ɿ���־
reg [7:0] ps2_byte;                     // �ɼ������ֽ�

// ��������־
always @ (posedge clk100mhz, negedge rst_n)
begin
  if (!rst_n)
    key_released <= 0;
  else if (cnt == 4'hA)                 // �ɼ���һ���ֽڣ�
  begin
    if (ps2_byte_buf == 8'hF0)          // ���յ�����F0��
      key_released <= 1;                // �ɿ���־��һ
    else
      key_released <= 0;                // �ɿ���־����
  end
end

// �ɼ���ֵ
always @ (posedge clk100mhz, negedge rst_n) 
begin             
  if (!rst_n) 
    key_pressed  <= 0;
  else if (cnt == 4'hA)                 // �ɼ���һ���ֽڣ� 
  begin      
    if (!key_released)                  // �м�������
    begin 
      ps2_byte    <= ps2_byte_buf;      // ���浱ǰ��ֵ
      key_pressed <= 1;                 // ���±�־��һ
    end
    else 
      key_pressed <= 0;                 // ���±�־����
  end
end 
//--------------------------------------
// ��ֵ���� ����
//--------------------------------------


//++++++++++++++++++++++++++++++++++++++
//  
//++++++++++++++++++++++++++++++++++++++
always @ (*) 
  
  case (ps2_byte)
  /*
    8'h16   : key_val <= "1";
    8'h1E   : key_val <= "2";
    8'h26   : key_val <= "3";
    8'h25   : key_val <= "4";
    8'h2E   : key_val <= "5";
    8'h36   : key_val <= "6";
    8'h3D   : key_val <= "7";
    8'h3E   : key_val <= "8";
    8'h46   : key_val <= "9";
    8'h45   : key_val <= "0";
 */
    8'h2D   : begin key_val <= " "; reset <= 1'b1; end        // key R
    8'h72   : begin key_val <= 3'b010; reset <= 1'b0; end     // key 2
    8'h6B   : begin key_val <= 3'b011; reset <= 1'b0; end     // key 4
    8'h74   : begin key_val <= 3'b100; reset <= 1'b0; end     // key 6
    8'h75   : begin key_val <= 3'b001; reset <= 1'b0; end     // key 8
    default : begin key_val <= 3'b000; reset <= 1'b0; end        //default
  endcase
 
//--------------------------------------
// key byte--> move direction ends
//--------------------------------------

endmodule
