module  FFT (clk, rst, fir_d, fir_valid, fft_valid, done,
 fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8,
 fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0);
input clk, rst;
input [15:0]fir_d; //8.8
input fir_valid;

output fft_valid; 
output done;
output [15:0] fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8;  //16.16
output [15:0] fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0;

// imag part
parameter signed [31:0] W0_IMAG = 32'h00000000 ;    //16.16
parameter signed [31:0] W1_IMAG = 32'hFFFF9E09 ;     
parameter signed [31:0] W2_IMAG = 32'hFFFF4AFC ;     
parameter signed [31:0] W3_IMAG = 32'hFFFF137D ;     
parameter signed [31:0] W4_IMAG = 32'hFFFF0000 ;     
parameter signed [31:0] W5_IMAG = 32'hFFFF137D ;     
parameter signed [31:0] W6_IMAG = 32'hFFFF4AFC ;     
parameter signed [31:0] W7_IMAG = 32'hFFFF9E09 ;     

// real part
parameter signed [31:0] W0_REAL  = 32'h00010000 ;    //16.16
parameter signed [31:0] W1_REAL  = 32'h0000EC83 ;   
parameter signed [31:0] W2_REAL  = 32'h0000B504 ;    
parameter signed [31:0] W3_REAL  = 32'h000061F7 ;    
parameter signed [31:0] W4_REAL  = 32'h00000000 ;   
parameter signed [31:0] W5_REAL  = 32'hFFFF9E09 ;    
parameter signed [31:0] W6_REAL  = 32'hFFFF4AFC ;     
parameter signed [31:0] W7_REAL  = 32'hFFFF137D ;  

reg [2:0]st,nxt;

parameter IDLE=0,READ=1,CAL=2,DONE=3;
integer i;

reg signed [31:0]fir_data[0:15]; // 16.16
reg [3:0]counter;
assign fft_valid=(st==CAL&&(counter==3||counter==4));
assign done=(st==DONE);

reg signed [31:0]s1_real[0:15]; 
reg signed [31:0]s1_imag[0:15];
reg signed [31:0]s1_real_reg[0:15]; 
reg signed [31:0]s1_imag_reg[0:15];

always@(*)begin // stage 1
	// real part
	s1_real[0]=BU0_real(fir_data[0],fir_data[8]);		s1_real[1]=BU0_real(fir_data[1],fir_data[9]);	//16.16
	s1_real[2]=BU0_real(fir_data[2],fir_data[10]);		s1_real[3]=BU0_real(fir_data[3],fir_data[11]);
	s1_real[4]=BU0_real(fir_data[4],fir_data[12]);		s1_real[5]=BU0_real(fir_data[5],fir_data[13]);  
	s1_real[6]=BU0_real(fir_data[6],fir_data[14]);		s1_real[7]=BU0_real(fir_data[7],fir_data[15]);	

	s1_real[8]=BU1_real(fir_data[0],32'd0,fir_data[8],32'd0,W0_REAL,W0_IMAG);			
	s1_real[9]=BU1_real(fir_data[1],32'd0,fir_data[9],32'd0,W1_REAL,W1_IMAG);
	s1_real[10]=BU1_real(fir_data[2],32'd0,fir_data[10],32'd0,W2_REAL,W2_IMAG);			
	s1_real[11]=BU1_real(fir_data[3],32'd0,fir_data[11],32'd0,W3_REAL,W3_IMAG);
	s1_real[12]=BU1_real(fir_data[4],32'd0,fir_data[12],32'd0,W4_REAL,W4_IMAG);			
	s1_real[13]=BU1_real(fir_data[5],32'd0,fir_data[13],32'd0,W5_REAL,W5_IMAG);
	s1_real[14]=BU1_real(fir_data[6],32'd0,fir_data[14],32'd0,W6_REAL,W6_IMAG);			
	s1_real[15]=BU1_real(fir_data[7],32'd0,fir_data[15],32'd0,W7_REAL,W7_IMAG);
	// imag part
	s1_imag[0]=BU0_imag(32'd0,32'd0);	s1_imag[1]=BU0_imag(32'd0,32'd0);	//16.16
	s1_imag[2]=BU0_imag(32'd0,32'd0);  	s1_imag[3]=BU0_imag(32'd0,32'd0);
	s1_imag[4]=BU0_imag(32'd0,32'd0);  	s1_imag[5]=BU0_imag(32'd0,32'd0);  
	s1_imag[6]=BU0_imag(32'd0,32'd0);  	s1_imag[7]=BU0_imag(32'd0,32'd0);
	
	s1_imag[8]=BU1_imag(fir_data[0],32'd0,fir_data[8],32'd0,W0_REAL,W0_IMAG);			
	s1_imag[9]=BU1_imag(fir_data[1],32'd0,fir_data[9],32'd0,W1_REAL,W1_IMAG);
	s1_imag[10]=BU1_imag(fir_data[2],32'd0,fir_data[10],32'd0,W2_REAL,W2_IMAG);			
	s1_imag[11]=BU1_imag(fir_data[3],32'd0,fir_data[11],32'd0,W3_REAL,W3_IMAG);
	s1_imag[12]=BU1_imag(fir_data[4],32'd0,fir_data[12],32'd0,W4_REAL,W4_IMAG);			
	s1_imag[13]=BU1_imag(fir_data[5],32'd0,fir_data[13],32'd0,W5_REAL,W5_IMAG);
	s1_imag[14]=BU1_imag(fir_data[6],32'd0,fir_data[14],32'd0,W6_REAL,W6_IMAG);			
	s1_imag[15]=BU1_imag(fir_data[7],32'd0,fir_data[15],32'd0,W7_REAL,W7_IMAG);
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
		for(i=0;i<16;i=i+1)begin
			s1_real_reg[i]<=0;
			s1_imag_reg[i]<=0;
		end
	end
	else if(st==CAL)begin
		for(i=0;i<16;i=i+1)begin
			s1_real_reg[i]<=s1_real[i];
			s1_imag_reg[i]<=s1_imag[i];
		end
	end
