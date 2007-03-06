---------------------------------------------------------------------------------------------------------
--                              Bus_Package.ads                                                        --
--                                                                                                     --
---------------------------------------------------------------------------------------------------------
with text_io,common_types,Ada.Numerics.Elementary_Functions;
use Ada.Numerics.Elementary_Functions,text_io,common_types;


package Bus_package is
	type T_direction is (Aller,Retour);
    
    task  type Bus is
        --entry changeLine(id_line : in integer);
        --entry changeDirection;
        entry receiveTimeDelay(delay_time : in float);
        entry sendBusPosition(position : in T_Position);
        entry sendEmergencyCall(emergency : in string);
        
    end Bus;
        
                    
       
   
    
    --/***********************************************************************************************************/  
    --/**********************************************Bus odometer*************************************************/
    --/***********************************************************************************************************/
    protected type Odometer is       
        procedure returnDistance(distance:out float) ;
        procedure raz;
    private
           covered_distance : float;
           cycleTime:integer:=20;
           procedure update;
    end Odometer; 
    
    type ptr_odom is access Odometer;  
       
    --/***********************************************************************************************************/  
    --/*********************************************Bus controller************************************************/
    --/***********************************************************************************************************/
    --task type Bus_Controller is       
    --       procedure CalulatePosition(old_position:in T_Position;distance:in float;new_position:out T_Position) ;
    --      busPosition : T_Position;
    --        odom : ptr_odom:=new Odometer;
    --        distance : float;
    --        new_position : T_Position;
    --end Bus_Controller;    
    

end Bus_package;