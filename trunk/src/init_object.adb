--/******************************************Init_object*****************************************************/
--/ Ensemble de fonctions permettant de dialoguer avec le centre et les taches ADA
--/ Gère l'instanciation des taches et leur manipulation ultérieure
--/***********************************************************************************************************/

--Paquetages inclus
with Interfaces.C,Text_io,BusStop_package,bus_package,common_types,common_types_busStop;
use Text_io,BusStop_package,Interfaces.C,bus_package,common_types,common_types_busStop;

--paquetage de manipulation des donnée ADA avec le centre
package body init_object is
   
    --procédure gerant l'initialisation des varaibles globales du simulateur
    procedure initGen(nb_bus_stop :in int;nb_bus : in int) is
        begin 
        NBBUSSTOP:=Integer(nb_bus_stop);
        NBBUS:=Integer(nb_bus);
    end initGen;    
        
    --procédure qui instancie un arret de bus dans le reseau  
    procedure initBusStop(idBusStop : in int; x : in C_Float; y : in C_Float) is
            --creation de la position de l'arret
            position : ptrT_position :=new T_position'(float(x),float(y));
            temp : String := integer'image(Integer(idBusStop));
            --géneration du nom de l'arret
            pt: ptrString :=new String'("Arret"&" "&temp);
            A1 : ptrT_busStop; 
            i :integer := integer(idBusStop);
        begin
            --on cree le bus 
            A1:=new BusStop(Integer(idBusStop),pt,position);
            --on stocke le pointeur pour reutilisation
            tab_BusStop(i):=A1;
    end initBusStop;
        
    --procedure qui instancie un bus dans le reseau     
    procedure initBus(num_bus : int;bus_line : ptrT_Line) is
        B1 : ptrT_bus;    
        num:integer := integer(num_bus); 
        begin  
            --instanciation du bus      
            B1:= new Bus(Integer(num_bus),bus_line);
            --stockage dans le tableau pour réutilisation
            tab_Bus(num):=B1;
    end initBus;
    
    --methode appelé par le centre pour l'affichage d'un message sur un arret    
    procedure sendDisplay(num_busStop :in int; chaine_affich : in string_c) is 
            num:integer := integer(num_busStop); 
            tmp : Integer := 1;
            trouve : Boolean := FALSE;
            begin  
                --on appelle l'entry de l'arret a partir de son id dans le tableau 
                tab_BusStop(num).receiveDisplay(to_ADA(chaine_affich));
    end sendDisplay;
    
    --procédure appelé depuis le centre pour créer un bus
     procedure lancement_bus(id_bus : int;id_line:in int; nb_arret:in int;chaine_route : in string_c) is
    bus_line :ptrT_Line;
    begin
        --on deserialise la chaine de caractere pour generer le plan de route du bus
        deserialize(nb_arret,chaine_route,id_line,bus_line);
        --on lance l'instanciation du bus dans le reseau
        initBus(id_bus,bus_line);
    end lancement_bus; 
    
    --procédure appelée depuis le centre pour informer un bus de son avance ou son retard
    procedure sendDelay(id_bus : int;delay_t : in C_Float) is
        num:integer := integer(id_bus); 
    begin
        tab_Bus(num).receiveTimeDelay(Float(delay_t));        
    end sendDelay;
    
    --procédure appelée depuis le centre pour simuler un appel d'urgence d'un bus
    procedure simulateEmergency(id_bus : int;message : in String_c) is
        num:integer := integer(id_bus); 
    begin      
          
        tab_Bus(num).sendEmergencyCall(num,to_ada(message)); 
    end simulateEmergency;
    
    
    -- procedure de désérialisation : nb_occurence == nb de "/" qui séparent les concaténations de structures
    -- les éléments de la structures sont séparés par des ";" : les structures passées sont des pointeurs sur des bus_stop
    -- et un booleen (required)
    -- la chaine sérialisée sera de la forme : int;bool/int;bool/int;bool/
    procedure deserialize(nb_occurence : in int; chaineSerial : in Char_Array; idline : int;bus_line : out ptrT_Line) is
        --variable de parcours
        i : Integer := 1;
        j : Integer := 1;
        k : Integer := 1; 
       
        compteur_tab : Integer := 1; 
        --tableau contenant le plan de route du bus
        arr : T_busStopList;
        entier : Integer;
        booleen : Boolean;
       
        --nombre d'arret dans le trajet du bus
        nb_occurence_i : Integer := Integer(nb_occurence);
        Type tableau is array (1..2,1..nb_occurence_i) of String(1..2);
        tab : tableau;
        --chaine a déserialiser
        chaineDep : String := to_ADA(chaineSerial);
        element : String:= "  "; -- element courant de la structure (un int =>2caracteres , bool => 1caratere : 1 == true)
        --taille totale de la chaine
        lg_string : Integer := chaineDep'length +1;
    
    begin
        --parcours de la chaine a déserialiser
        while(i < lg_string) loop
            
            if(chaineDep(i) = '/') then
                if(k = 1) then
                    element(2) := element(1);
                    element(1) := ' ';
                end if;  
                i := i+1;
                j := 1;
                k := 1;
                --on stocke dans le tableau de resultat
                tab(2,compteur_tab) := element;
                element := "  ";
                compteur_tab := compteur_tab + 1;
              
            elsif(chaineDep(i) = ';')then
                if(k = 1) then
                    element(2) := element(1);
                    element(1) := ' ';
                end if;
                i := i+1;
                j := 1;
                k := 1;
                --on stocke dans le tableau de resultat
                tab(1,compteur_tab) := element;
                element := "  "; 
            else
                element(j) := chaineDep(i); 
                i := i+1;
                j := j+1; 
                k := k+1; 
           end if;         
        end loop;
        
        --on parcours le tableau de resultat et on instancie un arret
        i := 1;
        while(i < compteur_tab) loop
            
            entier := Integer'Value(tab(1,i));    
         
            booleen := (tab(2,i) = "1 ");
            --on stocke dans le tableau d'arret le pointeur de l'arret 
            arr(i):= new T_busStopRecord'(tab_BusStop(entier+1),booleen);
            i :=i+1;
        end loop;
        --creation de la ligne pour retour
        bus_line := new T_Line'(Integer(idline),arr);
        
    end deserialize;

end init_object;