end

reg signed [31:0]s2_real[0:15]; 
reg signed [31:0]s2_imag[0:15];
reg signed [31:0]s2_real_reg[0:15]; 
reg signed [31:0]s2_imag_reg[0:15];
always@(*)begin// stage 2
	// real part
	s2_real[0]=BU0_real(s1_real_reg[0],s1_real_reg[4]);		
	s2_real[1]=BU0_real(s1_real_reg[1],s1_real_reg[5]);	
	s2_real[2]=BU0_real(s1_real_reg[2],s1_real_reg[6]);		
	s2_real[3]=BU0_real(s1_real_reg[3],s1_real_reg[7]);
	
	s2_real[4]=BU1_real(s1_real_reg[0],s1_imag_reg[0],s1_real_reg[4],s1_imag_reg[4],W0_REAL,W0_IMAG);			
	s2_real[5]=BU1_real(s1_real_reg[1],s1_imag_reg[1],s1_real_reg[5],s1_imag_reg[5],W2_REAL,W2_IMAG);	
	s2_real[6]=BU1_real(s1_real_reg[2],s1_imag_reg[2],s1_real_reg[6],s1_imag_reg[6],W4_REAL,W4_IMAG);				
	s2_real[7]=BU1_real(s1_real_reg[3],s1_imag_reg[3],s1_real_reg[7],s1_imag_reg[7],W6_REAL,W6_IMAG);	
	
	s2_real[8]=BU0_real(s1_real_reg[8],s1_real_reg[12]);		
	s2_real[9]=BU0_real(s1_real_reg[9],s1_real_reg[13]);	
	s2_real[10]=BU0_real(s1_real_reg[10],s1_real_reg[14]);		
	s2_real[11]=BU0_real(s1_real_reg[11],s1_real_reg[15]);	

	s2_real[12]=BU1_real(s1_real_reg[8],s1_imag_reg[8],s1_real_reg[12],s1_imag_reg[12],W0_REAL,W0_IMAG);			
	s2_real[13]=BU1_real(s1_real_reg[9],s1_imag_reg[9],s1_real_reg[13],s1_imag_reg[13],W2_REAL,W2_IMAG);	
	s2_real[14]=BU1_real(s1_real_reg[10],s1_imag_reg[10],s1_real_reg[14],s1_imag_reg[14],W4_REAL,W4_IMAG);				
	s2_real[15]=BU1_real(s1_real_reg[11],s1_imag_reg[11],s1_real_reg[15],s1_imag_reg[15],W6_REAL,W6_IMAG);
	// imag part
	s2_imag[0]=BU0_imag(s1_imag_reg[0],s1_imag_reg[4]);		
	s2_imag[1]=BU0_imag(s1_imag_reg[1],s1_imag_reg[5]);	
	s2_imag[2]=BU0_imag(s1_imag_reg[2],s1_imag_reg[6]);		
	s2_imag[3]=BU0_imag(s1_imag_reg[3],s1_imag_reg[7]);
	
	s2_imag[4]=BU1_imag(s1_real_reg[0],s1_imag_reg[0],s1_real_reg[4],s1_imag_reg[4],W0_REAL,W0_IMAG);			
	s2_imag[5]=BU1_imag(s1_real_reg[1],s1_imag_reg[1],s1_real_reg[5],s1_imag_reg[5],W2_REAL,W2_IMAG);	
	s2_imag[6]=BU1_imag(s1_real_reg[2],s1_imag_reg[2],s1_real_reg[6],s1_imag_reg[6],W4_REAL,W4_IMAG);				
	s2_imag[7]=BU1_imag(s1_real_reg[3],s1_imag_reg[3],s1_real_reg[7],s1_imag_reg[7],W6_REAL,W6_IMAG);	
	
	s2_imag[8]=BU0_imag(s1_imag_reg[8],s1_imag_reg[12]);		
	s2_imag[9]=BU0_imag(s1_imag_reg[9],s1_imag_reg[13]);	
	s2_imag[10]=BU0_imag(s1_imag_reg[10],s1_imag_reg[14]);	
	s2_imag[11]=BU0_imag(s1_imag_reg[11],s1_imag_reg[15]);	

	s2_imag[12]=BU1_imag(s1_real_reg[8],s1_imag_reg[8],s1_real_reg[12],s1_imag_reg[12],W0_REAL,W0_IMAG);			
	s2_imag[13]=BU1_imag(s1_real_reg[9],s1_imag_reg[9],s1_real_reg[13],s1_imag_reg[13],W2_REAL,W2_IMAG);	
	s2_imag[14]=BU1_imag(s1_real_reg[10],s1_imag_reg[10],s1_real_reg[14],s1_imag_reg[14],W4_REAL,W4_IMAG);				
	s2_imag[15]=BU1_imag(s1_real_reg[11],s1_imag_reg[11],s1_real_reg[15],s1_imag_reg[15],W6_REAL,W6_IMAG);
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
		for(i=0;i<16;i=i+1)begin
			s2_real_reg[i]<=0;
			s2_imag_reg[i]<=0;
		end
	end
	else if(st==CAL)begin
		for(i=0;i<16;i=i+1)begin
			s2_real_reg[i]<=s2_real[i];
			s2_imag_reg[i]<=s2_imag[i];
		end
	end
