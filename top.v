
module AKEANA_PO_AJ (input clk,rst);

wire [31:0] pc,inst,rs1,rs2,rd,imm_c,imm_w,w_data1,src1,src2,data_mem_R,RegWdata,A,B,C,D;
wire [4:0]addr_src1,addr_src2,addr_A,addr_B,addr_D,opcode;
wire [3:0]alu_sel;
wire [2:0]opr,mode,func3,imm_sel;
wire [1:0]sel,lw_comp,pc_sel,wb_sel,wb_sel_s2,wb_sel_s3,A_sel_F,B_sel_F,A_sel_F_s2,B_sel_F_s2,forward_A,forward_B,forward_C,forward_D;
wire reg_we,func7_5th_bit,c_inst_flag,br_eq,br_lt,br_un,B_sel,A_sel,data_mem_we,A_sel_s2,
	 B_sel_s2,comp,data_mem_we_s4,stall;

wire [31:0] inst_before_s1,pc_s2,src1_s2,src2_s2,imm_c_s2,AluOut,pc_s3,src2_s3,RegWdata_s4;
reg  [31:0] jump_addr,inst_s1,pc_s1;
wire [31:0] imm_s2,imm;
wire [2:0] imm_sel_s2,mode_s2,mode_s3;
wire [3:0] alu_sel_s2;
wire [4:0] RegWIndex_s2,opcode_lw_s2,opcode_lw_s3,RegWIndex_s3,RegWIndex_s4,RegRIndex1_s2,RegRIndex2_s2,RegRIndex1_s3,RegRIndex2_s3;
wire [6:0] opcode_s2;



assign inst = pc_sel[1] ? 32'h00000033 :inst_before_s1; 	  //stall condition for branch taken,jal,jalr
assign w_data1 = (wb_sel_s3==0) ? data_mem_R:				  //wb mux
				 (wb_sel_s3==1) ? AluOut :
				 (wb_sel_s3==2) ? pc_s3 +3'd4: 32'd0;

