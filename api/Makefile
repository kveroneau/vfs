%.s: %.c
	cc65 $<

%.o: %.s
	ca65 $<

%.eXe: %.o
	ld65 -C clib/vfs6502.cfg -o $@ $^ clib/vfs6502.lib
	cp $@ siteroot/vfs/Apps/$@

BOOT.SYS: bootsys.s
	ca65 $<
	ld65 -C clib/bootsys.cfg -o $@ bootsys.o
	cp $@ siteroot/vfs/$@

KERNEL.SYS: kernel.o
	ld65 -C clib/vfs6502.cfg -o $@ $^ clib/vfs6502.lib
	cp $@ siteroot/vfs/System/$@

clean:
	rm -rf *.o *.eXe *.SYS
