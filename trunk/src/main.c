/******************************************************************************/
/******************************************************************************/
/************Main C correspondant au centre controlant le reseau de bus********/
/**** Mattler Florence,Lapeyre Martial, Cazenave Florent, Ménard Alexis********/
/******************************************************************************/
/******************************************************************************/
#include <pthread.h>
#define NBBUSSTOP 20
#define NBBUS 10
#define TRUE  1
#define FALSE 0
#define bool  int
/******************************************************************************/
/***************Fonction externe appelé dans l'ADA*****************************/
/******************************************************************************/


//fonction initialisant l'environnement ADA/C
extern void adainit();

//fonction terminant l'environnement ADA/C
extern void adafinal();


//fonction permettant de regler la simulation
extern void initGen(int nb_busstop, int nb_bus);

//fonction permettant d'instancier un bus stop
extern void initBusStop(int id, float x, float y);

//fonction permettant d'instancier un bus stop
extern void lancement_bus(int id_bus, int id_line, int nb_arret,char * chaine_serial);

//fonction qui permet de mettre a jour l'ecran sur les arret de bus
extern void sendDisplay(int num_arret,char * message);

//fonction C permettant de recevoir des bus leur position, appel de calculatedelay qui
//permet de verifier si le bus est en retard et lui communiquer son avance/retard
void receivePosition(int id_bus, float x, float y, float x_last, float y_last);

//fonction C lancant l'instanciation ADA d'un arret de bus
void init_busStop_c(int id,float x, float y);

//fonction C permettant de mettre a jour l'affichage d'un arret
void affichage_arret(int num_arret, char * message);

//Stucture contenant les informations d'un arret
struct BusStop {
       int num;
       float x;
       float y;
};


//tableau d'arret de bus necessaire pour manipulation dans le centre
struct BusStop tab_BusStop[NBBUSSTOP];

//Stucture contenant les informations sur le parcour du bus
struct Bus_road {
       int id_busStop;
       bool required;
       //faudra rajouter une liste d'horaire mais bon on verra
};

struct Line 
{
    int id_line;
    int nb_arret;
    struct Bus_road tab_BusRoad[50];  
};

struct Bus
{
       int id_bus;
       struct Line l;      
};

//tableau de bus necessaire pour manipulation dans le centre
struct Bus tab_Bus[NBBUS];


//fonction C permettant de serialiser la ligne pour la passer a l'ADA et creation du bus
void init_bus_c(int id_bus, struct Line L);

//serialise une ligne en char * pour la passer a l'ADA
char * serialiser(struct Line L);