assign imm = c_inst_flag ? imm_c :imm_w; 					  //selection btw comp. imm and normal imm	
assign compressed_flag = (inst[1:0] == 2'b11) ? 1'b0 : 1'b1;  //compressed

//jump address
always @(*)
	begin
		if (opcode == 5'b11000 && pc_sel[1]) //branch
			jump_addr = pc_s1 + ({{19{inst_s1[31]}} ,inst_s1[31],inst_s1[7],inst_s1[30:25],inst_s1[11:8],1'b0});
		else if (opcode == 5'b11011) 		 //jal 
			jump_addr = pc_s1 + ({{11{inst_s1[31]}},inst_s1[31],inst_s1[19:12],inst_s1[20],inst_s1[30:21],1'b0});
		else if (opcode == 5'b11001)         //jalr 
			jump_addr = C + ({{20{inst_s1[31]}} ,inst_s1[31:20]});
		else
			jump_addr = 32'd0;
	end

//--------------------------------------------stage 1------------------------------------------------------

always @(posedge clk,negedge rst)
	begin
		if(!rst)
			begin
				inst_s1 <= 32'd0;
				pc_s1 <= 32'd0;
			end
		else if (!stall)
			begin
				inst_s1 <= inst_s1;
				pc_s1 <= pc_s1;
			end
		else
			begin
				inst_s1 <= inst;
				pc_s1 <= pc;
			end
	end

//--------------------------------------------stage 2------------------------------------------------------

ff i_s2_pc (.*,.d(pc_s1),.q(pc_s2));
ff i_s2_RegReadData1 (.*,.d(src1),.q(src1_s2));
ff i_s2_RegReadData2 (.*,.d(src2),.q(src2_s2));
ff i_s2_inst (.*,.d(imm),.q(imm_s2)); 
ff #(5)i_s2_RegWIndex (.*,.d(addr_D),.q(RegWIndex_s2)); //regWAddr
ff #(5)i_s2_RegRIndex1_s2 (.*,.d(addr_A),.q(RegRIndex1_s2)); //regRAddr1
ff #(5)i_s2_RegRIndex2_s2 (.*,.d(addr_B),.q(RegRIndex2_s2)); //regRAddr2
ff #(7)i_s2_opcode (.*,.d( ({opcode,inst_s1[1:0]}) | (lw_comp) ),.q(opcode_s2));  
ff #(5)i_s2_opcode_lw (.*,.d(opcode),.q(opcode_lw_s2));

ff #(1) i_s2_Asel (.*,.d(A_sel),.q(A_sel_s2));
ff #(2) i_s2_Asel_F (.*,.d(A_sel_F),.q(A_sel_F_s2));
ff #(1) i_s2_Bsel (.*,.d(B_sel),.q(B_sel_s2));
ff #(2) i_s2_Bsel_F (.*,.d(B_sel_F),.q(B_sel_F_s2));
ff #(4) i_s2_alu_sel (.*,.d(alu_sel),.q(alu_sel_s2));
ff #(1) i_s2_RegWe (.*,.d(reg_we & stall),.q(reg_we_s2)); 			//stall in case of datahazard detcetion regWE
ff #(1) i_s2_lw_reg_we (.*,.d(lw_reg_we & stall),.q(lw_reg_we_s2)); //stall in case of datahazard detcetion	dataWEn
ff #(1) i_s2_dataMemWe (.*,.d(data_mem_we),.q(data_mem_we_s2));
ff #(2) i_s2_wb_sel (.*,.d(wb_sel),.q(wb_sel_s2));
ff #(3) i_s2_mode (.*,.d(mode),.q(mode_s2));

//--------------------------------------------stage 3------------------------------------------------------

ff i_s3_pc (.*,.d(pc_s2),.q(pc_s3));
ff i_s3_AluOut (.*,.d(rd),.q(AluOut));
ff i_s3_RegReadData2 (.*,.d(B),.q(src2_s3));
ff #(5)i_s2_RegRIndex1_s3 (.*,.d(RegRIndex1_s2),.q(RegRIndex1_s3)); //RegWIndex_s2
ff #(5)i_s2_RegRIndex2_s3 (.*,.d(RegRIndex2_s2),.q(RegRIndex2_s3));
ff #(5) i_s3_RegWIndex (.*,.d(RegWIndex_s2),.q(RegWIndex_s3)); //regWAddr
ff #(5)i_s3_opcode_lw (.*,.d(opcode_lw_s2),.q(opcode_lw_s3));

ff #(1) i_s3_RegWe (.*,.d(reg_we_s2),.q(reg_we_s3));
ff #(1) i_s3_lw_reg_we (.*,.d(lw_reg_we_s2),.q(lw_reg_we_s3));
ff #(1) i_s3_dataMemWe (.*,.d(data_mem_we_s2),.q(data_mem_we_s3));
ff #(2) i_s3_wb_sel (.*,.d(wb_sel_s2),.q(wb_sel_s3));
ff #(3) i_s3_mode (.*,.d(mode_s2),.q(mode_s3));

//--------------------------------------------stage 4------------------------------------------------------

ff i_s4_RegWdata (.*,.d(w_data1),.q(RegWdata_s4));
ff #(1) i_s4_RegWe (.*,.d(reg_we_s3),.q(reg_we_s4));

ff #(1) i_s4_dataMemWe (.*,.d(data_mem_we_s3),.q(data_mem_we_s4));
ff #(5) i_s4_RegWIndex (.*,.d(RegWIndex_s3),.q(RegWIndex_s4)); //regWAddr


//-------------------------------------------- Top --------------------------------------------------------

program_counter  i_program_counter(.*,.pc_sel(pc_sel),.compressed_flag(compressed_flag),.pc(pc),.rd(jump_addr),.stall(stall)); 

inst_mem         i_inst_mem       (.pc(pc),.inst(inst_before_s1));

decompressor     i_decompressor   (.inst(inst_s1),.addr_A(addr_A),.addr_B(addr_B),.addr_D(addr_D),.opcode(opcode),.lw_comp(lw_comp),
							       .func3(func3),.func7_5th_bit(func7_5th_bit),.c_inst_flag(c_inst_flag),.imm_c(imm_c));
						
alu              i_alu            (.rs1(rs1),.rs2(rs2),.alu_sel(alu_sel_s2),.rd(rd));

branch_comp      i_branch_comp    (.src1(C),.src2(D),.br_un(br_un),.br_lt(br_lt),.br_eq(br_eq));

controller       i_controller     (.opcode(opcode),.func3(func3),.func7_5th_bit(func7_5th_bit),.c_inst_flag(c_inst_flag),
						           .br_eq(br_eq),.br_lt(br_lt),.pc_sel(pc_sel),.imm_sel(imm_sel),.reg_we(reg_we),
						           .br_un(br_un),.B_sel(B_sel),.A_sel(A_sel),.alu_sel(alu_sel),.data_mem_we(data_mem_we),.wb_sel(wb_sel),
						           .mode(mode));
data_mem         i_data_mem       (.*,.data_mem_we(data_mem_we_s3),.mode(mode_s3),.addr(AluOut[9:0]),.src2(src2_s3),.data_mem_R(data_mem_R));

imm_generator    i_imm_generator  (.imm_val(inst_s1[31:7]),.imm_sel(imm_sel),.imm_w(imm_w));

register_file    i_register_file  (.*,.reg_we(reg_we_s4),.addr_A(addr_A),.addr_B(addr_B),.addr_D(RegWIndex_s4),
							       .w_data(RegWdata_s4),.src1(src1),.src2(src2));

forwarding_unit  i_forwarding_unit(.ID_EX_RegWrite(reg_we_s2),.EX_MEM_RegWrite(reg_we_s3),.WB_MEM_RegWrite(reg_we_s4),
								   .ID_EX_RegisterRs1(RegRIndex1_s2),.ID_EX_RegisterRs2(RegRIndex2_s2),.ID_EX_RegisterRd(RegWIndex_s2),
								   .EX_MEM_RegisterRd(RegWIndex_s3),.WB_MEM_RegisterRd(RegWIndex_s4),.forward_A(forward_A),
								   .forward_B(forward_B),.forward_C(forward_C),.forward_D(forward_D),.IF_ID_RegisterRs1(addr_A),
								   .IF_ID_RegisterRs2(addr_B));

data_hazard      i_data_hazard	  (.*);

hazard_detection_unit i_hazard_detection_unit (.ID_EX_opcode(opcode_s2),.ID_EX_RegisterRd(RegWIndex_s2),.ID_EX_RegWrite(reg_we_s2),
											   .IF_ID_RegisterRs1(addr_A),.IF_ID_RegisterRs2(addr_B),.compressed_flag(compressed_flag),
											   .IF_ID_opcode(opcode),.stall(stall),.EX_MEM_opcode(opcode_lw_s3),.EX_MEM_RegisterRd(RegWIndex_s3));


endmodule 
