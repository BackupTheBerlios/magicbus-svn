with Interfaces.C;use Interfaces.C;
with common_types;use common_types;
package init_object is
    
    procedure lancement(Chaine : in String_c);
    pragma Export(C, lancement, "lancement");
    procedure affichage(Chaine : in Char_Array);
    pragma Import (C, affichage, "affichage") ;
    procedure initBusStop(name : in Char_Array; idBusStop : in int; x : in int; y : in int);
end init_object;