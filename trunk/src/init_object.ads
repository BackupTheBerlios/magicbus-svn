--/***********************************************************************************************************/  
--/******************************************Init_object*****************************************************/
--/ Ensemble de fonctions permettant de dialoguer avec le centre et les taches ADA
--/ G�re l'instanciation des taches et leur manipulation ult�rieure
--/***********************************************************************************************************/

--Paquetages inclus
with Interfaces.C;use Interfaces.C;
with common_types,common_types_busStop,bus_package;use common_types,common_types_busStop,bus_package;

--paquetage de manipulation des donn�e ADA avec le centre
package init_object is
    
    --pointeur sur les taches BUS
    type ptrT_bus is access Bus;
    
    
    --Variable globale de la simulation
    NBBUSSTOP:integer;
    NBBUS:integer; 
    
    --Tableau de pointeurs de bus et d'arret de bus du reseau   
    type A_BusStop is array (1..50) of ptrT_busStop; 
    type A_Bus is array (1..30) of ptrT_bus; 
    tab_BusStop :A_BusStop;
    tab_Bus :A_Bus; 
    
    --proc�dure gerant l'initialisation des varaibles globales du simulateur
    procedure initGen(nb_bus_stop :in int;nb_bus : in int); 
    pragma Export(C, initGen, "initGen");        
    
    --methode appel� par le centre pour l'affichage d'un message sur un arret
    procedure sendDisplay(num_busStop :in int; chaine_affich : in string_c);
    pragma Export(C, sendDisplay, "sendDisplay");
    
    --proc�dure qui instancie un arret de bus dans le reseau
    procedure initBusStop(idBusStop : in int; x : in C_float; y : in C_float);
    pragma Export(C, initBusStop, "initBusStop");
    
    --procedure qui instancie un bus dans le reseau 
    procedure initBus(num_bus : int;bus_line : ptrT_Line);
    
    --proc�dure appel�e depuis le centre pour cr�er un bus
 	procedure lancement_bus(id_bus : int;id_line:in int; nb_arret:in int;chaine_route : in string_c);
    pragma Export(C, lancement_bus, "lancement_bus");
    
    --proc�dure appel�e depuis le centre pour informer un bus de son avance ou son retard
    procedure sendDelay(id_bus : int;delay_t : in C_Float);
    pragma Export(C, sendDelay, "sendDelay");
    
    --proc�dure appel�e depuis le centre pour red�marrer le bus apres un terminus(changement de ligne ou retour)
    procedure restart(id_bus : int;id_line:in int; nb_arret:in int;chaine_route : in string_c);
    pragma Export(C, restart, "restart");
    
    --proc�dure appel�e depuis le centre pour simuler un appel d'urgence d'un bus
    procedure simulateEmergency(id_bus : int;message : in String_c);
    pragma Export(C, simulateEmergency, "simulateEmergency");
    
    -- procedure de d�s�rialisation : nb_occurence == nb de "/" qui s�parent les concat�nations de structures
    -- les �l�ments de la structures sont s�par�s par des ";" : les structures pass�es sont des pointeurs sur des bus_stop
    -- et un booleen (required)
    -- la chaine s�rialis�e sera de la forme : int;bool/int;bool/int;bool/
    procedure deserialize(nb_occurence : in int; chaineSerial : in Char_Array; idline : int;bus_line : out ptrT_Line);
 
end init_object;