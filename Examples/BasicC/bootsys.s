
.rodata

startmsg:
    .byte "System starting...",$0

sitetitle:
    .byte "C Library Test Site",$0

adminpass:
    .byte "password",$0

kernelsys:
    .byte "vfs/System/KERNEL.SYS",$0

loading:
    .byte "Loading KERNEL.SYS...",$0

.code

.proc _syswrite: near
    sta $40
    stx $41
    ldy #$1
    jmp $ffd0
.endproc

.proc loadkernel: near
    lda #<loading
    ldx #>loading
    jsr _syswrite
    lda #<kernelsys
    sta $40
    lda #>kernelsys
    sta $41
    lda #$0
    sta $46
    lda #$20
    sta $47
    ldy #$e
    jsr $ffc0
    jmp $2000
    rts
.endproc

.segment "STARTUP"

ldx #$ff
txs
cld
lda #<startmsg
ldx #>startmsg
jsr _syswrite
lda #<sitetitle
sta $50
lda #>sitetitle
sta $51
lda #<adminpass
sta $a0
lda #>adminpass
sta $a1
lda #<kernelsys
sta $40
lda #>kernelsys
sta $41
ldy #$f
jsr $ffc0
beq done
jsr loadkernel
done:
  jmp $fff0
