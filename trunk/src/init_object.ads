with Interfaces.C;use Interfaces.C;
with common_types,common_types_busStop;use common_types,common_types_busStop;
package init_object is
    
    procedure lancement(Chaine : in String_c);
    pragma Export(C, lancement, "lancement");
    procedure affichage(Chaine : in Char_Array);
    pragma Import (C, affichage, "affichage") ;
    procedure initBusStop(name : in String_c; idBusStop : in int; x : in int; y : in int);
    pragma Export(C, initBusStop, "initBusStop");
    procedure initBus(num_bus : int;bus_line : ptrT_Line);
    pragma Export(C, initBus, "initBus");
end init_object;