module decompressor(

input [31:0]inst,

output reg [4:0]addr_A,
output reg [4:0]addr_B,
output reg [4:0]addr_D,
output reg [4:0]opcode,
output reg [2:0]func3,
output reg func7_5th_bit,
output reg c_inst_flag, //cntrl signal for  imm_cidiate RVC32C instructions
output reg [31:0]imm_c,
output reg [1:0]lw_comp 
			
);



always@(*)
	begin
		lw_comp = 2'b00;
		case(inst[1:0])
		2'b00: //c.lw,c.sw
			begin
				case(inst[15:13])
				3'b010: //c.lw
					begin
						addr_A = inst[9:7] + 4'd8;
						addr_B = 5'd0;
						addr_D = inst[4:2] + 4'd8;
						imm_c = {{25{1'b0}},inst[5],inst[12:10],inst[6],2'b00};
						
						opcode = 5'd0;
						func3 = 3'h2;
						func7_5th_bit = 1'b0; //x
						c_inst_flag = 1'b1;
						lw_comp = 2'b11;

					end

				3'b110:
					begin //c.sw
						addr_A = inst[9:7] + 4'd8;
						addr_B = inst[4:2] + 4'd8;
						addr_D = 5'd0;
						imm_c = {{25{1'b0}},inst[5],inst[12:10],inst[6],2'b00};
		
						opcode = 5'b01000;
						func3 = 3'h2;
						func7_5th_bit = 1'b0; //x
						c_inst_flag = 1'b1;

					end
				
				default:
					begin
						addr_A = 5'd0;
						addr_B = 5'd0;
						addr_D = 5'd0;
						imm_c = 32'd0;
						opcode = 5'd0;
						func3 = 3'd0;
						func7_5th_bit = 1'b0;
						c_inst_flag = 1'b1;
					end
				endcase
			end

		2'b01: //c.cb,c.ci,c,cs
			begin
				case(inst[15:13])
					3'b000:  //c.addi
						begin
							addr_A = inst[11:7];
							addr_B = 5'd0;
							addr_D = inst[11:7];
							imm_c = {{27{inst[12]}},inst[6:2]};
	
							opcode = 5'b00100;
							func3 = 3'h0;
							func7_5th_bit = 1'b0; //x
							c_inst_flag = 1'b1;
						end

					3'b010:  //c.li
						begin
							addr_A = 5'd0;
							addr_B = 5'd0;
							addr_D = inst[11:7];
							imm_c = {{26{inst[12]}},inst[12],inst[6:2]};
	
							opcode = 5'b00100;
							func3 = 3'h0;
							func7_5th_bit = 1'b0; //x
							c_inst_flag = 1'b1;
						end

					3'b011:  //c.lui
						begin
							addr_A = 5'd0;
							addr_B = 5'd0;
							addr_D = inst[11:7];
							imm_c = {{15{inst[12]}},inst[6:2],{12{1'b0}}};
	
							opcode = 5'b01101;
							func3 = 3'h0;        //x
							func7_5th_bit = 1'b0; //x
							c_inst_flag = 1'b1;

						end

				    3'b100:  //
						begin
							case(inst[11:10])
							2'b00: //c.srli
								begin
									addr_A = inst[9:7] + 4'd8;
									addr_B = 5'd0;
									addr_D = inst[9:7] + 4'd8;
									imm_c = {{27{1'b0}},inst[6:2]}; //shamt = imm_c[5] = 0 for RVC32
			
									opcode = 5'b00100;
									func3 = 3'h5;        
									func7_5th_bit = 1'b0; 
									c_inst_flag = 1'b1;
								end
			
							2'b01: //c.srai
								begin
									addr_A = inst[9:7] + 4'd8;
									addr_B = 5'd0;
									addr_D = inst[9:7] + 4'd8;
									imm_c = {{27{1'b0}},inst[6:2]}; //shamt = imm_c[5] = 0 for RVC32
			
			
									opcode = 5'b00100;
									func3 = 3'h5;        
									func7_5th_bit = 1'b1; 
									c_inst_flag = 1'b1;
								end
			
							2'b10: //c.andi
								begin
									addr_A = inst[9:7] + 4'd8;
									addr_B = 5'd0;
									addr_D = inst[9:7] + 4'd8;
									imm_c = {{27{inst[5]}},inst[6:2]};
			
									opcode = 5'b00100;
									func3 = 3'h7;        
									func7_5th_bit = 1'b0; //x
									c_inst_flag = 1'b1;
								end
			
							2'b11: //
								begin	
									case(inst[6:5])
									2'b00: //c.sub
										begin
									
											addr_A = inst[9:7] + 4'd8;
											addr_B = inst[4:2] + 4'd8;
											addr_D = inst[9:7] + 4'd8;
											imm_c = 32'd0;
					
											opcode = 5'b01100;
											func3 = 3'h0;        
											func7_5th_bit = 1'b1; 
											c_inst_flag = 1'b1;
										end

									2'b01: //c.xor
										begin
											addr_A = inst[9:7] + 4'd8;
											addr_B = inst[4:2] + 4'd8;
											addr_D = inst[9:7] + 4'd8;
											imm_c = 32'd0;
					
											opcode = 5'b01100;
											func3 = 3'h4;        
											func7_5th_bit = 1'b0; //x
											c_inst_flag = 1'b1;
										end

									2'b10: //c.or
										begin
											addr_A = inst[9:7] + 4'd8;
											addr_B = inst[4:2] + 4'd8;
											addr_D = inst[9:7] + 4'd8;
											imm_c = 32'd0;
					
											opcode = 5'b01100;
											func3 = 3'h6;        
											func7_5th_bit = 1'b0; //x
											c_inst_flag = 1'b1;

										end

									2'b11: //c.and
										begin
											addr_A = inst[9:7] + 4'd8;
											addr_B = inst[4:2] + 4'd8;
											addr_D = inst[9:7] + 4'd8;
											imm_c = 32'd0;
					
											opcode = 5'b01100;
											func3 = 3'h7;        
											func7_5th_bit = 1'b0; //x
											c_inst_flag = 1'b1;
										end

									default: 
										begin
											addr_A = 5'd0;
											addr_B = 5'd0;
											addr_D = 5'd0;
											imm_c = 32'd0;
											opcode = 5'd0;
											func3 = 3'd0;
											func7_5th_bit = 1'b0;
											c_inst_flag = 1'b1;
										end
									endcase
								end
			
						default: 
							begin
								addr_A = 5'd0;
								addr_B = 5'd0;
								addr_D = 5'd0;
								imm_c = 32'd0;
								opcode = 5'd0;
								func3 = 3'd0;
								func7_5th_bit = 1'b0;
								c_inst_flag = 1'b1;
							end
						endcase
						end
				default: 
					begin
						addr_A = 5'd0;
						addr_B = 5'd0;
						addr_D = 5'd0;
						imm_c = 32'd0;
						opcode = 5'd0;
						func3 = 3'd0;
						func7_5th_bit = 1'b0;
						c_inst_flag = 1'b1;
					end
				endcase
			end

		2'b10: //c.move,c.add,c.slli
			begin
				case(inst[15:13])
				3'b000: //c.slli
					begin
						addr_A = inst[11:7];
						addr_B = 5'd0;
						addr_D = inst[11:7];
						imm_c = {{26{1'b0}},inst[12],inst[6:2]};

						opcode = 5'b00100;
						func3 = 3'h1;        
						func7_5th_bit = 1'b0; //x
						c_inst_flag = 1'b1;
					end
				3'b100: //
					begin
						if (inst[12]) //c.add
							begin
								addr_A = inst[11:7];
								addr_B = inst[6:2];
								addr_D = inst[11:7];
								imm_c = 31'd0;
		
								opcode = 5'b01100;
								func3 = 3'h0;        
								func7_5th_bit = 1'b0; 
								c_inst_flag = 1'b1;
							end

						else //c.move
							begin
								addr_A = 5'd0;
								addr_B = inst[6:2];
								addr_D = inst[11:7];
								imm_c = 31'd0;
		
								opcode = 5'b01100;
								func3 = 3'h0;        
								func7_5th_bit = 1'b0; 
								c_inst_flag = 1'b1;
							end
					end

				default: 
					begin
						addr_A = 5'd0;
						addr_B = 5'd0;
						addr_D = 5'd0;
						imm_c = 32'd0;
						opcode = 5'd0;
						func3 = 3'd0;
						func7_5th_bit = 1'b0;
						c_inst_flag = 1'b1;
					end
				endcase

			end

		2'b11: //word
			begin
				
				addr_A = inst[19:15];
				addr_B = inst[24:20];
				addr_D = inst[11:7];
				//imm_c = inst[31:7];
					
				opcode = inst[6:2];
				func3 = inst[14:12];
				func7_5th_bit = inst[30];
				c_inst_flag = 1'b0;

			end

		default:
		 begin
				addr_A = 5'd0;
				addr_B = 5'd0;
				addr_D = 5'd0;
				imm_c = 32'd0;
				opcode = 5'd0;
				func3 = 3'd0;
				func7_5th_bit = 1'b0;
				c_inst_flag = 1'b0;
			end
		endcase
	end


endmodule
