module SPI_Slave
                (input SCLK, input CS , input CPOL, input CPHA, 
                 input [7:0]MOSI , input [7:0]data_in , input write_enable , input read_enable,
 		 output reg [7:0]MISO, output reg [7:0]data_out);

always@(posedge SCLK)
begin
	if(!CS)
	begin
			case({CPOL,CPHA})

			'b00: if(read_enable) data_out = MOSI ;
				
			'b01: if(write_enable) MISO = data_in ;

			'b10: if(read_enable) data_out = MOSI ;

			'b11: if(write_enable) MISO = data_in ;

		
			endcase
	end
end

always@(negedge SCLK)
begin
	if(!CS)
	begin
			case({CPOL,CPHA})

			'b00: if(write_enable) MISO = data_in ;

			'b01: if(read_enable) data_out = MOSI ; 

			'b10: if(write_enable) MISO = data_in ;

			'b11: if(read_enable) data_out = MOSI ;

		
			endcase
	end
end

endmodule
