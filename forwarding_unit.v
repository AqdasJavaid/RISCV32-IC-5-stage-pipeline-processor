module forwarding_unit(

input ID_EX_RegWrite,EX_MEM_RegWrite,WB_MEM_RegWrite,
input [4:0] ID_EX_RegisterRs1,ID_EX_RegisterRs2,ID_EX_RegisterRd,    //stage 3
input [4:0] EX_MEM_RegisterRd, //stage 4
input [4:0] WB_MEM_RegisterRd, //stage 5
input [4:0] IF_ID_RegisterRs1,IF_ID_RegisterRs2,
output reg [1:0] forward_A,forward_B,forward_C,forward_D

);


/*Forwarding mux controls
----------------------
| 00  |  normal
----------------------
| 01  |  EX-EX
----------------------
| 10  |  WB-EX
----------------------*/

always@(*) //rs1 (forward_C)
	begin
		if (EX_MEM_RegWrite && EX_MEM_RegisterRd !=5'd0 && EX_MEM_RegisterRd == ID_EX_RegisterRs1 )
		   forward_A = 2'b01;
		else if ( WB_MEM_RegWrite && WB_MEM_RegisterRd !=5'd0 && WB_MEM_RegisterRd == ID_EX_RegisterRs1 )
		   forward_A = 2'b10;
		else
		   forward_A = 2'b00;
	end

always@(*) //rs2 (forward_D)
	begin
		if (EX_MEM_RegWrite && EX_MEM_RegisterRd !=5'd0 && EX_MEM_RegisterRd == ID_EX_RegisterRs2 )
		   forward_B = 2'b01;
		else if (WB_MEM_RegWrite && WB_MEM_RegisterRd !=5'd0 && WB_MEM_RegisterRd == ID_EX_RegisterRs2 )
		   forward_B = 2'b10;
		else
		   forward_B = 2'b00;
	end

/*Forwarding branch controls
----------------------
| 00  |  register data
----------------------
| 01  |  IF-EX
----------------------
| 10  |  IF-WB
----------------------*/

always@(*) //rs1 (forward_C)
	begin
		if (EX_MEM_RegWrite && EX_MEM_RegisterRd !=5'd0 && EX_MEM_RegisterRd == IF_ID_RegisterRs1 )
		   forward_C = 2'b01;
		else if (WB_MEM_RegWrite && WB_MEM_RegisterRd !=5'd0 && WB_MEM_RegisterRd == IF_ID_RegisterRs1 )
		   forward_C = 2'b10;
		else
		   forward_C = 2'b00;
	end

always@(*) //rs1 (forward_D)
	begin
		if (EX_MEM_RegWrite && EX_MEM_RegisterRd !=5'd0 && EX_MEM_RegisterRd == IF_ID_RegisterRs2 )
		   forward_D = 2'b01;
		else if (WB_MEM_RegWrite && WB_MEM_RegisterRd !=5'd0 && WB_MEM_RegisterRd == IF_ID_RegisterRs2 )
		   forward_D = 2'b10;
		else
		   forward_D = 2'b00;
	end

endmodule