//main du simulateur
int main(int argc, char *argv[]){
    
    
    pthread_t id_thread;
    int res;
    int i=1;
    struct Line L1;
    struct Bus_road b;
    int nb_alea;
    
    
    printf("%s\n","Main C en route");
    //lancement de la configuration ADA/C    
    adainit();
    
    //lancement de la configuration du reseau
    initGen(NBBUSSTOP,NBBUS);
    
    /**************************************************************************/
    /************************Creation des arrêts*******************************/
    /**************************************************************************/
    
    //creation et instanciation des arrêt de bus
    while (i<=NBBUSSTOP)
    {
     
       //génération aleatoire du placement des arrêts
       if(i==0)
       {
               tab_BusStop[i].x=5.0;
               tab_BusStop[i].y=5.0;
       }     
       else
       {
               nb_alea = (rand()%71);
               if( nb_alea%2==0)
               {
                   tab_BusStop[i].x+=tab_BusStop[i-1].x+(float)nb_alea;
                   nb_alea = rand()%71;               
                   tab_BusStop[i].y+=tab_BusStop[i-1].y+(float)nb_alea;
               }
               else
               {
                   tab_BusStop[i].x+=tab_BusStop[i-1].x+(float)nb_alea;
                   nb_alea = rand()%71;               
                   tab_BusStop[i].y+=tab_BusStop[i-1].y-(float)nb_alea;               
               }
               
       } 
            
       //printf("(%d,%d)", tab_BusStop[i].x,tab_BusStop[i].y);
       tab_BusStop[i].num=i;
       init_busStop_c(tab_BusStop[i].num,tab_BusStop[i].x,tab_BusStop[i].y);
       i++;
    }
    
    //test d'affichage sur un arret
    affichage_arret(1,"J'affiche sur l'arret 1");


    /**************************************************************************/
    /************************Creation d'une ligne**c***************************/
    /**************************************************************************/
    
    L1.id_line=1;
    i=0;
    L1.nb_arret=3;
    //on charge tous les arrêts dans la ligne 1
    while (i<3)
    {
       b.required=TRUE;
       b.id_busStop=i;
       L1.tab_BusRoad[i]=b;
       i++;
    }
    init_bus_c(1,L1);

    /*
    L1.id_line=2;
    i=0;
    L1.nb_arret=5;
    //on charge tous les arrêts dans la ligne 2
    while (i<5)
    {
       b.required=TRUE;
       b.id_busStop=i;
       L1.tab_BusRoad[i]=b;
       i++;
    }
    init_bus_c(2,L1);*/
    
    
    /*res=pthread_create(&id_thread,NULL,(void *) init_busStop_c,i);
    if (res!=0)
    {
       printf("error");
       exit(2);
    }
    //pthread_join(id_thread,NULL);*/
    
    //appel de la terminaison Ada/C
    adafinal();
    return 0;
}

//fonction C permettant de recevoir des bus leur position, appel de calculatedelay qui
//permet de verifier si le bus est en retard et lui communiquer son avance/retard
void receivePosition(int id_bus, float x, float y, float x_last, float y_last)
{
     printf("Le centre recois la position du bus %d\n",id_bus);
     //on a la position courante et la position du dernier arret qu'on vient de passer
     //il faut calculer le delai de retard/avance à partir des horaires
}

//fonction c qui permet d'appeller un fonction ADA de mise a jour de l'affichage sur un arret donné
void affichage_arret(int num_arret,char * message)
{
     sendDisplay(num_arret,message);
}

//fonction C lancant l'instanciation d'un arret
void init_busStop_c(int id, float x, float y)
{
  initBusStop(id,x,y);
}

//fonction C qui serialise le type ligne, le passe a l'ADA pour creer le bus
void init_bus_c(int id_bus,struct Line L)
{
     char * l;
     struct Bus b;
     b.id_bus=id_bus;
     b.l=L;
     tab_Bus[id_bus]=b;
     l=serialiser(L);
     lancement_bus(id_bus,L.id_line,L.nb_arret,l);
}

//serialise une ligne en char * pour la passer a l'ADA
char * serialiser(struct Line L)
{
     int i=0;
     char * resultat="";
     char * tempbool="0";
     char * tmp1;
     char * tmp2;
     int taille=0;
     while(i<L.nb_arret)
     {
          if(L.tab_BusRoad[i].required)
          {
           tempbool="1";
          }
          else
          {
           tempbool="0";
          }
          //on libere puis on realloue les variables temporaires
          free(tmp1);
          free(tmp2);
          tmp1=(char*)malloc( sizeof(L.tab_BusRoad[i].id_busStop)+4 );
          tmp2=(char*)malloc( strlen(resultat)*4+sizeof(L.tab_BusRoad[i].id_busStop)+4);

          //On creer la chaine a concatener
          sprintf(tmp1,"%d;%s/",L.tab_BusRoad[i].id_busStop,tempbool);

          //on copie les chaines déjà sauvegardées
          strcpy(tmp2,resultat);
          //on rajoute la portion en cours
          strcat(tmp2,tmp1);
          //on replace le tout dans la variable à retourner
          free(resultat);
          resultat=(char*)malloc(strlen(tmp2));
          strcpy(resultat,tmp2);
         i++;

     }


     return resultat;
}
