with Interfaces.C;use Interfaces.C;
with common_types,common_types_busStop,bus_package;use common_types,common_types_busStop,bus_package;
package init_object is
    
    type ptrT_bus is access Bus;
    NBBUSSTOP:integer;  
    type A_BusStop is array (1..50) of ptrT_busStop; 
    NBBUS:integer; 
    type A_Bus is array (1..30) of ptrT_bus; 
    tab_BusStop :A_BusStop;
    tab_Bus :A_Bus; 
    
    
    procedure initGen(nb_bus_stop :in int;nb_bus : in int); 
    pragma Export(C, initGen, "initGen");        
     
    procedure sendDisplay(num_busStop :in int; chaine_affich : in string_c);
    pragma Export(C, sendDisplay, "sendDisplay");
    procedure lancement(Chaine : in String_c);
    pragma Export(C, lancement, "lancement");
    procedure initBusStop(idBusStop : in int; x : in C_float; y : in C_float);
    pragma Export(C, initBusStop, "initBusStop");
    procedure initBus(num_bus : int;bus_line : ptrT_Line);
    pragma Export(C, initBus, "initBus");
    

 	procedure lancement_bus(id_bus : int;id_line:in int; nb_arret:in int;chaine_route : in string_c);
    pragma Export(C, lancement_bus, "lancement_bus");
    
    procedure deserialize(nb_occurence : in int; chaineSerial : in Char_Array; idline : int;bus_line : out ptrT_Line);
    --procedure deserialize(nb_occurence : in int; chaineSerial : in Char_Array);
end init_object;