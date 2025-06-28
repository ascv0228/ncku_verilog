module LCD_CTRL(
	input 			 clk	  ,
	input 			 rst	  ,
	input 	   [3:0] cmd      , 
	input 			 cmd_valid,
	input 	   [7:0] IROM_Q   ,
	output 			 IROM_rd  , 
	output reg [5:0] IROM_A   ,
	output 			 IRAM_ceb ,
	output 			 IRAM_web ,
	output reg [7:0] IRAM_D	  ,
	output reg [5:0] IRAM_A	  ,
	input 	   [7:0] IRAM_Q	  ,
	output 			 busy	  ,
	output 			 done
);


reg [3:0] curr_state, next_state; // for FSM
reg [7:0] img[0:7][0:7]; // for image storing
reg [2:0] x, y; // for operation point
reg [2:0] idx_wx,idx_wy; // index for img address


// FSM parameter
parameter IDLE     = 4'd0 ,
		  READ_IMG = 4'd1 ,
		  READ_CMD = 4'd2 ,
		  WRITE	   = 4'd3 ,
		  MOVE	   = 4'd4 ,
		  MAX	   = 4'd5 ,
		  MIN	   = 4'd6 ,
		  AVG	   = 4'd7 ,
		  WHITE	   = 4'd8 ,
		  BLACK	   = 4'd9 ,
		  ROTATE   = 4'd10,
		  RESTORE  = 4'd11,
		  COPY     = 4'd12,
		  PASTE    = 4'd13,
		  NOTHING  = 4'd14, 
		  DONE	   = 4'd15;

// Wire based on curr_state
assign busy = (curr_state == READ_CMD) ? 0 : 1;
assign IROM_rd = (curr_state == READ_IMG) ? 1 : 0;
assign IRAM_ceb = (curr_state == WRITE || curr_state == RESTORE || NOTHING) ? 1 : 0;
assign IRAM_web = (curr_state == WRITE) ? 0 : 1;
assign done = (curr_state == DONE) ? 1 : 0;

// Get the value of pixels in the window
wire [7:0] win [0:8];
assign win[0]  = img[y-1][x-1];
assign win[1]  = img[y-1][x];
assign win[2]  = img[y-1][x+1];
assign win[3]  = img[y][x-1];
assign win[4]  = img[y][x];
assign win[5]  = img[y][x+1];
assign win[6]  = img[y+1][x-1];
assign win[7]  = img[y+1][x];
assign win[8]  = img[y+1][x+1];

reg [7:0] copy_buff [0:8];
// Find average value
wire [11:0] sum;
assign sum = (win[0]  + win[1] + win[2] + win[3]  + win[4]  + win[5]  + win[6]  + 
			  win[7]  + win[8]);
wire [7:0] average;
assign average = sum / 9 ; // average =  sum / 16

reg [7:0] max, max1, max2, max3, max4, max5, max6, max7, max8, max9, max10, max11, max12, max13, max14;
reg [7:0] min, min1, min2, min3, min4, min5, min6, min7, min8, min9, min10, min11, min12, min13, min14;

// Pairwise comparison to find max value
always @(*) begin
    max1 = (win[0] > win[1]) ? win[0] : win[1];
    max2 = (win[2] > win[3]) ? win[2] : win[3];
    max3 = (win[4] > win[5]) ? win[4] : win[5];
    max4 = (win[6] > win[7]) ? win[6] : win[7];

    max5 = (max1 > max2) ? max1 : max2;
    max6 = (max3 > max4) ? max3 : max4;

    max7 = (max5 > max6) ? max5 : max6;
    max8 = (win[8] > max7) ? win[8] : max7;

    max = max8;
end

// Pairwise comparison to find min value
always @(*) begin
    min1 = (win[0] < win[1]) ? win[0] : win[1];
    min2 = (win[2] < win[3]) ? win[2] : win[3];
    min3 = (win[4] < win[5]) ? win[4] : win[5];
    min4 = (win[6] < win[7]) ? win[6] : win[7];

    min5 = (min1 < min2) ? min1 : min2;
    min6 = (min3 < min4) ? min3 : min4;

    min7 = (min5 < min6) ? min5 : min6;
    min8 = (win[8] < min7) ? win[8] : min7;

    min = min8;
end

