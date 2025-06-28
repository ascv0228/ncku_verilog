`include "Comparator2.v"

module MedianFinder_3num(
    input  [3:0]    num1    , 
    input  [3:0]    num2    , 
    input  [3:0]    num3    ,  
    output [3:0]    median  
);
    wire [3:0] min1, max1, min2, max2, min3;

	Comparator2 comp1(.A(num1), .B(num2), .min(min1), .max(max1));
	Comparator2 comp2(.A(num3), .B(max1), .min(min2), .max(max2));
    Comparator2 comp3(.A(min2), .B(min1), .min(min3), .max(median));

endmodule
