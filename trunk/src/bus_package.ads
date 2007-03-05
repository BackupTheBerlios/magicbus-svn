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
    
    
    type ptr_driver is access Driver;
    --/***********************************************************************************************************/  
    --/***********************************************Radio du bus************************************************/
    --/***********************************************************************************************************/
    protected type Radio is       
        procedure receiveTimeDelay(timeDelay : in Float);  
        private
            driver_ptr : ptr_driver:=new Driver;   
    end Radio;   
    
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