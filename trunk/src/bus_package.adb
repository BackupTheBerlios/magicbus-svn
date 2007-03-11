---------------------------------------------------------------------------------------------------------
--                              Bus_Package.adb                                                        --
--                                                                                                     --
---------------------------------------------------------------------------------------------------------


with text_io,common_types,common_types_busStop,Ada.Numerics.Elementary_Functions,busstop_package ;
use Ada.Numerics.Elementary_Functions,text_io,common_types,common_types_busStop,busstop_package ;

package body Bus_package is
 
task body Bus is
    id_bus : integer := num_bus;
    line : T_Line:= bus_line.all;
	Seconde : constant duration := 1.0;
    position : T_Position;
    lastBusStopCapted : ptrT_busStopRecord;
    nextBusStop : ptrT_busStopRecord;
    indice_busStop : integer := 1;
    IS_ARRIVED_BUSSTOP : boolean := false;
    
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
        procedure changeLine(new_line : in ptrT_line);
        procedure changeDirection;
        procedure setListBusStop(listBusStop : in T_busStopList);
        procedure calculateSpeed(delay_time:in float);
        private
             direction : T_direction:=Aller;
    end Driver;
   
    protected  body Driver is
        
        procedure changeLine (new_line : in ptrT_line)is
        begin
           Bus.line:=new_line.all;
        end changeLine;
            
        procedure changeDirection is
        begin
            if(direction = Aller) then
                direction:= Retour;
                put_line("changement de direction : sens = Retour"); 
            else
                direction:= Aller;
                put_line("changement de direction : sens = Aller"); 
            end if;

        end changeDirection;
                
        procedure setListBusStop(listBusStop : in T_busStopList) is
        begin
            for K in 1..50 loop
                --listOfBusStop(K):=listBusStop(K);
                put_line("ok");
            end loop;
        end setListBusStop;
                
        procedure calculateSpeed(delay_time:in float) is
        begin
                            put_line("calculatespeed");
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
        entry sendBusPosition (num_bus : in integer; position : in T_position);
        entry sendEmergencyCall(num_bus : in integer; emergency : in string);
    end Radio;
    
    task body Radio is  
   
        --/************* Channel standard ***********/
        protected StandardChannel is
            procedure sendBusPosition(num_bus : in integer; position : in T_Position);
            procedure receiveTimeDelay (delay_time : in float);
        end StandardChannel;
    
        protected body StandardChannel is
            procedure sendBusPosition(num_bus : in integer; position : in T_Position) is
            begin
                put("envoie position bus numero ");put_line(integer'image(num_bus));
                Bus.sendBusPosition(num_bus,position);
                --appel a la radio du centre

            end sendBusPosition;
            
            procedure receiveTimeDelay (delay_time : in float) is
            begin
                Driver.calculateSpeed(delay_time);
            end receiveTimeDelay ;
        end StandardChannel;
        
        --/************* Channel d'urgence ***********/
        protected EmergencyChannel is
            procedure sendEmergencyCall(num_bus : in integer; emergency : in string);
        end EmergencyChannel;
    
        protected body EmergencyChannel is
            procedure sendEmergencyCall(num_bus : in integer; emergency : in string) is
            begin
                put_line("envoie d'un message d'urgence ");
                Bus.sendEmergencyCall(num_bus,emergency);
                --appel a la radio du centre pour qu'il le reçoive...
            end sendEmergencyCall;
        end EmergencyChannel;
        
    begin
        loop   
            select
                accept sendEmergencyCall(num_bus : in integer; emergency : in string) do
                    EmergencyChannel.sendEmergencyCall(num_bus,emergency);
                end sendEmergencyCall;
            or 
                accept sendBusPosition (num_bus : in integer;position : in T_Position) do
                    StandardChannel.sendBusPosition(num_bus,position);    
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
    task Odometer is       
        entry returnDistance(distance:out float) ;
        entry raz;
    
    end Odometer; 
    
    task body Odometer is
        covered_distance : float:=0.0;
        cycleTime : constant duration := 2.0;
        procedure update; 
        
        procedure update is
            speed : integer;
        begin
            Speed_Control.returnSpeed(speed);
            covered_distance:=covered_distance + float(cycleTime) * float(speed)/3.6;
            put("distance parcourue : ");put_line(float'image(covered_distance));
            
        end update;
        
    begin
        loop
            select
                accept returnDistance(distance : out float) do
                    distance:=covered_distance;
                end returnDistance;
            or
                accept raz do
                    covered_distance:=0.0;
                    put_line("remise à zero de la distance parcourue!");
                end raz;
            else
                delay(cycleTime);
                update;
            end select;
        end loop; 
       
    end Odometer; 
    
    --/***********************************************************************************************************/  
    --/*********************************************Bus controller************************************************/
    --/***********************************************************************************************************/
    task Bus_Controller is  
   
    end Bus_Controller;    
    
    task body Bus_Controller is  

        procedure calculatePosition(distance:in float);    
              
        procedure calculatePosition(distance:in float) is
        begin
            position.x:=position.x + 5;
            position.y:=position.y + 5;
            put_line("nouvelle position calculee");
            Radio.sendBusPosition (id_bus,position);
        end calculatePosition;
        
        Seconde : constant duration :=2.0;
        distance : float;
    begin   
        loop
            delay(Seconde);
            Odometer.returnDistance(distance);
            calculatePosition(distance);
       end loop; 
    end Bus_Controller;
    
    
    --/***********************************************************************************************************/  
    --/************************************************ Sensor ***************************************************/
    --/***********************************************************************************************************/
    task Sensor is
        
    end Sensor;
    
    task body Sensor is
    begin
        loop     
            Bus.appelerEmit;
        end loop;
    end Sensor;
        
begin 
    Put_line("on demarre le bus");   
    position.x:=0;
    position.y:=0;
    lastBusStopCapted := null;
    nextBusStop := line.busStop_List(1);
    Speed_Control.START;
	loop
        select
            accept sendEmergencyCall(num_bus : in integer; emergency : in string) do
                put_line("envoi d'un message d'urgence bus");
                --appel à la radio du centre
            end sendEmergencyCall;
        or
            accept sendBusPosition(num_bus : in integer; position : in T_position) do
                put_line("envoi de la position du bus");
                --appel à la radio du centre
            end sendBusPosition;
        or
            accept receiveTimeDelay(delay_time : in float) do
                Radio.receiveTimeDelay(delay_time);
            end receiveTimeDelay;
        or
            accept changeLine(new_line : in ptrT_line) do
                Driver.changeLine(new_line);
            end changeLine;    
        or
            accept changeDirection do
                Driver.changeDirection;
            end changeDirection; 
        or
            accept appelerEmit do
                nextBusStop.busStop.emit(position,IS_ARRIVED_BUSSTOP);
                if (IS_ARRIVED_BUSSTOP) then
                    --arret du bus à l'arret
                    Speed_control.STOP;
                    --mise à jour du prochain arret à faire
                    lastBusStopCapted:=nextBusStop;
                    indice_busStop:=indice_busStop+1;
                    nextBusStop:=line.busStop_List(indice_busStop);
                    --simulation de la montée des voyageurs
                    delay(2.0);
                    --remise a zero de la distance parcourue
                    Odometer.raz;
                    --on redémarre le bus
                    Speed_control.START;
                    IS_ARRIVED_BUSSTOP:=false;
                end if;
            end appelerEmit;
        end select;
    end loop; 
 end Bus; 
end Bus_package;