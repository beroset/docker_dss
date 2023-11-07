LIBGCC_FILE := $(shell gcc -print-libgcc-file-name)
STATIC_LIBDIR := $(dir $(LIBGCC_FILE))
ifdef LOADER
FPC_EXTRA:="-FL$(LOADER)"
endif

opendsscmd : epri/electric-dss/CMD/test/opendsscmd 
	cp $^ $@

epri/electric-dss/CMD/units: 
	mkdir epri/electric-dss/CMD/units

epri/electric-dss/CMD/test/opendsscmd : KLUSolve/Lib/libklusolve.a linenoise-ng/build/liblinenoise.so epri/electric-dss/CMD/units epri/electric-dss/CMD/opendsscmd.lpr
	cd epri/electric-dss/CMD && fpc @linuxopts.cfg -k-L"$(STATIC_LIBDIR)" "$(FPC_EXTRA)" opendsscmd.lpr

linenoise-ng/build/liblinenoise.so : linenoise-ng/build/Makefile
	cd linenoise-ng && cmake --build build

linenoise-ng/build/Makefile : linenoise-ng/CMakeLists.txt
	cd linenoise-ng && cmake -DCMAKE_BUILD_TYPE=Release -S . -B build

KLUSolve/Lib/libklusolve.a: KLUSolve/Makefile
	mkdir -p KLUSolve/Lib
	cd KLUSolve && make all

.PHONY: clean
clean:
	-rm epri/electric-dss/CMD/opendsscmd opendsscmd
	-rm -rf linenoise-ng/build
	cd KLUSolve && make clean
