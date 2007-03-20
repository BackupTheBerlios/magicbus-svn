/******************************************************************************/
/******************************************************************************/
/************Main C correspondant au centre controlant le reseau de bus********/
/**** Mattler Florence,Lapeyre Martial, Cazenave Florent, Ménard Alexis********/
/******************************************************************************/
/******************************************************************************/
#include <pthread.h>
#include <time.h>
#include <math.h>
#define NBBUSSTOP 20
#define NBBUS 2
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

//fonction permettant d'envoyer l'avance/retard a un  bus
extern void sendDelay(int id_bus, float delay_t);

//fonction permettant de démarrer un bus qui est arrivé au bout de sa ligne.
extern void restart(int id_bus, int id_line, int nb_arret, char * chaine_serial);

//fonction du centre qui simule qu'un bus a une urgence
extern void simulateEmergency(int id_bus,char * message);

//fonction C permettant de recevoir des bus leur position, appel de calculatedelay qui
//permet de verifier si le bus est en retard et lui communiquer son avance/retard
void receivePosition(int id_bus, float x, float y, float x_last, float y_last);


//fonction C permettant d'indiquer au centre que le bus est arrivé au terminus de sa ligne
void arrivedToTerminus(int id_bus);


//fonction C lancant l'instanciation ADA d'un arret de bus
void init_busStop_c(int id,float x, float y);

//fonction C permettant de mettre a jour l'affichage d'un arret
void affichage_arret(int num_arret, char * message);

//fonction C qui capte les messages d'urgence d'un bus et effectue le traitement associé
void receiveEmergency(int id_bus, char * message, float x, float y);

//fonction C qui calcule si le bus est en avance ou en retard, le communique par la "radio" 
// au bus en question et met a jour l'affichage des arrêts de bus concernés (retard, ...)
void calculateDelay(void * arg);

//fonction C qui selon l'urgence recalcule l'itinéraire du bus
void calculateRoute(void * arg);

//Stucture contenant les informations d'un arret
struct BusStop {
       int num;
       float x;
       float y;
};

//tableau d'arret de bus necessaire pour manipulation dans le centre
struct BusStop tab_BusStop[NBBUSSTOP];

//Stucture une horaire de départ pour un bus
struct horaire {
       int id_bus;
       int minute;
       int heure;
       int seconde;
       };
//tableau d'arret de bus necessaire pour manipulation dans le centre
struct horaire tab_horaires_depart[NBBUS];

