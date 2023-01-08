
/*src1 of ALU								src2 of ALU
----------------------    				----------------------
| 00  |  RegReadData1					| 00  |  RegReadData2
----------------------					----------------------		
| 01  |  AluOut							| 01  |  AluOut
----------------------					----------------------
| 10  |  RegWdata_s4					| 10  |  RegWdata_s4
----------------------					----------------------
| 11  |  xx								| 11  |  xx
----------------------					----------------------*/

module data_hazard(

input   A_sel_s2,B_sel_s2,
input  [1:0] forward_A,forward_B,forward_C,forward_D,
input  [31:0]pc_s2,imm_s2,src1_s2,src2_s2,AluOut,RegWdata_s4,src1,src2,
output [31:0]rs1,rs2,B,C,D 

);
// ----------------------------- Muxes of execution stage ----------------
wire [31:0]A;
assign rs1 = A_sel_s2 ? pc_s2:A;
assign A = (forward_A == 2'b00 ) ? src1_s2:
		   (forward_A == 2'b01 ) ? AluOut : 
		   (forward_A == 2'b10 ) ? RegWdata_s4 : 32'd0;

assign rs2 = B_sel_s2 ? imm_s2:B;
assign B = (forward_B == 2'b00 ) ? src2_s2:
		   (forward_B == 2'b01 ) ? AluOut : 
		   (forward_B == 2'b10 ) ? RegWdata_s4 : 32'd0;

// ----------------------------- branches ----------------
assign C = (forward_C == 2'b00 ) ? src1:
		   (forward_C == 2'b01 ) ? AluOut : 
		   (forward_C == 2'b10 ) ? RegWdata_s4 : 32'd0;

assign D = (forward_D == 2'b00 ) ? src2:
		   (forward_D == 2'b01 ) ? AluOut : 
		   (forward_D == 2'b10 ) ? RegWdata_s4 : 32'd0;

endmodule