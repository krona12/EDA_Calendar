//****************  Complete_Clock.v  *****************
module Complete_Clock (sel,seg, ALARM, CLK_50, AdjMinkey, AdjHrkey, SetMinkey, SetHrkey, CtrlBell, Mode, nCR);
    input  CLK_50, nCR;    
    input  AdjMinkey, AdjHrkey;
    input SetHrkey, SetMinkey; //设定闹钟小时、分钟的输入按键
    input CtrlBell; //控制闹钟的声音是否输出的按键
    input Mode;  //控制显示模式切换的按键。
    wire [7:0] LED_Hr, LED_Min, LED_Sec; //输出BCD码
	 wire [31:0] data;
    output ALARM;       //仿电台或闹钟的声音信号输出
	 output [7:0] sel;
	 output [7:0] seg;
    wire _1Hz,  _500Hz,_1kHzIN;         //分频器的输出信号  
    wire [7:0] Hour, Minute, Second; //计时器的输出信号
    wire [7:0] Set_Hr, Set_Min;  //设定的闹钟时间输出信号
    wire  ALARM_Radio;  //仿电台报时信号输出
    wire  ALARM_Clock;  //闹钟的信号输出
	 //调用分频模块
	 CP_1kHz_500kHz_1Hz U0 (CLK_50, nCR, _1kHzIN, _500Hz,_1Hz); 
	 //计时主体电路
	 Top_Clock U1(.Hour(Hour), .Minute(Minute), .Second(Second), ._1Hz(_1Hz), .nCR(nCR), .AdjMinKey(AdjMinKey), .AdjHrKey(AdjHrKey)); 
	 //仿电台整点报时
	 Radio U2(ALARM_Radio , Minute, Second, _1kHzIN, _500Hz); 
	 //定时闹钟模块
	 Bell U3(ALARM_Clock, Set_Hr, Set_Min, Hour, Minute, Second, SetHrKey, SetMinKey, _1kHzIN, _500Hz, _1Hz, CtrlBell); 

    assign ALARM = ALARM_Radio||ALARM_Clock;  

    _2to1MUX MU1(LED_Hr,  Mode, Set_Hr, Hour);
    _2to1MUX MU2(LED_Min, Mode, Set_Min, Minute);
    _2to1MUX MU3(LED_Sec, Mode, 8'h00, Second);
	 //数码管
	 assign data = {LED_Hr, 4'hf, LED_Min, 4'hf, LED_Sec};

	 // dongtaishumaguan U4(_1kHzIN,nCR,data,sel,seg);
	 scan_dig U4(.clk(_1kHzIN), .rstn(nCR), .enable(1'b1), .data(data), .dig(sel), .seg(seg));
endmodule

module _2to1MUX(OUT,SEL,X,Y);
    input [7:0] X, Y;
    input SEL;
    output[7:0] OUT;
    assign OUT = SEL ? X : Y;
endmodule
