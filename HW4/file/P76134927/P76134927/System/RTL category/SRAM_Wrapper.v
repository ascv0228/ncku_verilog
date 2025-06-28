`timescale 1ns/10ps
`include "../include/define.v"

module SRAM_Wrapper(
    input                           bus_clk ,
    input                           bus_rst ,
    input      [`BUS_ADDR_BITS-1:0] ADDR_S  ,
    input      [`BUS_DATA_BITS-1:0] WDATA_S ,
    input      [`BUS_LEN_BITS -1:0] BLEN_S  ,
    input                           WLAST_S ,
    input                           WVALID_S,
    input                           RVALID_S,
    output reg [`BUS_DATA_BITS-1:0] RDATA_S ,
    output reg                      RLAST_S ,
    output reg                      WREADY_S,
    output reg                      RREADY_S,
    output     [`BUS_DATA_BITS-1:0] SRAM_D  ,
    output reg [`BUS_ADDR_BITS-1:0] SRAM_A  ,
    input      [`BUS_DATA_BITS-1:0] SRAM_Q  ,
    output reg                      SRAM_ceb,
    output reg                      SRAM_web
);
    /////////////////////////////////
    // Please write your code here //
    /////////////////////////////////
    parameter [1:0] IDLE = 2'b00,
                    WRITE = 2'b01,
                    READ = 2'b10,
                    LAST = 2'b11;

    reg [1:0] state;
    reg [`BUS_LEN_BITS-1:0] cnt;
    // reg [`BUS_ADDR_BITS-1:0] base_addr;
    // reg [`BUS_LEN_BITS -1:0] b_len;
    reg isWHandShake, isRHandShake;
    always @(posedge bus_clk or posedge bus_rst) begin
        if (bus_rst) begin
            isWHandShake <= 0;
            isRHandShake <= 0;
        end else begin
            if (WREADY_S) begin
                isWHandShake = 1'b1;
            end else if (WLAST_S)begin
                isWHandShake = 1'b0;
            end
            if (RREADY_S) begin
                isRHandShake = 1'b1;
            end else if (RLAST_S)begin
                isRHandShake = 1'b0;
            end
        end
    end
    assign SRAM_D = WDATA_S;
    always @(posedge bus_clk or posedge bus_rst) begin
        if (bus_rst) begin
            state    <= IDLE;
            cnt      <= 0;
            RDATA_S  <= 0;
            RLAST_S  <= 0;
            WREADY_S <= 0;
            RREADY_S <= 0;
            // SRAM_D   <= 0;
            SRAM_A   <= 0;
            SRAM_ceb <= 0; // 高代表 disable
            SRAM_web <= 0; // 高代表 read
        end else begin
            case (state)
                IDLE: begin
                    WREADY_S <= 0;
                    RREADY_S <= 0;
                    SRAM_ceb <= 0;
                    SRAM_web <= 0;
                    RLAST_S  <= 0;

                    if (WVALID_S) begin
                        state      <= WRITE;
                        // base_addr  <= ADDR_S;
                        SRAM_A     <= ADDR_S;
                        // b_len      <= BLEN_S;
                        // SRAM_D     <= WDATA_S;
                        WREADY_S   <= 1;
                        cnt        <= 0;
                    end else if (RVALID_S) begin
                        state      <= READ;
                        // base_addr  <= ADDR_S;
                        SRAM_A     <= ADDR_S;
                        // b_len      <= BLEN_S;
                        RREADY_S   <= 1;
                        cnt        <= 0;
                    end
                end
                WRITE: begin
                    SRAM_A   <= ADDR_S + cnt;
                    // SRAM_D   <= WDATA_S;
                    SRAM_ceb <= 1;
                    SRAM_web <= 0;
                    WREADY_S <= 0;

                    if (WLAST_S || cnt == BLEN_S) begin
                        state      <= IDLE;
                        SRAM_ceb   <= 0;
                        SRAM_web   <= 0;
                    end else begin
                        cnt <= cnt + 1;
                    end
                end
                READ: begin
                    SRAM_A   <= ADDR_S + cnt;
                    SRAM_ceb <= 1;
                    SRAM_web <= 1;
                    RDATA_S  <= SRAM_Q;
                    RLAST_S  <= (cnt == BLEN_S - 1);

                    if (cnt == BLEN_S - 1) begin
                        state    <= IDLE;
                        SRAM_ceb <= 1;
                    end else begin
                        cnt <= cnt + 1;
                    end
                end
            endcase
        end
    end
endmodule