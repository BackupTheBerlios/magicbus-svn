extern void lancement();
extern void adainit();
extern void adafinal();
void affichage();

int main(int argc, char *argv[]){
printf("Cest parti");
adainit();
lancement();
adafinal();
return 0;
}

void affichage()
{
printf("Ada m'a appele\n");
}