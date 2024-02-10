.import popax

.export _puts
.export _SetSiteTitle, _SetPageTitle, _SetTemplate, _SetSiteHeader, _SetAdminPass
.export _SetContentHandler, _EndRequest, _SetRedirect
.export _SetFolderVector, _SetInfoVector, _SetAdminVector

.export _GetQuery, _IsQuery
.export _GetPost, _SetSession, _GetSession

.export _GetPRGName, _GetPathInfo, _GetPrefix
.export _FileExists, _LoadPRGFile
.export _WriteFile, _SaveFile, _LoadFile, _ESaveFile, _ELoadFile

.export _PostbackWidget, _LogHTML, _LogVersion

.export _frcdata

_frcdata = $1a00

.proc _puts: near
    sta $40
    stx $41
    ldy #$0
    jmp $ffd0
.endproc

.proc _SetSiteTitle: near
    sta $50
    stx $51
    rts
.endproc

.proc _SetPageTitle: near
    sta $52
    stx $53
    rts
.endproc

.proc _SetTemplate: near
    sta $54
    stx $55
    rts
.endproc

.proc _SetSiteHeader: near
    sta $58
    stx $59
    rts
.endproc

.proc _SetAdminPass: near
    sta $a0
    stx $a1
    rts
.endproc

.proc ContentWrapper: near
    .byte $20,$00,$00
    jmp $fff0
.endproc

.proc _SetContentHandler: near
    sta ContentWrapper+1
    stx ContentWrapper+2
    lda #<ContentWrapper
    ldx #>ContentWrapper
    sta $a4
    stx $a5
    rts
.endproc

.proc _EndRequest: near
    jmp $fff0
.endproc

.proc _SetRedirect: near
    sta $a6
    stx $a7
    rts
.endproc

.proc _SetFolderVector: near
    sta $a2
    stx $a3
    rts
.endproc

.proc _SetInfoVector: near
    sta $a8
    stx $a9
    rts
.endproc

.proc _SetAdminVector: near
    sta $aa
    stx $ab
    rts
.endproc

.proc _GetQuery: near
    sta $44
    stx $45
    jsr popax
    sta $42
    stx $43
    ldy #$20
    jmp $ffe0
.endproc

.proc _IsQuery: near
    sta $44
    stx $45
    jsr popax
    sta $42
    stx $43
    ldy #$21
    jmp $ffe0
.endproc

.proc _GetPost: near
    sta $44
    stx $45
    jsr popax
    sta $42
    stx $43
    ldy #$22
    jmp $ffe0
.endproc

.proc _SetSession: near
    sta $40
    stx $41
    jsr popax
    sta $42
    stx $43
    ldy #$30
    jmp $ffd0
.endproc

.proc _GetSession: near
    sta $44
    stx $45
    jsr popax
    sta $42
    stx $43
    ldy #$30
    jmp $ffe0
.endproc

.proc _GetPRGName: near
    sta $44
    stx $45
    ldy #$10
    jmp $ffe0
.endproc

.proc _GetPathInfo: near
    sta $44
    stx $45
    ldy #$11
    jmp $ffe0
.endproc

.proc _GetPrefix: near
    sta $44
    stx $45
    ldy #$12
    jmp $ffe0
.endproc

.proc _FileExists: near
    sta $40
    stx $41
    ldy #$f
    jmp $ffc0
.endproc

.proc _LoadPRGFile: near
    sta $40
    stx $41
    ldy #$0
    jsr $ffc0
    lda $60
    ldx $61
    rts
.endproc

.proc _WriteFile: near
    sta $42
    stx $43
    jsr popax
    sta $40
    stx $41
    ldy #$b
    jmp $ffc0
.endproc

.proc _SaveFile: near
    sta $48
    stx $49
    jsr popax
    sta $46
    stx $47
    jsr popax
    sta $40
    stx $41
    ldy #$d
    jmp $ffc0
.endproc

.proc _LoadFile: near
    sta $46
    stx $47
    jsr popax
    sta $40
    stx $41
    ldy #$e
    jsr $ffc0
    lda $48
    ldx $49
    rts
.endproc

.proc _ESaveFile: near
    sta $48
    stx $49
    jsr popax
    sta $46
    stx $47
    jsr popax
    sta $40
    stx $41
    ldy #$30
    jmp $ffc0
.endproc

.proc _ELoadFile: near
    sta $46
    stx $47
    jsr popax
    sta $40
    stx $41
    ldy #$31
    jsr $ffc0
    lda $48
    ldx $49
    rts
.endproc

.proc st40: near
    sta $40
    stx $41
    rts
.endproc

.proc _PostbackWidget: near
    jsr st40
    jsr popax
    sta $42
    stx $43
    sty #$80
    jmp $ffd0
.endproc

.proc _LogHTML: near
    jsr st40
    ldy #$81
    jmp $ffd0
.endproc

.proc _LogVersion: near
    jsr st40
    ldy #$82
    jmp $ffd0
.endproc
