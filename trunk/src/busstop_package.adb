---------------------------------------------------------------------------------------------------------
--                              BusStop.adb                                                            --
--                                                                                                     --
---------------------------------------------------------------------------------------------------------
with Text_io;use Text_io;

package body BusStop_package is
    
    
    --/***********************************************************************************************************/  
    --/******************************************Arret de bus*****************************************************/
    --/***********************************************************************************************************/
    task body BusStop is 
        
        --attributs d'un arret de bus   
        idBusStop : integer:=id_BusStop;
        name : String:=name_busStop.all;
        position : T_position:=position_busStop.all;
        
        
        
        type RadioType is access Radio;
        type EmettorType is access Emettor;
        ptEmettor:EmettorType;        
        ptRadio:RadioType;
        
    begin
        
        ptRadio:=new Radio;
        ptEmettor:=new Emettor(position_busStop);
        
        put_line("Instanciation " & name);
        
        loop
            select
                     accept emit(position_bus : in T_position) do
                          ptEmettor.emit(position_bus);
                     end emit;
                or
                     accept receiveDisplay(toDisplay : in String) do
                           ptRadio.receiveDisplay(toDisplay);
                     end receiveDisplay;
                or
                     accept returnPositionBusStop(position_r : out T_position) do
                            position_r := position;
                     end returnPositionBusStop;
            end select;
         end loop;               
    end BusStop;
        
      
    --/***********************************************************************************************************/  
    --/******************************************Radio de l'arret de bus******************************************/
    --/***********************************************************************************************************/  
    task body Radio is 
        
        type Ptr_Screen_type is access Screen;
        pt_Screen:Ptr_Screen_type;
    begin 
        pt_Screen:=new Screen;
        
        put_line("Radio instanciee");
        loop
            accept receiveDisplay(toDisplay : in String) do
            pt_Screen.display(toDisplay);
            end receiveDisplay;            
        end loop;
     end Radio;
    
    --/***********************************************************************************************************/  
    --/******************************************Ecran de l'arret de bus******************************************/
    --/***********************************************************************************************************/
    task body Screen is 
        begin 
         
            put_line("Screen instancie");
        
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
        position_t : T_position:=position.all;
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
                    put_line("Bus passe pres de l'arret");
                else
                    put_line("Remballe ton stand");
                end if;
            end emit;
        end loop; 
    end Emettor; 
    
    
    

                
end BusStop_package;
