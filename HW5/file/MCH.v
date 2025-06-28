module MCH (
    input               clk,
    input               reset,
    input       [ 7:0]  X,    // Q8.0
    input       [ 7:0]  Y,    // Q8.0
    output reg          Done,
    output reg  [16:0]  area  // Q16.1
);

/////////////////////////////////
// Please write your code here //
/////////////////////////////////
    parameter [4:0] DATA_COUNT = 20;
    reg [7:0] x_values [0:DATA_COUNT-1];
    reg [7:0] y_values [0:DATA_COUNT-1];
    reg [4:0] write_addr;
    // reg copy_done;
    integer i;
    
    // FIND P0
    reg [4:0] p0_idx, find_idx;
    reg [7:0] p0_x, p0_y, tmp_x, tmp_y;

    
    parameter [3:0] S_IDLE    = 4'd0,
                    S_FIND_P0 = 4'd1,
                    S_SWAP_P0 = 4'd2,
                    S_SORT    = 4'd3,
                    S_SCAN    = 4'd4,
                    S_AREA    = 4'd5,
                    S_DONE    = 4'd6;

    reg [3:0] state, next_state;



    always @(posedge clk or posedge reset) begin
        if (reset) begin
            p0_x <= 8'hFF;  // Initialize to max value
            p0_y <= 8'hFF;  // Initialize to max value
            p0_idx <= 5'd0;
            find_idx <= 0;
        end else if (Done) begin
            p0_x <= 8'hFF;  // Initialize to max value
            p0_y <= 8'hFF;  // Initialize to max value
            p0_idx <= 5'd0;
            find_idx <= 0;
        end else if (state == S_FIND_P0) begin
            if (find_idx == 0) begin
                p0_x <= x_values[0];
                p0_y <= y_values[0];
                p0_idx <= 0;
                find_idx <= 1;
            end else if (find_idx < DATA_COUNT) begin
                if (y_values[find_idx] < p0_y ||
                (y_values[find_idx] == p0_y && x_values[find_idx] < p0_x)) begin
                    p0_x <= x_values[find_idx];
                    p0_y <= y_values[find_idx];
                    p0_idx <= find_idx;
                end
                find_idx <= find_idx + 1;
            end
        end
    end

    // Cross product function
    function signed [16:0] cross;
        input signed [8:0] x1, y1, x2, y2;
        cross = x1 * y2 - x2 * y1;
    endfunction

    // Calculate orientation of (p, q, r)
    // function signed [16:0] orientation;
    //     input [4:0] p, q, r;
    //     orientation = cross(
    //         x_values[q] - x_values[p],
    //         y_values[q] - y_values[p],
    //         x_values[r] - x_values[p],
    //         y_values[r] - y_values[p]
    //     );
    // endfunction

    // sorted_idx[i] 代表原始點 index
    // reg [4:0] sorted_idx[0:19];
    reg [4:0] sort_pass;
    // reg signed [16:0] ori_reg;
    // wire signed [16:0] orient;
    reg [4:0] p_o, q_o, r_o;
    // assign orient = orientation(p_o, q_o, r_o);

    
    reg [4:0] c_0, c_1;
    wire signed [16:0] cross_area;

    wire signed [8:0] x_1, y_1, x_2, y_2;
    assign x_1 = (state == S_AREA) ? x_values[c_0] : x_values[q_o] - x_values[p_o];
    assign y_1 = (state == S_AREA) ? y_values[c_0] : y_values[q_o] - y_values[p_o];
    assign x_2 = (state == S_AREA) ? x_values[c_1] : x_values[r_o] - x_values[p_o];
    assign y_2 = (state == S_AREA) ? y_values[c_1] : y_values[r_o] - y_values[p_o];
    assign cross_area = cross(x_1, y_1, x_2, y_2);



    // reg [4:0] tmp;
    integer j, k;
    reg init_sort, init_scan;
    
    reg [4:0] top;

    // 20個cycle 會讀完值
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            write_addr <= 0;
            sort_pass <= 0;
            // sort_i <= 1;
            init_sort <= 1;
            init_scan <= 1;
            top <= 0;
            // scan_i <= 0;
        end else if (Done) begin
            write_addr <= 0;
            sort_pass <= 0;
            // sort_i <= 1;
            init_sort <= 1;
            init_scan <= 1;
            top <= 0;
            // scan_i <= 0;
        end else if (write_addr < DATA_COUNT) begin
            x_values[write_addr] <= X;
            y_values[write_addr] <= Y;
            write_addr <= write_addr + 1;
        end else
            case(state)
            S_SWAP_P0: begin
                x_values[p0_idx] <= x_values[0];
                x_values[0] <= p0_x;
                y_values[p0_idx] <= y_values[0];
                y_values[0] <= p0_y;
            end

            S_SORT: begin
                if (init_sort) begin
                    sort_pass <= 0;
                    init_sort <= 0;

                    p_o <= 0;
                    q_o <= 1;
                    r_o <= 2;
                end else begin
                    if (q_o < DATA_COUNT - 1 - sort_pass) begin
                        // 計算 orientation(x[0], x[i], x[i+1])
                        // orient = orientation(0, sort_i, sort_i + 1);
                        if (cross_area < 0) begin
                            // swap x_values
                            // tmp_x = x_values[q_o];
                            {x_values[q_o], x_values[q_o+1]} = {x_values[q_o+1], x_values[q_o]};
                            {y_values[q_o], y_values[q_o+1]} = {y_values[q_o+1], y_values[q_o]};
                            // swap y_values
                            // tmp_y = y_values[q_o];
                            // y_values[q_o] = y_values[q_o+1];
                            // y_values[q_o+1] = tmp_y;
                        end
                        q_o <= q_o + 1;
                        r_o <= r_o + 1;
                    end else begin
                        q_o <= 1;
                        r_o <= 2;
                        sort_pass <= sort_pass + 1;
                    end
                end
            end

            S_SCAN: begin
            if (init_scan) begin
                init_scan <= 0;
                top <= 1;
                // scan_i <= 2;
                p_o <= 0;
                q_o <= 1;
                r_o <= 2;
                // 前兩點永遠在 hull 中
                // x_values[0], y_values[0] already P0
                // x_values[1], y_values[1] already sorted 2nd
            end else if (r_o < DATA_COUNT) begin
                // 計算 orientation(x[top-1], x[top], x[scan_i])
                // ori_reg = orientation(top-1, top, scan_i);

                if (top > 0 && cross_area <= 0) begin
                    top <= top - 1; // Pop
                    p_o <= p_o - 1;
                    q_o <= q_o - 1;
                    r_o <= r_o;
                end else begin
                    top <= top + 1;
                    if (top < DATA_COUNT) begin
                        // Push: 把 scan_i 的點搬到 top+1
                        x_values[top+1] <= x_values[r_o];
                        y_values[top+1] <= y_values[r_o];
                    end
                    p_o <= p_o + 1;
                    q_o <= q_o + 1;
                    r_o <= r_o + 1;
                end
            end
            end
            default: 
            begin
                init_sort <= 1;
                // init_scan <= 1;
            end


            endcase
    end


    // 計算凸包面積（向量叉積法）
    // reg [4:0] area_i;
    reg signed [16:0] temp_area;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            temp_area <= 0;
            c_0 <= 0;
            c_1 <= 1;
        end else if (Done) begin
            temp_area <= 0;
            c_0 <= 0;
            c_1 <= 1;
        end else if (state == S_AREA) begin
            if (c_0 < top) begin
                temp_area <= temp_area + cross_area;
                // area_i <= area_i + 1;
                
                c_0 <= c_0 + 1;
                c_1 <= (c_1 < top ) ? c_1 + 1 : 0;
                
            end else begin
                temp_area <= temp_area + cross_area;
            end
            // $display("================ cross_area %h ================", cross_area);
        end
    end


    always @(posedge clk or posedge reset) begin
        if (reset)
            Done <= 0;
        else if (Done)
            Done <= 0;
        else if (state == S_DONE) begin
            Done <= 1;
            area <= temp_area;
        end
        else
            Done <= 0;
    end

    // FSM Transitions
    // FSM Transition
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= S_IDLE;
        else if (Done)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            S_IDLE:    next_state = (write_addr == 2) ? S_FIND_P0 : S_IDLE;
            S_FIND_P0: next_state = (find_idx == DATA_COUNT)   ? S_SWAP_P0 : S_FIND_P0;
            S_SWAP_P0: next_state = S_SORT;
            S_SORT:    next_state = (sort_pass == 18)          ? S_SCAN    : S_SORT;
            S_SCAN:    next_state = (~init_scan && r_o == DATA_COUNT)     ? S_AREA    : S_SCAN;
            S_AREA:    next_state = (c_0 == top)            ? S_DONE    : S_AREA;
            S_DONE:    next_state = S_IDLE;
            default:   next_state = S_IDLE;
        endcase
    end
endmodule
