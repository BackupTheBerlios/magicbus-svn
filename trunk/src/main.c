/******************************************************************************/
/******************************************************************************/
/************Main C correspondant au centre controlant le reseau de bus********/
/**** Mattler Florence,Lapeyre Martial, Cazenave Florent, Ménard Alexis********/
/******************************************************************************/
/******************************************************************************/
#include <pthread.h>
#include <stdio.h>
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


//fonction qui retourne le bus stop correspondant à l'id passé en paramètre
struct BusStop getBusStop(int idBusStop);

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

//fonction initialisant le fichier d'archive
void initArchivage();

//procedure permettant la sauvegarde d'une evenement passé en paramètre
void archiver (char * message);

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
    
    float duree;
    int res;
    int i=1;
    int j;
    float posx,posy,oldposx,oldposy,pos = 0.0;
    float temps = 0.0;
    int arret_depart;
    struct Line L1;
    struct Line L2;
    struct Bus_road b;
    struct Bus_road b2;
    int nb_alea;
    int heureActuelle=time(NULL)/3600%24+1;
    int minuteActuelle=time(NULL)/60%60;
    //lancement de la configuration ADA/C    
    adainit();
    //initialisation de larchiveur (raz du fichier log.txt)
    initArchivage();
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
    posx = posy = oldposx = oldposy = pos = 0.0;

    //on charge tous les arrêts dans la ligne 1
    while (j<(L1.nb_arret+arret_depart)){
       b.required=TRUE;
       b.id_busStop=j;
       temps=0.0;
       if(j != 1){
            posx = tab_BusStop[j].x;
            posy = tab_BusStop[j].y;
            pos = sqrt((oldposx-posx)*(oldposx-posx)+(oldposy-posy)*(oldposy-posy))*10;
            pos = (pos/1000);   //pos en km
            temps= pos/30;
            temps=temps*3600;
            duree=duree+temps;
            oldposx = posx;
            oldposy = posy;
       }
       b.duree=duree;
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
    init_bus_c(1,L1);

    sleep(12000);
    //on simule une urgence sur le bus 1
    simulateEmergency(1,"Probleme de freins");

    //2 eme bus a instancier si on veut faire mumuz
    
  /*
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

    init_bus_c(2,L2);
       */
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
    char * archivage=(char*)malloc(100);
    pthread_t id_thread;
    p.id_bus=id_bus;
    p.x_courant=x;
    p.y_courant=y;
    p.x_dernier=x_last;
    p.y_dernier=y_last;

    //archivage de la reception
    sprintf(archivage,"%d:%d:%d;bus:%d;position(%3.2f,%3.2f)\n",time(NULL)/3600%24+1,time(NULL)/60%60,time(NULL)%60,id_bus,x,y);
    archiver (archivage);

    //on a la position courante et la position du dernier arret qu'on vient de passer
    //il faut calculer le delai de retard/avance à partir des horaires
    res=pthread_create(&id_thread,NULL,(void *) calculateDelay,&p);

    if (res!=0)
    {
       printf("error");
       exit(2);
    }
      sleep(2000);


    
     
}

