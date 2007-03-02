with Text_io,BusStop_package;use Text_io,BusStop_package;

package common_types_ptr is
    
    type ptBusStopType is access BusStop_package.BusStop;
    type ptRadioType is access Radio;
    type ptEmettorType is access Emettor;
    type ptScreenType is access Screen;
    
        type T_Arret is record
            ptBusStop : ptBusStopType;
            ptRadio : ptRadioType;
            ptEmettor : ptEmettorType;
            ptScreen : ptScreenType;                          
        end record;
end common_types_ptr;