module address_fsm (clk, get_new_addr,start_addr,end_addr,new_addr_ready_in,need_new_addr_out, address, new_addr_out);

		input  clk, get_new_addr;
		input new_addr_ready_in;
		input [23:0] start_addr;
		input [23:0] end_addr;		

		output logic [23:0] address;
		output logic new_addr_out;
		output reg need_new_addr_out=1'b0;

		logic [2:0] state;
		reg [5:0]counter=6'b000000;

		parameter idle           				= 3'b000;
		parameter Address_Increment 			= 3'b001;
		parameter Get_New_Addr			         = 3'b010;
		parameter Wait_and_Check				= 3'b011;
		parameter Finish     					= 3'b100;
		always_ff @ (posedge clk ) begin					
		 
			case(state)
				
				idle: if(get_new_addr) state <= Address_Increment; 
				else state <= idle;			
				
				Address_Increment:begin
				if(address == end_addr) begin
				  need_new_addr_out=1; //address gets to the end. tell picoblaze that new address is needed
				  state <= Get_New_Addr; end 
				else begin
				  address = address+1; 
				  state <=Finish; end
				end 
				
				Get_New_Addr:begin                           
				if(new_addr_ready_in) begin //If picoblaze indicates that new address is ready, start reading
					need_new_addr_out=0;	
					state<=Wait_and_Check; end
				else begin				
					need_new_addr_out=1;
					state<=Get_New_Addr; end
				end

				Wait_and_Check:begin
				address= start_addr;
				if(counter==6'b111111) begin
					counter=6'b0;		
					state<=Finish; end
				else begin
					state<=Wait_and_Check;	
                    counter=counter + 1; end
				end				

				Finish: begin new_addr_out=1;
				        state <= idle;	end	 
				 
				default: state <= idle;
				
				endcase
			
		end
		
	endmodule
		