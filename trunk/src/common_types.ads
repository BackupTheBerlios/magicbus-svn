with Text_io,Interfaces.C;use Text_io,Interfaces.C;
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

        type ptrString is access String;
    
        type ptrT_position is access T_position;
    
        Seconde : constant duration := 1.0;
       
        subtype String_c is Interfaces.C.Char_Array (Interfaces.C.Size_T);   

end common_types;

