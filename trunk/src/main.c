
extern void lancement();
extern void adainit();
extern void adafinal();
void affichage(char * test[]);

int main(int argc, char *argv[]){
	printf("%s\n","Main C en route");
	adainit();
	lancement("Bienvenue dans magicbus (param envoye de C vers ADA)");
	adafinal();
	return 0;
}

void affichage(char * test[])
{
	printf("%s\n",test);
}