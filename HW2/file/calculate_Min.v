
// module calculate_Min #(parameter N = 16) (input [7:0] data [0:N-1], output reg [7:0] min):
// 	wire [7:0] min_1, min_2, min_3, min_4, min_5, min_6, min_7, min_8;
// 	wire [7:0] min_21, min_22, min_23, min_24;
// 	wire [7:0] min_31, min_32;

// 	assign min_1 = (data[15] < data[14]) ? data[15] : data[14];
// 	assign min_2 = (data[13] < data[12]) ? data[13] : data[12];
// 	assign min_3 = (data[11] < data[10]) ? data[11] : data[10];
// 	assign min_4 = (data[9] < data[8]) ? data[9] : data[8];
// 	assign min_5 = (data[7] < data[6]) ? data[7] : data[6];
// 	assign min_6 = (data[5] < data[4]) ? data[5] : data[4];
// 	assign min_7 = (data[3] < data[2]) ? data[3] : data[2];
// 	assign min_8 = (data[1] < data[0]) ? data[1] : data[0];

// 	assign min_21 = (min_1 < min_2) ? min_1 : min_2;
// 	assign min_22 = (min_3 < min_4) ? min_3 : min_4;
// 	assign min_23 = (min_5 < min_6) ? min_5 : min_6;
// 	assign min_24 = (min_7 < min_8) ? min_7 : min_8;

// 	assign min_31 = (min_21 < min_22) ? min_21 : min_22;
// 	assign min_32 = (min_23 < min_24) ? min_23 : min_24;

// 	assign min = (min_31 < min_32) ? min_31 : min_32;

// endmodule

module calculate_Min #(parameter WORD_WIDTH = 8, DATA_LEN = 16) (
    input [WORD_WIDTH*DATA_LEN-1:0] data,  // 展平輸入數據
    output reg [WORD_WIDTH-1:0] min        // 最小值
);
    // 局部線網
    wire [WORD_WIDTH-1:0] min_1, min_2, min_3, min_4, min_5, min_6, min_7, min_8;
    wire [WORD_WIDTH-1:0] min_21, min_22, min_23, min_24;
    wire [WORD_WIDTH-1:0] min_31, min_32;

    // 比較數據
    assign min_1 = (data[WORD_WIDTH*15 +: WORD_WIDTH] < data[WORD_WIDTH*14 +: WORD_WIDTH]) ? data[WORD_WIDTH*15 +: WORD_WIDTH] : data[WORD_WIDTH*14 +: WORD_WIDTH];
    assign min_2 = (data[WORD_WIDTH*13 +: WORD_WIDTH] < data[WORD_WIDTH*12 +: WORD_WIDTH]) ? data[WORD_WIDTH*13 +: WORD_WIDTH] : data[WORD_WIDTH*12 +: WORD_WIDTH];
    assign min_3 = (data[WORD_WIDTH*11 +: WORD_WIDTH] < data[WORD_WIDTH*10 +: WORD_WIDTH]) ? data[WORD_WIDTH*11 +: WORD_WIDTH] : data[WORD_WIDTH*10 +: WORD_WIDTH];
    assign min_4 = (data[WORD_WIDTH*9 +: WORD_WIDTH] < data[WORD_WIDTH*8 +: WORD_WIDTH]) ? data[WORD_WIDTH*9 +: WORD_WIDTH] : data[WORD_WIDTH*8 +: WORD_WIDTH];
    assign min_5 = (data[WORD_WIDTH*7 +: WORD_WIDTH] < data[WORD_WIDTH*6 +: WORD_WIDTH]) ? data[WORD_WIDTH*7 +: WORD_WIDTH] : data[WORD_WIDTH*6 +: WORD_WIDTH];
    assign min_6 = (data[WORD_WIDTH*5 +: WORD_WIDTH] < data[WORD_WIDTH*4 +: WORD_WIDTH]) ? data[WORD_WIDTH*5 +: WORD_WIDTH] : data[WORD_WIDTH*4 +: WORD_WIDTH];
    assign min_7 = (data[WORD_WIDTH*3 +: WORD_WIDTH] < data[WORD_WIDTH*2 +: WORD_WIDTH]) ? data[WORD_WIDTH*3 +: WORD_WIDTH] : data[WORD_WIDTH*2 +: WORD_WIDTH];
    assign min_8 = (data[WORD_WIDTH*1 +: WORD_WIDTH] < data[WORD_WIDTH*0 +: WORD_WIDTH]) ? data[WORD_WIDTH*1 +: WORD_WIDTH] : data[WORD_WIDTH*0 +: WORD_WIDTH];

    // 進一步比較
    assign min_21 = (min_1 < min_2) ? min_1 : min_2;
    assign min_22 = (min_3 < min_4) ? min_3 : min_4;
    assign min_23 = (min_5 < min_6) ? min_5 : min_6;
    assign min_24 = (min_7 < min_8) ? min_7 : min_8;

    assign min_31 = (min_21 < min_22) ? min_21 : min_22;
    assign min_32 = (min_23 < min_24) ? min_23 : min_24;

    // 最終最小值
    assign min = (min_31 < min_32) ? min_31 : min_32;
endmodule
