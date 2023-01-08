
module ff #(parameter N = 32)(
	input clk,rst,
	input [N-1:0]d,
	output reg [N-1:0]q
	

);

always @(posedge clk,negedge rst)
	begin
		if(!rst)
			q <= {N{1'b0}};
		else
			q <= d;
	end
	
endmodule
