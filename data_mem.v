/*instruction memory 1024x32
---------------------------------------------------------------------------
| depth   	       |   1024
---------------------------------------------------------------------------
| width  	 	   |   32
---------------------------------------------------------------------------
| addr_bits 	   |   8
---------------------------------------------------------------------------
| Type of mem addr |   Little endian
---------------------------------------------------------------------------
| Note		       |   Parametrized ROM.writing all data in mem at 0 time.
---------------------------------------------------------------------------*/


/*mode
---------------------------------------------------------------------------
| 000  |  word 
---------------------------------------------------------------------------
| 001  |  half word
---------------------------------------------------------------------------
| 010  |  byte
---------------------------------------------------------------------------
| 011  |  unsigned byte
---------------------------------------------------------------------------
| 100  |  unsigned half
---------------------------------------------------------------------------*/

module data_mem #(parameter depth = 1024, width = 32, addr_width = 10)(

	input wire clk,
	input wire rst,
	input wire data_mem_we,
	input wire [2:0] mode,
	input wire [addr_width-1:0]addr,
	input wire [31:0]src2, //w_data

	output reg [31:0]data_mem_R

);
wire [31:0]w_data;
assign w_data = src2;

reg [width-1:0] mem [0:depth-1];
integer i;


//write data in register file
wire [addr_width-3:0]addr1;
assign addr1 = addr[addr_width-1:2];

always @(posedge clk,negedge rst)
	begin
		casex({rst,data_mem_we,mode[1:0]}) //only 2 bits of mood are used to write as we need 3 options only, i.e, sw,sh,sb
		4'b0xxx:  //rst
			begin
				for(i=0; i<depth; i=i+1'b1)
					 mem[i] <= {width{1'b0}};   //initilize
			end
		4'b1100: mem[addr1] <= w_data;  //sw
		5'b1101:                        //sh
			begin
				case(addr[1])
				1'b0: mem[addr1][15:0] <= w_data[15:0];
				1'b1: mem[addr1][31:16] <= w_data[15:0];
				endcase
			end

		5'b1110:                        //sb
			case(addr[1:0])
			2'b00: mem[addr1][7:0]   <= w_data[7:0];
			2'b01: mem[addr1][15:8]  <= w_data[7:0];
			2'b10: mem[addr1][23:16] <= w_data[7:0];
			2'b11: mem[addr1][31:24] <= w_data[7:0];
			endcase

		default: mem[addr1] <= mem[addr1];  

		endcase
	end

always@(*)
	begin
		case(mode)
		3'b000:	data_mem_R = mem[addr1]; //lw
		3'b001:  //lh
			begin	
				case(addr[1])
				1'b0:data_mem_R = {{16{mem[addr1][15]}},mem[addr1][15:0]};
				1'b1:data_mem_R = {{16{mem[addr1][31]}},mem[addr1][31:16]};
				endcase
			end
		3'b010: //lb
			begin
				case(addr[1:0])
				2'b00:data_mem_R = {{24{mem[addr1][7]}},mem[addr1][7:0]};
				2'b01:data_mem_R = {{24{mem[addr1][15]}},mem[addr1][15:8]};
				2'b10:data_mem_R = {{24{mem[addr1][23]}},mem[addr1][23:16]};
				2'b11:data_mem_R= {{24{mem[addr1][31]}},mem[addr1][31:24]};
				endcase
			end

		3'b011: //lbu
			begin
				case(addr[1:0])
				2'b00:data_mem_R = {24'd0,mem[addr1][7:0]};
				2'b01:data_mem_R = {24'd0,mem[addr1][15:8]};
				2'b10:data_mem_R = {24'd0,mem[addr1][23:16]};
				2'b11:data_mem_R = {24'd0,mem[addr1][31:24]};
				endcase
			end
		3'b100:  //lhu
			begin
				case(addr[1])
				1'b0:data_mem_R = {16'd0,mem[addr1][15:0]};
				1'b1:data_mem_R = {16'd0,mem[addr1][31:16]};
				endcase
			end
		default:data_mem_R = {width{1'b0}};
		endcase
	end

endmodule
