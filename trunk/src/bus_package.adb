---------------------------------------------------------------------------------------------------------
--                              Bus_Package.adb                                                        --
--                                                                                                     --
---------------------------------------------------------------------------------------------------------


with text_io,common_types,Ada.Numerics.Elementary_Functions;
use Ada.Numerics.Elementary_Functions,text_io,common_types;

package body Bus_package is

task body Bus is
    id_line : integer;
    listOfBusStop : T_busStopList;
	  Seconde : constant duration := 1.0;
begin 
	Put("on demarre");
	loop
		delay(5*Seconde);
    end loop; 
 end Bus; 
     
     
--/***********************************************************************************************************/  
--/******************************************Driver***********************************************************/
--/***********************************************************************************************************/  
     
  protected  body Driver is 
        
        entry changeLine (new_line : in integer)when  id_line=1 is
            begin
                id_line:= new_line;
            end changeLine;
      
        entry changeDirection when  id_line=1 is
            begin
                if(direction = Aller) then
                    direction:= Retour;
                else
                    direction:= Retour;
                end if;
            end changeDirection;
        
    
        entry setListBusStop(listBusStop : in T_busStopList) when  id_line=1 is
           begin
            for K in 1..50 loop
         --       listOfBusStop(K):=listBusStop(K);
         		put_line("ok");
            end loop;
        end setListBusStop;
        
        entry calculateSpeed(delay_time:in float) when id_line=1 is
              begin
              		put_line("calculatespeed");
              		sc_ptr.START;
            		if (delay_time<0.0)then
            			sc_ptr.ACCELERATE;
            		else
            			sc_ptr.DECELERATE;
            		end if;
            end calculateSpeed;
       
     end Driver;
     
     
--/***********************************************************************************************************/
--/**********************************Speed_Control************************************************************/
--/***********************************************************************************************************/  
     

  protected body Speed_Control is 
        entry ACCELERATE when speed < 50 is
        begin
         speed:=speed + 5;
         put("speed : ") ;
         put_line(integer'image(speed));
       end ACCELERATE;
        
      entry DECELERATE when speed > 5 is
     begin
         speed:=speed - 5;
         put("speed : ") ;
         put_line(integer'image(speed));
       end DECELERATE;
        
      entry START when speed = 0 is
     	begin
         speed:=25;
            put("speed : ") ;
         put_line(integer'image(speed));
       end START;
        
      entry STOP when speed > 0 is
      begin
         put_line("arret du bus ...");
         while(speed > 0) loop
             speed:= speed - 5;
                put("speed : ") ;
             put_line(integer'image(speed));
           end loop;       
      end STOP;
     
      procedure ReturnSpeed (current_speed : out integer) is
        begin
         current_speed := speed;
       end ReturnSpeed;
  end Speed_Control;

    --/***********************************************************************************************************/  
    --/***********************************************Radio du bus************************************************/
    --/***********************************************************************************************************/
    protected body Radio is       
        procedure receiveTimeDelay(timeDelay : in Float) is
        begin
              driver_ptr.calculateSpeed(timeDelay);  
        end receiveTimeDelay;
    end Radio;     
       
    --/***********************************************************************************************************/  
    --/**********************************************Bus odometer*************************************************/
    --/***********************************************************************************************************/
    protected body Odometer is       
        procedure returnDistance(distance:out float) is
        begin
            distance:=covered_distance;
        end returnDistance;
        procedure raz is
        begin
            covered_distance:=0.0;
        end raz;
        
        procedure update is
        begin
            --calcul a faire ne fonction de la vitesse
            covered_distance:=covered_distance + 5.0;
        end update;
    end Odometer; 
    
    --/***********************************************************************************************************/  
    --/*********************************************Bus controller************************************************/
    --/***********************************************************************************************************/
    --protected body Bus_Controller is  
    --    procedure calculatePosition(old_position:in T_Position;distance:in float;new_position:out T_Position) is
    --    begin
    --        new_position.x:=old_position.x + 5;
    --        new_position.y:=old_position.y + 5;
    --    end calculatePosition;
    --    Seconde : constant duration := 1.0;
    --begin      
    --    loop
    --        delay(5*Seconde);
    --        odom.returnDistance(distance);
    --        calculatePosition(busPosition,distance,new_position);
    --        busPosition:=new_position;
    --   end loop; 
    --end Bus_Controller;    
    
  
    
    
    
    
end Bus_package;