module hazard_detection_unit (

input ID_EX_RegWrite,compressed_flag,
input [4:0]ID_EX_RegisterRd,IF_ID_RegisterRs1,IF_ID_RegisterRs2,IF_ID_opcode,EX_MEM_opcode,EX_MEM_RegisterRd,
input [6:0]ID_EX_opcode,
output stall


);

wire stall_lw,stall_branch,stall_lw_comp,stall_jalr_lw;

assign stall_lw =  (  (ID_EX_opcode == 7'd3  &&  ID_EX_RegisterRd == IF_ID_RegisterRs1)    // dependency: inst after load -> rs1 
					||(ID_EX_opcode == 7'd3  &&  ID_EX_RegisterRd == IF_ID_RegisterRs2 )   // dependency: inst after load -> rs2
				   )? 1'b0: 1'b1; 

assign stall_branch = (   (IF_ID_opcode == 5'd24  && ID_EX_RegWrite && ID_EX_RegisterRd != 5'd0 &&  ID_EX_RegisterRd == IF_ID_RegisterRs1 ) // dependency: inst before branch -> rs1 
					   || (IF_ID_opcode == 5'd24  && ID_EX_RegWrite && ID_EX_RegisterRd != 5'd0 &&  ID_EX_RegisterRd == IF_ID_RegisterRs2 ) // dependency: inst before branch -> rs2 
					  )? 1'b0:1'b1;
 
assign stall_jalr = (     (IF_ID_opcode == 5'd25  && ID_EX_RegWrite && ID_EX_RegisterRd != 5'd0 && ID_EX_RegisterRd == IF_ID_RegisterRs1 ) // dependency: inst before branch -> rs1 
					   || (IF_ID_opcode == 5'd25  && ID_EX_RegWrite && ID_EX_RegisterRd != 5'd0 && ID_EX_RegisterRd == IF_ID_RegisterRs2 ) // dependency: inst before branch -> rs2 
					  )? 1'b0:1'b1;

assign stall_jalr_lw = (  IF_ID_opcode == 5'd25  && EX_MEM_opcode == 5'd0 && IF_ID_RegisterRs1 == EX_MEM_RegisterRd  ) 	? 1'b0:1'b1;


assign stall = stall_lw & stall_branch & stall_jalr & stall_jalr_lw;// & stall_lw_comp;
endmodule
