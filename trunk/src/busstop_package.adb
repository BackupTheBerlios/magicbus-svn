---------------------------------------------------------------------------------------------------------
--                              BusStop.adb                                                            --
--                                                                                                     --
---------------------------------------------------------------------------------------------------------
with Text_io;use Text_io;

package body BusStop_package is
    package REEL_ES is new Float_Io(Float); use REEL_ES;
    
    --/***********************************************************************************************************/  
    --/******************************************Arret de bus*****************************************************/
    --/***********************************************************************************************************/
    task body BusStop is 
        
        --attributs d'un arret de bus   
        idBusStop : integer:=id_BusStop;
        name : String:=name_busStop.all;
        position : T_position:=position_busStop.all;
        
     
        --/***********************************************************************************************************/  
        --/******************************************Radio de l'arret de bus******************************************/
        --/***********************************************************************************************************/
        task Radio is       
            entry receiveDisplay(toDisplay : in String);     
        end Radio;
        
        
        --/***********************************************************************************************************/  
        --/******************************************Ecran de l'arret de bus******************************************/
        --/***********************************************************************************************************/
        task Screen is
            entry display (toDisplay : in String);      
        end Screen;
        
        
        --/***********************************************************************************************************/  
        --/******************************************Emmettor de l'arret**********************************************/
        --/***********************************************************************************************************/
        task Emettor is
            entry emit (num_bus : in integer;position_bus : in T_position;is_arrived : in out boolean);      
        end Emettor; 
        
        --/***********************************************************************************************************/  
        --/******************************************Radio de l'arret de bus******************************************/
        --/***********************************************************************************************************/  
        task body Radio is 
                        
        begin 
             
            loop
                accept receiveDisplay(toDisplay : in String) do
                Screen.display(toDisplay);
                end receiveDisplay;            
            end loop;
        end Radio;
        
        --/***********************************************************************************************************/  
        --/******************************************Ecran de l'arret de bus******************************************/
        --/***********************************************************************************************************/
        task body Screen is 
            begin 
                loop
                    
                    accept display(toDisplay : in String) do
                        put_line(toDisplay);
                    end display;
                    
                end loop;
        end Screen;
        
        
        --/***********************************************************************************************************/  
        --/******************************************Emmettor de l'arret**********************************************/
        --/***********************************************************************************************************/
        task body Emettor is 
        begin 
            
                    
            loop
                --la methode emit est appelee par le bus ->condition when quand la position de l'arret
                -- == la position du bus qui appelle le emit
                --emit appelle la methode du bus qui sette le dernier arret ou est passé le bus
                
                accept emit(num_bus : in integer; position_bus : in T_position;is_arrived : in out boolean) do
                    if( position_bus.x > (position.x - 3.0) and 
                       position_bus.x < (position.x + 3.0) and 
                       position_bus.y > (position.y - 3.0) and 
                       position_bus.y < (position.y + 3.0) ) then
                       New_line;
                       put_line("Bus " & integer'image(num_bus) & " passe pres de l'arret numero " &integer'image(idBusStop));
                       New_line;
                       is_arrived := true;
                    else
                        is_arrived := false;
                    end if;
                end emit;
            end loop; 
        end Emettor; 
    begin
        
         
        put_line("Instanciation " & name);
        
        loop
            select
                accept emit(num_bus : in integer; position_bus : in T_position;is_arrived : in out boolean) do
                          Emettor.emit(num_bus,position_bus,is_arrived);
                     end emit;
                or
                     accept receiveDisplay(toDisplay : in String) do
                           Radio.receiveDisplay(toDisplay);
                     end receiveDisplay;
                or
                     accept returnPositionBusStop(position_r : out T_position) do
                            position_r := position;
                     end returnPositionBusStop;
            end select;
         end loop;               
    end BusStop;
        

                
end BusStop_package;
