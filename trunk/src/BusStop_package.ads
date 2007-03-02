with Text_io,common_types;use Text_io,common_types;

package BusStop_package is
    
    
    task type BusStop is       
        --entry initBusStop(ptEmettor : out ptEmettorType; ptRadio : out ptRadioType;ptScreen : out ptScreenType);  
    end BusStop;
    
    task type Radio is
       
        entry receiveDisplay(toDisplay : in String);      
    end Radio;
    
    task type Screen is
        entry display (toDisplay : in String);      
    end Screen;
    
    task type Emettor is
        entry emit (position_bus : in T_position);      
    end Emettor;  
    
end BusStop_package;