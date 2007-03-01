---------------------------------------------------------------------------------------------------------
--                              BusStop.adb                                                            --
--                                                                                                     --
---------------------------------------------------------------------------------------------------------
with Text_io,CHAINES;use Text_io,CHAINES;

package body BusStop_package is
    
    task body BusStop is      
        idBusStop : integer;
        name : CHAINE;
        position : T_position;
    begin
        loop
                select
                     accept emit(position_bus : in T_position) do
                            Emettor.emit(position_bus);
                     end emit;
                or
                     accept receiveDisplay(toDisplay : in CHAINE) do
                            Screen.display(toDisplay);
                     end receiveDisplay;
                or
                     accept returnPositionBusStop(position_r : out T_position) do
                            position_r := position;
                     end returnPositionBusStop;
            end select;
            end loop;               
    end BusStop;
        
        
    task body Radio is 
    begin  
        loop
            accept receiveDisplay(toDisplay : in CHAINE) do
                Screen.display(toDisplay);
            end receiveDisplay;
        end loop;
     end Radio;
    
  
    task body Screen is 
        begin  
            loop
                accept display(toDisplay : in CHAINE) do
                    PUT(toDisplay);
                end display;
            end loop;
    end Screen;
    
    task body Emettor is 
        position_t : T_position;
    begin  
        loop
            --la methode emit est appelee par le bus ->condition when quand la position de l'arret
            -- == la position du bus qui appelle le emit
            --emit appelle la methode du bus qui sette le dernier arret ou est passé le bus
            accept emit(position_bus : in T_position) do                
                BusStop.returnPositionBusStop(position_t);
                if(position_t.x = position_bus.x and position_t.y = position_bus.y) then
                    --appel du code emettor du bus (setLastBusStopCapted)
                    PUT("COCO");
                end if;
            end emit;
        end loop; 
    end Emettor; 
    
                
end BusStop_package;