end

reg signed [31:0]s3_real[0:15]; 
reg signed [31:0]s3_imag[0:15];
reg signed [31:0]s3_real_reg[0:15]; 
reg signed [31:0]s3_imag_reg[0:15];
always@(*)begin// stage 3
	// real part
	s3_real[0]=BU0_real(s2_real_reg[0],s2_real_reg[2]);		
	s3_real[1]=BU0_real(s2_real_reg[1],s2_real_reg[3]);	
	
	s3_real[2]=BU1_real(s2_real_reg[0],s2_imag_reg[0],s2_real_reg[2],s2_imag_reg[2],W0_REAL,W0_IMAG);			
	s3_real[3]=BU1_real(s2_real_reg[1],s2_imag_reg[1],s2_real_reg[3],s2_imag_reg[3],W4_REAL,W4_IMAG);	
	
	s3_real[4]=BU0_real(s2_real_reg[4],s2_real_reg[6]);		
	s3_real[5]=BU0_real(s2_real_reg[5],s2_real_reg[7]);
	
	s3_real[6]=BU1_real(s2_real_reg[4],s2_imag_reg[4],s2_real_reg[6],s2_imag_reg[6],W0_REAL,W0_IMAG);				
	s3_real[7]=BU1_real(s2_real_reg[5],s2_imag_reg[5],s2_real_reg[7],s2_imag_reg[7],W4_REAL,W4_IMAG);	
	
	s3_real[8]=BU0_real(s2_real_reg[8],s2_real_reg[10]);		
	s3_real[9]=BU0_real(s2_real_reg[9],s2_real_reg[11]);		

	s3_real[10]=BU1_real(s2_real_reg[8],s2_imag_reg[8],s2_real_reg[10],s2_imag_reg[10],W0_REAL,W0_IMAG);			
	s3_real[11]=BU1_real(s2_real_reg[9],s2_imag_reg[9],s2_real_reg[11],s2_imag_reg[11],W4_REAL,W4_IMAG);	
	
	s3_real[12]=BU0_real(s2_real_reg[12],s2_real_reg[14]);		
	s3_real[13]=BU0_real(s2_real_reg[13],s2_real_reg[15]);
	
	s3_real[14]=BU1_real(s2_real_reg[12],s2_imag_reg[12],s2_real_reg[14],s2_imag_reg[14],W0_REAL,W0_IMAG);				
	s3_real[15]=BU1_real(s2_real_reg[13],s2_imag_reg[13],s2_real_reg[15],s2_imag_reg[15],W4_REAL,W4_IMAG);
	// imag part
	s3_imag[0]=BU0_imag(s2_imag_reg[0],s2_imag_reg[2]);		
	s3_imag[1]=BU0_imag(s2_imag_reg[1],s2_imag_reg[3]);	
	
	s3_imag[2]=BU1_imag(s2_real_reg[0],s2_imag_reg[0],s2_real_reg[2],s2_imag_reg[2],W0_REAL,W0_IMAG);			
	s3_imag[3]=BU1_imag(s2_real_reg[1],s2_imag_reg[1],s2_real_reg[3],s2_imag_reg[3],W4_REAL,W4_IMAG);	
	
	s3_imag[4]=BU0_imag(s2_imag_reg[4],s2_imag_reg[6]);		
	s3_imag[5]=BU0_imag(s2_imag_reg[5],s2_imag_reg[7]);
	
	s3_imag[6]=BU1_imag(s2_real_reg[4],s2_imag_reg[4],s2_real_reg[6],s2_imag_reg[6],W0_REAL,W0_IMAG);				
	s3_imag[7]=BU1_imag(s2_real_reg[5],s2_imag_reg[5],s2_real_reg[7],s2_imag_reg[7],W4_REAL,W4_IMAG);	
	
	s3_imag[8]=BU0_imag(s2_imag_reg[8],s2_imag_reg[10]);		
	s3_imag[9]=BU0_imag(s2_imag_reg[9],s2_imag_reg[11]);		

	s3_imag[10]=BU1_imag(s2_real_reg[8],s2_imag_reg[8],s2_real_reg[10],s2_imag_reg[10],W0_REAL,W0_IMAG);			
	s3_imag[11]=BU1_imag(s2_real_reg[9],s2_imag_reg[9],s2_real_reg[11],s2_imag_reg[11],W4_REAL,W4_IMAG);	
	
	s3_imag[12]=BU0_imag(s2_imag_reg[12],s2_imag_reg[14]);		
	s3_imag[13]=BU0_imag(s2_imag_reg[13],s2_imag_reg[15]);
	
	s3_imag[14]=BU1_imag(s2_real_reg[12],s2_imag_reg[12],s2_real_reg[14],s2_imag_reg[14],W0_REAL,W0_IMAG);				
	s3_imag[15]=BU1_imag(s2_real_reg[13],s2_imag_reg[13],s2_real_reg[15],s2_imag_reg[15],W4_REAL,W4_IMAG);
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
		for(i=0;i<16;i=i+1)begin
			s3_real_reg[i]<=0;
			s3_imag_reg[i]<=0;
		end
	end
	else if(st==CAL)begin
		for(i=0;i<16;i=i+1)begin
			s3_real_reg[i]<=s3_real[i];
			s3_imag_reg[i]<=s3_imag[i];
		end
	end
