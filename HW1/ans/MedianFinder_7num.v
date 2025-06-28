`include "Comparator2.v"
`include "MedianFinder_3num.v"
`include "MedianFinder_5num.v"

module MedianFinder_7num(
    input  	[3:0]  	num1  , 
	input  	[3:0]  	num2  , 
	input  	[3:0]  	num3  , 
	input  	[3:0]  	num4  , 
	input  	[3:0]  	num5  , 
	input  	[3:0]  	num6  , 
	input  	[3:0]  	num7  ,  
    output 	[3:0] 	median  
);
    wire [3:0] min1, max1, min2, max2, min3, max3, min4, max4, min5, max5, min6, max6;

	Comparator2 comp1(.A(num1), .B(num2), .min(min1), .max(max1));
	Comparator2 comp2(.A(num3), .B(num4), .min(min2), .max(max2));
	Comparator2 comp3(.A(max1), .B(max2), .min(min3), .max(max3));
	Comparator2 comp4(.A(min1), .B(min2), .min(min4), .max(max4));
	Comparator2 comp5(.A(max3), .B(num5), .min(min5), .max(max5));
	Comparator2 comp6(.A(min4), .B(num6), .min(min6), .max(max6));

	MedianFinder_5num find1(.num1(min3), .num2(max4), .num3(min5), .num4(max6), .num5(num7), .median(median));

endmodule
