---------------------------------------------------------------------------------------------------------
--                              Bus_Package.ads                                                        --
--                                                                                                     --
---------------------------------------------------------------------------------------------------------
with text_io,common_types,common_types_busStop,Ada.Numerics.Elementary_Functions,Interfaces.c;
use Ada.Numerics.Elementary_Functions,text_io,common_types,common_types_busStop,Interfaces.c;


package Bus_package is
	type T_direction is (Aller,Retour);
    procedure receivePosition(id_bus:in int;x : in C_float ; y :in C_float;x_last : in C_float ; y_last :in C_float);
    pragma import(C, receivePosition, "receivePosition");
    
    
    procedure arrivedToTerminus(id_bus:in int);
    pragma import(C, arrivedToTerminus, "arrivedToTerminus");
    
    procedure receiveEmergency(num_bus : in int;smessage : in char_array;x : in C_float;y:in C_float);
    pragma import(C, receiveEmergency, "receiveEmergency");
    
    task  type Bus (num_bus : integer;bus_line : ptrT_Line) is
        entry start;
        entry stop;
        entry changeLine(new_line : in ptrT_line);
        entry restart;
        entry changeDirection;
        entry receiveTimeDelay(delay_time : in float);
        entry sendBusPosition(num_bus : in integer ; position : in T_Position);
        entry sendEmergencyCall(num_bus : in integer;emergency : in string);
    end Bus;
        
end Bus_package;