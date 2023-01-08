module ID(

input [31:0]inst,
input func3,
input func7,

output reg [4:0]addr_A,
output reg [4:0]addr_B,
output reg [4:0]addr_D,
output reg [31:0]c_imm,
output reg [1:0]pc_sel,
output reg [2:0]imm_sel,
output reg reg_we,
output reg br_un,
output reg B_sel,
output reg A_sel,
output reg [3:0]alu_sel,
output reg data_mem_we,
output reg [1:0]wb_sel,

output reg c_imm_mux  //cntrl signal for  immidiate RVC32C instructions

);

reg default_flag;
wire sel_addr_src1;

always@(*)
	begin
		default_flag = 1'b0;
		c_imm_mux = 1'b1;

		case(inst[1:0])
		2'b00: //c.lw,c.sw
			begin
				case(inst[15:13])
				3'b010: //c.lw
					begin
						addr_A = inst[9:7] + 4'd8;
						addr_B = 5'd0;
						addr_D = inst[4:2] + 4'd8;
						c_imm = {{25{1'b0}},inst[5],inst[12:10],inst[6],2'b00};

						pc_sel = 2'b00;
						imm_sel = 3'd0;
						reg_we = 1'b1;
						//br_un = 1'b0;
						B_sel = 1'b1;
						A_sel = 1'b0;
						alu_sel = 4'd0;
						data_mem_we = 1'b0;
						wb_sel = 2'b00;
					end

				3'b110:
					begin //c.sw
						addr_A = inst[9:7] + 4'd8;
						addr_B = inst[4:2] + 4'd8;
						addr_D = 5'd0;
						c_imm = {{25{1'b0}},inst[5],inst[12:10],inst[6],2'b00};

						pc_sel = 2'b00;
						imm_sel = 3'd0;
						reg_we = 1'b0;
						//br_un = 1'b0;
						B_sel = 1'b1;
						A_sel = 1'b0;
						alu_sel = 4'd0;
						data_mem_we = 1'b1;
						//wb_sel = 2'b00;

					end
				
				default: default_flag = 1'b1;
				endcase
			end

		2'b01: //c.cb,c.ci,c,cs
			begin
				case(inst[15:13])
					3'b000:  //addi
						begin
							addr_A = inst[11:7];
							addr_B = 5'd0;
							addr_D = inst[11:7];
							c_imm = {{27{inst[12]}},inst[6:2]};
	
							pc_sel = 2'b00;
							//imm_sel = 3'd0;
							reg_we = 1'b1;
							//br_un = 1'b0;
							B_sel = 1'b1;
							A_sel = 1'b0;
							alu_sel = 4'd0;
							data_mem_we = 1'b0;
							wb_sel = 2'b01;
						end

					3'b010:  //li
						begin
							addr_A = 5'd0;
							addr_B = 5'd0;
							addr_D = inst[11:7];
							c_imm = {{26{inst[12]}},inst[12],inst[6:2]};
	
							pc_sel = 2'b00;
							//imm_sel = 3'd0;
							reg_we = 1'b1;
							//br_un = 1'b0;
							B_sel = 1'b1;
							A_sel = 1'b0;
							alu_sel = 4'd10;
							data_mem_we = 1'b0;
							wb_sel = 2'b01;
						end

					3'b011:  //lui
						begin
							addr_A = 5'd0;
							addr_B = 5'd0;
							addr_D = inst[11:7];
							c_imm = {{15{inst[12]}},inst[6:2],{12{1'b0}}};
	
							pc_sel = 2'b00;
							//imm_sel = 3'd0;
							reg_we = 1'b1;
							//br_un = 1'b0;
							B_sel = 1'b1;
							A_sel = 1'b0;
							alu_sel = 4'd10;
							data_mem_we = 1'b0;
							wb_sel = 2'b01;

						end

				    3'b100:  //
						begin
							case(inst[11:10])
							2'b00: //srli
								begin
									addr_A = inst[9:7] + 4'd8;
									addr_B = 5'd0;
									addr_D = inst[9:7] + 4'd8;
									c_imm = {{27{1'b0}},inst[6:2]}; //shamt = imm[5] = 0 for RVC32
			
									pc_sel = 2'b00;
									imm_sel = 3'd0;
									reg_we = 1'b1;
									//br_un = 1'b0;
									B_sel = 1'b1;
									A_sel = 1'b0;
									alu_sel = 4'd6;
									data_mem_we = 1'b0;
									wb_sel = 2'b01;

								end
			
							2'b01: //srai
								begin
									addr_A = inst[9:7] + 4'd8;
									addr_B = 5'd0;
									addr_D = inst[9:7] + 4'd8;
									c_imm = {{27{1'b0}},inst[6:2]}; //shamt = imm[5] = 0 for RVC32
			
									pc_sel = 2'b00;
									imm_sel = 3'd0;
									reg_we = 1'b1;
									//br_un = 1'b0;
									B_sel = 1'b1;
									A_sel = 1'b0;
									alu_sel = 4'd7;
									data_mem_we = 1'b0;
									wb_sel = 2'b01;
	
								end
			
							2'b10: //andi
								begin
									addr_A = inst[9:7] + 4'd8;
									addr_B = 5'd0;
									addr_D = inst[9:7] + 4'd8;
									c_imm = {{27{inst[5]}},inst[6:2]};
			
									pc_sel = 2'b00;
									imm_sel = 3'd0;
									reg_we = 1'b1;
									//br_un = 1'b0;
									B_sel = 1'b1;
									A_sel = 1'b0;
									alu_sel = 4'd4;
									data_mem_we = 1'b0;
									wb_sel = 2'b01;
							
								end
			
							2'b11: //
								begin	
									case(inst[6:5])
									2'b00: //sub
										begin
									
											addr_A = inst[9:7] + 4'd8;
											addr_B = inst[4:2] + 4'd8;
											addr_D = inst[9:7] + 4'd8;
											//c_imm = {{7{inst[5]}},inst[6:2]};
					
											pc_sel = 2'b00;
											//imm_sel = 3'd0;
											reg_we = 1'b1;
											//br_un = 1'b0;
											B_sel = 1'b0;
											A_sel = 1'b0;
											alu_sel = 4'd1;
											data_mem_we = 1'b0;
											wb_sel = 2'b01;

										end

									2'b01: //xor
										begin
											addr_A = inst[9:7] + 4'd8;
											addr_B = inst[4:2] + 4'd8;
											addr_D = inst[9:7] + 4'd8;
											//c_imm = {{7{inst[5]}},inst[6:2]};
					
											pc_sel = 2'b00;
											//imm_sel = 3'd0;
											reg_we = 1'b1;
											//br_un = 1'b0;
											B_sel = 1'b0;
											A_sel = 1'b0;
											alu_sel = 4'd2;
											data_mem_we = 1'b0;
											wb_sel = 2'b01;

										end

									2'b10: //or
										begin
											addr_A = inst[9:7] + 4'd8;
											addr_B = inst[4:2] + 4'd8;
											addr_D = inst[9:7] + 4'd8;
											//c_imm = {{7{inst[5]}},inst[6:2]};
					
											pc_sel = 2'b00;
											//imm_sel = 3'd0;
											reg_we = 1'b1;
											//br_un = 1'b0;
											B_sel = 1'b0;
											A_sel = 1'b0;
											alu_sel = 4'd3;
											data_mem_we = 1'b0;
											wb_sel = 2'b01;

										end

									2'b11: //and
										begin
											addr_A = inst[9:7] + 4'd8;
											addr_B = inst[4:2] + 4'd8;
											addr_D = inst[9:7] + 4'd8;
											//c_imm = {{7{inst[5]}},inst[6:2]};
					
											pc_sel = 2'b00;
											//imm_sel = 3'd0;
											reg_we = 1'b1;
											//br_un = 1'b0;
											B_sel = 1'b0;
											A_sel = 1'b0;
											alu_sel = 4'd4;
											data_mem_we = 1'b0;
											wb_sel = 2'b01;

										end

									default: default_flag = 1'b1;
									endcase
								end
			
							default: default_flag = 1'b1;
							endcase
		
						end
					default: default_flag = 1'b1;
				endcase
			end

		2'b10: //c.move,c.add,c.slli
			begin
				case(inst[15:13])
				3'b000: //slli
					begin
						addr_A = inst[11:7];
						addr_B = 5'd0;
						addr_D = inst[11:7];
						c_imm = {{26{1'b0}},inst[12],inst[6:2]};

						pc_sel = 2'b00;
						//imm_sel = 3'd0;
						reg_we = 1'b1;
						//br_un = 1'b0;
						B_sel = 1'b1;
						A_sel = 1'b0;
						alu_sel = 4'd3;
						data_mem_we = 1'b0;
						wb_sel = 2'b01;
					end
				3'b100: //
					begin
						if (inst[12]) //add
							begin
								addr_A = inst[11:7];
								addr_B = inst[6:2];
								addr_D = inst[11:7];
								//c_imm = {{26{1'b0}},inst[12],inst[6:2]};
		
								pc_sel = 2'b00;
								//imm_sel = 3'd0;
								reg_we = 1'b1;
								//br_un = 1'b0;
								B_sel = 1'b0;
								A_sel = 1'b0;
								alu_sel = 4'd0;
								data_mem_we = 1'b0;
								wb_sel = 2'b01;

							end

						else //move
							begin
								addr_A = 5'd0;
								addr_B = inst[6:2];
								addr_D = inst[11:7];
								//c_imm = {{26{1'b0}},inst[12],inst[6:2]};
		
								pc_sel = 2'b00;
								//imm_sel = 3'd0;
								reg_we = 1'b1;
								//br_un = 1'b0;
								B_sel = 1'b0;
								A_sel = 1'b0;
								alu_sel = 4'd0;
								data_mem_we = 1'b0;
								wb_sel = 2'b01;
							end
					end

				default: default_flag = 1'b1;
				endcase

			end

		2'b11: //word
			begin

			end

		default: default_flag = 1'b1;
		endcase
	end


endmodule