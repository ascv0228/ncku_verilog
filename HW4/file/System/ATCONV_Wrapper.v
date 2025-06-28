`timescale 1ns/10ps
`include "./include/define.v"

module ATCONV_Wrapper(
    input		                        bus_clk  ,
    input		                        bus_rst  ,
    input         [`BUS_DATA_BITS-1:0]  RDATA_M  ,
    input 	      					 	RLAST_M  ,
    input 	      					 	WREADY_M ,
    input 	      					 	RREADY_M ,
    output reg    [`BUS_ID_BITS  -1:0]  ID_M	 ,
    output reg    [`BUS_ADDR_BITS-1:0]  ADDR_M	 ,
    output reg    [`BUS_DATA_BITS-1:0]  WDATA_M  ,
    output        [`BUS_LEN_BITS -1:0]  BLEN_M   , // BLEN = 4 always
    output reg					 	    WLAST_M  ,
    output reg 						    WVALID_M ,
    output reg 						    RVALID_M ,
    output reg                          done   
);

    /////////////////////////////////
	// Please write your code here //
	/////////////////////////////////
    
    reg signed [15:0] raw_array [0:511]; // 64 * 8
    reg signed [15:0] atrous_array [0:127]; // 64 * 2
    // reg [9:0] raw_addr; // from [11:0] to [9:0]
    // reg [9:0] layer0_calc_addr; // from [11:0] to [9:0]
    // reg [7:0] layer1_calc_addr; // from [9:0] to [7:0]
    reg [11:0] raw_addr;
    reg [11:0] layer0_calc_addr;
    reg [9:0] layer1_calc_addr;
    reg [9:0] raw_base_addr; // from [11:0] to [9:0]
    reg [9:0] layer0_calc_base_addr; // from [11:0] to [9:0]
    reg [7:0] layer1_calc_base_addr; // from [9:0] to [7:0]

    reg [3:0] state; // 0 <= init_read(read_ROM 2*64), 1 <= read_ROM(2*64), 2 <= write_SRAM0(2*64), 3 <= write SROM1

    parameter [3:0]READ_ROM_0   = 4'd0;
    parameter [3:0]DONE_ROM_0   = 4'd1; // READ_ROM_0已完成
    parameter [3:0]READ_ROM_128 = 4'd2;
    parameter [3:0]DONE_ROM_128 = 4'd3;
    parameter [3:0]WRITE_SRAM0  = 4'd4;
    parameter [3:0]DONE_SRAM0   = 4'd5;
    parameter [3:0]WRITE_SRAM1  = 4'd6;
    parameter [3:0]DONE_SRAM1   = 4'd7;
    parameter [3:0]DONE_ALL   = 4'd8;

    assign BLEN_M = 4'd4;
    
    // state machine
    reg isHankShake;
    always @(posedge bus_clk or posedge bus_rst) begin
        if (bus_rst) begin
            state <= 0;
            isHankShake <= 0;
            state <= READ_ROM_0;
            done <= 1'b0;
        end	else begin
            if (WREADY_M || RREADY_M) begin
                isHankShake = 1'b1;
            end else if (WLAST_M || RLAST_M)begin
                isHankShake = 1'b0;
            end
            case (state)
                READ_ROM_0: begin
                    ID_M <= 0;
                    RVALID_M <= (~isHankShake && (raw_addr[6:0] != 7'b1111111));
                    WVALID_M <= 1'b0;
                    if (RLAST_M && (raw_addr[6:0] == 7'b1111111)) begin
                        state <= DONE_ROM_0;
                    end
                end
                READ_ROM_128: begin
                    ID_M <= 0;
                    RVALID_M <= (~isHankShake && (raw_addr[6:0] != 7'b1111111));
                    WVALID_M <= 1'b0;
                    if (RLAST_M && (raw_addr[6:0] == 7'b1111111)) begin
                        state <= DONE_ROM_128;
                    end
                end
                WRITE_SRAM0: begin
                    ID_M <= 1;
                    WVALID_M <= (~isHankShake && (layer0_calc_addr[6:0] != 7'b1111111));
                    RVALID_M <= 1'b0;
                    if ((layer0_calc_addr[6:0] == 7'b1111111)) begin
                        state <= DONE_SRAM0;
                    end
                end
                WRITE_SRAM1: begin
                    ID_M <= 2;
                    WVALID_M <= (~isHankShake && (layer1_calc_addr[4:0] != 5'b11111));
                    RVALID_M <= 1'b0;
                    if ((layer1_calc_addr[4:0] == 5'b11111)) begin
                        state <= (layer1_calc_base_addr[7:0] == 8'b11111111) ? DONE_ALL : 
                                 (layer1_calc_base_addr[7:0] == 8'b11110111) ? DONE_ROM_128 : 
                                 DONE_SRAM1;
                    end
                end
                DONE_ROM_0: begin
                    ID_M <= 3;
                    RVALID_M <= 1'b0;
                    WVALID_M <= 1'b0;
                    state <= READ_ROM_128;
                end
                DONE_ROM_128: begin
                    ID_M <= 3;
                    RVALID_M <= 1'b0;
                    WVALID_M <= 1'b0;
                    state <= WRITE_SRAM0;
                end
                DONE_SRAM0: begin
                    ID_M <= 3;
                    RVALID_M <= 1'b0;
                    WVALID_M <= 1'b0;
                    state <= WRITE_SRAM1;
                end
                DONE_SRAM1: begin
                    ID_M <= 3;
                    RVALID_M <= 1'b0;
                    WVALID_M <= 1'b0;
                    state <= READ_ROM_128;
                end
                DONE_ALL: begin
                    ID_M <= 3;
                    RVALID_M <= 1'b0;
                    WVALID_M <= 1'b0;
                    done <= 1'b1;
                    state <= DONE_ALL;
                end
            endcase
        end
    end

    
    parameter signed[15:0] bias = 16'hFFF4;
    wire signed [15:0] tmp_sum, out_L0;
    wire [15:0] max_val;
    // read from ROM
    reg [11:0] next0_A;
    reg [9:0] next1_A;
    reg [`BUS_LEN_BITS -1:0] b_len;
    reg allow_operater;
    always @(posedge bus_clk or posedge bus_rst) begin
        if (bus_rst) begin
            ADDR_M <= 0;
            raw_addr <= 0;
            layer0_calc_addr <= 0;
            layer1_calc_addr <= 0;
            raw_base_addr <= 0;
            layer0_calc_base_addr <= 0;
            layer1_calc_base_addr <= 0;
        end
        else begin
            allow_operater <= isHankShake;
            case (state)
                READ_ROM_0, READ_ROM_128: begin
                    WLAST_M <= 1'b0;
                    if (RLAST_M) begin
                        raw_base_addr <= raw_base_addr + 1;
                        ADDR_M <= {raw_base_addr + 1, 2'd0};
                    end
                    else begin
                        raw_base_addr <= raw_base_addr;
                        ADDR_M <= {raw_base_addr, 2'd0};
                    end
                    if (isHankShake) begin
                        raw_addr <= {raw_base_addr, 2'd0};
                    end
                    if (allow_operater) begin
                        raw_array[raw_addr[8:0]] <= RDATA_M;
                        raw_addr <= raw_addr + 1;
                    end
                end
                WRITE_SRAM0: begin
                    if (WLAST_M) begin
                        layer0_calc_base_addr <= layer0_calc_base_addr + 1;
                        ADDR_M <= {layer0_calc_base_addr + 1, 2'd0};
                    end
                    else begin
                        layer0_calc_base_addr <= layer0_calc_base_addr;
                        ADDR_M <= {layer0_calc_base_addr, 2'd0};
                    end
                    if (isHankShake) begin
                        WDATA_M <= out_L0;
                        atrous_array[layer0_calc_addr[6:0]] <= out_L0;
                        layer0_calc_addr <= layer0_calc_addr + 1;
                    end
                    WLAST_M <= layer0_calc_addr[1:0] == 2'b11;
                end
                WRITE_SRAM1: begin
                    if (WLAST_M) begin
                        layer1_calc_base_addr <= layer1_calc_base_addr + 1;
                        ADDR_M <= {layer1_calc_base_addr + 1, 2'd0};
                    end
                    else begin
                        layer1_calc_base_addr <= layer1_calc_base_addr;
                        ADDR_M <= {layer1_calc_base_addr, 2'd0};
                    end
                    if (isHankShake) begin
                        WDATA_M <= max_val;
                        layer1_calc_addr <= layer1_calc_addr + 1;
                    end
                    WLAST_M <= layer1_calc_addr[1:0] == 2'b11;
                end
                DONE_ROM_0, DONE_ROM_128, DONE_ALL: begin
                    if (WLAST_M) begin
                        layer1_calc_base_addr <= layer1_calc_base_addr + 1;
                        WLAST_M <= 1'b0;
                    end
                end
                DONE_SRAM0:  begin
                    if (WLAST_M) begin
                        layer0_calc_base_addr <= layer0_calc_base_addr + 1;
                        WLAST_M <= 1'b0;
                    end
                end
                DONE_SRAM1: begin
                    if (WLAST_M) begin
                        layer1_calc_base_addr <= layer1_calc_base_addr + 1;
                        WLAST_M <= 1'b0;
                    end
                end
                
            endcase
        end
    end
    // ////////////////////////////////////
        
    wire [5:0] layer0_x, layer0_y;
    wire [2:0] up_y, down_y;
    wire [5:0] left_x, right_x;

    assign layer0_y = layer0_calc_addr[11:6];
    assign layer0_x = layer0_calc_addr[5:0];
    
    assign up_y = (layer0_y > 1) ? (layer0_y - 6'd2) & 3'b111 : 3'b000;
    assign down_y = (layer0_y < 62) ? (layer0_y + 6'd2) & 3'b111 : 3'b111;
    assign left_x = (layer0_x > 1) ? layer0_x - 2: 6'b000;
    assign right_x = (layer0_x < 62) ? layer0_x + 2: 6'b111111;

    wire signed [15:0] p0 = raw_array[{up_y,     left_x  }];
    wire signed [15:0] p1 = raw_array[{up_y,     layer0_x}];
    wire signed [15:0] p2 = raw_array[{up_y,     right_x }];
    wire signed [15:0] p3 = raw_array[{layer0_y[2:0], left_x  }];
    wire signed [15:0] p4 = raw_array[{layer0_y[2:0], layer0_x}];
    wire signed [15:0] p5 = raw_array[{layer0_y[2:0], right_x }];
    wire signed [15:0] p6 = raw_array[{down_y,   left_x  }];
    wire signed [15:0] p7 = raw_array[{down_y,   layer0_x}];
    wire signed [15:0] p8 = raw_array[{down_y,   right_x }];
    
    assign tmp_sum = p4 + ((-(p0 + p2 + p6 + p8)) >>> 4) + ((-(p1 + p7)) >>> 3) + ((-(p3 + p5)) >>> 2) + bias;
    assign out_L0 = (tmp_sum[15]) ? 16'sd0 : tmp_sum; // if negative, set to 0
    // ////////////////////////////////////////////////////
    
    wire [4:0] layer1_row, layer1_col;  // index for 32x32
    wire [15:0] a, b, c, d;
    wire [15:0] max_out;

    assign layer1_row = layer1_calc_addr[6:5];
    assign layer1_col = layer1_calc_addr[4:0];

    wire [1:0] layer1_base_row = layer1_row * 2;
    wire [5:0] layer1_base_col = layer1_col * 2;
    wire [6:0] layer1_base_addr = {layer1_base_row, layer1_base_col};
    assign a = atrous_array[layer1_base_addr];
    assign b = atrous_array[layer1_base_addr+1];
    assign c = atrous_array[layer1_base_addr+64];
    assign d = atrous_array[layer1_base_addr+65];


    find_max_4 max_inst (
        .a(a), .b(b), .c(c), .d(d),
        .max(max_out)
    );

    assign max_val = (max_out[3:0] != 4'b0000) ? {max_out[15:4] + 1'b1, 4'b0000} : max_out;

endmodule

module find_max_4(
    input  [15:0] a,
    input  [15:0] b,
    input  [15:0] c,
    input  [15:0] d,
    output [15:0] max
);
    wire [15:0] max_1, max_2;

    assign max_1 = (a > b) ? a : b;
    assign max_2 = (c > d) ? c : d;
    assign max   = (max_1 > max_2) ? max_1 : max_2;
endmodule