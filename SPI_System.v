module SPI_System #(parameter T = 10)
          			     (input enable, input [1:0]mode_select, input [1:0]slave_select, input [1:0]read_write_enable,

 				      input [7:0]Master_To_Slave_Data, input [7:0]Slave_To_Master_Data,

				      output [7:0]Master_Read_Output, output [7:0]Slave_Read_Output);

//This validation is to ensure that if mode_select changes illegally (when enable is active) no invalid effects happen
//We do this for the slave , the Master does it's own validation
wire Slave_CPOL = (!enable) ? mode_select[1] : Slave_CPOL ;
wire Slave_CPHA = (!enable) ? mode_select[0] : Slave_CPHA ;

//wiring to relay the output of the master to slaves
wire [7:0]MOSI ;
wire [7:0]MISO ;
wire SCLK ;
//3bit bus because 3 CS wires from the master
wire [2:0] CSs ;




			 //Control Buses and other flags
SPI_Master#(T/2) Master( .communication_flag(enable) , .address(slave_select) , .cpol(mode_select[1]) , .cpha(mode_select[0]) ,
			 .read_enable(read_write_enable[0]) , .write_enable(read_write_enable[1]) , 

			 //Data buses
			 .data_in(Master_To_Slave_Data) , .MOSI(MOSI) , 
			 .MISO(MISO) 			, .data_out(Master_Read_Output)  , 

			 //Synchronication and select signals
			 .SCLK(SCLK) , .CS1(CSs[0]) , .CS2(CSs[1]) , .CS3(CSs[2]) ); 





//a ternary operator mux that connects the MISO of the correct slave to the MISO of master	
wire [7:0]Slave1_MISO ;
wire [7:0]Slave2_MISO ;
wire [7:0]Slave3_MISO ;
//Multiple assignments to the same wire in this manner are OK
//Becuase only one of the condition will be true at any given time 
//So only on actual value will be written to MISO , other values are "'bz" s with low strength so they will be drowned by the actual value
assign 	MISO = (slave_select == 0)? Slave1_MISO : 'bz ;
assign  MISO = (slave_select == 1)? Slave2_MISO : 'bz ;
assign  MISO = (slave_select == 2)? Slave3_MISO : 'bz ;
//same thing for the read output 
wire [7:0]Slave1_Read_Output ;
wire [7:0]Slave2_Read_Output ;
wire [7:0]Slave3_Read_Output ;
assign 	Slave_Read_Output = (slave_select == 0)? Slave1_Read_Output : 'bz ;
assign  Slave_Read_Output = (slave_select == 1)? Slave2_Read_Output : 'bz ;
assign  Slave_Read_Output = (slave_select == 2)? Slave3_Read_Output : 'bz ;


SPI_Slave Slave1( .SCLK(SCLK), .CS(CSs[0]) , .CPOL(Slave_CPOL) , .CPHA(Slave_CPHA) ,
		  .read_enable(read_write_enable[1]) , .write_enable(read_write_enable[0]),

		  .data_in(Slave_To_Master_Data), .MISO(Slave1_MISO),
	   	  .data_out(Slave1_Read_Output)  , .MOSI(MOSI) );


SPI_Slave Slave2( .SCLK(SCLK), .CS(CSs[1]) , .CPOL(Slave_CPOL) , .CPHA(Slave_CPHA) ,
		  .read_enable(read_write_enable[1]) , .write_enable(read_write_enable[0]),

		  .data_in(Slave_To_Master_Data), .MISO(Slave2_MISO),
	   	  .data_out(Slave2_Read_Output)  , .MOSI(MOSI) );

SPI_Slave Slave3( .SCLK(SCLK), .CS(CSs[2]) , .CPOL(Slave_CPOL) , .CPHA(Slave_CPHA) ,
		  .read_enable(read_write_enable[1]) , .write_enable(read_write_enable[0]),

		  .data_in(Slave_To_Master_Data), .MISO(Slave3_MISO),
	   	  .data_out(Slave3_Read_Output)  , .MOSI(MOSI) );







endmodule 