---------------------------------------------------------------------------------------------------------
--                              Bus_Package.adb                                                        --
--                                                                                                     --
---------------------------------------------------------------------------------------------------------


with text_io,common_types,common_types_busStop,Ada.Numerics.Elementary_Functions,busstop_package ;
use Ada.Numerics.Elementary_Functions,text_io,common_types,common_types_busStop,busstop_package ;

package body Bus_package is
    package REEL_ES is new Float_Io(Float); use REEL_ES;
    
task body Bus is
    id_bus : integer := num_bus;
    line : T_Line:= bus_line.all;
	Seconde : constant duration := 1.0;
    --position courante du bus
    position : T_Position;
    --dernier arret auxquel on s'est arreté et sa position
    lastBusStopCapted : ptrT_busStopRecord := null;
    position_last : T_Position;
    --prochain arret auxquel on doit arreté et sa position
    nextBusStop : ptrT_busStopRecord := line.busStop_List(1);
    position_next : T_Position;
    --distance entre les deux arrets (dernier et suivant)
    distanceBetweenBusStop : float;
    --indice de l'arret dans le tableau des arrets de la ligne
    indice_busStop : integer := 1;

    -- ******************************************
    -- Déclaration des taches et objets protégés
    -- ******************************************
    
    
    -- ************* Driver ************* 
    -- Cet objet permet au bus de recalculer sa vitesse suivant le temps 
    -- d'avance ou de retard renvoyé par le centre, de modifier le sens 
    -- du trajet (aller ou retard)... 
    -- **********************************
    protected Driver is
        procedure changeLine(new_line : in ptrT_line);
        procedure changeDirection;
        procedure setListBusStop(listBusStop : in T_busStopList);
        procedure calculateSpeed(delay_time:in float);
        private
             direction : T_direction:=Aller;
    end Driver;
   
    
    --************ Speed_Control ************ 
    -- Cet objet permet de controler la vitesse du bus
    -- Ses entry sont surtout appelées par le driver  
    -- ************************************** 
    protected Speed_Control is
        entry ACCELERATE;
        entry DECELERATE;
        entry START;
        entry STOP;
        procedure ReturnSpeed (current_speed : out integer);
        private
           speed : integer:=0;
    end Speed_Control;
    
   
    --************* Radio ************* 
    -- Composée de 2 sous-taches (standardchannel et emergnecyChannel
    -- Le emergencyChannel est reservé à l'envoi de message d'urgence en cas d'accident,...
    -- Le standardChannel permet de recevoir le temps d'avance ou de retard de la part du centre
    -- ainsi que d'envoyer régulièrement sa position courante au centre
    --********************************* 
    task Radio is
        entry receiveTimeDelay(timeDelay : in Float);
        entry sendBusPosition (num_bus : in integer; position : in T_position);
        entry sendEmergencyCall(num_bus : in integer; emergency : in string);
    end Radio;
    
    
    -- ************* Bus Odometer *************
    -- L'odometre permet de renvoyer la distance parcourue
    -- La distance parcourue est remise à zero a chaque fois 
    -- qu'on s'arrete à un arret de bus
    -- ****************************************  
    task Odometer is       
        entry returnDistance(distance:out float) ;
        entry raz;
    end Odometer; 
    
    -- ************* Bus Controller ************* 
    -- ****************************************** 
    task Bus_Controller is  
   
    end Bus_Controller;    
    
    
    -- ************* Sensor *************
    -- A chaque fois que la position courante sera calculée,
    -- le sensor appelera l'entry emit du prochain arret de bus 
    -- pour savoir s'il est à proximité ou non
    -- si c'est le cas, il s'arrête
    -- ********************************** 
    task Sensor is
        entry TestBusStop(position : in T_Position);
    end Sensor;
    
    -- **********************************************
    -- Fin Déclaration des taches et objets protégés
    -- **********************************************
    
    
    -- ******************************************************
    -- declaration du corps des objets protegés et des taches
    -- ******************************************************
    
    -- ***************************************
    -- *************Speed_Control*************  
    -- ***************************************  
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

    
    
    -- **********************************
    -- ************* Driver ************* 
    -- **********************************
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
    
    -- *********************************
    -- ************* Radio ************* 
    -- *********************************
    task body Radio is  
   
        --************* Channel standard ***********
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
        
        --************* Channel d'urgence ***********
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
       
    
    -- ****************************************
    -- ************* Bus Odometer *************
    -- **************************************** 
    task body Odometer is
        covered_distance : float:=0.0;
        cycleTime : constant duration := 2.0;
        procedure update; 
        
        procedure update is
            speed : integer;
        begin
            Speed_Control.returnSpeed(speed);
            covered_distance:=covered_distance + float(cycleTime) * float(speed)/3.6;
            put("distance parcourue : ");Put(covered_distance,4,3,0);New_line;        
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
    
    
    -- ******************************************
    -- ************* Bus Controller ************* 
    -- ******************************************
    task body Bus_Controller is  

        procedure calculatePosition(distance:in float);    
              
        procedure calculatePosition(distance:in float) is
            rapport : float;
        begin
            --on suppose qu'une unité de position = 10 m
            rapport := (distance/10.0)/distanceBetweenBusStop;
            position.x:=position_last.x + rapport*(position_next.x - position_last.x);
            position.y:=position_last.y + rapport*(position_next.y - position_last.y);
            put_line("nouvelle position calculee ");
            Sensor.TestBusStop(position);
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
    
    
    -- **********************************
    -- ************* Sensor ************* 
    -- **********************************
    task body Sensor is
        IS_ARRIVED_BUSSTOP : boolean := false;
    begin
        loop     
            accept TestBusStop(position : in T_Position) do
                nextBusStop.busStop.emit(position,IS_ARRIVED_BUSSTOP);
                if (IS_ARRIVED_BUSSTOP) then
                        --arret du bus à l'arret
                        Speed_control.STOP;
                        --mise à jour du prochain arret à faire
                        lastBusStopCapted:=nextBusStop;
                        indice_busStop:=indice_busStop+1;
                        nextBusStop:=line.busStop_List(indice_busStop);
                        lastBusStopCapted.busStop.returnPositionBusStop(position_last);
                        nextBusStop.busStop.returnPositionBusStop(position_next);
                        distanceBetweenBusStop := sqrt((position_last.x-position_next.x)**2 + (position_last.y-position_next.y)**2);
                        --simulation de la montée des voyageurs
                        delay(2.0);
                        --remise a zero de la distance parcourue
                        Odometer.raz;
                        --on redémarre le bus
                        Speed_control.START;
                        IS_ARRIVED_BUSSTOP:=false;
                end if;
            end TestBusStop;
        end loop;
    end Sensor;
    
    -- **********************************************************
    -- fin declaration du corps des objets protegés et des taches
    -- **********************************************************
    
begin 
    Put_line("on demarre le bus");   
    position.x := 0.0;
    position.y := 0.0;
    position_last.x := 0.0;
    position_last.y := 0.0;
    nextBusStop.busStop.returnPositionBusStop(position_next);
    -- calcul de la distance initiale entre le depart et le prochain arret de bus
    -- la distance entre 2 points de coordonnées (x1,y1) et (x2,y2)
    -- est = racine_carree((x1-x2)² + (y1-y2)²)
    distanceBetweenBusStop := sqrt((position.x-position_next.x)**2 + (position.y-position_next.y)**2);
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

        end select;
    end loop; 
 end Bus; 
end Bus_package;