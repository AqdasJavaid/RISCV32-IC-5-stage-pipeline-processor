/*immediate handler
---------------------------------------------------------------------------
| rst				|   Type	 
---------------------------------------------------------------------------
|  0				|	I 
---------------------------------------------------------------------------
|  1				|	I srai 
---------------------------------------------------------------------------
|  2				|	S  
---------------------------------------------------------------------------
|  3				|	B   
---------------------------------------------------------------------------
|  4				|	U   
---------------------------------------------------------------------------
|  5				|	J   
---------------------------------------------------------------------------*/

module imm_generator #(parameter width = 32)(

input wire [24:0] imm_val,
input wire  [2:0]imm_sel,
output wire [width-1:0]imm_w  //RV32I type inst's imm

);
//
//assign imm_w =   (imm_sel==3'd0) ? ({{20{imm_val[24]}} ,imm_val[24:13]}):  					//I-TYPE 
//				 (imm_sel==3'd1) ? ({{27{1'b0}} ,imm_val[17:13]}): 							//I-TYPE srai
//				 (imm_sel==3'd2) ? ({{20{imm_val[24]}} ,imm_val[24:18],imm_val[4:0]}):    	//S-TYPE
//				 (imm_sel==3'd3) ? ({{19{imm_val[24]}} ,imm_val[24],imm_val[0],imm_val[23:18],imm_val[4:1],1'b0}):   	//B-TYPE
//				 (imm_sel==3'd4) ? ({imm_val[24:5],{12{1'b0}}}):													  	//U-TYPE
//				 (imm_sel==3'd5) ? ({{11{imm_val[24]}},imm_val[24],imm_val[12:5],imm_val[13],imm_val[23:14],1'b0}):  	//J-TYPE
//								   {width{1'b0}};  //default


assign imm_w =   (imm_sel==3'd0) ? ({{20{imm_val[24]}} ,imm_val[24:13]}):  					//I-TYPE 
				 (imm_sel==3'd1) ? ({{27{1'b0}} ,imm_val[17:13]}): 							//I-TYPE srai
				 (imm_sel==3'd2) ? ({{20{imm_val[24]}} ,imm_val[24:18],imm_val[4:0]}):    	//S-TYPE
				 (imm_sel==3'd3) ? ({{19{imm_val[24]}} ,imm_val[24],imm_val[0],imm_val[23:18],imm_val[4:1],1'b0}):   	//B-TYPE
				 (imm_sel==3'd4) ? ({imm_val[24:5],{12{1'b0}}}):													  	//U-TYPE
				 (imm_sel==3'd5) ?  32'd4:  			//Jalr return address forwarding
								   {width{1'b0}};  //default

endmodule
