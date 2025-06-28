// `timescale 1ns/10ps

// // 4238 cycles // 理論極限 4096 + allow_layer0_write_threshold = 4096 + 132 = 4228
// module  ATCONV(
//     input		clk       ,
//     input		rst       ,
//     output              ROM_rd    ,
//     output reg [11:0]	iaddr     ,
//     input      [15:0]	idata     ,
//     output              layer0_ceb,
//     output              layer0_web,   
//     output reg [11:0]   layer0_A  ,
//     output reg [15:0]   layer0_D  ,
//     input      [15:0]   layer0_Q  ,
//     output              layer1_ceb,
//     output              layer1_web,
//     output reg [11:0]   layer1_A  ,
//     output reg [15:0]   layer1_D  ,
//     input      [15:0]   layer1_Q  ,
//     output              done        
// );

// /////////////////////////////////
// // Please write your code here //
// /////////////////////////////////

//     // reg [8:0] state
//     // state [0] = COPY_UNDONE / COPY_DONE = 0 / 1
//     // state [1] = ALLOW_LAYER0_CALCULATE or not = 0 / 1
//     // state [2] = LAYER0_CALCULATE_UNDONE / DONE = 0 / 1
//     // state [3] = ALLOW_LAYER0_WRITE or not = 0 / 1
//     // state [4] = LAYER0_WRITE_UNDONE / DONE = 0 / 1

//     // state [5] = ALLOW_LAYER1_CALCULATE or not = 0 / 1
//     // state [6] = LAYER1_CALCULATE_UNDONE / DONE = 0 / 1
//     // state [7] = ALLOW_LAYER1_WRITE or not = 0 / 1
//     // state [8] = LAYER1_WRITE_UNDONE / DONE = 0 / 1
    
//     reg signed [15:0] raw_array [0:511]; // 64 * 8
//     reg signed [15:0] atrous_array [0:127]; // 64 * 2
//     reg [11:0] layer0_calc_addr;
//     reg [9:0] layer1_calc_addr;  // 0~1023

//     reg copy_enable, layer0_calc_enable, layer0_write_enable, layer1_calc_enable, layer1_write_enable;
//     reg copy_done;
//     reg layer0_calc_done;
//     reg layer0_write_done;
//     reg layer1_calc_done;
//     reg layer1_write_stage_done;
//     reg layer1_write_done;

    
//     wire [4:0] oper_stage = layer0_calc_addr >>> 7; // 0~32 // 64*2 一組

//     assign done = (layer0_write_done && layer1_write_done);
//     // assign done = ( layer0_write_done);

//     assign ROM_rd      = copy_enable;
//     assign layer0_ceb  = layer0_write_enable && ~layer0_write_done;
//     assign layer0_web  = ~(layer0_write_enable && ~layer0_write_done);
//     assign layer1_ceb  = layer1_write_enable && ~layer1_write_done;
//     assign layer1_web  = ~(layer1_write_enable && ~layer1_write_done);

//     ///////////////////MAIN STATE CONTROL////////
//     always @(posedge clk or posedge rst) begin
//     if (rst) begin
//         copy_done <= 1'b0;
//         layer0_calc_done <= 1'b0;
//         layer0_write_done <= 1'b0;
//         layer1_calc_done <= 1'b0;
//         layer1_write_stage_done <= 1'b0;
//         layer1_write_done <= 1'b0;
//     end else begin
//         if (!copy_done && iaddr == 12'd4095)
//         copy_done <= 1'b1;
//         if (!layer0_calc_done && layer0_calc_addr == 12'd4095)
//             layer0_calc_done <= 1'b1;

//         if (!layer0_write_done && layer0_A == 12'd4095)
//             layer0_write_done <= 1'b1;

//         if (!layer1_calc_done && layer1_calc_addr == 10'd1023)
//             layer1_calc_done <= 1'b1;

//         if (!layer1_write_stage_done && layer1_A == 5'd31)
//             layer1_write_stage_done <= 1'b1;

//         if (!layer1_write_done && layer1_A == 12'd1023)
//             layer1_write_done <= 1'b1;
//         end
//     end


//     /////////////////////////////READ IMAGE DATA///////////////////////////////////////
//     wire [8:0] raw_addr = iaddr[8:0];

//     // handle copy_enable flag
//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             copy_enable <= 1'b1;
//         end
//         else begin
//             // copy_enable <= (~layer0_write_enable && ~layer1_write_enable && ~copy_done);
//             copy_enable <= ~copy_done;
//         end
//     end

//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             iaddr <= 12'd0;
//         end else if (ROM_rd) begin
//             raw_array[raw_addr] <= idata;
//             iaddr <= iaddr + 1;
//         end
//     end

//     ////////////////////////////LAYER 0/////////////////////////
//     // layer 0
//     // integer i, j;
//     parameter signed[15:0]k0 = 16'hFFFF, // = k2, 6, 8 = -0.0625 == -1 * 2^(-4)
//               k1 = 16'hFFFE, // = k7 = -0.125 == -1 * 2^(-3)
//               k3 = 16'hFFFC, // = k5 = -0.25 == -1 * 2^(-2)
//               k4 = 16'h0010, // = 1
//               bias = 16'hFFF4; // = -0.75