// rotate
reg [8:0] rotate_img[0:8];
always @(*) begin
	rotate_img[0] = win[3];
	rotate_img[1] = win[0];
	rotate_img[2] = win[1];
	rotate_img[3] = win[6];
	rotate_img[4] = win[4];
	rotate_img[5] = win[2];
	rotate_img[6] = win[7];
	rotate_img[7] = win[8];
	rotate_img[8] = win[5];
end

// img address
always @(*) begin
	if(curr_state == WRITE) begin
		if(IRAM_A[2:0] == 3'd7)begin
			idx_wx = 3'd0;
			idx_wy = IRAM_A[5:3] + 3'd1;
		end
		else begin
			idx_wx = IRAM_A[2:0] + 3'd1;
			idx_wy = IRAM_A[5:3];
		end
	end	
	else begin
		idx_wx = 3'd0;
		idx_wy = 3'd0;
	end
end

// Get data for IRAM_D from img
always @(posedge clk or posedge rst) begin
	if(rst) begin
		IRAM_D <= 8'd0;
	end	
	else if(next_state == WRITE) begin
		IRAM_D <= img[idx_wy][idx_wx];
	end	
	else begin
		IRAM_D <= 8'd0;
	end
end

// RAM Address to write
always @(posedge clk or posedge rst) begin
	if(rst)begin
		IRAM_A <= 6'd0;
	end	
	else if(curr_state == WRITE)begin
		IRAM_A <= IRAM_A + 6'd1;
	end	
	else if(curr_state == RESTORE)begin
		IRAM_A <= (8*y + x);
	end
	else begin
		IRAM_A <= 6'd0;
	end
end

always @(negedge clk) begin
	if(curr_state == RESTORE && IRAM_ceb == 1'b1)begin
		$display("RESTORE (%h, %h) Q =%h ",y, x, IRAM_Q);
		img[y][x] <= IRAM_Q;
	end
end

// Update the value in window
integer i_x, i_y;
always @(posedge clk or posedge rst) begin
	if(rst) begin
		for(i_x=0; i_x<8; i_x=i_x+1) begin
			for(i_y=0; i_y<8; i_y=i_y+1) begin
				img[i_x][i_y] <= 8'd0;
			end
		end
	end
	else if(curr_state == READ_IMG) begin
		img[IROM_A[5:3]][IROM_A[2:0]] <= IROM_Q;
	end
	else if(curr_state == MAX) begin
		img[y-1][x-1] <= max;
		img[y-1][x  ] <= max;
		img[y-1][x+1] <= max;
		img[y  ][x-1] <= max;
		img[y  ][x  ] <= max;
		img[y  ][x+1] <= max;
		img[y+1][x-1] <= max;
		img[y+1][x  ] <= max;
		img[y+1][x+1] <= max;

	end	
	else if(curr_state == MIN) begin
		img[y-1][x-1] <= min;
		img[y-1][x  ] <= min;
		img[y-1][x+1] <= min;
		img[y  ][x-1] <= min;
		img[y  ][x  ] <= min;
		img[y  ][x+1] <= min;
		img[y+1][x-1] <= min;
		img[y+1][x  ] <= min;
		img[y+1][x+1] <= min;
	end
	else if(curr_state == AVG) begin
		img[y-1][x-1] <= average;
		img[y-1][x  ] <= average;
		img[y-1][x+1] <= average;
		img[y  ][x-1] <= average;
		img[y  ][x  ] <= average;
		img[y  ][x+1] <= average;
		img[y+1][x-1] <= average;
		img[y+1][x  ] <= average;
		img[y+1][x+1] <= average;
	end
	else if (curr_state == WHITE) begin
		img[y-1][x-1] <= 8'hFF;
		img[y-1][x  ] <= 8'hFF;
		img[y-1][x+1] <= 8'hFF;
		img[y  ][x-1] <= 8'hFF;
		img[y  ][x  ] <= 8'hFF;
		img[y  ][x+1] <= 8'hFF;
		img[y+1][x-1] <= 8'hFF;
		img[y+1][x  ] <= 8'hFF;
		img[y+1][x+1] <= 8'hFF;
	end
	else if(curr_state == BLACK) begin
		img[y-1][x-1] <= 8'd0;
		img[y-1][x  ] <= 8'd0;
		img[y-1][x+1] <= 8'd0;
		img[y  ][x-1] <= 8'd0;
		img[y  ][x  ] <= 8'd0;
		img[y  ][x+1] <= 8'd0;
		img[y+1][x-1] <= 8'd0;
		img[y+1][x  ] <= 8'd0;
		img[y+1][x+1] <= 8'd0;	
	end
	else if(curr_state == ROTATE) begin
		img[y-1][x-1] <= rotate_img[0];
		img[y-1][x  ] <= rotate_img[1];
		img[y-1][x+1] <= rotate_img[2];
		img[y  ][x-1] <= rotate_img[3];
		img[y  ][x  ] <= rotate_img[4];
		img[y  ][x+1] <= rotate_img[5];
		img[y+1][x-1] <= rotate_img[6];
		img[y+1][x  ] <= rotate_img[7];
		img[y+1][x+1] <= rotate_img[8];
	end
	else if(curr_state == COPY) begin
		copy_buff[0] <= img[y-1][x-1];
		copy_buff[1] <= img[y-1][x  ];
		copy_buff[2] <= img[y-1][x+1];
		copy_buff[3] <= img[y  ][x-1];
		copy_buff[4] <= img[y  ][x  ];
		copy_buff[5] <= img[y  ][x+1];
		copy_buff[6] <= img[y+1][x-1];
		copy_buff[7] <= img[y+1][x  ];
		copy_buff[8] <= img[y+1][x+1];
	end
	else if(curr_state == PASTE) begin
		img[y-1][x-1] <= copy_buff[0];
		img[y-1][x  ] <= copy_buff[1];
		img[y-1][x+1] <= copy_buff[2];
		img[y  ][x-1] <= copy_buff[3];
		img[y  ][x  ] <= copy_buff[4];
		img[y  ][x+1] <= copy_buff[5];
		img[y+1][x-1] <= copy_buff[6];
		img[y+1][x  ] <= copy_buff[7];
		img[y+1][x+1] <= copy_buff[8];	
	end
end		

// Move the operation point
always@(posedge clk or posedge rst)begin
	if(rst) begin
		x <= 3'd4;
		y <= 3'd4;
	end	
	else if(curr_state == MOVE) begin
		case(cmd)
			4'd1 : y <= (y == 3'd1) ? 3'd1 : (y - 3'd1);
			4'd2 : y <= (y == 3'd6) ? 3'd6 : (y + 3'd1);
			4'd3 : x <= (x == 3'd1) ? 3'd1 : (x - 3'd1);
			4'd4 : x <= (x == 3'd6) ? 3'd6 : (x + 3'd1);
		endcase 
	end
