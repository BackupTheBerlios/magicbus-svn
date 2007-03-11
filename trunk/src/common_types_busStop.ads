with common_types,BusStop_package;use common_types,BusStop_package;

package common_types_busStop is
    type ptrT_busStop is access BusStop;
     
    type T_busStopRecord is record
            busStop : ptrT_busStop;
            required : boolean;
            --listHours : T_listHours;
    end record;

    type ptrT_busStopRecord is access T_busStoprecord;
    
    type T_busStopList is array (1..50) of ptrT_busStopRecord;

    type T_Line is record
        id_line : integer;
        BusStop_List : T_busStopList;
    end record;    
    
    type ptrT_line is access T_Line;
    
end common_types_busStop;