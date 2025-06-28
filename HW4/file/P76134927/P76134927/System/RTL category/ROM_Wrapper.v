`timescale 1ns/10ps
`include "../include/define.v"

module ROM_Wrapper(
	input     						bus_clk ,
	input     						bus_rst ,
	input      [`BUS_ADDR_BITS-1:0] ADDR_S  ,
	input      [`BUS_LEN_BITS -1:0] BLEN_S  ,
	input     						RVALID_S,
	output reg [`BUS_DATA_BITS-1:0] RDATA_S ,
	output reg 						RLAST_S ,
	output reg 						RREADY_S,
	output reg 						ROM_rd  ,
	output reg [`BUS_ADDR_BITS-1:0] ROM_A  	,
	input 	   [`BUS_DATA_BITS-1:0] ROM_Q 
);

	// 狀態編碼
	localparam IDLE      = 2'd0,
			   READ_WAIT = 2'd1,  // 等待 ROM_Q 有效
			   READ      = 2'd2;

	reg [1:0] state;

	// 控制變數
	reg [`BUS_LEN_BITS-1:0] read_count;
	// reg [`BUS_ADDR_BITS-1:0] base_addr;
	// reg [`BUS_LEN_BITS -1:0] b_len;

	always @(posedge bus_clk or posedge bus_rst) begin
		if (bus_rst) begin
			state      <= IDLE;
			RDATA_S    <= 0;
			RLAST_S    <= 0;
			RREADY_S   <= 0;
			ROM_rd     <= 0;
			ROM_A      <= 0;
			read_count <= 0;
			// b_len      <= 0;
		end else begin
			case (state)
				IDLE: begin
					RDATA_S    <= 0;
					RLAST_S    <= 0;
					RREADY_S   <= 0;  // ready to accept command
					ROM_rd     <= 0;

					if (RVALID_S) begin
						state      <= READ;
						// b_len      <= BLEN_S;
						read_count <= 1;
						RREADY_S   <= 1;      // 收到命令後清除
						ROM_A      <= ADDR_S;
						ROM_rd     <= 1;      // 啟動第一次 ROM 讀取
					end
				end

				// READ_WAIT: begin
				// 	state    <= READ;
				// 	RREADY_S   <= 0;      // 收到命令後清除
				// 	ROM_rd   <= 1;
				// 	ROM_A      <= ADDR_S + read_count;
				// 	RDATA_S    <= ROM_Q;
				// 	read_count <= read_count + 1;
				// end

				READ: begin
					ROM_rd <= 1;
					ROM_A <= ADDR_S + read_count;
					RDATA_S    <= ROM_Q;
					RREADY_S   <= 0;
					RLAST_S    <= (read_count == BLEN_S);
					read_count <= read_count + 1;

					if (read_count == BLEN_S) begin
						state    <= IDLE;
					end
				end

			endcase
		end
	end

endmodule
