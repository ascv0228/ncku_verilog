`include "Comparator2.v"

module MedianFinder_7num(
    input      [3:0]      num1  , 
    input      [3:0]      num2  , 
    input      [3:0]      num3  , 
    input      [3:0]      num4  , 
    input      [3:0]      num5  , 
    input      [3:0]      num6  , 
    input      [3:0]      num7  ,  
    output     [3:0]     median  
);
///////////////////////////////
//    Write Your Design Here ~ //
    wire [3:0] min_1, max_1;
    wire [3:0] min_2, max_2;
    wire [3:0] min_3, max_3;
    wire [3:0] min_4, max_4;
    wire [3:0] min_5;
    wire [3:0] min_6, max_6;
    wire [3:0] max_7;

    // 想法: 因為是奇數個數，所以兩兩配對會剩下一個

    // 1st stage : 先倆倆比較，找出相對小值和相對大值，為了後面
    Comparator2 c1(.A(num1), .B(num2), .min(min_1), .max(max_1));
    Comparator2 c2(.A(num3), .B(num4), .min(min_2), .max(max_2));
    Comparator2 c3(.A(num5), .B(num6), .min(min_3), .max(max_3));

    // 2nd stage : 用上一個 stage 的結果，第1, 2, 3對的相對大值中，找出最大值。此時這個最大值屬於don't care
    //             要被拋棄的，因為這個最大值不會是median，他頂多是最大或第二大的數
    Comparator2 c4(.A(max_1), .B(max_2), .min(min_4), .max(max_4));
    Comparator2 c5(.A(max_4), .B(max_3), .min(min_5), .max());

    // 3nd stage : 用 1st stage 的結果，第1, 2, 3對的相對小值中，找出最小值。此時這個最小值屬於don't care
    //             要被拋棄的，因為這個最小值不會是median，他頂多是最小或第二小的數
    Comparator2 c6(.A(min_1), .B(min_2), .min(min_6), .max(max_6));
    Comparator2 c7(.A(min_3), .B(min_6), .min(), .max(max_7));

    // 4nd stage : 現在剩下5個偏中間的數字，用MedianFinder_5num，從5個數找出median，也是7個數的median
    MedianFinder_5num m5_1(
        .num1(min_5) , 
        .num2(min_4) , 
        .num3(max_7)  , 
        .num4(max_6)  , 
        .num5(num7)  ,  
        .median(median)  
    );
///////////////////////////////
endmodule
