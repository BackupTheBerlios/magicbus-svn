del b~*.*
del *.ali
gnatmake -c *.adb
gnatbind -n *.ali
gnatlink test.ali main.o -o magicbus