end

reg signed [31:0]s4_real[0:15]; 
reg signed [31:0]s4_imag[0:15];
always@(*)begin// stage 4
	// real part
	s4_real[0]=BU0_real(s3_real_reg[0],s3_real_reg[1]);		
	s4_real[1]=BU1_real(s3_real_reg[0],s3_imag_reg[0],s3_real_reg[1],s3_imag_reg[1],W0_REAL,W0_IMAG);
	s4_real[2]=BU0_real(s3_real_reg[2],s3_real_reg[3]);		
	s4_real[3]=BU1_real(s3_real_reg[2],s3_imag_reg[2],s3_real_reg[3],s3_imag_reg[3],W0_REAL,W0_IMAG);
	s4_real[4]=BU0_real(s3_real_reg[4],s3_real_reg[5]);		
	s4_real[5]=BU1_real(s3_real_reg[4],s3_imag_reg[4],s3_real_reg[5],s3_imag_reg[5],W0_REAL,W0_IMAG);
	s4_real[6]=BU0_real(s3_real_reg[6],s3_real_reg[7]);		
	s4_real[7]=BU1_real(s3_real_reg[6],s3_imag_reg[6],s3_real_reg[7],s3_imag_reg[7],W0_REAL,W0_IMAG);
	s4_real[8]=BU0_real(s3_real_reg[8],s3_real_reg[9]);		
	s4_real[9]=BU1_real(s3_real_reg[8],s3_imag_reg[8],s3_real_reg[9],s3_imag_reg[9],W0_REAL,W0_IMAG);
	s4_real[10]=BU0_real(s3_real_reg[10],s3_real_reg[11]);		
	s4_real[11]=BU1_real(s3_real_reg[10],s3_imag_reg[10],s3_real_reg[11],s3_imag_reg[11],W0_REAL,W0_IMAG);
	s4_real[12]=BU0_real(s3_real_reg[12],s3_real_reg[13]);		
	s4_real[13]=BU1_real(s3_real_reg[12],s3_imag_reg[12],s3_real_reg[13],s3_imag_reg[13],W0_REAL,W0_IMAG);
	s4_real[14]=BU0_real(s3_real_reg[14],s3_real_reg[15]);		
	s4_real[15]=BU1_real(s3_real_reg[14],s3_imag_reg[14],s3_real_reg[15],s3_imag_reg[15],W0_REAL,W0_IMAG);
	// imag part
	s4_imag[0]=BU0_imag(s3_imag_reg[0],s3_imag_reg[1]);		
	s4_imag[1]=BU1_imag(s3_real_reg[0],s3_imag_reg[0],s3_real_reg[1],s3_imag_reg[1],W0_REAL,W0_IMAG);
	s4_imag[2]=BU0_imag(s3_imag_reg[2],s3_imag_reg[3]);		
	s4_imag[3]=BU1_imag(s3_real_reg[2],s3_imag_reg[2],s3_real_reg[3],s3_imag_reg[3],W0_REAL,W0_IMAG);
	s4_imag[4]=BU0_imag(s3_imag_reg[4],s3_imag_reg[5]);		
	s4_imag[5]=BU1_imag(s3_real_reg[4],s3_imag_reg[4],s3_real_reg[5],s3_imag_reg[5],W0_REAL,W0_IMAG);
	s4_imag[6]=BU0_imag(s3_imag_reg[6],s3_imag_reg[7]);		
	s4_imag[7]=BU1_imag(s3_real_reg[6],s3_imag_reg[6],s3_real_reg[7],s3_imag_reg[7],W0_REAL,W0_IMAG);
	s4_imag[8]=BU0_imag(s3_imag_reg[8],s3_imag_reg[9]);		
	s4_imag[9]=BU1_imag(s3_real_reg[8],s3_imag_reg[8],s3_real_reg[9],s3_imag_reg[9],W0_REAL,W0_IMAG);
	s4_imag[10]=BU0_imag(s3_imag_reg[10],s3_imag_reg[11]);		
	s4_imag[11]=BU1_imag(s3_real_reg[10],s3_imag_reg[10],s3_real_reg[11],s3_imag_reg[11],W0_REAL,W0_IMAG);
	s4_imag[12]=BU0_imag(s3_imag_reg[12],s3_imag_reg[13]);		
	s4_imag[13]=BU1_imag(s3_real_reg[12],s3_imag_reg[12],s3_real_reg[13],s3_imag_reg[13],W0_REAL,W0_IMAG);
	s4_imag[14]=BU0_imag(s3_imag_reg[14],s3_imag_reg[15]);		
	s4_imag[15]=BU1_imag(s3_real_reg[14],s3_imag_reg[14],s3_real_reg[15],s3_imag_reg[15],W0_REAL,W0_IMAG);
