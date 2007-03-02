with Text_io,CHAINES;use Text_io,CHAINES;

package common_types is
        type T_hour is record
                heure : integer;
                minute : integer;
        end record;

        type T_listHours is array (1..50) of T_hour;

        type T_position is record
            x:integer;
            y:integer;
        end record;

        type T_busStop is record
                idBusStop : integer;
                name : CHAINE;
                position : T_position;
        end record;

        type T_busStopRecord is record
                busStop : T_busStop;
                required : boolean;
                listHours : T_listHours;
        end record;

        type T_busStopList is array (1..50) of T_busStopRecord;

        type T_Line is record
            id_line : integer;
            BusStop_List : T_busStopList;
        end record;
    
       


end common_types;

