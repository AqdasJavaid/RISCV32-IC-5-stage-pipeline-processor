module branch_comp #(parameter width = 32)(

input signed [width-1:0]src1,
input signed [width-1:0]src2,
input br_un,  //branch unsigned
output reg br_lt,
output reg br_eq
);

always @(*)
	begin
		if(br_un)
			begin
			 if (($unsigned(src1) < $unsigned(src2)))
					br_lt =1;
			 else
					br_lt =0;
			end
		else
			begin
				if (src1 == src2)
					br_eq = 1;
				else
					br_eq = 0;

				if (src1 < src2)
					br_lt = 1;
				else
					br_lt = 0;
				//br_eq = (src1 == src2);
				//br_lt = (src1 < src2);
			end
	end

endmodule
