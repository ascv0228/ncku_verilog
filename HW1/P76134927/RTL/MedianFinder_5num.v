`include "Comparator2.v"

module MedianFinder_5num(
    input  [3:0]     num1  , 
    input  [3:0]     num2  , 
    input  [3:0]     num3  , 
    input  [3:0]     num4  , 
    input  [3:0]     num5  ,  
    output [3:0]     median  
);

///////////////////////////////
//    Write Your Design Here ~ //
    wire [3:0] min_1, max_1;
    wire [3:0] min_2, max_2;
    wire [3:0] max_3;
    wire [3:0] min_4;
    Comparator2 c1(.A(num1), .B(num2), .min(min_1), .max(max_1));
    Comparator2 c2(.A(num3), .B(num4), .min(min_2), .max(max_2));
    Comparator2 c3(.A(min_1), .B(min_2), .min(), .max(max_3));
    Comparator2 c4(.A(max_1), .B(max_2), .min(min_4), .max());
    MedianFinder_3num m3_1(.num1(max_3), .num2(min_4), .num3(num5), .median(median));
///////////////////////////////

endmodule
