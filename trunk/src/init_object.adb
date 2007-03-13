with Interfaces.C,Text_io,BusStop_package,bus_package,common_types,common_types_busStop;


use Text_io,BusStop_package,Interfaces.C,bus_package,common_types,common_types_busStop;


package body init_object is
procedure lancement(Chaine : in String_c) is
    Seconde : constant duration := 1.0;
    pos1 : ptrT_position:= new T_position'(15.0, 15.0);
    pt : ptrString:=new String'("Arret 1");
    A1 : ptrT_busStop;
    pos2 : ptrT_position:= new T_position'(35.0, 35.0);
    pt2: ptrString :=new String'("Arret 2");
    A2 : ptrT_busStop;
    pos3 : ptrT_position:= new T_position'(40.0, 40.0);
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
    put_line(To_ADA(Chaine));
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
    delay(5*Seconde);    
    B:= new Bus(1,bus_line);
end lancement;
    
    procedure initGen(nb_bus_stop :in int;nb_bus : in int) is
        begin 
        NBBUSSTOP:=Integer(nb_bus_stop);
        NBBUS:=Integer(nb_bus);
    end initGen;    
        
        
    procedure initBusStop(idBusStop : in int; x : in C_Float; y : in C_Float) is
            position : ptrT_position :=new T_position'(float(x),float(y));
            temp : String := integer'image(Integer(idBusStop));
            pt: ptrString :=new String'("Arret"&" "&temp);
            A1 : ptrT_busStop; 
            i :integer := integer(idBusStop);
        begin
            A1:=new BusStop(Integer(idBusStop),pt,position);
            tab_BusStop(i):=A1;
    end initBusStop;
        
        
    procedure initBus(num_bus : int;bus_line : ptrT_Line) is
        B1 : ptrT_bus;    
        num:integer := integer(num_bus); 
        begin        
            B1:= new Bus(Integer(num_bus),bus_line);
            tab_Bus(num):=B1;
    end initBus;
        
    procedure sendDisplay(num_busStop :in int; chaine_affich : in string_c) is 
            num:integer := integer(num_busStop); 
            begin       
                tab_BusStop(num).receiveDisplay(to_ADA(chaine_affich));
                put_line("avant le parsing");
                --deserialize(3,chaine_affich);
    end sendDisplay;
    
     procedure lancement_bus(id_bus : int;id_line:in int; nb_arret:in int;chaine_route : in string_c) is
    bus_line :ptrT_Line;
    begin
        deserialize(nb_arret,chaine_route,id_line,bus_line);
        initBus(id_bus,bus_line);
    end lancement_bus; 
    
    -- procedure de désérialisation : nb_occurence == nb de "/" qui séparent les concaténations de structures
    -- les éléments de la structures sont séparés par des ";" : les structures passées sont des pointeurs sur des bus_stop
    -- et un booleen (required)
    -- la chaine sérialisée sera de la forme : int;bool/int;bool/int;bool/
    procedure deserialize(nb_occurence : in int; chaineSerial : in Char_Array; idline : int;bus_line : out ptrT_Line) is
    --procedure deserialize(nb_occurence : in int; chaineSerial : in Char_Array) is  
        i : Integer := 1;
        j : Integer := 1;
        k : Integer := 1; 
        compteur_tab : Integer := 1; 
        ptr : ptrT_busStopRecord;
        arr : T_busStopList;
        entier : Integer;
        booleen : Boolean;

        
        nb_occurence_i : Integer := Integer(nb_occurence);
        Type tableau is array (1..2,1..nb_occurence_i) of String(1..2);
        tab : tableau;
        chaineDep : String := to_ADA(chaineSerial);
        element : String:= "  "; -- element courant de la structure (un int =>2caracteres , bool => 1caratere : 1 == true)
         
        toto : Integer := chaineDep'length +1;
    
    begin
        put_line("on commence le parsing ");
        
        while(i < toto) loop
            
            if(chaineDep(i) = '/') then
                if(k = 1) then
                    element(2) := element(1);
                    element(1) := ' ';
                end if;  
                i := i+1;
                j := 1;
                k := 1;
                tab(2,compteur_tab) := element;
                --put_line(tab(2,compteur_tab)); 
                element := "  ";
                compteur_tab := compteur_tab + 1;
            --end if;   
            elsif(chaineDep(i) = ';')then
                if(k = 1) then
                    element(2) := element(1);
                    element(1) := ' ';
                end if;
                i := i+1;
                j := 1;
                k := 1;
                tab(1,compteur_tab) := element;
                --put_line(tab(1,compteur_tab)); 
                element := "  "; 
            else
                element(j) := chaineDep(i); 
                i := i+1;
                j := j+1; 
                k := k+1; 
           end if;         
        end loop;
        
        i := 1;
        while(i < compteur_tab) loop
            entier := Integer'Value(tab(1,i));
            booleen := (tab(2,i) = "1 ");
            put_line(Boolean'Image(booleen));
            ptr:=new T_busStopRecord'(tab_BusStop(entier),booleen);
            arr(i):= ptr;
            i :=i+1;
        end loop;
        
        bus_line := new T_Line'(Integer(idline),arr);
           
            
        put_line("fin boucle");   
    end deserialize;

end init_object;

