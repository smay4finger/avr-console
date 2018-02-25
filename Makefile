TARGET    = main
OBJECTS   = main.o console.o
MCU       = atmega328p
OPTIMIZE  = -Os
DEFS      = -DF_CPU=16000000UL -DBAUD=57600UL
LIBS      = 

PROGRAMMER= -P /dev/ttyUSB0 -b 57600 -c arduino

###############################################################################
#### DO NOT CHANGE ANYTHING FROM HERE #########################################
###############################################################################

LDFLAGS   = -mmcu=$(MCU) -Wl,-Map,$(TARGET).map
CFLAGS    = -mmcu=$(MCU) -g -Wall -Wstrict-prototypes -W $(OPTIMIZE) $(DEFS)
ASFLAGS   = -mmcu=$(MCU) -gstabs $(DEFS)

CC        = avr-gcc
OBJCOPY   = avr-objcopy
OBJDUMP   = avr-objdump

.PHONY: all prog prog_erase prog_flash prog_eeprom srec bin clean

#
# the all rule for building the whole target
# 
all: $(TARGET:=.elf) $(TARGET:=.lst)
	@avr-size --mcu=$(DEVICE) --format=avr $<

#
# link all objects into elf target
# 
$(TARGET:=.elf): $(OBJECTS)
	$(CC) $(LDFLAGS) $(LIBS) -o $@ $^ 

#
# program target into controller
# 
prog: srec
	avrdude $(PROGRAMMER) -p $(MCU) -e -U flash:w:$(TARGET:=_flash.$<) -U eeprom:w:$(TARGET:=_eeprom.$<)
	
#
# generate srec or bin files from target
#
srec: $(TARGET:=_flash.srec) $(TARGET:=_eeprom.srec)
bin: $(TARGET:=_flash.bin) $(TARGET:=_eeprom.bin)
hex: $(TARGET:=_flash.hex) $(TARGET:=_eeprom.hex)

#
# the usual cleanup
#
clean:
	rm -f $(TARGET:=.elf) $(TARGET:=.lst) $(TARGET:=.map) 
	rm -f $(TARGET:=*.bin) $(TARGET:=*.srec) $(TARGET:=*.hex)
	rm -f $(OBJECTS) $(EXTRA_CLEAN_FILES)

####################################################################################
# some special file generation rules
#

#
# rule to make listing out of elf file
#
%.lst: %.elf
	$(OBJDUMP) -h -S $< > $@
	
#
# copy special sections out of elf file
#
%_flash.bin: %.elf
	$(OBJCOPY) -O binary -j .text -j .data $< $@
%_eeprom.bin: %.elf
	$(OBJCOPY) -O binary -j .eeprom --change-section-lma .eeprom=0 $< $@

%_flash.srec: %.elf
	$(OBJCOPY) -O srec   -j .text -j .data $< $@
%_eeprom.srec: %.elf
	$(OBJCOPY) -O srec   -j .eeprom --change-section-lma .eeprom=0 $< $@

%_flash.hex: %.elf
	$(OBJCOPY) -O ihex   -j .text -j .data $< $@
%_eeprom.hex: %.elf
	$(OBJCOPY) -O ihex   -j .eeprom --change-section-lma .eeprom=0 $< $@
