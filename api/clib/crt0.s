.export _init, _exit
.import _main, _puts

.export __STARTUP__ : absolute = 1
.import __HEAP_START__, __HEAP_SIZE__, __DATA_SIZE__, __DATA_LOAD__, __DATA_RUN__

.import zerobss, initlib, donelib, copydata

.include "zeropage.inc"

.rodata

cwelcome:
    .byte "C Runtime starting...",$00

cdone:
    .byte "done.",$a,$00

.segment "STARTUP"

_init:  lda #<(__HEAP_START__+__HEAP_SIZE__)
        sta sp
        lda #>(__HEAP_START__+__HEAP_SIZE__)
        sta sp+1
;        lda #<cwelcome
;        ldx #>cwelcome
;        jsr _puts
        jsr zerobss
        jsr copydata
        jsr initlib
;        lda #<cdone
;        ldx #>cdone
;        jsr _puts
        jsr _main

_exit:
        jsr donelib
        jmp $fff0