end

reg [15:0]imag_temp[0:15];

assign fft_d0=(counter==4)?imag_temp[0]:s4_real[0][23:8];		
assign fft_d8=(counter==4)?imag_temp[1]:s4_real[1][23:8];		
assign fft_d4=(counter==4)?imag_temp[2]:s4_real[2][23:8];		
assign fft_d12=(counter==4)?imag_temp[3]:s4_real[3][23:8];	
assign fft_d2=(counter==4)?imag_temp[4]:s4_real[4][23:8];		
assign fft_d10=(counter==4)?imag_temp[5]:s4_real[5][23:8];	
assign fft_d6=(counter==4)?imag_temp[6]:s4_real[6][23:8];		
assign fft_d14=(counter==4)?imag_temp[7]:s4_real[7][23:8];	
assign fft_d1=(counter==4)?imag_temp[8]:s4_real[8][23:8];		
assign fft_d9=(counter==4)?imag_temp[9]:s4_real[9][23:8];		
assign fft_d5=(counter==4)?imag_temp[10]:s4_real[10][23:8];	
assign fft_d13=(counter==4)?imag_temp[11]:s4_real[11][23:8];	
assign fft_d3=(counter==4)?imag_temp[12]:s4_real[12][23:8];	
assign fft_d11=(counter==4)?imag_temp[13]:s4_real[13][23:8];	
assign fft_d7=(counter==4)?imag_temp[14]:s4_real[14][23:8];	
assign fft_d15=(counter==4)?imag_temp[15]:s4_real[15][23:8];	

