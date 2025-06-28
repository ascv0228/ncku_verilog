module BU(
	input signed [31:0] a,
	input signed [31:0] b,
	input signed [31:0] c,
	input signed [31:0] d,
	input signed [31:0] W_real,
	input signed [31:0] W_imag,
	
	output signed [31:0] result0_real,
	output signed [31:0] result0_imag,
	output signed [31:0] result1_real,
	output signed [31:0] result1_imag
);

/////////////////////////////////
// Please write your code here //
/////////////////////////////////
	// wire signed [31:0] ac_add = a + c;
	// wire signed [31:0] bd_add = b + d;
	assign result0_real = a + c;
	assign result0_imag = b + d;

	wire signed [63:0] mult1 = (a - c) * W_real;
	wire signed [63:0] mult2 = (d - b) * W_imag;
	wire signed [63:0] mult3 = (a - c) * W_imag;
	wire signed [63:0] mult4 = (b - d) * W_real;

	assign result1_real = (mult1 + mult2) >>> 16;
	assign result1_imag = (mult3 + mult4) >>> 16;

endmodule