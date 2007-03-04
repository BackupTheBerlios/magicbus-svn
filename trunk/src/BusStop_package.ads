with Text_io,common_types;use Text_io,common_types;

--Package contenant la définition d'un arret de bus


package BusStop_package is
    
    --/***********************************************************************************************************/  
    --/******************************************Arret de bus*****************************************************/
    --/***********************************************************************************************************/
    task type BusStop(id_BusStop : integer; name_busStop : ptrString;position_busStop : ptrT_position) is       
        entry emit(position_bus : in T_position);
        entry receiveDisplay(toDisplay : in String);
        entry returnPositionBusStop(position_r : out T_position);  
    end BusStop;
    
    
    --/***********************************************************************************************************/  
    --/******************************************Radio de l'arret de bus******************************************/
    --/***********************************************************************************************************/
    task type Radio is       
        entry receiveDisplay(toDisplay : in String);     
    end Radio;
    
    
    --/***********************************************************************************************************/  
    --/******************************************Ecran de l'arret de bus******************************************/
    --/***********************************************************************************************************/
    task type Screen is
        entry display (toDisplay : in String);      
    end Screen;
    
    
    --/***********************************************************************************************************/  
    --/******************************************Emmettor de l'arret**********************************************/
    --/***********************************************************************************************************/
    task type Emettor(position : ptrT_position) is
        entry emit (position_bus : in T_position);      
    end Emettor;  
    
end BusStop_package;