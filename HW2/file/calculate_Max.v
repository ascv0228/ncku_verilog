// module calculate_Max #(parameter WORD_WIDTH = 8, DATA_LEN = 16) (
//     input [WORD_WIDTH*DATA_LEN-1:0] data,  // 将整个数组展平为一个输入
//     output reg [WORD_WIDTH-1:0] max        // 最大值
// );
//     // 局部线网
//     wire [WORD_WIDTH-1:0] max_1, max_2, max_3, max_4, max_5, max_6, max_7, max_8;
//     wire [WORD_WIDTH-1:0] max_21, max_22, max_23, max_24;
//     wire [WORD_WIDTH-1:0] max_31, max_32;

//     // 从展平的数据中提取每个数据
//     assign max_1 = (data[WORD_WIDTH*15 +: WORD_WIDTH] > data[WORD_WIDTH*14 +: WORD_WIDTH]) ? data[WORD_WIDTH*15 +: WORD_WIDTH] : data[WORD_WIDTH*14 +: WORD_WIDTH];
//     assign max_2 = (data[WORD_WIDTH*13 +: WORD_WIDTH] > data[WORD_WIDTH*12 +: WORD_WIDTH]) ? data[WORD_WIDTH*13 +: WORD_WIDTH] : data[WORD_WIDTH*12 +: WORD_WIDTH];
//     assign max_3 = (data[WORD_WIDTH*11 +: WORD_WIDTH] > data[WORD_WIDTH*10 +: WORD_WIDTH]) ? data[WORD_WIDTH*11 +: WORD_WIDTH] : data[WORD_WIDTH*10 +: WORD_WIDTH];
//     assign max_4 = (data[WORD_WIDTH*9 +: WORD_WIDTH] > data[WORD_WIDTH*8 +: WORD_WIDTH]) ? data[WORD_WIDTH*9 +: WORD_WIDTH] : data[WORD_WIDTH*8 +: WORD_WIDTH];
//     assign max_5 = (data[WORD_WIDTH*7 +: WORD_WIDTH] > data[WORD_WIDTH*6 +: WORD_WIDTH]) ? data[WORD_WIDTH*7 +: WORD_WIDTH] : data[WORD_WIDTH*6 +: WORD_WIDTH];
//     assign max_6 = (data[WORD_WIDTH*5 +: WORD_WIDTH] > data[WORD_WIDTH*4 +: WORD_WIDTH]) ? data[WORD_WIDTH*5 +: WORD_WIDTH] : data[WORD_WIDTH*4 +: WORD_WIDTH];
//     assign max_7 = (data[WORD_WIDTH*3 +: WORD_WIDTH] > data[WORD_WIDTH*2 +: WORD_WIDTH]) ? data[WORD_WIDTH*3 +: WORD_WIDTH] : data[WORD_WIDTH*2 +: WORD_WIDTH];
//     assign max_8 = (data[WORD_WIDTH*1 +: WORD_WIDTH] > data[WORD_WIDTH*0 +: WORD_WIDTH]) ? data[WORD_WIDTH*1 +: WORD_WIDTH] : data[WORD_WIDTH*0 +: WORD_WIDTH];

//     // 比较和求最大值
//     assign max_21 = (max_1 > max_2) ? max_1 : max_2;
//     assign max_22 = (max_3 > max_4) ? max_3 : max_4;
//     assign max_23 = (max_5 > max_6) ? max_5 : max_6;
//     assign max_24 = (max_7 > max_8) ? max_7 : max_8;

//     assign max_31 = (max_21 > max_22) ? max_21 : max_22;
//     assign max_32 = (max_23 > max_24) ? max_23 : max_24;

//     // 最终最大值
//     assign max = (max_31 > max_32) ? max_31 : max_32;
// endmodule