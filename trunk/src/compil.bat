del b~*.*
gcc -c main.c
gnatmake -c *.adb
gnatbind -n *.ali
gnatlink test.ali main.o -o magicbus