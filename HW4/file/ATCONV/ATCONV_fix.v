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
    
//     reg signed [15:0] raw_array [0:4095];
//     reg signed [15:0] atrous_array [0:4095];
//     reg [11:0] oper_addr;
//     reg [9:0] layer1_addr;  // 0~1023

//     reg [8:0] state;
//     wire copy_done              = state[0];
//     wire allow_layer0_calc      = state[1];
//     wire layer0_calc_done       = state[2];
//     wire allow_layer0_write     = state[3];
//     wire layer0_write_done      = state[4];

//     wire allow_layer1_calc      = state[5];
//     wire layer1_calc_done       = state[6];
//     wire allow_layer1_write     = state[7];
//     wire layer1_write_done      = state[8];

//     assign ROM_rd      = ~copy_done;
//     assign layer0_ceb  = (allow_layer0_write && ~layer0_write_done);
//     assign layer0_web  = !(allow_layer0_write && ~layer0_write_done);
//     assign layer1_ceb  = (allow_layer1_write && ~layer1_write_done);
//     assign layer1_web  = !(allow_layer1_write && ~layer1_write_done);

//     parameter [11:0]allow_layer0_calc_threshold = 12'd130; // state[1] // OK
//     parameter [11:0]layer0_calc_done_threshold = 12'd4095; // state[2]
//     parameter [11:0]allow_layer0_write_threshold = 12'd0; // state[3] // OK
//     parameter [11:0]allow_layer1_calc_threshold = 12'd3072; // state[5] // OK
//     parameter [11:0]layer1_calc_done_threshold = 10'd1023; // state[6]
//     parameter [11:0]allow_layer1_write_threshold = 10'd2; // state[7] // OK

//     reg layer0_calc_done_flag,
//         allow_layer0_write_flag,
//         allow_layer1_calc_flag,
//         layer1_calc_done_flag,
//         allow_layer1_write_flag;

//     ///////////////////MAIN STATE CONTROL////////
//     always @(posedge clk) begin
//         if (rst) begin
//             state <= 9'd0;
//         end
//         else begin
//             if(~copy_done && iaddr == 12'd4095) begin
//                 state[0] <= 1'b1;
//             end
//             if (~allow_layer0_calc && iaddr == allow_layer0_calc_threshold) begin // allow_layer0_calc, 130就能開始算layer0了，但是預留5個cycle
//                 state[1] <= 1'b1;
//             end
//             if(allow_layer0_calc && ~layer0_calc_done && layer0_calc_done_flag) begin // TODO: LAYER0_CALCULATE_DONE
//                 state[2] <= 1'b1;
//             end
//             if(~allow_layer0_write && allow_layer0_write_flag) begin // allow_layer0_write // 假設捲積 + RELU 只需要 1 cycle，但是預留5個cycle
//                 state[3] <= 1'b1;
//             end
//             if(~layer0_write_done && layer0_A == 12'd4095) begin // TODO: LAYER0_WRITE_DONE
//                 state[4] <= 1'b1;
//             end
//             if(~allow_layer1_calc && allow_layer1_calc_flag) begin
//                 state[5] <= 1'b1;
//             end
//             if(allow_layer1_calc && ~layer1_calc_done && layer1_calc_done_flag) begin // TODO: LAYER1_CALCULATE_DONE
//                 state[6] <= 1'b1;
//             end
//             if(~allow_layer1_write && allow_layer1_write_flag) begin
//                 state[7] <= 1'b1;
//             end
//             if(~state[8] && layer1_A == 12'd1023) begin // TODO: LAYER1_WRITE_DONE
//                 state[8] <= 1'b1;
//             end
//         end
//     end
//     assign done = state == 9'b111111111;

//     /////////////////////////////READ IMAGE DATA///////////////////////////////////////
//     always @(posedge clk) begin
//         if (rst) begin
//             iaddr <= 12'd0;
//         end else if (ROM_rd) begin
//             raw_array[iaddr] <= idata;
//             iaddr <= iaddr + 1;
//         end
//     end

//     ////////////////////////////LAYER 0/////////////////////////
//     // layer 0
//     integer i, j;
//     parameter signed[15:0]k0 = 16'hFFFF, // = k2, 6, 8 = -0.0625 == -1 * 2^(-4)
//               k1 = 16'hFFFE, // = k7 = -0.125 == -1 * 2^(-3)
//               k3 = 16'hFFFC, // = k5 = -0.25 == -1 * 2^(-2)
//               k4 = 16'h0010, // = 1
//               bias = 16'hFFF4; // = -0.75



//     wire [5:0] layer0_x, layer0_y;
//     wire [5:0] up_y, down_y, left_x, right_x;

//     assign layer0_y = oper_addr [11:6];
//     assign layer0_x = oper_addr [5:0];
//     assign up_y = (layer0_y > 1) ? layer0_y - 2: 6'b0;
//     assign down_y = (layer0_y < 62) ? layer0_y + 2: 6'b111111;
//     assign left_x = (layer0_x > 1) ? layer0_x - 2: 6'b0;
//     assign right_x = (layer0_x < 62) ? layer0_x + 2: 6'b111111;