end

// READ from ROM
always@(posedge clk or posedge rst)begin
	if(rst) begin
		IROM_A <= 6'd0;
	end
	else if(curr_state == READ_IMG) begin
		IROM_A <= IROM_A + 6'd1;
	end
	else begin
		IROM_A <= 6'd0;
	end
end

// FSM
always @(*) begin
	case(curr_state)
		IDLE : 
			next_state = READ_IMG;
		READ_IMG : 
			next_state = (IROM_A == 6'd63) ? READ_CMD : READ_IMG;
		READ_CMD : begin
			case(cmd)
				4'd0 : next_state = WRITE;
				4'd1, 4'd2, 4'd3, 4'd4 : next_state = MOVE;
				4'd5 : next_state = MAX;
				4'd6 : next_state = MIN;
				4'd7 : next_state = AVG;
				4'd8 : next_state = WHITE;
				4'd9 : next_state = BLACK;
				4'd10: next_state = ROTATE;
				4'd11: next_state = RESTORE;
				4'd12: next_state = COPY;
				4'd13: next_state = PASTE;
				4'd15: next_state = DONE;
				default : next_state = READ_CMD;
			endcase
		end
		WRITE : 
			next_state = (IRAM_A == 6'd63) ? READ_CMD : WRITE;
		MOVE : 
			next_state = READ_CMD;
		MAX : 
			next_state = READ_CMD;
		MIN : 
			next_state = READ_CMD;
		AVG : 
			next_state = READ_CMD;
		WHITE :
			next_state = READ_CMD;
		BLACK :
			next_state = READ_CMD;
		ROTATE :
			next_state = READ_CMD;
		RESTORE :
			next_state = (IRAM_A == (8*y+x)) ? NOTHING : RESTORE;
		COPY :
			next_state = READ_CMD;
		NOTHING :
			next_state = READ_CMD;


		DONE : 
			next_state = DONE;
		default : 
			next_state = IDLE;
	endcase
end

always@(posedge clk or posedge rst)begin
	if(rst)
		curr_state <= IDLE;
	else
		curr_state <= next_state;
end

endmodule




