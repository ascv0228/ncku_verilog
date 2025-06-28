`include "Comparator2.v"

module MedianFinder_6num(
    input  	[3:0]  	num1  , 
	input  	[3:0]  	num2  , 
	input  	[3:0]  	num3  , 
	input  	[3:0]  	num4  , 
	input  	[3:0]  	num5  , 
	input  	[3:0]  	num6  ,  
    output 	[3:0] 	median  
);
	
    wire [3:0] min1, max1, min2, max2, min3, max3;

	// stage 1, 
	Comparator2 comp1(.A(num1), .B(num2), .min(min1), .max(max1));
	Comparator2 comp2(.A(num3), .B(num4), .min(min2), .max(max2));
    Comparator2 comp3(.A(num5), .B(num6), .min(min3), .max(max3));


	wire [3:0] max4, min4, max5, min5, max6, min6, min7, max7;
	// stage 2, remove largest and smallest
	Comparator2 comp4(.A(max1), .B(max2), .min(min4), .max(max4));
	Comparator2 comp5(.A(max3), .B(max4), .min(min5), .max(max5)); // max5 最大

	Comparator2 comp6(.A(min1), .B(min2), .min(min6), .max(max6));
	Comparator2 comp7(.A(min3), .B(min6), .min(min7), .max(max7)); // min7 最小
	// 剩下 min4, min5, max6, max7

	// stage 3, remove largest and smallest from 4 numbers
	wire [3:0] min8, max8, min9, max9;
	Comparator2 comp8(.A(min4), .B(min5), .min(min8), .max(max8));
	Comparator2 comp9(.A(max6), .B(max7), .min(min9), .max(max9));
	wire [3:0] min10, max10, min11, max11;
	Comparator2 comp10(.A(min8), .B(min9), .min(min10), .max(max10)); // min10 最小
	Comparator2 comp11(.A(max8), .B(max9), .min(min11), .max(max11)); // max11 最大

	wire [4:0] add = (max10 + min11);
	assign median = add >> 1; // median = (min + max) / 2



endmodule
