module controller(

input [4:0]opcode,   //5 bit
input [2:0]func3,    //3 bit
input func7_5th_bit,  //1 bit
input c_inst_flag,	 //1 bit
input br_eq,
input br_lt,

output reg [1:0]pc_sel,
output reg [2:0]imm_sel,
output reg reg_we,
output reg br_un, 		
output reg B_sel,
output reg A_sel,
output reg [3:0]alu_sel,
output reg data_mem_we,
output reg [1:0]wb_sel, 	 
output reg [2:0]mode

);

always@(*)
	begin

		
		case(opcode)
		5'b01100: // R TYPE
			begin
				imm_sel = 3'd0;  //x
				reg_we = 1'b1;
				br_un = 1'b0;    //x
				B_sel = 1'b0;
				A_sel = 1'b0;
				data_mem_we = 1'b0;
				wb_sel = 2'b01;
				mode = 3'd0;             //x

				case(c_inst_flag) 
					1'b0: pc_sel = 2'd1; 
					1'b1: pc_sel = 2'd0; 
				endcase

				case(func3)
				3'b000: 
					begin
						case(func7_5th_bit) 
						1'b0: alu_sel = 4'd0; //add
						1'b1: alu_sel = 4'd1; //sub
						default:
							begin
								reg_we = 1'b0;
								data_mem_we = 1'b0;
								alu_sel = 4'd0; //mem we are 0s,so it dosnot matter
							end 
						endcase
					end
				3'b100: alu_sel = 4'd2; //xor
				3'b110: alu_sel = 4'd3; //or
				3'b111: alu_sel = 4'd4; //and
				3'b001: alu_sel = 4'd5; //sll
				3'b101: 
					begin
						case(func7_5th_bit) 
						1'b0: alu_sel = 4'd6; //srl
						1'b1: alu_sel = 4'd7; //sra
						default:
							begin
								reg_we = 1'b0;
								data_mem_we = 1'b0;
								alu_sel = 4'd0;
							end 
						endcase
					end
				3'b010: alu_sel = 4'd8; //slt
				3'b011: alu_sel = 4'd9; //sltu

				default:
					begin
						reg_we = 1'b0;
						data_mem_we = 1'b0;
						alu_sel = 4'd0;
					end
				endcase
			end

		5'b00100: // I-R TYPE
			begin
				imm_sel = 3'd0;
				reg_we = 1'b1;
				br_un = 1'b0;  //x
				B_sel = 1'b1;
				A_sel = 1'b0;
				data_mem_we = 1'b0;
				wb_sel = 2'b01;
				mode = 3'd0;             //x

				case(c_inst_flag) 
					1'b0: pc_sel = 2'd1; 
					1'b1: pc_sel = 2'd0; 
				endcase

				case(func3)
				3'b000: alu_sel = 4'd0; //addi
				3'b100: alu_sel = 4'd2; //xori
				3'b110: alu_sel = 4'd3; //ori
				3'b111: alu_sel = 4'd4; //andi
				3'b001: alu_sel = 4'd5; //slli
				3'b101:
					begin
						case(func7_5th_bit)
						1'b0: alu_sel = 4'd6; //srli
						1'b1: 
							begin
								alu_sel = 4'd7; //srai
								imm_sel = 3'd1;
							end
						default:
							begin
								reg_we = 1'b0;
								data_mem_we = 1'b0;
								alu_sel = 4'd0;
							end
						endcase
					end
				3'b010: alu_sel = 4'd8; //slti
				3'b011: alu_sel = 4'd9; //sltiu

				default: 
					begin
						reg_we = 1'b0;
						data_mem_we = 1'b0;
						alu_sel = 4'd0;
					end
				endcase
			end

		5'b00000: // I-L TYPE
			begin
				imm_sel = 3'd0;
				reg_we = 1'b1;
				br_un = 1'b0;  //x
				B_sel = 1'b1;
				A_sel = 1'b0;
				alu_sel = 4'd0;
				data_mem_we = 1'b0;
				wb_sel = 2'b00;
				
				case(c_inst_flag) 
					1'b0: pc_sel = 2'd1; 
					1'b1: pc_sel = 2'd0; 
				endcase
				
				case(func3)
				3'd0: mode = 3'd2;
				3'd1: mode = 3'd1;
				3'd2: mode = 3'd0;
				3'd4: mode = 3'd3;
				3'd5: mode = 3'd4;
				default: 
					begin
						reg_we = 1'b0;
						data_mem_we = 1'b0;
						mode = 3'd0;
					end
				endcase
			end

		5'b01000: // S TYPE
			begin
				imm_sel = 3'd2;
				reg_we = 1'b0;
				br_un = 1'b0;  //x
				B_sel = 1'b1;
				A_sel = 1'b0;
				alu_sel = 4'd0;
				data_mem_we = 1'b1;
				wb_sel = 2'b00;  //x
				
				case(c_inst_flag) 
					1'b0: pc_sel = 2'd1; 
					1'b1: pc_sel = 2'd0; 
				endcase

				case(func3)
					3'd0: mode = 3'd2;
					3'd1: mode = 3'd1;
					3'd2: mode = 3'd0;
					default: 
						begin
							reg_we = 1'b0;
							data_mem_we = 1'b0;
							mode = 3'd0;
						end
					endcase
			end

		5'b11000: // B TYPE
			begin
				imm_sel = 3'd3;
				reg_we = 1'b0;
				B_sel = 1'b1;
				A_sel = 1'b1;
				alu_sel = 4'd0;
				data_mem_we = 1'b0;
				wb_sel = 2'b00;     //x
				mode = 3'd0; 		//x

				case(func3)
				3'd0:   //beq
					begin
						br_un = 1'b0;

						case({c_inst_flag,br_eq})
						2'b00: pc_sel = 2'b01;
						2'b01: pc_sel = 2'b10;
						2'b10: pc_sel = 2'b00;
						2'b11: pc_sel = 2'b10;
						endcase

					end

				3'd1:	//bne
					begin
						br_un = 1'b0;

						case({c_inst_flag,br_eq})
						2'b00: pc_sel = 2'b10;
						2'b01: pc_sel = 2'b01;
						2'b10: pc_sel = 2'b10;
						2'b11: pc_sel = 2'b00;
						endcase
					end

				3'd4:	//blt
					begin
						br_un = 1'b0;

						case({c_inst_flag,br_lt})
						2'b00: pc_sel = 2'b01;
						2'b01: pc_sel = 2'b10;
						2'b10: pc_sel = 2'b00;
						2'b11: pc_sel = 2'b10;
						endcase
					end

				3'd5:	//bge 
					begin
						br_un = 1'b0;

						case({c_inst_flag,br_eq,br_lt})
						3'b000:  pc_sel = 2'b10;
						3'b001:  pc_sel = 2'b01;
						3'b010:  pc_sel = 2'b10;
						3'b011:  pc_sel = 2'b10;
						3'b100:  pc_sel = 2'b10;
						3'b101:  pc_sel = 2'b00;
						3'b110:  pc_sel = 2'b10;
						3'b111:  pc_sel = 2'b10;
						endcase
					end

				3'd6:	//bltu
					begin
						br_un = 1'b1;

						case({c_inst_flag,br_lt})
						2'b00: pc_sel = 2'b01;
						2'b01: pc_sel = 2'b10;
						2'b10: pc_sel = 2'b00;
						2'b11: pc_sel = 2'b10;
						endcase
					end

				3'd7:	//bgeu
					begin
						br_un = 1'b1;

						case({c_inst_flag,br_eq,br_lt})
						3'b000:  pc_sel = 2'b10;
						3'b001:  pc_sel = 2'b01;
						3'b010:  pc_sel = 2'b10;
						3'b011:  pc_sel = 2'b10;
						3'b100:  pc_sel = 2'b10;
						3'b101:  pc_sel = 2'b00;
						3'b110:  pc_sel = 2'b10;
						3'b111:  pc_sel = 2'b10;
						endcase
					end

				default: 
					begin
						reg_we = 1'b0;
						data_mem_we = 1'b0;
						case(c_inst_flag) 
						1'b0: pc_sel = 2'd1; 
						1'b1: pc_sel = 2'd0; 
						endcase 	
						//pc_sel = 2'b01;
						br_un = 1'b0;
					end
				endcase
			end

		5'b11011: // J TYPE
			begin
				pc_sel = 2'b10; 
				imm_sel = 3'd5;//using imm_gen to calculate return address for forwarding
				reg_we = 1'b1;
				br_un = 1'b0; 	 //x
				B_sel = 1'b1; 
				A_sel = 1'b1; 
				alu_sel = 4'd0; 
				data_mem_we = 1'b0; 
				wb_sel = 2'b10;  	
				mode = 3'd0; 		 //x

			end

		5'b11001: // I-J TYPE
			begin
				pc_sel = 2'b10;
				imm_sel = 3'd5; //using imm_gen to calculate return address for forwarding
				reg_we = 1'b1;
				br_un = 1'b0; 		 //x
				B_sel = 1'b1;
				A_sel = 1'b0;
				alu_sel = 4'd0;
				data_mem_we = 1'b0;
				wb_sel = 2'b10;  	 
				mode = 3'd0; 		 //x
			end

		5'b01101: // U-LUI TYPE
			begin
				//pc_sel = 2'b01;
				imm_sel = 3'd4;
				reg_we = 1'b1;
				br_un = 1'b0; 		 //x
				B_sel = 1'b1;
				A_sel = 1'b0;
				alu_sel = 4'd10;
				data_mem_we = 1'b0;
				wb_sel = 2'b01;  	 
				mode = 3'd0; 		 //x
				case(c_inst_flag) 
					1'b0: pc_sel = 2'd1; 
					1'b1: pc_sel = 2'd0; 
				endcase
			end

		5'b00101: // U-AUIPC TYPE
			begin
				imm_sel = 3'd4;
				reg_we = 1'b1;
				br_un = 1'b0; 		 //x
				B_sel = 1'b1;
				A_sel = 1'b1;
				alu_sel = 4'd0;
				data_mem_we = 1'b0;
				wb_sel = 2'b01;  	 
				mode = 3'd0; 
				case(c_inst_flag) 
					1'b0: pc_sel = 2'd1; 
					1'b1: pc_sel = 2'd0; 
				endcase	
			end

		default: 
			begin
				imm_sel = 3'd0;
				reg_we = 1'b0;
				br_un = 1'b0; 		
				B_sel = 1'b0;
				A_sel = 1'b0;
				alu_sel = 4'd0;
				data_mem_we = 1'b0;
				wb_sel = 2'b00;  	 
				mode = 3'd0;
				case(c_inst_flag) 
					1'b0: pc_sel = 2'd1; 
					1'b1: pc_sel = 2'd0; 
				endcase 	
			end

		endcase
	end


endmodule
