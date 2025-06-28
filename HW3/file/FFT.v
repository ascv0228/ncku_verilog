module  FFT(
    input           clk      , 
    input           rst      , 
    input  [15:0]   fir_d    , 
    input           fir_valid,
    output reg          fft_valid, 
    output reg          done     ,
    output reg [15:0]   fft_d1   , 
    output reg [15:0]   fft_d2   ,
    output reg [15:0]   fft_d3   , 
    output reg [15:0]   fft_d4   , 
    output reg [15:0]   fft_d5   , 
    output reg [15:0]   fft_d6   , 
    output reg [15:0]   fft_d7   , 
    output reg [15:0]   fft_d8   ,
    output reg [15:0]   fft_d9   , 
    output reg [15:0]   fft_d10  , 
    output reg [15:0]   fft_d11  , 
    output reg [15:0]   fft_d12  , 
    output reg [15:0]   fft_d13  , 
    output reg [15:0]   fft_d14  , 
    output reg [15:0]   fft_d15  , 
    output reg [15:0]   fft_d0
);
    parameter Fractional_Add_bit = 4;
/////////////////////////////////
// Please write your code here //
/////////////////////////////////
    parameter [31:0] W_r_0 = 32'h00010000;
    parameter [31:0] W_r_1 = 32'h0000EC83;
    parameter [31:0] W_r_2 = 32'h0000B504;
    parameter [31:0] W_r_3 = 32'h000061F7;
    parameter [31:0] W_r_4 = 32'h00000000;
    parameter [31:0] W_r_5 = 32'hFFFF9E09;
    parameter [31:0] W_r_6 = 32'hFFFF4AFC;
    parameter [31:0] W_r_7 = 32'hFFFF137D;
    parameter [31:0] W_i_0 = 32'h00000000;
    parameter [31:0] W_i_1 = 32'hFFFF9E09;
    parameter [31:0] W_i_2 = 32'hFFFF4AFC;
    parameter [31:0] W_i_3 = 32'hFFFF137D;
    parameter [31:0] W_i_4 = 32'hFFFF0000;
    parameter [31:0] W_i_5 = 32'hFFFF137D;
    parameter [31:0] W_i_6 = 32'hFFFF4AFC;
    parameter [31:0] W_i_7 = 32'hFFFF9E09;

    reg signed [31:0] W_r [0:7];
    reg signed [31:0] W_i [0:7];
    reg signed[15:0] memory [0:15];
    reg [3:0] write_addr;
    // reg signed[15:0] stage_real [0:15];
    reg signed[15+Fractional_Add_bit:0] stage_real [0:15];
    reg signed[15+Fractional_Add_bit:0] stage_image [0:15];

    reg copy_enable;
    
    parameter COPY_UNABLE = 0,
              COPY_DONE = 1,
              STAGE_1_WAIT = 2,
              STAGE_1_WAIT_2 = 3,
              STAGE_1_FINISH = 4,
              STAGE_2_WAIT = 5,
              STAGE_2_WAIT_2 = 6,
              STAGE_2_FINISH = 7,
              STAGE_3_WAIT = 8,
              STAGE_3_WAIT_2 = 9,
              STAGE_3_FINISH = 10,
              STAGE_4_WAIT = 11,
              STAGE_4_WAIT_2 = 12,
              STAGE_4_FINISH = 13,
              OUTPUT_REAL_DONE = 14,
              OUTPUT_IMAGE_DONE = 15;
    reg [3:0]state = COPY_UNABLE;

    always @(posedge clk) begin
        if (rst) begin
            write_addr <= 4'd0;
            
        end else if (fir_valid) begin
            memory[write_addr] <= fir_d;
            write_addr <= write_addr + 1;
            if(write_addr == 4'd15) begin
                copy_enable <= 1'b1;
            end
        end 
        if (copy_enable && state == COPY_DONE) begin
            copy_enable <= 1'b0;
        end
    end

    integer i, j;
    integer offset;
    reg signed [15+Fractional_Add_bit:0] temp_real [0:15];
    reg signed [15+Fractional_Add_bit:0] temp_image [0:15];
    reg signed [Fractional_Add_bit+47:0] mul_temp_real [0:15];
    reg signed [Fractional_Add_bit+47:0] mul_temp_image [0:15];
    
    // // assign W_r[0] = W_r_0;
    // // assign W_r[1] = (state == COPY_DONE || state == STAGE_1_WAIT) ? W_r_1 : W_r_0;
    // // assign W_r[2] = (state == COPY_DONE || state == STAGE_1_WAIT || state == STAGE_1_FINISH || state == STAGE_2_WAIT) ? W_r_2 : W_r_0;
    // // assign W_r[3] = (state == COPY_DONE || state == STAGE_1_WAIT) ? W_r_3 : (state == STAGE_1_FINISH || state == STAGE_2_WAIT) ? W_r_2: W_r_0;
    // // assign W_r[4] = (state == STAGE_2_FINISH || state == STAGE_3_WAIT) ? W_r_4 : W_r_0;
    // // assign W_r[5] = (state == COPY_DONE || state == STAGE_1_WAIT) ? W_r_5 : (state == STAGE_2_FINISH || state == STAGE_3_WAIT) ? W_r_4 : W_r_0;
    // // assign W_r[6] = (state == COPY_DONE || state == STAGE_1_WAIT || state == STAGE_1_FINISH || state == STAGE_2_WAIT) ? W_r_6 : (state == STAGE_2_FINISH || state == STAGE_3_WAIT) ? W_r_4 : W_r_0;
    // // assign W_r[7] = (state == COPY_DONE || state == STAGE_1_WAIT) ? W_r_7 : (state == STAGE_1_FINISH || state == STAGE_2_WAIT) ? W_r_6: (state == STAGE_2_FINISH || state == STAGE_3_WAIT) ? W_r_4 : W_r_0;

    // // assign W_i[0] = W_i_0;
    // // assign W_i[1] = (state == COPY_DONE || state == STAGE_1_WAIT) ? W_i_1 : W_i_0;
    // // assign W_i[2] = (state == COPY_DONE || state == STAGE_1_WAIT || state == STAGE_1_FINISH || state == STAGE_2_WAIT) ? W_i_2 : W_i_0;
    // // assign W_i[3] = (state == COPY_DONE || state == STAGE_1_WAIT) ? W_i_3 : (state == STAGE_1_FINISH || state == STAGE_2_WAIT) ? W_i_2: W_i_0;
    // // assign W_i[4] = (state == STAGE_2_FINISH || state == STAGE_3_WAIT) ? W_i_4 : W_i_0;
    // // assign W_i[5] = (state == COPY_DONE || state == STAGE_1_WAIT) ? W_i_5 : (state == STAGE_2_FINISH || state == STAGE_3_WAIT) ? W_i_4 : W_i_0;
    // // assign W_i[6] = (state == COPY_DONE || state == STAGE_1_WAIT || state == STAGE_1_FINISH || state == STAGE_2_WAIT) ? W_i_6 : (state == STAGE_2_FINISH || state == STAGE_3_WAIT) ? W_i_4 : W_i_0;
    // // assign W_i[7] = (state == COPY_DONE || state == STAGE_1_WAIT) ? W_i_7 : (state == STAGE_1_FINISH || state == STAGE_2_WAIT) ? W_i_6: (state == STAGE_2_FINISH || state == STAGE_3_WAIT) ? W_i_4 : W_i_0;
    always @(posedge clk) begin
        case(state)
            COPY_DONE,
            STAGE_1_WAIT,
            STAGE_1_WAIT_2: begin
                W_r[0] <= W_r_0;
                W_r[1] <= W_r_1;
                W_r[2] <= W_r_2;
                W_r[3] <= W_r_3;
                W_r[4] <= W_r_4;
                W_r[5] <= W_r_5;
                W_r[6] <= W_r_6;
                W_r[7] <= W_r_7;
                W_i[0] <= W_i_0;
                W_i[1] <= W_i_1;
                W_i[2] <= W_i_2;
                W_i[3] <= W_i_3;
                W_i[4] <= W_i_4;
                W_i[5] <= W_i_5;
                W_i[6] <= W_i_6;
                W_i[7] <= W_i_7;
            end 
            STAGE_1_FINISH,
            STAGE_2_WAIT,
            STAGE_2_WAIT_2: begin
                for (j = 0; j < 2; j = j + 1) begin
                    W_r[j]   <= W_r_0;
                    W_r[2+j] <= W_r_2;
                    W_r[4+j] <= W_r_4;
                    W_r[6+j] <= W_r_6;
                    W_i[j]   <= W_i_0;
                    W_i[2+j] <= W_i_2;
                    W_i[4+j] <= W_i_4;
                    W_i[6+j] <= W_i_6;
                end
            end 
            STAGE_2_FINISH,
            STAGE_3_WAIT,
            STAGE_3_WAIT_2: begin
            for (j = 0; j < 4; j = j + 1) begin
                W_r[j]   <= W_r_0;
                W_r[4+j] <= W_r_4;
                W_i[j]   <= W_i_0;
                W_i[4+j] <= W_i_4;
            end
            end 
            STAGE_3_FINISH,
            STAGE_4_WAIT,
            STAGE_4_WAIT_2: begin
                for (j = 0; j < 8; j = j + 1) begin
                    W_r[j] <= W_r_0;
                    W_i[j] <= W_i_0;
                end
            end
    endcase
    end

    always @(posedge clk) begin
        
        case (state)
            COPY_UNABLE: begin
                if (copy_enable) begin
                    for (i = 0; i < 16; i = i + 1) begin
                        stage_real[i] <= (memory[i] <<< Fractional_Add_bit);
                        stage_image[i] <= 0;
                        temp_real[i] <= 0;
                        temp_image[i] <= 0;
                    end

                    state <= COPY_DONE;
                end
            end
            COPY_DONE,
            STAGE_1_FINISH,
            STAGE_2_FINISH,
            STAGE_3_FINISH: begin
                // butterfly 加法
                for (i = 0; i < 8; i = i + 1) begin
                    temp_real[i]   <= stage_real[i] + stage_real[i + 8];
                    temp_image[i]  <= stage_image[i] + stage_image[i + 8];
                end

                // butterfly 減法
                for (i = 0; i < 8; i = i + 1) begin
                    temp_real[i+8]   <= stage_real[i] - stage_real[i + 8];
                    temp_image[i+8]  <= stage_image[i] - stage_image[i + 8];
                end

                state <= state + 1;
            end
            STAGE_1_WAIT,
            STAGE_2_WAIT,
            STAGE_3_WAIT,
            STAGE_4_WAIT: begin
                for (i = 0; i < 8; i = i + 1) begin
                    mul_temp_real[i]    <= (temp_real[i+8] * W_r[i]);
                    mul_temp_real[i+8]  <= (temp_image[i+8] * W_i[i]);
                    mul_temp_image[i]   <= (temp_real[i+8] * W_i[i]);
                    mul_temp_image[i+8] <= (temp_image[i+8] * W_r[i]);
                end
                state <= state + 1;
            end
            STAGE_1_WAIT_2,
            STAGE_2_WAIT_2,
            STAGE_3_WAIT_2,
            STAGE_4_WAIT_2: begin
                for (i = 0; i < 8; i = i + 1) begin
                    stage_real[2*i] <= temp_real[i];
                    stage_image[2*i] <= temp_image[i];
                end
                for (i = 0; i < 8; i = i + 1) begin
                    stage_real[2*i+1] <= (mul_temp_real[i] - mul_temp_real[i+8]) >>> 16;
                    stage_image[2*i+1] <= (mul_temp_image[i] + mul_temp_image[i+8]) >>> 16;
                end
                state <= state + 1;
            end
            STAGE_4_FINISH: begin
                fft_d0  <= stage_real[0]  >>> Fractional_Add_bit;
                fft_d8  <= stage_real[1]  >>> Fractional_Add_bit;
                fft_d4  <= stage_real[2]  >>> Fractional_Add_bit;
                fft_d12 <= stage_real[3]  >>> Fractional_Add_bit;
                fft_d2  <= stage_real[4]  >>> Fractional_Add_bit;
                fft_d10 <= stage_real[5]  >>> Fractional_Add_bit;
                fft_d6  <= stage_real[6]  >>> Fractional_Add_bit;
                fft_d14 <= stage_real[7]  >>> Fractional_Add_bit;
                fft_d1  <= stage_real[8]  >>> Fractional_Add_bit;
                fft_d9  <= stage_real[9]  >>> Fractional_Add_bit;
                fft_d5  <= stage_real[10] >>> Fractional_Add_bit;
                fft_d13 <= stage_real[11] >>> Fractional_Add_bit;
                fft_d3  <= stage_real[12] >>> Fractional_Add_bit;
                fft_d11 <= stage_real[13] >>> Fractional_Add_bit;
                fft_d7  <= stage_real[14] >>> Fractional_Add_bit;
                fft_d15 <= stage_real[15] >>> Fractional_Add_bit;

                fft_valid <= 1'b1;
                state <= OUTPUT_REAL_DONE;
            end

            OUTPUT_REAL_DONE: begin
                fft_valid <= 1'b1;
                fft_d0  <= stage_image[0]  >>> Fractional_Add_bit;
                fft_d8  <= stage_image[1]  >>> Fractional_Add_bit; 
                fft_d4  <= stage_image[2]  >>> Fractional_Add_bit; 
                fft_d12 <= stage_image[3]  >>> Fractional_Add_bit; 
                fft_d2  <= stage_image[4]  >>> Fractional_Add_bit; 
                fft_d10 <= stage_image[5]  >>> Fractional_Add_bit; 
                fft_d6  <= stage_image[6]  >>> Fractional_Add_bit; 
                fft_d14 <= stage_image[7]  >>> Fractional_Add_bit; 
                fft_d1  <= stage_image[8]  >>> Fractional_Add_bit; 
                fft_d9  <= stage_image[9]  >>> Fractional_Add_bit; 
                fft_d5  <= stage_image[10] >>> Fractional_Add_bit; 
                fft_d13 <= stage_image[11] >>> Fractional_Add_bit;
                fft_d3  <= stage_image[12] >>> Fractional_Add_bit; 
                fft_d11 <= stage_image[13] >>> Fractional_Add_bit;
                fft_d7  <= stage_image[14] >>> Fractional_Add_bit; 
                fft_d15 <= stage_image[15] >>> Fractional_Add_bit;

                fft_valid <= 1'b1;
                state <= OUTPUT_IMAGE_DONE;
            end

            OUTPUT_IMAGE_DONE: begin
                fft_valid <= 1'b0;
                state <= COPY_UNABLE;
                
                for (i = 0; i < 16; i = i + 1) begin
                    stage_real[i] <= 0;
                    stage_image[i] <= 0;
                end
                // for (i = 0; i < 8; i = i + 1) begin
                //     mul_temp_real[i] <= 0;
                //     mul_temp_image[i] <= 0;
                // end
                if (!fir_valid) begin
                    done <= 1'b1;
                end else begin
                    done <= 1'b0;
                end
            end

            default: begin
                for (i = 0; i < 16; i = i + 1) begin
                    stage_real[i] <= 0;
                    stage_image[i] <= 0;
                end
                // for (i = 0; i < 8; i = i + 1) begin
                //     mul_temp_real[i] <= 0;
                //     mul_temp_image[i] <= 0;
                // end
                fft_valid <= 1'b0;
                done <= 1'b0;
            end
        endcase
    end
endmodule