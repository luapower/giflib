gcc -arch i386 -O2 *.c -shared -install_name @loader_path/libgiflib.dylib -o ../../bin/osx32/libgif.dylib -I.
