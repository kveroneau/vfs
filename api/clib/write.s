.include "_file.inc"

.export _write
.import popax

.importzp tmp1

.code

.proc _write: near
    sta tmp1
    jsr popax
    sta $40
    stx $41
    jsr popax
    cmp #1
    beq :+
    rts
:   ldy #0
    jmp $ffd0
.endproc
