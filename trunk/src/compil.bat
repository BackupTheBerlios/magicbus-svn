del b~*.*
del *.ali
del *.o
gcc -c main.c
gnatmake -c *.adb
gnatbind -n *.ali
gnatlink init_object.ali main.o -o magicbus -L"C:\GNAT\lib\gcc-lib\pentium-mingw32msv\2.8.1" C:\GNAT\lib\gcc-lib\pentium-mingw32msv\2.8.1\libpthreadGCE2.a C:\GNAT\lib\gcc-lib\pentium-mingw32msv\2.8.1\pthreadVC2.lib C:\GNAT\lib\gcc-lib\pentium-mingw32msv\2.8.1\pthreadVCE2.lib C:\GNAT\lib\gcc-lib\pentium-mingw32msv\2.8.1\pthreadVSE2.lib C:\GNAT\lib\gcc-lib\pentium-mingw32msv\2.8.1\libpthreadGC2.a 


