---------------------------------------------------------------------------------------------------------
--                              Bus_Package.ads                                                        --
--                                                                                                     --
---------------------------------------------------------------------------------------------------------
with text_io,common_types,common_types_busStop,Ada.Numerics.Elementary_Functions;
use Ada.Numerics.Elementary_Functions,text_io,common_types,common_types_busStop;


package Bus_package is
	type T_direction is (Aller,Retour);
    
    task  type Bus (num_bus : integer;bus_line : ptrT_Line) is
--        (bus_line : ptrT_Line)
        entry changeLine(new_line : in ptrT_line);
        entry changeDirection;
        entry receiveTimeDelay(delay_time : in float);
        entry sendBusPosition(num_bus : in integer ; position : in T_Position);
        entry sendEmergencyCall(num_bus : in integer;emergency : in string);
    end Bus;
        
end Bus_package;