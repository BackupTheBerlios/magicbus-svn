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
    
    --/***********************************************************************************************************/
    --/**********************************Speed_Control************************************************************/
    --/***********************************************************************************************************/      
    protected Speed_Control is
        entry ACCELERATE;
        entry DECELERATE;
        entry START;
        entry STOP;
        procedure ReturnSpeed (current_speed : out integer);
        private
           speed : integer:=0;
    end Speed_Control;
    
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
    --/******************************************Driver***********************************************************/
    --/***********************************************************************************************************/
    protected Driver is
        procedure changeLine(new_line : in integer);
        procedure changeDirection;
        entry setListBusStop(listBusStop : in T_busStopList);
        entry calculateSpeed(delay_time:in float);
        private
             direction : T_direction;
             id_line:integer:=1;
    end Driver;
   
    protected  body Driver is
        
        procedure changeLine (new_line : in integer)is
        begin
            id_line:= new_line;
        end changeLine;
            
        procedure changeDirection is
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
                --listOfBusStop(K):=listBusStop(K);
                put_line("ok");
            end loop;
        end setListBusStop;
                
        entry calculateSpeed(delay_time:in float) when id_line=1 is
        begin
                            put_line("calculatespeed");
                            Speed_Control.START;
                            if (delay_time<0.0)then
                                Speed_Control.ACCELERATE;
                            else
                                Speed_Control.DECELERATE;
                            end if;
                    end calculateSpeed;
            
            end Driver;
    
    
    --/***********************************************************************************************************/  
    --/***********************************************Radio du bus************************************************/
    --/***********************************************************************************************************/
    task Radio is
        entry receiveTimeDelay(timeDelay : in Float);
        entry sendBusPosition (position : in T_position);
        entry sendEmergencyCall(emergency : in string);
    end Radio;
    
    task body Radio is  
   
        --/************* Channel standard ***********/
        protected StandardChannel is
            procedure sendBusPosition(position : in T_Position);
            procedure receiveTimeDelay (delay_time : in float);
        end StandardChannel;
    
        protected body StandardChannel is
            procedure sendBusPosition(position : in T_Position) is
            begin
                put_line("envoie de ma position ");
                Radio.sendBusPosition(position);
                --appel a la radio du centre

            end sendBusPosition;
            
            procedure receiveTimeDelay (delay_time : in float) is
            begin
                Driver.calculateSpeed(delay_time);
            end receiveTimeDelay ;
        end StandardChannel;
        
        --/************* Channel d'urgence ***********/
        protected EmergencyChannel is
            procedure sendEmergencyCall(emergency : in string);
        end EmergencyChannel;
    
        protected body EmergencyChannel is
            procedure sendEmergencyCall(emergency : in string) is
            begin
                put_line("envoie d'un message d'urgence ");
                Radio.sendEmergencyCall(emergency);
                --appel a la radio du centre pour qu'il le reçoive...
            end sendEmergencyCall;
        end EmergencyChannel;
        
    begin
        loop   
            select
                accept sendEmergencyCall(emergency : in string) do
                    Bus.sendEmergencyCall(emergency);
                end sendEmergencyCall;
            or 
                accept sendBusPosition (position : in T_Position) do
                    Bus.sendBusPosition(position);    
                end sendBusPosition;
            or
                accept receiveTimeDelay(timeDelay : in Float) do
                    StandardChannel.receiveTimeDelay(timeDelay);
                end receiveTimeDelay;
            end select;
            
        end loop;
    end Radio;     
       
    
    --/***********************************************************************************************************/  
    --/**********************************************Bus odometer*************************************************/
    --/***********************************************************************************************************/
    protected Odometer is       
        procedure returnDistance(distance:out float) ;
        procedure raz;
    private
           covered_distance : float;
           cycleTime:float:=20.0;
           procedure update;
    end Odometer; 
    
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
            speed : integer;
        begin
            Speed_Control.returnSpeed(speed);
            covered_distance:=covered_distance + cycleTime * float(speed)/3.6;
        end update;
        
    end Odometer; 
    
    --/***********************************************************************************************************/  
    --/*********************************************Bus controller************************************************/
    --/***********************************************************************************************************/
    task Bus_Controller is  
   
    end Bus_Controller;    
    
    task body Bus_Controller is  
        busPosition : T_Position;
        
        procedure calculatePosition(old_position:in T_Position;distance:in float;new_position:out T_Position);    
              
        procedure calculatePosition(old_position:in T_Position;distance:in float;new_position:out T_Position) is
        begin
            new_position.x:=old_position.x + 5;
            new_position.y:=old_position.y + 5;
        end calculatePosition;
        
        Seconde : constant duration := 1.0;
        distance : float;
        new_position : T_Position;
    begin      
        loop
            delay(5*Seconde);
            Odometer.returnDistance(distance);
            calculatePosition(busPosition,distance,new_position);
            busPosition:=new_position;
       end loop; 
    end Bus_Controller;    
begin 
    Put_line("on demarre le bus");   
	loop
        select
            accept sendEmergencyCall(emergency : in string) do
                put_line("envoi d'un message d'urgence bus");
                --appel à la radio du centre
            end sendEmergencyCall;
        or
            accept sendBusPosition(position : in T_position) do
                put_line("envoi de la position du bus");
                --appel à la radio du centre
            end sendBusPosition;
        or
            accept receiveTimeDelay(delay_time : in float) do
                Radio.receiveTimeDelay(delay_time);
            end receiveTimeDelay;
        or
            accept changeLine(id_line : in integer) do
                Driver.changeLine(id_line);
            end changeLine;    
        or
            accept changeDirection do
                Driver.changeDirection;
            end changeDirection; 
        end select;
    end loop; 
 end Bus; 
     
     
  
     
  
     
     


  

 
 
    
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