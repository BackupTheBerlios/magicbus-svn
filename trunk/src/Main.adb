with Text_io,BusStop_package,common_types_ptr,common_types;use Text_io,BusStop_package,common_types_ptr,common_types;


procedure Main is 
    Seconde : constant duration := 1.0;
    pos1 : ptrT_position:= new T_position'(3, 5);
    pt : ptrString:=new String'("Arret 1");
    B1 : BusStop_package.BusStop(1,pt,pos1);
    pos2 : ptrT_position:= new T_position'(5, 15);
    pt2: ptrString :=new String'("Arret 2");
    B2 : BusStop_package.BusStop(2,pt2,pos2); 
    Tab: array (0..5) of T_Arret;
begin
    put_line("gogogogogo");
    delay(5*Seconde);
    
    B1.receiveDisplay("Affichage sur l'ecran de l'arret 1");
    B1.emit(pos1.all);
    B2.emit(pos1.all);
    --put_line(B1.name);
end Main;
