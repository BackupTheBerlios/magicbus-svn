gnatmake -c *.adb
gnatbind -n *.ali
gcc -c main.c
gnatlink test.ali main.o -o magicbus