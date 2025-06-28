`timescale 1ns/10ps
`include "./include/define.v"

module BUS(
	input 							bus_clk  ,
	input 							bus_rst  ,

	// MASTERS PORTS
	input      [`BUS_ID_BITS  -1:0] ID_M0	 ,
	input      [`BUS_ADDR_BITS-1:0] ADDR_M0	 ,
	input      [`BUS_DATA_BITS-1:0] WDATA_M0 ,
	input      [`BUS_LEN_BITS -1:0] BLEN_M0  ,
	input   						WLAST_M0 ,
	input   						WVALID_M0,
	input   						RVALID_M0,
	output 	   [`BUS_DATA_BITS-1:0] RDATA_M0 ,
	output 	   						RLAST_M0 ,
	output 	   						WREADY_M0,
	output 	   						RREADY_M0,
	
	// SLAVE S0 PORTS (Image ROM)
	output     [`BUS_ADDR_BITS-1:0] ADDR_S0  ,
	output     [`BUS_LEN_BITS -1:0] BLEN_S0  ,
	output     						RVALID_S0,
	input  	   [`BUS_DATA_BITS-1:0] RDATA_S0 ,
	input 							RLAST_S0 ,
	input 							RREADY_S0,
	
	// SLAVE S1 PORTS (Layer0 SRAM)
	output     [`BUS_ADDR_BITS-1:0] ADDR_S1  ,
	output     [`BUS_DATA_BITS-1:0] WDATA_S1 ,
	output     [`BUS_LEN_BITS -1:0] BLEN_S1  ,
	output     						WLAST_S1 ,
	output     						WVALID_S1,
	output     						RVALID_S1,
	input  	   [`BUS_DATA_BITS-1:0] RDATA_S1 ,
	input 							RLAST_S1 ,
	input 							WREADY_S1,
	input 							RREADY_S1,

	// SLAVE S2 PORTS (Layer1 SRAM)
	output     [`BUS_ADDR_BITS-1:0] ADDR_S2  ,
	output     [`BUS_DATA_BITS-1:0] WDATA_S2 ,
	output     [`BUS_LEN_BITS -1:0] BLEN_S2  ,
	output     						WLAST_S2 ,
	output     						WVALID_S2,
	output     						RVALID_S2,
	input  	   [`BUS_DATA_BITS-1:0] RDATA_S2 ,
	input 							RLAST_S2 ,
	input 							WREADY_S2,
	input 							RREADY_S2
);
	/////////////////////////////////
	// Please write your code here //
	/////////////////////////////////
	parameter [1:0] ROM_ID = 0,
					SRAM1_ID = 1,
					SRAM2_ID = 2,
					Default_ID = 3;

	// Master to ROM
	assign ADDR_S0   = (ID_M0 == ROM_ID) ? ADDR_M0   : 0;
	assign BLEN_S0   = (ID_M0 == ROM_ID) ? BLEN_M0   : 0;
	assign RVALID_S0 = (ID_M0 == ROM_ID) ? RVALID_M0 : 0;

	// Master to SRAM1
	assign ADDR_S1 = (ID_M0 == SRAM1_ID) ? ADDR_M0   : 0;
	assign WDATA_S1 = (ID_M0 == SRAM1_ID) ? WDATA_M0  : 0;
	assign BLEN_S1 = (ID_M0 == SRAM1_ID) ? BLEN_M0   : 0;
	assign WLAST_S1 = (ID_M0 == SRAM1_ID) ? WLAST_M0  : 0;
	assign WVALID_S1 = (ID_M0 == SRAM1_ID) ? WVALID_M0 : 0;
	assign RVALID_S1 = (ID_M0 == SRAM1_ID) ? RVALID_M0 : 0;

	// Master to SRAM2
	assign ADDR_S2 = (ID_M0 == SRAM2_ID) ? ADDR_M0   : 0;
	assign WDATA_S2 = (ID_M0 == SRAM2_ID) ? WDATA_M0  : 0;
	assign BLEN_S2 = (ID_M0 == SRAM2_ID) ? BLEN_M0   : 0;
	assign WLAST_S2 = (ID_M0 == SRAM2_ID) ? WLAST_M0  : 0;
	assign WVALID_S2 = (ID_M0 == SRAM2_ID) ? WVALID_M0 : 0;
	assign RVALID_S2 = (ID_M0 == SRAM2_ID) ? RVALID_M0 : 0;

	assign RDATA_M0  = (ID_M0 == ROM_ID)   ? RDATA_S0 :
                   (ID_M0 == SRAM1_ID) ? RDATA_S1 :
                   (ID_M0 == SRAM2_ID) ? RDATA_S2 : 0;

	assign RLAST_M0  = (ID_M0 == ROM_ID)   ? RLAST_S0 :
					(ID_M0 == SRAM1_ID) ? RLAST_S1 :
					(ID_M0 == SRAM2_ID) ? RLAST_S2 : 0;

	assign RREADY_M0 = (ID_M0 == ROM_ID)   ? RREADY_S0 :
					(ID_M0 == SRAM1_ID) ? RREADY_S1 :
					(ID_M0 == SRAM2_ID) ? RREADY_S2 : 0;

	assign WREADY_M0 = (ID_M0 == SRAM1_ID) ? WREADY_S1 :
					(ID_M0 == SRAM2_ID) ? WREADY_S2 : 0;

endmodule
