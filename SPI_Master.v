module SPI_Master#(parameter halfT = 5)
                                       (input communication_flag, input [1:0]address, input  cpol, input cpha,
		                        input [7:0]MISO, input [7:0]data_in , input read_enable, input write_enable,
                                        output reg SCLK, output reg [7:0]MOSI, output reg CS1, output reg CS2, output reg CS3, output reg [7:0]data_out) ;
wire CPOL ;
wire CPHA ;

//assign CPOL and CPHA to external outputs IF comm_flag == 0
//else their previous values
assign CPOL = (!communication_flag)? cpol : CPOL ;
assign CPHA = (!communication_flag)? cpha : CPHA ;

always @(posedge communication_flag)
begin
	SCLK = CPOL ;
        #halfT SCLK = ~SCLK ;
        while(communication_flag)
        begin	
		//Decoding the address bus to the three 1-bit chips selects:
		{CS1,CS2,CS3} = 'b111 ;
		case(address)
		'b00 : CS1 = 0 ;
		'b01 : CS2 = 0 ;
		'b10 : CS3 = 0 ;
		endcase
		

		//Performing the read/write_delay_read/write sequence according to value of the control flags
		case({CPOL,CPHA})
		
		'b00 :
		 begin
			if(read_enable) data_out = MISO ;
			#halfT SCLK = ~SCLK ;
			if(write_enable) MOSI = data_in ;
			#halfT SCLK = ~SCLK	;
		 end

		'b01 :
		 begin
			if(write_enable) MOSI = data_in ;
			#halfT SCLK = ~SCLK ;
			if(read_enable) data_out = MISO ;
			#halfT SCLK = ~SCLK	;

		 end

		'b10 :
		 begin
			#halfT SCLK = ~SCLK ;
			if(read_enable) data_out = MISO ;
			#halfT SCLK = ~SCLK ;
			if(write_enable) MOSI = data_in ;
			#halfT SCLK = ~SCLK	;
			
		 end

		'b11 :
		 begin
			#halfT SCLK = ~SCLK ;
			if(write_enable) MOSI = data_in ;
			#halfT SCLK = ~SCLK ;
			if(read_enable) data_out = MISO ;
			#halfT SCLK = ~SCLK	;
		 end
		 
 		endcase
	end
end
endmodule
 
