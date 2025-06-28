`include "Comparator2.v"

module MedianFinder_3num(
    input  [3:0]    num1    , 
    input  [3:0]    num2    , 
    input  [3:0]    num3    ,  
    output [3:0]    median  
);

///////////////////////////////
//    Write Your Design Here ~ //
///////////////////////////////
    wire [3:0] min_1, max_1;
    wire [3:0] min_2, max_2;
    wire [3:0] min_3, max_3;
    Comparator2 c1(.A(num1), .B(num2), .min(min_1), .max(max_1));
    Comparator2 c2(.A(max_1), .B(num3), .min(min_2), .max(max_2));
    Comparator2 c3(.A(min_1), .B(min_2), .min(min_3), .max(max_3));

    assign median = max_3;

///////////////////////////////


endmodule
