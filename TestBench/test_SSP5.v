module test_SSP5;
	reg clock, clear_b, pwrite, psel;
	reg [7:0] data_in;
	wire [7:0] data_out;
	wire tx_to_rx, clk_wire, fss_wire, ssptxintr, ssprxintr, oe_b;

	initial begin
		clock = 1'b0;
		clear_b = 1'b0;
		psel = 1'b1;
		@(posedge clock);
		#1;
		@(posedge clock);
    data_in = 8'b11111111; //8'hFF, dummy data. should not enter into SSP.
		#1;
		clear_b = 1'b1;
		#15 
		pwrite = 1'b1;
		data_in = 8'b10010100; //8'h94
		#40
		data_in = 8'b00001111; //8'h0F
		#40
		data_in = 8'b01010001; //8'h51
		#40
		data_in = 8'b00100100; //8'h24
		#40
		data_in = 8'b01100111; //8'h67
		#40 
		data_in = 8'b11110011; //8'hF3
    #40
		data_in = 8'b10110110; //8'hB6
    #40
    data_in = 8'b10000100; //8'b84
		#30
    psel = 1'b0;
		#870
		psel = 1'b1;
		pwrite = 1'b0;
    #80
    pwrite = 1'b1;
    #40
    psel = 1'b0;
    #3600
    pwrite = 1'b0;
    psel = 1'b1;
	end
	
	always 
	#20 clock = ~clock;

// serial output from SSP is looped back to the serial input.
	SSP5 ssp2 (.PCLK(clock), .CLEAR_B(clear_b), .PSEL(psel), .PWRITE(pwrite), .SSPCLKIN(clk_wire), .SSPFSSIN(fss_wire), .SSPRXD(tx_to_rx), .PWDATA(data_in), .PRDATA(data_out), .SSPCLKOUT(clk_wire), .SSPFSSOUT(fss_wire), .SSPTXD(tx_to_rx), .SSPOE_B(oe_b), .SSPTXINTR(ssptxintr), .SSPRXINTR(ssprxintr));

endmodule