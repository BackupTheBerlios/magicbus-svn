with Interfaces.C,Text_io,BusStop_package,bus_package,common_types;use Text_io,BusStop_package,Interfaces.C,bus_package,common_types;

package body init_object is
procedure lancement(Chaine : in String_c) is 
    --pragma import(C,tachatte,"tachatte");
    Seconde : constant duration := 1.0;
    pos1 : ptrT_position:= new T_position'(3, 5);
    pt : ptrString:=new String'("Arret 1");
    A1 : BusStop_package.BusStop(1,pt,pos1);
    pos2 : ptrT_position:= new T_position'(5, 15);
    pt2: ptrString :=new String'("Arret 2");
    A2 : BusStop_package.BusStop(2,pt2,pos2); 
    
    Bus1 : Bus;
begin
    put_line(To_ADA(Chaine));
    delay(5*Seconde);    
    --appelle une fonction C
    Bus1.receiveTimeDelay(-10.0);
    affichage(To_C("Voila un affichage pour tester (param envoye de l'ADA vers le C)"));
    A1.receiveDisplay("Affichage sur l'ecran de l'arret 1");
    A1.emit(pos1.all);
    A2.emit(pos1.all);    
end lancement;
end init_object;