always@(posedge clk or posedge rst)begin
	if(rst)begin
		for(i=0;i<16;i=i+1)
			imag_temp[i]<=0;
	end		
	else if(st==CAL)begin
		if(counter==3)begin
			for(i=0;i<16;i=i+1)
				imag_temp[i]<=s4_imag[i][23:8];
		end
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)	
		counter<=0;
	else if(nxt==READ||nxt==CAL)
		counter<=counter+1;
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
		for(i=0;i<16;i=i+1)
			fir_data[i]<=0;
	end		
	else if(nxt==READ||st==READ)begin
		fir_data[counter]<={{8{fir_d[15]}},fir_d,{8{1'b0}}};
	end	
	else if(st==CAL)begin
		fir_data[counter]<={{8{fir_d[15]}},fir_d,{8{1'b0}}};
	end	
end

always@(*)begin
	case(st)
		IDLE : nxt=(fir_valid)?READ:IDLE;
		READ : nxt=(&counter)?CAL:READ;  // counter == 15
		CAL : nxt=(counter==4&&!fir_valid)?DONE:CAL;
		DONE : nxt=DONE;
		default : nxt=IDLE;
	endcase
end

always@(posedge clk or posedge rst)begin
	if(rst)
		st<=IDLE;
	else
		st<=nxt;
end

function [31:0] BU0_real;
    input signed[31:0] a;
    input signed[31:0] c;

    begin 
        BU0_real = a+c;
    end
endfunction

function [31:0] BU0_imag;
    input signed[31:0] b;
    input signed[31:0] d;

    begin 
        BU0_imag = b+d;
    end
endfunction

function [31:0] BU1_real;
    input signed[31:0] a;
    input signed[31:0] b;
	input signed[31:0] c;
    input signed[31:0] d;
	input signed[31:0] W_real;
    input signed[31:0] W_imag;
	
	reg signed[63:0] temp;
    begin 
		temp = ((a-c)*W_real+(d-b)*W_imag);
        BU1_real = temp[47:16];
    end
endfunction

function [31:0] BU1_imag;
    input signed[31:0] a;
    input signed[31:0] b;
	input signed[31:0] c;
    input signed[31:0] d;
	input signed[31:0] W_real;
    input signed[31:0] W_imag;
	
	reg signed[63:0] temp;
    begin 
		temp = ((a-c)*W_imag+(b-d)*W_real);
        BU1_imag = temp[47:16];
    end
endfunction


endmodule