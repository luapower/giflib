gcc -arch x86_64 -O2 *.c -shared -install_name @loader_path/libgiflib.dylib -o ../../bin/osx64/libgif.dylib -I.
