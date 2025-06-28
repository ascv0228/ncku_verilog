
// module calculate_Avg #(parameter N = 16) (input [7:0] data [0:N-1], output reg [7:0] avg):
// 	wire [11:0] sum;
// 	wire [11:0] sum_1, sum_2, sum_3, sum_4, sum_5, sum_6, sum_7, sum_8;
// 	wire [11:0] sum_21, sum_22, sum_23, sum_24;
// 	wire [11:0] sum_31, sum_32;

// 	assign sum_1 = data[15] + data[14];
// 	assign sum_2 = data[13] + data[12];
// 	assign sum_3 = data[11] + data[10];
// 	assign sum_4 = data[9] + data[8];
// 	assign sum_5 = data[7] + data[6];
// 	assign sum_6 = data[5] + data[4];
// 	assign sum_7 = data[3] + data[2];
// 	assign sum_8 = data[1] + data[0];

// 	assign sum_21 = sum_1 + sum_2;
// 	assign sum_22 = sum_3 + sum_4;
// 	assign sum_23 = sum_5 + sum_6;
// 	assign sum_24 = sum_7 + sum_8;

// 	assign sum_31 = sum_21 + sum_22;
// 	assign sum_32 = sum_23 + sum_24;

// 	assign sum = sum_31 + sum_32;

// 	assign avg = sum >> 4; // 無條件捨去 
// endmodule

module calculate_Avg #(parameter WORD_WIDTH = 8, DATA_LEN = 16) (
    input [WORD_WIDTH*DATA_LEN-1:0] data,  // 展平輸入數據
    output reg [WORD_WIDTH-1:0] avg        // 平均值
);
    // 局部線網
    wire [WORD_WIDTH+3:0] sum; // 需要額外位元來存儲加總結果
    wire [WORD_WIDTH+3:0] sum_1, sum_2, sum_3, sum_4, sum_5, sum_6, sum_7, sum_8;
    wire [WORD_WIDTH+3:0] sum_21, sum_22, sum_23, sum_24;
    wire [WORD_WIDTH+3:0] sum_31, sum_32;

    // 兩兩相加
    assign sum_1 = data[WORD_WIDTH*15 +: WORD_WIDTH] + data[WORD_WIDTH*14 +: WORD_WIDTH];
    assign sum_2 = data[WORD_WIDTH*13 +: WORD_WIDTH] + data[WORD_WIDTH*12 +: WORD_WIDTH];
    assign sum_3 = data[WORD_WIDTH*11 +: WORD_WIDTH] + data[WORD_WIDTH*10 +: WORD_WIDTH];
    assign sum_4 = data[WORD_WIDTH*9  +: WORD_WIDTH] + data[WORD_WIDTH*8  +: WORD_WIDTH];
    assign sum_5 = data[WORD_WIDTH*7  +: WORD_WIDTH] + data[WORD_WIDTH*6  +: WORD_WIDTH];
    assign sum_6 = data[WORD_WIDTH*5  +: WORD_WIDTH] + data[WORD_WIDTH*4  +: WORD_WIDTH];
    assign sum_7 = data[WORD_WIDTH*3  +: WORD_WIDTH] + data[WORD_WIDTH*2  +: WORD_WIDTH];
    assign sum_8 = data[WORD_WIDTH*1  +: WORD_WIDTH] + data[WORD_WIDTH*0  +: WORD_WIDTH];

    // 進一步加總
    assign sum_21 = sum_1 + sum_2;
    assign sum_22 = sum_3 + sum_4;
    assign sum_23 = sum_5 + sum_6;
    assign sum_24 = sum_7 + sum_8;

    assign sum_31 = sum_21 + sum_22;
    assign sum_32 = sum_23 + sum_24;

    // 最終總和
    assign sum = sum_31 + sum_32;

    // 無條件捨去
    assign avg = sum >> 4;
endmodule
