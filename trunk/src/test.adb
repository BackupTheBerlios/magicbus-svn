with Interfaces.C,Text_io,BusStop_package,bus_package,common_types_ptr,common_types;use Text_io,BusStop_package,common_types_ptr,Interfaces.C,bus_package,common_types;

package body test is
procedure lancement is 
    --pragma import(C,tachatte,"tachatte");
    Seconde : constant duration := 1.0;
    pos1 : ptrT_position:= new T_position'(3, 5);
    pt : ptrString:=new String'("Arret 1");
    A1 : BusStop_package.BusStop(1,pt,pos1);
    pos2 : ptrT_position:= new T_position'(5, 15);
    pt2: ptrString :=new String'("Arret 2");
    A2 : BusStop_package.BusStop(2,pt2,pos2); 
    Tab: array (0..5) of T_Arret;
    B1:Driver;
begin
    put_line("gogogogogo");
    delay(5*Seconde);
    B1.calculateSpeed(5.0);
    A1.receiveDisplay("Affichage sur l'ecran de l'arret 1");
    A1.emit(pos1.all);
    A2.emit(pos1.all);
    B1.calculateSpeed(-70.0);
end lancement;
end test;