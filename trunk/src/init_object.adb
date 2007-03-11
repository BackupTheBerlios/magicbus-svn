with Interfaces.C,Text_io,BusStop_package,bus_package,common_types,common_types_busStop;


use Text_io,BusStop_package,Interfaces.C,bus_package,common_types,common_types_busStop;


package body init_object is
procedure lancement(Chaine : in String_c) is 
    --pragma import(C,tachatte,"tachatte");
    Seconde : constant duration := 1.0;
    pos1 : ptrT_position:= new T_position'(15, 15);
    pt : ptrString:=new String'("Arret 1");
    A1 : ptrT_busStop;
    pos2 : ptrT_position:= new T_position'(35, 35);
    pt2: ptrString :=new String'("Arret 2");
    A2 : ptrT_busStop;
    pos3 : ptrT_position:= new T_position'(40, 40);
    pt3: ptrString :=new String'("Arret 3");
    A3 : ptrT_busStop;
    bus_line : ptrT_Line;
    ptr: ptrT_busStopRecord;
    ptr2: ptrT_busStopRecord;
    ptr3: ptrT_busStopRecord;
    arr : T_busStopList;
    type pt_bus is access Bus;
    B: pt_bus;
begin
    A1 := new BusStop_package.BusStop(1,pt,pos1);
    A2 := new BusStop_package.BusStop(2,pt2,pos2);
    A3 := new BusStop_package.BusStop(3,pt3,pos3);
    ptr:=new T_busStopRecord'(A1,true);
    ptr2:=new T_busStopRecord'(A2,true);
    ptr3:=new T_busStopRecord'(A3,true);
    arr(1):=ptr;
    arr(2):=ptr2;
    arr(3):=ptr3;
    bus_line:= new T_Line'(1,arr);
    put_line(To_ADA(Chaine));
    delay(5*Seconde);    
    B:= new Bus(1,bus_line);
end lancement;

procedure initBusStop(name : in String_c;idBusStop : in int; x : in int; y : in int) is
        position : ptrT_position :=new T_position'(Integer(x),Integer(y));
        pt: ptrString :=new String'(To_ADA(name));
        A1 : BusStop_package.BusStop(Integer(idBusStop),pt,position); 
    begin
        
        null;
end initBusStop;
    
procedure initBus(num_bus : int;bus_line : ptrT_Line) is
       B1 : Bus(Integer(num_bus),bus_line); 
    begin        
        null;
end initBus;

end init_object;

