---------------------------------------------------------------------------------------------------------
--                              BusStop.adb                                                            --
--                                                                                                     --
---------------------------------------------------------------------------------------------------------
with Text_io,CHAINES;use Text_io,CHAINES;

package body BusStop_package is
    
    task body BusStop is      
        idBusStop : integer;
        name : String(1..50):="yop";
        position : T_position;
        Seconde : constant duration := 1.0;
        type RadioType is access Radio;
        ptRadio:RadioType;
        type EmettorType is access Emettor;
        ptEmettor:EmettorType;
    begin
        ptRadio:=new Radio;
        put_line("Instanciation BusStop...");
        ptEmettor:=new Emettor;
        
        loop
                --select
                     --accept emit(position_bus : in T_position) do
                     --      Emettor.emit(position_bus);
                     --end emit;
                --or
                     --accept receiveDisplay(toDisplay : in String) do
                     --       Screen.display(toDisplay);
                     --end receiveDisplay;
                --or
                     --accept returnPositionBusStop(position_r : out T_position) do
                     --       position_r := position;
                     --end returnPositionBusStop;
            --end select;
            
            delay(5*Seconde);
            end loop;               
    end BusStop;
        
        
    task body Radio is 
        Seconde : constant duration := 1.0;
        type P is access Screen;
        A:P;
    begin 
        A:=new Screen;
        put_line("Radio instanciee");
        delay(5*Seconde); 
        
        loop
            accept receiveDisplay(toDisplay : in String) do
            A.display(toDisplay);
            end receiveDisplay;
            
        end loop;
     end Radio;
    
  
    task body Screen is 
        begin  
            put_line("Screen instancie");
            loop
                accept display(toDisplay : in String) do
                    put_line(toDisplay);
                end display;
            end loop;
    end Screen;
    
    task body Emettor is 
        position_t : T_position;
    begin  
        put_line("Instanciation Emettor...");
        loop
            --la methode emit est appelee par le bus ->condition when quand la position de l'arret
            -- == la position du bus qui appelle le emit
            --emit appelle la methode du bus qui sette le dernier arret ou est passé le bus
            accept emit(position_bus : in T_position) do                
                --BusStop.returnPositionBusStop(position_t);
                if(position_t.x = position_bus.x and position_t.y = position_bus.y) then
                    --appel du code emettor du bus (setLastBusStopCapted)
                    PUT("COCO");
                end if;
            end emit;
        end loop; 
    end Emettor; 
    
    
    

                
end BusStop_package;
