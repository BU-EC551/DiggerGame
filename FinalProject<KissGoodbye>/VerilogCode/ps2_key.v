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
  input            clk100mhz,           // 时钟信号
  input            rst_n,               // 复位信号
  //
  input            ps2_clk,             // PS2接口时钟信号
  input            ps2_data,             // PS2接口数据信号
  //
  output reg       key_pressed,         // 键盘按下标志
  output reg       reset,
  output reg [2:0] key_val              
);

//++++++++++++++++++++++++++++++++++++++
// 检测PS2_CLK的下降沿 开始
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
 //由于 ps2_clk_r0 <= ps2_clk;ps2_clk_r1 <= ps2_clk_r0;
 //属于非阻塞赋值，所以，ps2_clk_r0的值会在一段延时之后赋给ps2_clk_r1
 //致ps2_clk_r1与最初的ps2_clk出现时间差，故此得出ps2_clk_n
 
wire ps2_clk_n = (~ps2_clk_r0) & ps2_clk_r1;
//ps2_clk_n表示的高电平表示时钟的下降沿
//--------------------------------------
// 检测PS2_CLK的下降沿 结束
//--------------------------------------


//++++++++++++++++++++++++++++++++++++++
// 从PS2采集数据 开始
//++++++++++++++++++++++++++++++++++++++
reg [3:0] cnt;                          // 计数子 0x0 ~ 0xA

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
  else if (ps2_clk_n)                   // ps2_clk的下降沿
  begin
    if (cnt >= 4'hA)
      cnt <= 0;
    else
      cnt <= cnt + 1'b1;
  end
end

reg [7:0] ps2_byte_buf;                 // 采集到的字节的缓存

always @ (posedge clk100mhz, negedge rst_n)
begin
  if(!rst_n) 
      ps2_byte_buf <= 8'h0;
  else if (ps2_clk_n)                   // ps2_clk的下降沿
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
// 从PS2采集数据 结束
//--------------------------------------


//++++++++++++++++++++++++++++++++++++++
// 键值处理 开始
//++++++++++++++++++++++++++++++++++++++
reg key_released;                       // 接收到段码F0后，松开标志
reg [7:0] ps2_byte;                     // 采集到的字节

// 处理断码标志
always @ (posedge clk100mhz, negedge rst_n)
begin
  if (!rst_n)
    key_released <= 0;
  else if (cnt == 4'hA)                 // 采集完一个字节？
  begin
    if (ps2_byte_buf == 8'hF0)          // 接收到段码F0后
      key_released <= 1;                // 松开标志置一
    else
      key_released <= 0;                // 松开标志清零
  end
end

// 采集键值
always @ (posedge clk100mhz, negedge rst_n) 
begin             
  if (!rst_n) 
    key_pressed  <= 0;
  else if (cnt == 4'hA)                 // 采集完一个字节？ 
  begin      
    if (!key_released)                  // 有键按过？
    begin 
      ps2_byte    <= ps2_byte_buf;      // 锁存当前键值
      key_pressed <= 1;                 // 按下标志置一
    end
    else 
      key_pressed <= 0;                 // 按下标志清零
  end
end 
//--------------------------------------
// 键值处理 结束
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
