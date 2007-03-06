package test is
    procedure lancement;
    pragma Export(C, lancement, "lancement");
    procedure affichage;
    pragma Import (C, affichage, "affichage") ;
end test;