//     wire [5:0] layer0_x, layer0_y;
//     wire [2:0] up_y, down_y;
//     wire [5:0] left_x, right_x;

//     assign layer0_y = layer0_calc_addr[11:6];
//     assign layer0_x = layer0_calc_addr[5:0];
    
//     assign up_y = (layer0_y > 1) ? (layer0_y - 6'd2) & 3'b111 : 3'b000;
//     assign down_y = (layer0_y < 62) ? (layer0_y + 6'd2) & 3'b111 : 3'b111;
//     assign left_x = (layer0_x > 1) ? layer0_x - 2: 6'b000;
//     assign right_x = (layer0_x < 62) ? layer0_x + 2: 6'b111111;

//     wire signed [15:0] p0 = raw_array[{up_y,     left_x  }];
//     wire signed [15:0] p1 = raw_array[{up_y,     layer0_x}];
//     wire signed [15:0] p2 = raw_array[{up_y,     right_x }];
//     wire signed [15:0] p3 = raw_array[{layer0_y[2:0], left_x  }];
//     wire signed [15:0] p4 = raw_array[{layer0_y[2:0], layer0_x}];
//     wire signed [15:0] p5 = raw_array[{layer0_y[2:0], right_x }];
//     wire signed [15:0] p6 = raw_array[{down_y,   left_x  }];
//     wire signed [15:0] p7 = raw_array[{down_y,   layer0_x}];
//     wire signed [15:0] p8 = raw_array[{down_y,   right_x }];
    
//     wire signed [15:0] tmp_sum = p4 + ((-(p0 + p2 + p6 + p8)) >>> 4) + ((-(p1 + p7)) >>> 3) + ((-(p3 + p5)) >>> 2) + bias;

//     // handle layer0_calc_enable flag
//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             layer0_calc_enable <= 1'b0;
//         end else if (!layer0_calc_enable)begin
//             layer0_calc_enable <= (iaddr == 12'd130);
//         end else if (layer0_calc_done) begin
//             layer0_calc_enable <= 1'b0;
//         end 
//     end


//     // reg signed 
//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             layer0_calc_addr <= 12'd0;
//         end 
//         if (layer0_calc_enable && !layer0_calc_done) begin
//             atrous_array[layer0_calc_addr[6:0]] <= (tmp_sum[15]) ? 16'sd0 : tmp_sum; // p0 is signed
//             layer0_calc_addr <= layer0_calc_addr + 1;
//         end
//     end

//     // handle layer0_write_enable flag
//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             layer0_write_enable <= 1'b0;
//         end else begin
//             layer0_write_enable <= (layer0_calc_enable && !layer0_write_done);
//         end
//     end
//     reg [11:0] next_A;

//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             layer0_A <= 12'd0;
//             next_A <= 12'd0;
//             layer0_D <= 16'd0;
//             layer0_write_enable <= 1'b0;
//         end else if (layer0_write_enable) begin
//             layer0_D <= atrous_array[next_A[6:0]];
//             layer0_A <= next_A;
//             next_A <= next_A + 1;
//         end else begin
//         end
//     end

//     ////////////////////////////Layer1///////////////////////////////
//     // reg [15:0] ceil_array [0:1023];

//     wire [4:0] layer1_row, layer1_col;  // index for 32x32
//     wire [15:0] a, b, c, d;
//     wire [15:0] max_out;
//     wire [15:0] max_val;

//     assign layer1_row = layer1_calc_addr[6:5];
//     assign layer1_col = layer1_calc_addr[4:0];

//     wire [1:0] layer1_base_row = layer1_row * 2;
//     wire [5:0] layer1_base_col = layer1_col * 2;
//     wire [6:0] layer1_base_addr = {layer1_base_row, layer1_base_col};
//     assign a = atrous_array[layer1_base_addr];
//     assign b = atrous_array[layer1_base_addr+1];
//     assign c = atrous_array[layer1_base_addr+64];
//     assign d = atrous_array[layer1_base_addr+65];


//     find_max_4 max_inst (
//         .a(a), .b(b), .c(c), .d(d),
//         .max(max_out)
//     );
//     // handle layer1_calc_enable flag
//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             layer1_calc_enable <= 1'b0;
//         end else begin
//             layer1_calc_enable <= (layer0_write_done && !layer1_calc_done);
//         end
//     end

//     assign max_val = (max_out[3:0] != 4'b0000) ? {max_out[15:4] + 1'b1, 4'b0000} : max_out;
//     always @(posedge clk) begin
//         if (rst) begin
//             layer1_D <= 16'd0;
//             layer1_A <= 12'd0;
//             layer1_calc_addr <= 10'd0;
//         end
//         if (layer1_calc_enable && !layer1_calc_done) begin
//             layer1_D <= max_val;
//             layer1_A <= layer1_calc_addr;
//             layer1_calc_addr <= layer1_calc_addr + 1;
//         end
//     end

// endmodule

// module find_max_4(
//     input  [15:0] a,
//     input  [15:0] b,
//     input  [15:0] c,
//     input  [15:0] d,
//     output [15:0] max
// );
//     wire [15:0] max_1, max_2;

//     assign max_1 = (a > b) ? a : b;
//     assign max_2 = (c > d) ? c : d;
//     assign max   = (max_1 > max_2) ? max_1 : max_2;
// endmodule