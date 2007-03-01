with Text_io,CHAINES,common_types;use Text_io,CHAINES,common_types;

package BusStop_package is

    task BusStop is        
        entry emit(position_bus : in T_position);
        entry receiveDisplay(toDisplay : in CHAINE);
        entry returnPositionBusStop(position_r : out T_position);
                
    end BusStop;
    
    task Radio is
      entry receiveDisplay (toDisplay : in CHAINE);      
    end Radio;
    
    task Screen is
        entry display (toDisplay : in CHAINE);      
    end Screen;
    
    task Emettor is
        entry emit (position_bus : in T_position);      
    end Emettor;  
    
end BusStop_package;