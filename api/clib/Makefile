SOURCES = crt0.s vfs6502.s write.s

LIBRARY = vfs6502.lib

all: $(LIBRARY)

$(LIBRARY): $(SOURCES:.s=.o)
	ar65 a $(LIBRARY) $^

%.o: %.s
	ca65 $<

clean:
	rm -rf $(SOURCES:.s=.o)
