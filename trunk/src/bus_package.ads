---------------------------------------------------------------------------------------------------------
--                              Bus_Package.ads                                                        --
--                                                                                                     --
---------------------------------------------------------------------------------------------------------
with text_io,common_types,Ada.Numerics.Elementary_Functions;
use Ada.Numerics.Elementary_Functions,text_io,common_types;


package Bus_package is
	type T_direction is (Aller,Retour);

    task  type Bus is
    
    end Bus;
        
        protected type Speed_Control is
      		entry ACCELERATE;
      		entry DECELERATE;
	       entry START;
	       entry STOP;
      		procedure ReturnSpeed (current_speed : out integer);
  			private
       			speed : integer:=0;
   		end Speed_Control;                 
    
    		 type ptr_sc is access Speed_Control;
       
        protected type Driver is
            entry changeLine(new_line : in integer);
            entry changeDirection;
            entry setListBusStop(listBusStop : in T_busStopList);
            entry calculateSpeed(delay_time:in float);
            private
       			  direction : T_direction;
       			  sc_ptr : ptr_sc:=new Speed_Control;
       			  id_line:integer:=1;
        end Driver;
        
        
       
    
end Bus_package;