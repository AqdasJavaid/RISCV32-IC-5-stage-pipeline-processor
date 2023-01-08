/*iProgram counter
---------------------------------------------------------------------------
| rst	|   pc_sel	 |	 output
---------------------------------------------------------------------------
|  0	|	x    |    0
---------------------------------------------------------------------------
|  1	|	0    |    pc+2
---------------------------------------------------------------------------
|  1	|	1    |    pc+4
---------------------------------------------------------------------------
|  1	|	2    |    pc+imm
---------------------------------------------------------------------------*/

module program_counter#(parameter width = 32)(  

input clk,
input rst,stall,
input [1:0]pc_sel,
input compressed_flag,
output reg [width-1:0]pc,
input [width-1:0]rd  //alu_out

);

//wire [width-1:0] count;

always@(posedge clk,negedge rst)  //active low reset
	begin
		if(!rst)
			begin
				pc <= {width{1'b0}};

			end
		else
			begin
				if (!stall)
					pc <= pc ;
				else
					begin
						case({pc_sel[1],compressed_flag})
						2'b01: pc <= pc + 2'd2;
						2'b00: pc <= pc + 3'd4;
						2'b10: pc <= rd;
						2'b11: pc <= rd;
						default: pc <= pc; //active low reset
						endcase
					end
			end
	end

//assign count = pc + 3'd4;

endmodule
