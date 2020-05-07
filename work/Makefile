LIBGCC_FILE := $(shell gcc -print-libgcc-file-name)
STATIC_LIBDIR := $(dir $(LIBGCC_FILE))
LOADER:=/lib/ld-musl-x86_64.so.1


opendsscmd : electric-dss/CMD_Lazz/CMD/opendsscmd 
	cp $^ $@

electric-dss/CMD_Lazz/units: 
	mkdir electric-dss/CMD_Lazz/units

electric-dss/CMD_Lazz/CMD/opendsscmd.res : electric-dss/CommandLine/OpenDSS.res
	cp $^ $@

electric-dss/CMD_Lazz/CMD/opendsscmd : electric-dss/CMD_Lazz/lib/libklusolve.a electric-dss/CMD_Lazz/units electric-dss/CMD_Lazz/CMD/opendsscmd.res electric-dss/CMD_Lazz/CMD/opendsscmd.lpr
	cd electric-dss/CMD_Lazz/CMD && fpc @fpcopts.cfg -k-L"$(STATIC_LIBDIR)" -k-lstdc++ -k-lc -k-lm -k-lgcc_s -B -gl -Xm -FL"$(LOADER)" opendsscmd.lpr

electric-dss/CMD_Lazz/lib/libklusolve.a: KLUSolve/Lib/libklusolve.a
	cp KLUSolve/Lib/*.a electric-dss/CMD_Lazz/lib/

KLUSolve/Lib/libklusolve.a: KLUSolve/Makefile
	mkdir -p KLUSolve/Lib
	cd KLUSolve && make all

.PHONY: clean
clean:
	rm electric-dss/CMD_Lazz/CMD/opendsscmd opendsscmd
	cd KLUSolve && make clean