//     wire signed [15:0] p0 = raw_array[{up_y,     left_x  }];
//     wire signed [15:0] p1 = raw_array[{up_y,     layer0_x}];
//     wire signed [15:0] p2 = raw_array[{up_y,     right_x }];
//     wire signed [15:0] p3 = raw_array[{layer0_y, left_x  }];
//     wire signed [15:0] p4 = raw_array[{layer0_y, layer0_x}];
//     wire signed [15:0] p5 = raw_array[{layer0_y, right_x }];
//     wire signed [15:0] p6 = raw_array[{down_y,   left_x  }];
//     wire signed [15:0] p7 = raw_array[{down_y,   layer0_x}];
//     wire signed [15:0] p8 = raw_array[{down_y,   right_x }];
    
//     wire signed [15:0] tmp_sum = p4 + ((-(p0 + p2 + p6 + p8)) >>> 4) + ((-(p1 + p7)) >>> 3) + ((-(p3 + p5)) >>> 2) + bias;

//     // reg signed 
//     always @(posedge clk) begin
//         if (rst) begin
//             oper_addr <= 12'd0;
//             layer0_calc_done_flag <= 1'b0;
//             allow_layer0_write_flag <= 1'b0;
//             allow_layer1_calc_flag <= 1'b0;
//         end 
//         if (allow_layer0_calc && !layer0_calc_done) begin
//             atrous_array[oper_addr] <= (tmp_sum[15]) ? 16'sd0 : tmp_sum; // p0 is signed
//             oper_addr <= oper_addr + 1;
//             if(oper_addr == 12'd4095) begin
//                 layer0_calc_done_flag <= 1'b1;
//                 oper_addr <= 12'd0;
//             end
//             if(~allow_layer0_write_flag && oper_addr == allow_layer0_write_threshold) begin
//                 allow_layer0_write_flag <= 1'b1;
//             end
//             if(~allow_layer1_calc_flag && oper_addr == allow_layer1_calc_threshold) begin
//                 allow_layer1_calc_flag <= 1'b1;
//             end
//         end
//     end

//     // reg layer0_write_finish;
//     // layer 0 done

//     always @(posedge clk) begin
//         if (rst) begin
//             layer0_A <= 12'd0;
//             layer0_D <= 16'd0;
//         end else if (allow_layer0_write && !layer0_write_done) begin
//             layer0_D <= atrous_array[oper_addr];
//             layer0_A <= oper_addr;
//         end else begin
//             layer0_D <= 16'd0;
//             layer0_A <= 12'd0;
//         end
//     end

//     ////////////////////////////Layer1///////////////////////////////

//     wire [4:0] layer1_row, layer1_col;  // index for 32x32
//     wire [15:0] a, b, c, d;
//     wire [15:0] max_out;
//     wire [15:0] max_val;

//     assign layer1_row = layer1_addr[9:5];
//     assign layer1_col = layer1_addr[4:0];

//     wire [5:0] layer1_base_row = layer1_row * 2;
//     wire [5:0] layer1_base_col = layer1_col * 2;
//     wire [11:0] layer1_base_addr = {layer1_base_row, layer1_base_col};
//     assign a = atrous_array[layer1_base_addr];
//     assign b = atrous_array[layer1_base_addr+1];
//     assign c = atrous_array[layer1_base_addr+64];
//     assign d = atrous_array[layer1_base_addr+65];


//     find_max_4 max_inst (
//         .a(a), .b(b), .c(c), .d(d),
//         .max(max_out)
//     );

//     assign max_val = (max_out[3:0] != 4'b0000) ? {max_out[15:4] + 1'b1, 4'b0000} : max_out;
    
//     reg [11:0] next1_A;
//     always @(posedge clk) begin
//         if (rst) begin
//             layer1_A <= 10'd0;
//             layer1_A <= 12'd0;
//             next1_A <= 12'd0;
//             layer1_calc_done_flag <= 1'b0;
//             allow_layer1_write_flag <= 1'b0;
//         end
//         if (allow_layer1_calc && !layer1_calc_done) begin
//             layer1_D <= max_val;
//             layer1_A <= next1_A;
//             next1_A <= next1_A + 1;
//             if (layer1_A == layer1_calc_done_threshold) begin
//                 layer1_calc_done_flag <= 1'b1;
//             end
//             if (layer1_A == allow_layer1_write_threshold) begin
//                 allow_layer1_write_flag <= 1'b1;
//             end
//         end
//     end

//     // reg [11:0] next1_A;
//     // always @(posedge clk) begin
//     //     if (rst) begin
//     //         layer1_D <= 16'd0;
//     //         layer1_A <= 12'd0;
//     //         next1_A <= 12'd0;
//     //         // layer1_write_finish <= 0;
//     //     end else if (allow_layer1_write && !layer1_write_done) begin
//     //         layer1_D <= ceil_array[next1_A];
//     //         layer1_A <= next1_A;
//     //         next1_A <= next1_A + 1;
//     //     end else begin
//     //         layer1_D <= 16'd0;
//     //         layer1_A <= 12'd0;
//     //         next1_A <= 12'd0;
//     //     end
//     // end
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