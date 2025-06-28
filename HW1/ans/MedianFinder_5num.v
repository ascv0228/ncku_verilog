`include "Comparator2.v"
`include "MedianFinder_3num.v"

module MedianFinder_5num(
    input  [3:0] 	num1  , 
	input  [3:0] 	num2  , 
	input  [3:0] 	num3  , 
	input  [3:0] 	num4  , 
	input  [3:0] 	num5  ,  
    output [3:0] 	median  
);
    wire [3:0] min1, max1, min2, max2, min3, max3, min4, max4, min5, max5, min6, max6, min7;

	Comparator2 comp1(.A(num1), .B(num2), .min(min1), .max(max1));
	Comparator2 comp2(.A(num3), .B(num4), .min(min2), .max(max2));
	Comparator2 comp3(.A(min1), .B(min2), .min(min3), .max(max3));
	Comparator2 comp4(.A(max1), .B(max2), .min(min4), .max(max4));

	MedianFinder_3num find1(.num1(num5), .num2(max3), .num3(min4), .median(median));

endmodule