//Stucture contenant les informations sur le parcour du bus
struct Bus_road {
       int id_busStop;
       bool required;
       int duree;
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

//fonction qui retourne le tableau des arrets (ligne) passée en paramètres.
void swap_tableau(struct Line * L);

struct param
    {
           int id_bus;
           float x_courant;
           float y_courant;
           float x_dernier;
           float y_dernier;       
    };
    
struct param2
    {
           int id_bus;
           float x_courant;
           float y_courant;
           char * message;       
    };

//main du simulateur
int main(int argc, char *argv[]){
    
    int duree;
    int res;
    int i=1;
    int j;
    int posx,posy,oldposx,oldposy,pos = 0;
    int temps = 0.0;
    int arret_depart;
    struct Line L1;
    struct Line L2;
    struct Bus_road b;
    struct Bus_road b2;
    int nb_alea;
    int heureActuelle=time(NULL)/3600%24+1;
    int minuteActuelle=time(NULL)/60%60;
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
       if(i==1)
       {
               tab_BusStop[i].x=0.0;
               tab_BusStop[i].y=0.0;
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
    duree=0;
    L1.id_line=1;
    arret_depart=1;
    L1.nb_arret=3;
    j=arret_depart;
    posx = posy = oldposx = oldposy = pos = 0;

    //on charge tous les arrêts dans la ligne 1
    while (j<(L1.nb_arret+arret_depart))
    {
       b.required=TRUE;
       b.id_busStop=j;
       
       
       //TODO ajouter un random ?
      /* if(j != 1){
            posx = tab_BusStop[j].x;
            posy = tab_BusStop[j].y;
            pos = sqrt((oldposx-posx)*(oldposx-posx)+(oldposy-posy)*(oldposy-posy))*10;
            temps = (pos/25);
            printf("================== >>>temps : %d \n",temps);
            oldposx = posx;
            oldposy = posy;
            
       }*/
               
 
       
       b.duree=duree;
       duree=duree+1;
       L1.tab_BusRoad[(j-arret_depart)]=b;
       j++;

    }
    /**************************************************************************/
    /************************Mise en place de l'heure de départ****************/
    /**************************************************************************/

    tab_horaires_depart[1].heure=heureActuelle;
    tab_horaires_depart[1].minute=minuteActuelle;
    tab_horaires_depart[1].seconde=time(NULL)%60;
    tab_horaires_depart[1].id_bus=1;
    printf("vaant init\n");
    init_bus_c(1,L1);

    sleep(12000);
    //on simule une urgence sur le bus 1
    simulateEmergency(1,"Probleme de freins");
  /*
    //2 eme bus a instancier si on veut faire mumuz
    
    
    L2.id_line=2;
    arret_depart=3;
    j=arret_depart;
    L2.nb_arret=3;
    duree=0;
    //on charge tous les arrêts dans la ligne 2
    while (j<(L2.nb_arret+arret_depart))
    {
       b2.required=TRUE;
       b2.id_busStop=j;
        //TODO ajouter un random ?
       b2.duree=duree;
       duree=duree+3;
       L2.tab_BusRoad[(j-arret_depart)]=b2;
       j++;
    }
   tab_horaires_depart[2].heure=heureActuelle;
   tab_horaires_depart[2].minute=minuteActuelle+1;
   tab_horaires_depart[2].seconde=0;
   tab_horaires_depart[2].id_bus=2;

    init_bus_c(2,L2);*/

    //appel de la terminaison Ada/C
    adafinal();
    return 0;
}

//fonction C permettant de recevoir des bus leur position, appel de calculatedelay qui
//permet de verifier si le bus est en retard et lui communiquer son avance/retard
void receivePosition(int id_bus, float x, float y, float x_last, float y_last)
{
    struct param p;
    int res;
    pthread_t id_thread;
    p.id_bus=id_bus;
    p.x_courant=x;
    p.y_courant=y;
    p.x_dernier=x_last;
    p.y_dernier=y_last;
    //on a la position courante et la position du dernier arret qu'on vient de passer
    //il faut calculer le delai de retard/avance à partir des horaires
    res=pthread_create(&id_thread,NULL,(void *) calculateDelay,&p);

    if (res!=0)
    {
       printf("error");
       exit(2);
    }
      sleep(2000);
     //pthread_join(id_thread,NULL);
     //printf("Le centre recoit la position du bus %d\n",id_bus);

    
     
}

//fonction C permettant d'indiquer au centre que le bus est arrivé au terminus de sa ligne
void arrivedToTerminus(int id_bus)
{
   
   
    int heureActuelle=time(NULL)/3600%24+1;
    int minuteActuelle=time(NULL)/60%60;
    int i=0;
    printf("###########################################on change de sens dans le centre\n");
    //le bus est arrété dans l'ada...il attend que le centre passe une nouvelle ligne et qu'il lui dise de 
    //repartir...
    //on retourne le tableau des arrets si on souhaite repartir dans l'autre sens
   swap_tableau(&tab_Bus[id_bus].l);
   tab_horaires_depart[id_bus].heure=heureActuelle;
   tab_horaires_depart[id_bus].minute=minuteActuelle;
   tab_horaires_depart[id_bus].seconde=time(NULL)%60;
   restart(id_bus,tab_Bus[id_bus].l.id_line,tab_Bus[id_bus].l.nb_arret, serialiser(tab_Bus[id_bus].l));

     
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
     printf(" ");
     b.id_bus=id_bus;
     b.l=L;
     tab_Bus[id_bus]=b;
     l=serialiser(L);
     printf("avant lancement\n");
     lancement_bus(id_bus,L.id_line,L.nb_arret,l);
     printf("apres lancement\n");
}


//fonction C qui calcule si le bus est en avance ou en retard, le communique par la "radio" 
// au bus en question et met a jour l'affichage des arrêts de bus concernés (retard, ...)
void calculateDelay(void * arg)
{
 //TODO remettre l'heure de demarrage au lancement du bus
     int indice=1;
     int i,k;
     int j=0;
     int trouve=FALSE;
     int id_last_busstop;
     int duree_last_busstop;
     int id_next_busstop;
     int duree_next_busstop;
     int tmpSeconde,duree_entre_deux_arrets;
     int indice_avant = 0;
     int indice_arriere = 0;
     int indice_temp1;
     int indice_temp2;
     char * envoi;
     float next_x;
     float next_y;
     float theoric_x,theoric_y;
     float distance, theoric_distance;
     float tmp,reelle_distance;
     float resultat;
     struct param * pa = (struct param *) arg;
     struct horaire depart_bus;
     int heureActuelle=time(NULL)/3600%24+1;
     int minuteActuelle=time(NULL)/60%60;
     int idbus=(*pa).id_bus;
     struct Bus_road temp[50];
 
     printf("************Reception de la position du bus %d******************\n",(*pa).id_bus);
     //on cherche le bus ayant l'id (*pa).id_bus
     while(tab_Bus[indice].id_bus!=idbus && indice<NBBUS)
     {
       indice++;
     }
     if(indice==NBBUS)
    {
       printf("error");
       exit(2);
    }
    for(j = 0; j < tab_Bus[indice].l.nb_arret; j++)
    {
       printf("JAJJAJAJAJAJA %d\n",tab_Bus[indice]. l. tab_BusRoad[j].id_busStop);
    }
    j=1;

     //On recupere l'id du dernier arret passé
     while( trouve==FALSE && j<=NBBUSSTOP)
     {
      if((tab_BusStop[j].x==(*pa).x_dernier)&& (tab_BusStop[j].y==(*pa).y_dernier)) {
            trouve=TRUE;
            id_last_busstop=tab_BusStop[j].num;
            printf("CENTRE dernier arret capte %d\n",tab_BusStop[j].num);
            printf("CENTRE *pa %f\n",(*pa).x_dernier);
            printf("CENTRE *pa %f\n",(*pa).y_dernier);
       }
       j++;
     }
     

     //on recupere l'id du prochain arret de bus
      trouve=FALSE;
      i=0;
      while( trouve==FALSE && i<tab_Bus[indice].l.nb_arret)
      {
             if(tab_Bus[indice].l.tab_BusRoad[i].id_busStop==id_last_busstop)
             {
                duree_last_busstop=tab_Bus[indice].l.tab_BusRoad[i].duree;
                duree_next_busstop=tab_Bus[indice].l.tab_BusRoad[i+1].duree;
                id_next_busstop=tab_Bus[indice].l.tab_BusRoad[i+1].id_busStop;
                trouve=TRUE;
             }
             i++;
      }
      for(j = 0; j < tab_Bus[indice].l.nb_arret; j++)
    {
       printf("JJSDHUFGSDJFGFHFH %d\n",tab_Bus[indice]. l. tab_BusRoad[j].id_busStop);
    }

      //on recupere la position du prochain arret
      trouve=FALSE;
      j=1;
      while( trouve==FALSE && j<=NBBUSSTOP)
     {
             printf("on boucle \n");
              if(id_next_busstop==tab_BusStop[j].num)
              {
                 trouve=TRUE;
                 next_x=tab_BusStop[j].x;
                 next_y=tab_BusStop[j].y;
                 printf("le prochain arret Y est %f\n",next_y);
                 printf("le prochain arret X est %f\n",next_x);
              }
              j++;
      }
      
      printf("l'ancien bus stop est %d, le nouveau :%d\n",id_last_busstop,id_next_busstop);

     //recuperation de l'heure de depart du bus
      trouve=FALSE;
      j=0;
      while( trouve==FALSE && j<=NBBUS)
     {
              if((*pa).id_bus=tab_horaires_depart[j].id_bus)
              {
                 trouve=TRUE;
                 depart_bus.minute=tab_horaires_depart[j].minute;
                 depart_bus.heure=tab_horaires_depart[j].heure;
                 depart_bus.seconde=tab_horaires_depart[j].seconde;

              }
              j++;
      }

     //printf(" le bus a demarrer a %d:%d\n",depart_bus.heure,depart_bus.minute);

     //calcul de la distance entre les deux arrets
     // la distance entre 2 points de coordonnées (x1,y1) et (x2,y2)
     // est = racine_carree((x1-x2)² + (y1-y2)²)
     //TODO verifier pkoi X 10
     distance=sqrt(((*pa).x_dernier-next_x)*((*pa).x_dernier-next_x)+((*pa).y_dernier-next_y)*((*pa).y_dernier-next_y))*10;
     printf("   --------------->>>distance : %f \n",distance);

     //il est actuellement heureActuelle:minuteActuelle
     //calcul de la position theorique du bus
     duree_entre_deux_arrets=(duree_next_busstop-duree_last_busstop)*60;
     printf("   --------------->>>duree_entre_deux_arrets : %d \n",duree_entre_deux_arrets);
     //temps passé depuis le dernier arret
     tmpSeconde = (heureActuelle*3600+minuteActuelle*60+(time(NULL))%60)- (depart_bus.heure*3600+depart_bus.minute*60+depart_bus.seconde);//duree_last_busstop*60
     printf("   --------------->>>tmpSeconde : %d \n",tmpSeconde);

     //on aurait donc dû parcourir theoric_distance depuis le dernier arret passé
     theoric_distance=(float)distance*tmpSeconde/duree_entre_deux_arrets;
     printf("   --------------->>>theoric_distance : %f \n",theoric_distance);
     
     

     //or on en a parcouru
     reelle_distance=sqrt(((*pa).x_dernier-(*pa).x_courant)*((*pa).x_dernier-(*pa).x_courant)+((*pa).y_dernier-(*pa).y_courant)*((*pa).y_dernier-(*pa).y_courant))*10;

     printf("*   on a parcouru %f à la place de %f\n",reelle_distance,theoric_distance);

     resultat=(float)duree_entre_deux_arrets*(theoric_distance-reelle_distance)/distance;
     printf("*   Retard a envoyer : %f\n",-resultat);
     printf("***************************************************************\n");
     sendDelay((*pa).id_bus,-resultat);

     // envoie des affichages indiquants aux busstop suivants le retard/avance du bus
     
     trouve=FALSE;
      j=0;
      envoi=malloc(100);
      while( j<tab_Bus[indice].l.nb_arret)
     {
              
              
              if(tab_Bus[indice].l.tab_BusRoad[j].id_busStop==id_next_busstop)
              {
                  
                  trouve=TRUE;
              }
              if(trouve==TRUE)
              {
              
                  
                  if(resultat<0)
                  {
                      sprintf(envoi,"affichage arret %d: le bus %d a %f secondes d'avance\n",tab_Bus[indice].l.tab_BusRoad[j].id_busStop,idbus,-resultat);
                  }else
                  {
                      sprintf(envoi,"affichage arret %d: le bus %d a %f secondes de retard\n",tab_Bus[indice].l.tab_BusRoad[j].id_busStop,idbus,resultat); 
                  } 
                  printf("on envoi sur le bisstop %d\n",tab_Bus[indice].l.tab_BusRoad[j].id_busStop);
                  affichage_arret(tab_Bus[indice].l.tab_BusRoad[j].id_busStop,envoi);
              
              }
              

              j++;
      }




     // sendDelay((*pa).id_bus,-2.0);
}

//fonction C qui capte les messages d'urgence d'un bus et effectue le traitement associé
void receiveEmergency(int id_bus, char * message, float x, float y)
{
    int res;
    struct param2 p;
    pthread_t id_thread;
    p.id_bus=id_bus;
    p.message=message;
    p.x_courant=x;
    p.y_courant=y;
    //on thread pour traiter en parallele les demandes d'urgence
    res=pthread_create(&id_thread,NULL,(void *) calculateRoute,&p);
    if (res!=0)
    {
       printf("error");
       exit(2);
    }
    //pthread_join(id_thread,NULL);*/
     printf("Le centre recoit une urgence du bus : %d\n",id_bus);
}

//fonction C qui selon l'urgence recalcule l'itinéraire du bus
void calculateRoute(void * arg)
{
     struct param2 * pa = (struct param2 *) arg;
     char * message=(*pa).message;
     //on calcule la route MARTIAL ToDO DEMERDE TOI :p
     printf("Le message d'urgence est : %s\n",message);    
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

     //printf(" $$$$$$ resultat de la serialisation %s\n",resultat);
     return resultat;
}

//fonction qui échange les éléments du tableau (inversion de la ligne des bus stops)
void swap_tableau(struct Line * L){
     int i = 0;
     int j = 0;
     int k = (*L).nb_arret-1;
     struct Bus_road temp[50];
     for(j = 0; j < (*L).nb_arret; j++){
         temp[k] = (*L).tab_BusRoad[j];
         temp[k].duree = (*L).tab_BusRoad[k].duree;
         
         k--;
     }
     for(j = 0; j < (*L).nb_arret; j++){
         (*L).tab_BusRoad[j]=temp[j];
     }
     
}








