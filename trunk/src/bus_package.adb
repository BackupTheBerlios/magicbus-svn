---------------------------------------------------------------------------------------------------------
--                              Bus_Package.adb                                                        --
--                                                                                                     --
---------------------------------------------------------------------------------------------------------


with text_io,common_types,common_types_busStop,Ada.Numerics.Elementary_Functions,Ada.Calendar;
use Ada.Numerics.Elementary_Functions,text_io,common_types,common_types_busStop,Ada.Calendar;

package body Bus_package is
    package REEL_ES is new Float_Io(Float); use REEL_ES;
    
task body Bus is
    id_bus : integer := num_bus;
    line : T_Line:= bus_line.all;
	--Seconde : constant duration := 1.0;
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
    distance_restante : float;
    --indice de l'arret dans le tableau des arrets de la ligne
    indice_busStop : integer := 1;
    
    speed:integer:=0;
    covered_distance : float:=0.0;
    
    --unite graphique
    unite_graph:float:=10.0;

    -- ******************************************
    -- procédure permettant d'inverser la liste 
    -- des arrets quand le bus fait demi-tour
    -- ******************************************
    procedure inverserListe (list : in out T_busStopList);
    procedure inverserListe (list : in out T_busStopList) is
        j:integer:=1;
        liste_inversee : T_busStopList;
    begin
        for i in list'RANGE loop
            if (list(list'LAST - i + list'FIRST) /= null) then
                liste_inversee(j) := list(list'LAST -i + list'FIRST);
                j:=j+1;
            end if;
        end loop;
        list:=liste_inversee;
        --quand on fait demi-tour, le dernier arret capté est le terminus. 
        -- c'est aussi le point de départ du bus dans l'autre sens
        lastBusStopCapted := nextBusStop;
        indice_busStop:=2;
        nextBusStop:=list(2);
    end inverserListe ;
      
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
        procedure restart;
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
    private
        debut,
        fin,
        duree : duration;
        distance_restante : float;
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
        entry restart;
    end Radio;
    
    
    -- ************* Bus Odometer *************
    -- L'odometre calcule toutes les secondes 
    -- la distance parcourue et la nouvelle position
    -- ****************************************  
    task Odometer is       
        
    end Odometer; 
    
    -- ************* Bus Controller ************* 
    -- Il dispose d'un temps de cycle. A chaque 
    -- cycle il enverra la position du bus au 
    -- centre via la radio.
    -- ****************************************** 
    task Bus_Controller is  
   
    end Bus_Controller;    
    
    
    -- ************* Sensor *********************
    -- A chaque fois que la position courante sera 
    -- calculée (toutes les secondes), le sensor
    -- testera s'il est près de son prochain arret 
    -- de bus et effectuera le traitement en conséquence
    -- ****************************************** 
    task Sensor is
        
    end Sensor;
    
    -- **********************************************
    -- Fin Déclaration des taches et objets protégés
    -- **********************************************
    
 
    
    -- ******************************************************
    -- declaration du corps des objets protegés et des taches
    -- ******************************************************
    
    
    -- **********************************
    -- ************* Driver ************* 
    -- **********************************
    protected  body Driver is
        
        procedure changeLine (new_line : in ptrT_line)is
        begin
           Bus.line:=new_line.all;
        end changeLine;

        procedure restart is
            
        begin
            --la procedure restart doit donner la nouvelle ligne au bus et le faire démarrer...
           --Bus.line:=new_line.all;
            covered_distance := 0.0;
            distance_restante := 0.0;
            nextBusStop:=line.busStop_List(2);
            lastBusStopCapted:=line.busStop_List(1);
            --put_line("RESTART last bus capted"&lastBusStopCapted.busStop.idBusStop);
            nextBusStop.busStop.returnPositionBusStop(position_next);
            lastBusStopCapted.busStop.returnPositionBusStop(position_last);
            distanceBetweenBusStop := sqrt((position_last.x-position_next.x)**2 + (position_last.y-position_next.y)**2)*unite_graph;
            indice_busStop:=1;
            Speed_Control.START;
            
            put("position last (");put(position_last.x);put(position_last.y);put(")");
            put("position next (");put(position_next.x);put(position_next.y);put(")");


        end restart;
        
        
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
                line.BusStop_List(K):= listBusStop(K);
            end loop;
        end setListBusStop;
                
        procedure calculateSpeed(delay_time:in float) is
        begin
            if (delay_time < 0.0 and speed < 50 and distance_restante > 50.0) then
                Speed_Control.ACCELERATE;
            else
                if (delay_time > 0.0 and speed > 0 ) then
                    Speed_Control.DECELERATE;
                end if;
            end if;
        end calculateSpeed;
            
    end Driver;
    
    
    -- ***************************************
    -- *************Speed_Control*************  
    -- ***************************************  
    protected body Speed_Control is 

        entry START when speed = 0 is
            heures : integer range 1..23;
            minutes : Integer range 0 .. 59;
            secondes : integer;
        begin
            debut:= Seconds(Clock);
            heures := Integer (debut) / 3600 ;
            minutes := Integer (debut - Day_Duration ( heures * 3600 )) / 60 ;
            secondes := Integer(debut - Day_Duration ( heures * 3600 )- Day_Duration ( minutes * 60 ));
            
            put_line("*** Depart du bus " &integer'image(id_bus) &" a " &integer'image(heures)&" h" 
                &integer'image(minutes) &" m" &integer'image(secondes) &" s ***");
            speed:=30;
            put("speed = ") ; put_line(integer'image(speed));
        end START;
    
        entry ACCELERATE when speed < 50 is
        begin
            fin:= Seconds(Clock);
            duree:=fin-debut;
            debut:=Seconds(Clock);
           -- Odometer.updateDistance(duree);
            speed:=speed + 5;
            put("acceleration speed = ") ; put_line(integer'image(speed));
        end ACCELERATE;
       
        entry DECELERATE when speed > 0 is
        begin
            fin:= Seconds(Clock);
            duree:=fin-debut;
            debut:=Seconds(Clock);
            --Odometer.updateDistance(duree);
            speed:=speed - 5;
            put("speed : ") ;
            put_line(integer'image(speed));
        end DECELERATE;
          
        entry STOP when speed >= 0 is
        begin
            fin:= Seconds(Clock);
            duree:=fin-debut;
            debut:=Seconds(Clock);
           -- Odometer.updateDistance(duree);
            put ("Arrivée a un arret!! Il reste " );Put(distance_restante,4,3,0); put_line(" metres a parcourir");
            put_line("arret du bus ...");
            speed:=0;   
            put("speed : ") ;put_line(integer'image(speed));
        end STOP;
        
    end Speed_Control;

    
    
  
    -- *********************************
    -- ************* Radio ************* 
    -- *********************************
    task body Radio is  
   
        --************* Channel standard ***********
        protected StandardChannel is
            procedure sendBusPosition(num_bus : in integer; position : in T_Position);
            procedure receiveTimeDelay (delay_time : in float);
            procedure restart;
        end StandardChannel;
    
        protected body StandardChannel is
            procedure sendBusPosition(num_bus : in integer; position : in T_Position) is
            begin
                put("envoie position bus numero ");put_line(integer'image(num_bus));
                Bus.sendBusPosition(num_bus,position);
                --appel a la radio du centre

            end sendBusPosition;
            
            procedure restart is
            begin
                Driver.restart;
                put_line(" #### on passe dans le restart radio standard channel");  
            end restart;
            
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
                --appel a la radio du centre pour qu'il le reçoive...
                receiveEmergency(int(num_bus),to_c(emergency),c_float(position.x),c_float(position.y));
            end sendEmergencyCall;
        end EmergencyChannel;
        
    begin
        loop   
            select
                accept sendEmergencyCall(num_bus : in integer; emergency : in string) do
                    put_line(emergency);
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
            or
                accept restart do
                    StandardChannel.restart;
                    put_line(" #### on passe dans le restart radio");  
                end restart; 
            end select;
            
        end loop;
    end Radio;     
       
    
    -- ****************************************
    -- ************* Bus Odometer *************
    -- **************************************** 
    task body Odometer is
        
        cycleTime : constant duration := 1.0;

        -- ******************************************
        -- procédure permettant de calculer la distance
        -- parcourue et la nouvelle position du bus
        -- ******************************************
        procedure update(cycle_time : in integer); 
        
        procedure update(cycle_time : in integer) is
            rapport : float;
        begin
            covered_distance:=covered_distance + float(cycle_time) * float(speed)/3.6;
         
            distance_restante := distanceBetweenBusStop - covered_distance;
            --put("distance parcourue : ");Put(covered_distance,4,3,0);New_line;        
            put("distance restante : ");Put(distance_restante,4,3,0);New_line;
            
            -- la distance parcourue a été mise à jour : on met a jour la position
            --on suppose qu'une unité de position = 10 m
            rapport := covered_distance/distanceBetweenBusStop;
            position.x:=position_last.x + rapport*(position_next.x - position_last.x);
            position.y:=position_last.y + rapport*(position_next.y - position_last.y);
        end update;

    begin
        loop
            delay(cycleTime);
            update(integer(cycleTime));
        end loop; 
       
    end Odometer; 
    
    
    -- ******************************************
    -- ************* Bus Controller ************* 
    -- ******************************************
    task body Bus_Controller is  
       
        CycleTime : constant duration :=10.0;
    begin   
        loop
            delay(CycleTime);
            Radio.sendBusPosition(id_bus,position);
       end loop; 
    end Bus_Controller;
    
    
    -- **********************************
    -- ************* Sensor ************* 
    -- **********************************
    task body Sensor is
        IS_ARRIVED_BUSSTOP : boolean := false;
    begin
       
        loop     
            delay(1.0);
            nextBusStop.busStop.emit(id_bus,position,IS_ARRIVED_BUSSTOP);
            if (IS_ARRIVED_BUSSTOP) then
                --arret du bus à l'arret
                -- tant que la distance restante a parcourir est superieure à 3m,
                -- on decelère si c'est possible
                loop
                    if (speed > 10) then
                        Speed_control.DECELERATE;
                        delay(1.0);
                    end if;
                    exit when distance_restante < 3.0;
                end loop;
                    
                --il reste moins de 3 m a parcourir, on arrete le bus!
                Speed_control.STOP;
                   
                --mise à jour du prochain arret à faire
                lastBusStopCapted:=nextBusStop;
                indice_busStop:=indice_busStop+1;   
                --test si c'est le terminus ou non
                if (line.busStop_List(indice_busStop+1) /= null) then   
                    nextBusStop:=line.busStop_List(indice_busStop+1);
                    --remise a zero de la distance parcourue
                    covered_distance := 0.0;
                    distance_restante := 0.0;
                       
                    --simulation de la montée / descente des voyageurs
                    delay(2.0);
                    
                    -- recuperation des positions des 2 arrets enre lesquels se trouve le bus
                    lastBusStopCapted.busStop.returnPositionBusStop(position_last);
                    nextBusStop.busStop.returnPositionBusStop(position_next);
                    -- mise à jour de la distance entre les deux arrets
                    distanceBetweenBusStop := sqrt((position_last.x-position_next.x)**2 + (position_last.y-position_next.y)**2)*unite_graph;
                    put_line("distance entre les 2 arret = ");Put(distanceBetweenBusStop,4,3,0);New_line;
                    Speed_control.START;
                    
                else
                    New_line;
                    put_line("****** TERMINUS DU BUS " &integer'image(id_bus) &" TOUT LE MONDE DESCEND ********");
                    New_line;
                    --appel d'une fonction C pour indiquer que l'on est arrivé au terminus

                    arrivedToTerminus(int(id_bus));
                    indice_busStop:=1;
                    
                    put("------------------->last bus stop capted ");
                    put(Integer'Image(indice_busStop));

                end if;
                
                
                
                --on redémarre le bus
                
                IS_ARRIVED_BUSSTOP:=false;  
                                     
            end if;
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
    distanceBetweenBusStop := sqrt((position.x-position_next.x)**2 + (position.y-position_next.y)**2) *unite_graph;
    put("distance entre les 2 arret = ");Put(distanceBetweenBusStop,4,3,0);New_line;
    Speed_Control.START;
	loop
        select
            accept sendEmergencyCall(num_bus : in integer; emergency : in string) do
               --utilisation de la radio pour appel d'urgence
                Radio.sendEmergencyCall(num_bus,emergency);
            end sendEmergencyCall;
        or
            accept sendBusPosition(num_bus : in integer; position : in T_position) do
                New_line;
                --appel à la radio du centre
                receivePosition(int(num_bus),c_float(position.x),c_float(position.y),c_float(position_last.x),c_float(position_last.y));
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
            accept restart do
                null;
                Radio.restart;
                put_line(" #### on passe dans le restart bus");  
            end restart;   
        or
            accept changeDirection do
                Driver.changeDirection;
            end changeDirection; 
        or
            accept start do
                Speed_control.START;
            end start;
        or
            accept stop do
                Speed_control.STOP;
            end;
        end select;
    end loop; 
 end Bus; 
end Bus_package;