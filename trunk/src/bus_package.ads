---------------------------------------------------------------------------------------------------------
--                              Bus_Package.ads                                                        --
--                                                                                                     --
---------------------------------------------------------------------------------------------------------
with text_io,common_types,Ada.Numerics.Elementary_Functions;
use Ada.Numerics.Elementary_Functions,text_io,common_types;


package Bus_package is
	type T_direction is (Aller,Retour);
    
    task  type Bus is
        entry changeLine(id_line : in integer);
        entry changeDirection;
        entry receiveTimeDelay(delay_time : in float);
        entry sendBusPosition(position : in T_Position);
        entry sendEmergencyCall(emergency : in string);
        
    end Bus;
        
end Bus_package;