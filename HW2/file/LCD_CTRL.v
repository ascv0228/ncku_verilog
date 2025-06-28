// `include "calculate_Avg.v"
// // `include "calculate_Max.v"
// `include "calculate_Min.v"

module LCD_CTRL(
    input           clk,
    input           rst,
    input   [3:0]   cmd,
    input           cmd_valid,
    input   [7:0]   IROM_Q,
    output reg      IROM_rd,
    output reg [5:0] IROM_A,
    output reg      IRAM_ceb,  // **保持 1 进行写入**
    output reg      IRAM_web,  // **0 时写入**
    output reg [7:0] IRAM_D,
    output reg [5:0] IRAM_A,
    input   [7:0]   IRAM_Q,
    output reg      busy,
    output reg      done
);
    
    reg [7:0] memory [0:63];  // 64 个 8-bit 存储单元
    reg [5:0] count;  // 计数器用于地址递增
    
    // 状态定义（使用 parameter）
    parameter LOAD      = 1'b0;  // 读取 IROM 数据
    parameter LOADDONE  = 1'b1;  // 读取完成，等待命令

    reg state;

    // 处理命令（使用 parameter）
    parameter WRITE       = 4'b0000;
    parameter SHIFT_UP    = 4'b0001;
    parameter SHIFT_DOWN  = 4'b0010;
    parameter SHIFT_LEFT  = 4'b0011;
    parameter SHIFT_RIGHT = 4'b0100;
    parameter MAX         = 4'b0101;
    parameter MIN         = 4'b0110;
    parameter AVG         = 4'b0111;
    parameter DONE        = 4'b1000;
    parameter NONE        = 4'b1111;
    

    reg [3:0] process;

    reg [2:0] index_x, index_y;
    reg [5:0] index_array [15:0];
    reg [127:0] region_memory;
    // reg [7:0] modified_value;

    always @(posedge clk) begin
        if (state == LOAD) begin
            memory[IROM_A] <= IROM_Q;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            IROM_rd   <= 1'b1;  // 复位后立刻开始读 IROM
            IROM_A    <= 6'd0;  // 地址从 0 开始
            state     <= LOAD;
            busy      <= 1'b1;
            done      <= 1'b0;
            index_x   <= 4;
            index_y   <= 4;
        end else begin
            case (state)
                LOAD: begin
                      // 存入 memory
                    if (IROM_A == 6'd63) begin
                        IROM_rd <= 1'b0;  // 读取完成
                        state   <= LOADDONE;  // 进入下一个阶段
                        busy  <= 1'b0;
                    end else begin
                        IROM_A <= IROM_A + 1;  // 地址递增
                    end
                end

                LOADDONE: begin
                    IROM_A <= 6'd0;
                end
            endcase
        end
    end

    reg [3:0] cmd_count; 
    
    reg [7:0] max_value, min_value, avg_value, modified_value;
    reg [11:0] sum;
    reg calculate_done;
    // cmd, initialize
    always @(posedge clk) begin
        if (cmd_valid && state == LOADDONE && !busy) begin
            busy  <= 1'b1;
            done  <= 1'b0;
            count <= 6'd0;

            case (cmd)
                WRITE: begin
                    IRAM_ceb <= 1'b1;
                    IRAM_web <= 1'b0;
                    IRAM_A   <= 6'd0;
                    IRAM_D   <= 8'd0;
                    process  <= WRITE;
                end

                
                SHIFT_UP: begin
                    if (index_y > 2) begin
                        index_y <= index_y - 1;
                    end
                    process = SHIFT_UP;
                end

                SHIFT_DOWN: begin
                    if (index_y < 6) begin
                        index_y <= index_y + 1;
                    end
                    process = SHIFT_DOWN;
                end

                SHIFT_LEFT: begin
                    if (index_x > 2) begin
                        index_x <= index_x - 1;
                    end
                    process = SHIFT_LEFT;
                end

                SHIFT_RIGHT: begin
                    if (index_x < 6) begin
                        index_x <= index_x + 1;
                    end
                    process = SHIFT_RIGHT;
                end

                MAX, MIN, AVG: begin
                    region_memory = { 
                        memory[8 * index_y + index_x - 18], memory[8 * index_y + index_x - 17],
                        memory[8 * index_y + index_x - 16], memory[8 * index_y + index_x - 15],
                        memory[8 * index_y + index_x - 10], memory[8 * index_y + index_x - 9],
                        memory[8 * index_y + index_x - 8 ], memory[8 * index_y + index_x - 7],
                        memory[8 * index_y + index_x - 2 ], memory[8 * index_y + index_x - 1],
                        memory[8 * index_y + index_x     ], memory[8 * index_y + index_x + 1],
                        memory[8 * index_y + index_x + 6 ], memory[8 * index_y + index_x + 7],
                        memory[8 * index_y + index_x + 8 ], memory[8 * index_y + index_x + 9] 
                    };
                    cmd_count <= 4'd0;
                    process = cmd;
                    calculate_done = 1'b0;
                    
                end
                default: begin
                end
            endcase
        end
    end


    // process
    always @(posedge clk) begin
        if (busy) begin
            case (process)
                WRITE: begin
                    IRAM_A = IRAM_A + 1;
                    IRAM_D <= memory[IRAM_A];
                    if(IRAM_A == 6'd63) begin
                        process <= DONE;
                    end
                end

                SHIFT_UP, SHIFT_DOWN, SHIFT_LEFT, SHIFT_RIGHT: begin
                    process = NONE;
                end

                MAX, MIN, AVG: begin
                    if(!calculate_done) begin
                        if (cmd_count == 4'd0) begin
                            max_value <= region_memory[cmd_count*8 +: 8];
                            min_value <= region_memory[cmd_count*8 +: 8];
                            sum <= region_memory[cmd_count*8 +: 8];
                        end
                        else begin
                            if (region_memory[cmd_count*8 +: 8] > max_value)
                                max_value <= region_memory[cmd_count*8 +: 8];
                            if (region_memory[cmd_count*8 +: 8] < min_value)
                                min_value <= region_memory[cmd_count*8 +: 8];
                            sum <= sum + region_memory[cmd_count*8 +: 8];
                        end

                        cmd_count <= cmd_count + 1;
                        if (cmd_count == 4'd15) begin
                            calculate_done = 1'b1;
                        end
                    end
                    else begin
                        modified_value = (process == MAX) ? max_value : (process == MIN) ? min_value : sum >> 4;
                        { 
                            memory[8 * index_y + index_x - 18], memory[8 * index_y + index_x - 17],
                            memory[8 * index_y + index_x - 16], memory[8 * index_y + index_x - 15],
                            memory[8 * index_y + index_x - 10], memory[8 * index_y + index_x - 9],
                            memory[8 * index_y + index_x - 8 ], memory[8 * index_y + index_x - 7],
                            memory[8 * index_y + index_x - 2 ], memory[8 * index_y + index_x - 1],
                            memory[8 * index_y + index_x     ], memory[8 * index_y + index_x + 1],
                            memory[8 * index_y + index_x + 6 ], memory[8 * index_y + index_x + 7],
                            memory[8 * index_y + index_x + 8 ], memory[8 * index_y + index_x + 9] 
                        } = {16{modified_value}};
                        process = NONE;
                    end
                end

                DONE: begin
                    done <= 1'b1;
                    busy <= 1'b0;
                    IRAM_web <= 1'b1;
                    IRAM_ceb <= 1'b0;
                end 

                NONE: begin
                    done <= 1'b0;
                    busy <= 1'b0;
                    IRAM_web <= 1'b1;
                    IRAM_ceb <= 1'b0;
                    process = NONE;
                end
            endcase
        end
    end

endmodule
