
/*Dual instruction memory 1024x16
---------------------------------------------------------------------------
| depth   	       |   1024
---------------------------------------------------------------------------
| width  	 	   |   16
---------------------------------------------------------------------------
| addr_bits 	   |   10
---------------------------------------------------------------------------
| Type of mem addr |   Big endian
---------------------------------------------------------------------------
| Note		       |   parametrized ROM.writing all data in mem at 0 time.
---------------------------------------------------------------------------*/


module inst_mem #(parameter depth = 1024,width = 32,mem_addr_count = 32)(

input wire [mem_addr_count-1:0]pc,
output reg [31:0]inst

);

reg [width-1:0]mem[0:depth-1];  //mem vector

//assign inst = {mem[pc],mem[pc+1],mem[pc+2],mem[pc+3]};  //read from rom
reg [mem_addr_count-1:0]addr;
always @(*)
	begin
		addr = pc>>2;
		case(pc[1])
		1'b0: inst = mem[addr];
		1'b1: inst = {mem[addr+1'b1][15:0],mem[addr][31:16]};
		endcase
	end

endmodule