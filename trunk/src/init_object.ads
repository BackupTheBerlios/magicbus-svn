with Interfaces.C;use Interfaces.C;
with common_types;use common_types;
package init_object is
    
    procedure lancement(Chaine : in String_c);
    pragma Export(C, lancement, "lancement");
    procedure affichage(Chaine : in Char_Array);
    pragma Import (C, affichage, "affichage") ;
end init_object;