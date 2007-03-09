with Text_io,common_types;use Text_io,common_types;

--Package contenant la définition d'un arret de bus


package BusStop_package is
    
    --/***********************************************************************************************************/  
    --/******************************************Arret de bus*****************************************************/
    --/***********************************************************************************************************/
    task type BusStop(id_BusStop : integer; name_busStop : ptrString;position_busStop : ptrT_position) is       
        entry emit(position_bus : in T_position;is_arrived : in out boolean);
        entry receiveDisplay(toDisplay : in String);
        entry returnPositionBusStop(position_r : out T_position);  
    end BusStop; 
    
end BusStop_package;