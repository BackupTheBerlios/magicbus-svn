---------------------------------------------------------------------------------------------------------
--                              Bus_Package.adb                                                        --
--                                                                                                     --
---------------------------------------------------------------------------------------------------------


with text_io,common_types,common_types_busStop,Ada.Numerics.Elementary_Functions,Ada.Calendar ;
use Ada.Numerics.Elementary_Functions,text_io,common_types,common_types_busStop,Ada.Calendar ;

package body Bus_package is
    package REEL_ES is new Float_Io(Float); use REEL_ES;
    
task body Bus is
    id_bus : integer := num_bus;
    line : T_Line:= bus_line.all;
	Seconde : constant duration := 1.0;
    --position courante du bus
    position : T_Position;
    --dernier arret auxquel on s'est arret� et sa position
    lastBusStopCapted : ptrT_busStopRecord := null;
    position_last : T_Position;
    --prochain arret auxquel on doit arret� et sa position
    nextBusStop : ptrT_busStopRecord := line.busStop_List(1);
    position_next : T_Position;
    --distance entre les deux arrets (dernier et suivant)
    distanceBetweenBusStop : float;
    --indice de l'arret dans le tableau des arrets de la ligne
    indice_busStop : integer := 1;
    
    speed:integer:=0;
    --unite graphique
    unite_graph:float:=10.0;
    -- ******************************************
    -- proc�dure permettant d'inverser la liste 
    -- des arrets quand le bus fait demi-tour
    -- ******************************************
    procedure inverserListe (list : in out T_busStopList);
    procedure inverserListe (list : in out T_busStopList) is
        list_temp : T_busStopList;
        j:integer:=1;
    begin
        for i in list'RANGE loop
            if (list(list'LAST - i + list'FIRST) /= null) then
                list_temp(j) := list(list'LAST -i + list'FIRST);
                j:=j+1;
            end if;
        end loop;
        for i in list'RANGE loop
            list(i):=list_temp(i);
        end loop;
        --quand on fait demi-tour, le dernier arret capt� est le terminus. 
        -- c'est aussi le point de d�part du bus dans l'autre sens
        lastBusStopCapted := nextBusStop;
        indice_busStop:=2;
        nextBusStop:=list(2);
    end inverserListe ;
    
      
    -- ******************************************
    -- D�claration des taches et objets prot�g�s
    -- ******************************************
    
    
    -- ************* Driver ************* 
    -- Cet objet permet au bus de recalculer sa vitesse suivant le temps 
    -- d'avance ou de retard renvoy� par le centre, de modifier le sens 
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
    -- Ses entry sont surtout appel�es par le driver  
    -- ************************************** 
    protected Speed_Control is
        entry ACCELERATE;
        procedure DECELERATE;
        entry START;
        entry STOP;
    private
        debut,
        fin,
        duree : duration;
    end Speed_Control;
    
   
    --************* Radio ************* 
    -- Compos�e de 2 sous-taches (standardchannel et emergnecyChannel
    -- Le emergencyChannel est reserv� � l'envoi de message d'urgence en cas d'accident,...
    -- Le standardChannel permet de recevoir le temps d'avance ou de retard de la part du centre
    -- ainsi que d'envoyer r�guli�rement sa position courante au centre
    --********************************* 
    task Radio is
        entry receiveTimeDelay(timeDelay : in Float);
        entry sendBusPosition (num_bus : in integer; position : in T_position);
        entry sendEmergencyCall(num_bus : in integer; emergency : in string);
    end Radio;
    
    
    -- ************* Bus Odometer *************
    -- L'odometre permet de renvoyer la distance parcourue
    -- La distance parcourue est remise � zero a chaque fois 
    -- qu'on s'arrete � un arret de bus
    -- ****************************************  
    task Odometer is       
        entry returnDistance(distance:out float) ;
        entry raz;
        entry updateDistance(cycle_time : in duration);
    end Odometer; 
    
    -- ************* Bus Controller ************* 
    -- ****************************************** 
    task Bus_Controller is  
   
    end Bus_Controller;    
    
    
    -- ************* Sensor *************
    -- A chaque fois que la position courante sera calcul�e,
    -- le sensor appelera l'entry emit du prochain arret de bus 
    -- pour savoir s'il est � proximit� ou non
    -- si c'est le cas, il s'arr�te
    -- ********************************** 
    task Sensor is
        entry TestBusStop(position : in T_Position);
    end Sensor;
    
    -- **********************************************
    -- Fin D�claration des taches et objets prot�g�s
    -- **********************************************
    
 
    
    -- ******************************************************
    -- declaration du corps des objets proteg�s et des taches
    -- ******************************************************
    
    
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
    
    
    -- ***************************************
    -- *************Speed_Control*************  
    -- ***************************************  
    protected body Speed_Control is 

        entry START when speed = 0 is
        begin
            debut:= Seconds(Clock);
            speed:=30;
            put("speed = ") ; put_line(integer'image(speed));
        end START;
    
        entry ACCELERATE when speed > 0 is
        begin
            fin:= Seconds(Clock);
            duree:=fin-debut;
            debut:=Seconds(Clock);
            Odometer.updateDistance(duree);
            speed:=speed + 5;
            put("speed = ") ; put_line(integer'image(speed));
        end ACCELERATE;
       
        procedure DECELERATE is
        begin
            fin:= Seconds(Clock);
            duree:=fin-debut;
            debut:=Seconds(Clock);
            Odometer.updateDistance(duree);
            speed:=speed - 5;
            put("speed : ") ;
            put_line(integer'image(speed));
        end DECELERATE;
          
        entry STOP when speed > 0 is
        begin
            put_line("arret du bus ...");
            while(speed > 0) loop
                DECELERATE;
                --put("speed : ") ;
                --put_line(integer'image(speed));
            end loop;       
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
                --appel a la radio du centre pour qu'il le re�oive...
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
            end select;
            
        end loop;
    end Radio;     
       
    
    -- ****************************************
    -- ************* Bus Odometer *************
    -- **************************************** 
    task body Odometer is
        covered_distance : float:=0.0;
        cycleTime : constant duration := 2.0;
        time : integer;
        --speed : integer;
        procedure update(cycle_time : in integer;speed : in integer); 
        
        procedure update(cycle_time : in integer;speed:in integer) is
        begin
            covered_distance:=covered_distance + float(cycle_time) * float(speed)/3.6;
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
                    put_line("remise � zero de la distance parcourue!");
                end raz;
            or
                accept updateDistance(cycle_time : in duration) do
                    time:=integer(cycle_time) mod integer(cycleTime);
                    if (time > 0) then
                        update(time,speed); 
                    end if;
                end updateDistance;
            else
                delay(cycleTime);
                --Speed_Control.returnSpeed(speed);
                update(integer(cycleTime),speed);
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
            --on suppose qu'une unit� de position = 10 m
            rapport := (distance/unite_graph)/distanceBetweenBusStop;
            position.x:=position_last.x + rapport*(position_next.x - position_last.x);
            position.y:=position_last.y + rapport*(position_next.y - position_last.y);
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
                nextBusStop.busStop.emit(id_bus,position,IS_ARRIVED_BUSSTOP);
                if (IS_ARRIVED_BUSSTOP) then
                    --arret du bus � l'arret
                    Speed_control.STOP;
                    --mise � jour du prochain arret � faire
                    lastBusStopCapted:=nextBusStop;
                    indice_busStop:=indice_busStop+1;
                    
                    --test si c'est le terminus ou non
                    if (line.busStop_List(indice_busStop) /= null) then
                        nextBusStop:=line.busStop_List(indice_busStop);
                        --remise a zero de la distance parcourue
                        Odometer.raz;
                        --simulation de la mont�e / descente des voyageurs
                        delay(2.0);
                    else
                        New_line;
                        put_line("****** TERMINUS DU BUS " &integer'image(id_bus) &" TOUT LE MONDE DESCEND ********");
                        New_line;
                        inverserListe(line.BusStop_List);
                        Driver.changeDirection;
                        --remise a zero de la distance parcourue
                        Odometer.raz;
                        --terminus donc on attend un peu
                        
                        delay(10.0);  
                    end if;
                    
                    -- recuperation des positions des 2 arrets enre lesquels se trouve le bus
                    lastBusStopCapted.busStop.returnPositionBusStop(position_last);
                    nextBusStop.busStop.returnPositionBusStop(position_next);
                    -- mise � jour de la distance entre les deux arrets
                    distanceBetweenBusStop := sqrt((position_last.x-position_next.x)**2 + (position_last.y-position_next.y)**2);
                    put_line("distance entre les 2 arret = ");Put(distanceBetweenBusStop*unite_graph,4,3,0);New_line;
                    --on red�marre le bus
                    Speed_control.START;
                    IS_ARRIVED_BUSSTOP:=false;                       
                end if;
            end TestBusStop;
        end loop;
    end Sensor;
    
    -- **********************************************************
    -- fin declaration du corps des objets proteg�s et des taches
    -- **********************************************************
    
begin 
    Put_line("on demarre le bus");   
    position.x := 0.0;
    position.y := 0.0;
    position_last.x := 0.0;
    position_last.y := 0.0;
    nextBusStop.busStop.returnPositionBusStop(position_next);
    -- calcul de la distance initiale entre le depart et le prochain arret de bus
    -- la distance entre 2 points de coordonn�es (x1,y1) et (x2,y2)
    -- est = racine_carree((x1-x2)� + (y1-y2)�)
    distanceBetweenBusStop := sqrt((position.x-position_next.x)**2 + (position.y-position_next.y)**2);
    put("distance entre les 2 arret = ");Put(distanceBetweenBusStop*unite_graph,4,3,0);New_line;
    Speed_Control.START;
	loop
        select
            accept sendEmergencyCall(num_bus : in integer; emergency : in string) do
               --utilisation de la radio pour appel d'urgence
                Radio.sendEmergencyCall(num_bus,emergency);
            end sendEmergencyCall;
        or
            accept sendBusPosition(num_bus : in integer; position : in T_position) do
                New_line;--appel � la radio du centre
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
            accept changeDirection do
                Driver.changeDirection;
            end changeDirection; 

        end select;
    end loop; 
 end Bus; 
end Bus_package;