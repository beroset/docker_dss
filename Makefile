work/opendsscmd : electric-dss/CMD_Lazz/CMD/opendsscmd 
	cp $^ $@

electric-dss/CMD_Lazz/units: 
	mkdir electric-dss/CMD_Lazz/units

electric-dss/CMD_Lazz/CMD/opendsscmd.res : electric-dss/CommandLine/OpenDSS.res
	cp $^ $@

electric-dss/CMD_Lazz/CMD/opendsscmd : electric-dss/CMD_Lazz/lib/libklusolve.a electric-dss/CMD_Lazz/units electric-dss/CMD_Lazz/CMD/opendsscmd.res 
	cd electric-dss/CMD_Lazz/CMD && fpc @fpcopts.cfg -k-L/usr/lib/gcc/x86_64-redhat-linux/9 -k-lstdc++ -k-lc -k-lm -k-lgcc_s -B opendsscmd.lpr

electric-dss/CMD_Lazz/lib/libklusolve.a: klusolve/Lib/libklusolve.a
	cp klusolve/Lib/*.a electric-dss/CMD_Lazz/lib/

klusolve/Lib/libklusolve.a : klusolve/Makefile
	mkdir -p klusolve/Lib 
	cd klusolve && make all