//fonction C permettant d'indiquer au centre que le bus est arrivé au terminus de sa ligne
void arrivedToTerminus(int id_bus)
{
   
   
    int heureActuelle=time(NULL)/3600%24+1;
    int minuteActuelle=time(NULL)/60%60;
    int i=0;
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
     lancement_bus(id_bus,L.id_line,L.nb_arret,l);
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
    j=1;

     //On recupere l'id du dernier arret passé
     while( trouve==FALSE && j<=NBBUSSTOP)
     {
      if((tab_BusStop[j].x==(*pa).x_dernier)&& (tab_BusStop[j].y==(*pa).y_dernier)) {
            trouve=TRUE;
            id_last_busstop=tab_BusStop[j].num;

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
   /*   for(j = 0; j < tab_Bus[indice].l.nb_arret; j++)
    {
       printf("JJSDHUFGSDJFGFHFH %d\n",tab_Bus[indice]. l. tab_BusRoad[j].id_busStop);
    }      */

      //on recupere la position du prochain arret
      trouve=FALSE;
      j=1;
      while( trouve==FALSE && j<=NBBUSSTOP)
     {

              if(id_next_busstop==tab_BusStop[j].num)
              {
                 trouve=TRUE;
                 next_x=tab_BusStop[j].x;
                 next_y=tab_BusStop[j].y;

              }
              j++;
      }
      


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



     //calcul de la distance entre les deux arrets
     // la distance entre 2 points de coordonnées (x1,y1) et (x2,y2)
     // est = racine_carree((x1-x2)² + (y1-y2)²)

     distance=sqrt(((*pa).x_dernier-next_x)*((*pa).x_dernier-next_x)+((*pa).y_dernier-next_y)*((*pa).y_dernier-next_y))*10;


     //il est actuellement heureActuelle:minuteActuelle
     //calcul de la position theorique du bus
     duree_entre_deux_arrets=(duree_next_busstop-duree_last_busstop);

     //temps passé depuis le dernier arret
     tmpSeconde = (heureActuelle*3600+minuteActuelle*60+(time(NULL))%60)- (depart_bus.heure*3600+depart_bus.minute*60+depart_bus.seconde);//duree_last_busstop*60


     //on aurait donc dû parcourir theoric_distance depuis le dernier arret passé
     theoric_distance=(float)distance*tmpSeconde/duree_entre_deux_arrets;

     //or on en a parcouru
     reelle_distance=sqrt(((*pa).x_dernier-(*pa).x_courant)*((*pa).x_dernier-(*pa).x_courant)+((*pa).y_dernier-(*pa).y_courant)*((*pa).y_dernier-(*pa).y_courant))*10;

     printf("*   on a parcouru %4.2f a la place de %4.2f\n",reelle_distance,theoric_distance);

     resultat=(float)duree_entre_deux_arrets*(theoric_distance-reelle_distance)/distance;
     if(resultat < 0.0){
          printf("***************************************************************\n");
          printf("*   Le bus est en avance de : %3.2f secondes * \n",-resultat);
          printf("***************************************************************\n");
     }
     else{
         printf("***************************************************************\n");
         printf("*   Le bus est en retard de : %3.2f secondes * \n",resultat);
         printf("***************************************************************\n");
     }

     sendDelay((*pa).id_bus,-resultat);

     // envoie des affichages indiquants aux busstop suivants le retard/avance du bus
     
     trouve=FALSE;
     j=0;
     envoi=(char *)malloc(100);
     while( j<tab_Bus[indice].l.nb_arret)
     {
              if(tab_Bus[indice].l.tab_BusRoad[j].id_busStop==id_next_busstop)
              {
                  trouve=TRUE;
              }
              if(trouve==TRUE){
                 if(resultat<0){
                   sprintf(envoi,"affichage arret %d: le bus %d a %3.2f secondes d'avance\n",tab_Bus[indice].l.tab_BusRoad[j].id_busStop,idbus,-resultat);
                 }else{
                    sprintf(envoi,"affichage arret %d: le bus %d a %3.2f secondes de retard\n",tab_Bus[indice].l.tab_BusRoad[j].id_busStop,idbus,resultat);
                 }
                 printf("on envoi sur le bisstop %d\n",tab_Bus[indice].l.tab_BusRoad[j].id_busStop);
                 affichage_arret(tab_Bus[indice].l.tab_BusRoad[j].id_busStop,envoi);
              }
              j++;
      }
}

//fonction C qui capte les messages d'urgence d'un bus et effectue le traitement associé
void receiveEmergency(int id_bus, char * message, float x, float y)
{
    int res;
    struct param2 p;
    char * archivage=(char*)malloc(100);
    pthread_t id_thread;
    p.id_bus=id_bus;
    p.message=message;
    p.x_courant=x;
    p.y_courant=y;

    //archivage des informations dans log.txt
    sprintf(archivage,"%d:%d:%d;bus:%d;Urgence(%3.2f,%3.2f)\n",time(NULL)/3600%24+1,time(NULL)/60%60,time(NULL)%60,id_bus,x,y);
    archiver (archivage);
    //on thread pour traiter en parallele les demandes d'urgence
    res=pthread_create(&id_thread,NULL,(void *) calculateRoute,&p);
    if (res!=0)
    {
       printf("error");
       exit(2);
    }
    //pthread_join(id_thread,NULL);
     printf("Le centre recoit une urgence du bus : %d\n",id_bus);


}

//fonction C qui selon l'urgence recalcule l'itinéraire du bus
void calculateRoute(void * arg)
{
     struct param2 * pa = (struct param2 *) arg;
     char * message=(*pa).message;
     //TODO

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

//fonction qui échange les éléments du tableau (inversion de la ligne des bus stops)
void swap_tableau(struct Line * L){
     int i = 0;
     int j = 0;
     int k = (*L).nb_arret-1;
     float pos,posx,posy,oldposx,oldposy,temps,duree = 0.0;
     struct Bus_road temp[50];
     for(j = 0; j < (*L).nb_arret; j++){
         temp[k] = (*L).tab_BusRoad[j];
         k--;
     }
     for(j = 0; j < (*L).nb_arret; j++){
         (*L).tab_BusRoad[j]=temp[j];
     }
     //calcul des heures de passage du bus
     (*L).tab_BusRoad[0].duree = 0;
     oldposx = getBusStop((*L).tab_BusRoad[0].id_busStop).x;
     oldposy = getBusStop((*L).tab_BusRoad[0].id_busStop).y;
     for(j = 1; j < (*L).nb_arret; j++){
       temps=0.0;
       posx = getBusStop((*L).tab_BusRoad[j].id_busStop).x;
       posy = getBusStop((*L).tab_BusRoad[j].id_busStop).y;
       pos = sqrt((oldposx-posx)*(oldposx-posx)+(oldposy-posy)*(oldposy-posy))*10;
       pos = (pos/1000);   //pos en km
       temps= pos/30;      //une vitesse moyenne de 30km/h
       temps=temps*3600;   //en secondes
       duree=duree+temps;
       oldposx = posx;
       oldposy = posy;
       (*L).tab_BusRoad[j].duree = duree;
     }
}


struct BusStop getBusStop(int idBusStop){
      int j,trouve;

      trouve=FALSE;
      j=1;
      while(trouve==FALSE && j<=NBBUSSTOP){
          if(idBusStop==tab_BusStop[j].num){
             trouve=TRUE;
             return tab_BusStop[j];
             }
           j++;
      }
}
void initArchivage()
{
   FILE *file = fopen("log.txt","w");
   fclose(file);
}
void archiver (char * message)
{

   FILE *file = fopen("log.txt","a+");
   if (file == NULL) {
      printf("Erreur dans l'ouverture du fichier\n");
      exit(-1);
    }
   fwrite(message,1,strlen(message),file);
   fclose(file);
}






