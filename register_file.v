
module register_file #(parameter depth = 32, width = 32, addr_width = 5)(

input wire clk,
input wire rst,
input wire reg_we,              			   		// 1 for write 0 for read

input wire [addr_width-1'b1:0] addr_A,
input wire [addr_width-1'b1:0] addr_B,
input wire [addr_width-1'b1:0] addr_D,          // write addr

input wire [width-1'b1:0] w_data,          		// write data
output wire [width-1'b1:0] src1,
output wire [width-1'b1:0] src2

);


reg [width-1'b1:0] mem [0:depth-1'b1] ;
integer i;
wire x0_flag;

//if dest is x0
assign x0_flag = (addr_D == 0);

//write data in register file
always @(negedge clk,negedge rst)  //double pumping
	begin
		if(!rst)
			begin
				for(i=0; i<depth; i=i+1'b1)
					 mem[i] <= {width{1'b0}};   //initilize

			end
		else
			begin
			case({reg_we,x0_flag})
			2'b10: mem[addr_D] <= w_data;
			default: mem[0] <= {width{1'b0}};      //flag = 1 or any other condition

			endcase
			end
	end

//read data from register file
assign src1 = (addr_A == {addr_width{1'b0}}) ? {width{1'b0}} : mem[addr_A]; 	//if rst doesnot come & addr =0;
assign src2 = (addr_B == {addr_width{1'b0}}) ? {width{1'b0}} : mem[addr_B];		//if rst doesnot come & addr =0;


endmodule
