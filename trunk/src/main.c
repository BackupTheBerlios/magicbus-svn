
#include <pthread.h>
#include <unistd.h>
#include <fcntl.h>


extern void lancement(char * s);
extern void initBusStop(char * s,int id, int x, int y);
extern void adainit();
extern void adafinal();
void affichage(char * test[]);
void init_busStop_c(int num);

int main(int argc, char *argv[]){
    pthread_t id_thread;
    char * s="Bienvenue dans magicbus (param envoye de C vers ADA)";
    int res;
    int i=3;
    printf("%s\n","Main C en route");
    adainit();
    res=pthread_create(&id_thread,NULL,(void *) lancement,s);
    if (res!=0)
    {
       printf("error");
       exit(2);
    }
    pthread_join(id_thread,NULL);
    adafinal();
    return 0;
}

void affichage(char * test[])
{
        printf("%s\n",test);
}
void init_busStop_c(int num)
{
   char * s="Arret test";
   int x=3;
   int y=5;
   initBusStop(s,num,x,y);
}
