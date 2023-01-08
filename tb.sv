
module tb ();

localparam no_of_inst = 80; 


logic clk,rst;
AKEANA_PO_AJ dut(.*);

initial 
	begin
		clk=0;
		rst =0;
		#10
		rst=1;

	end


initial $readmemh("data.txt",dut.i_inst_mem.mem);
initial
	begin
		#10;
		$display ("Initial reg values");
 		$display("PC = %h",dut.i_program_counter.pc);
		for(int i=0; i<32; i=i+1)
			
			 $display("r[%d] = %h",i,dut.i_register_file.mem[i]);
		
		for(int i=0; i<no_of_inst; i=i+1)
			 #50;

		$display ("Final reg values");
		$display("PC = %h",dut.i_program_counter.pc);
		for(int i=0; i<32; i=i+1)
			 $display("r[%d] = %h",i,dut.i_register_file.mem[i]);


	end

always #25 clk = ~clk;

reg [31:0]count = 32'd0;
always@(posedge clk)
	count <= count +1;

endmodule