////////////////////////////////////////////
// New unit created in 17-6-23}
////////////////////////////////////////////
{Description of the unit.}
{$BOOTLOADER $20,'COD_HL','JMP',$f0,$ff}
{$STRING NULL_TERMINATED}
{$ORG $0801}
unit vfs6502;

interface

type
  pointer = word;
  str20 = array[20] of char;
  pstr20 = ^str20;
  str40 = array[40] of char;
  pstr40 = ^str40;
  str60 = array[60] of char;
  pstr60 = ^str60;
  string = array of char;
  pstr = ^string;
  
var
  SITE_TITLE: pointer absolute $50;
  PAGE_TITLE: pointer absolute $52;
  TMPL: pointer absolute $54;
  AJAX: boolean absolute $56;
  SITE_HEADER: pointer absolute $58;
  ADMIN_PASS: pointer absolute $a0;
  FOLDER_VEC: pointer absolute $a2;
  GetContent: pointer absolute $a4;
  REDIRECT: pointer absolute $a6;
  INFO_VEC: pointer absolute $a8;
  ADMIN_VEC: pointer absolute $aa;
  RUN_COUNT: word absolute $ac;
  SHELL_VEC: pointer absolute $ae;
  MimeType: pointer absolute $b0;
  TAG_VEC: pointer absolute $b2;
  TagParam: pointer absolute $b4;

  FRC_PASS: str20 absolute $1a00;
  FRC_HDR: str20 absolute $1a14;
  FRC_BTN: str20 absolute $1a29;
  FRC_HIDE: boolean absolute $1a3d;
  FRC_HOOK: str40 absolute $1a3e;

  param1: pointer absolute $40;
  param2: pointer absolute $42;
  value: pointer absolute $44;
  LOAD_ADDR: pointer absolute $60;
  pcallkey: pointer absolute $90;
  
  BLKTITLESIZE: byte absolute $1c04;
  BLOCK_TITLE: array[20] of char absolute $1c05;
  BLOCK_TYPE: byte absolute $1c19;
  BLOCK_APP: byte absolute $1c1a;
  BLOCK_NEXT: byte absolute $1c1b;
  BLOCK_TOTAL: word absolute $1c1c;

procedure Write(s: pointer absolute $40);
procedure WriteLn(s: pointer absolute $40);
procedure WriteHex(s: pointer absolute $40);
procedure WriteWord(s: pointer absolute $40);
procedure WriteTemplate(s: pointer absolute $40);
procedure GetQuery(s: pointer absolute $42);
procedure IsQuery(s: pointer absolute $42; s2: pointer absolute $44): boolean;
procedure GetPost(s: pointer absolute $42);
procedure IsPost(s: pointer absolute $42; s2: pointer absolute $44): boolean;
procedure SetSession(s: pointer absolute $42; s2: pointer absolute $40);
procedure GetSession(s: pointer absolute $42);
procedure IsSession(s: pointer absolute $42; s2: pointer absolute $44): boolean;
procedure GetPRGName;
procedure GetPathInfo;
procedure GetPrefix;
procedure FileExists(fi: pointer absolute $40): boolean;
procedure LoadPRGFile(fi: pointer absolute $40): pointer;
procedure WriteFile(s: pointer absolute $40; pv: pointer absolute $42);
procedure SaveFile(fi: pointer absolute $40; addr: pointer absolute $46; size: word absolute $48);
procedure LoadFile(fi: pointer absolute $40; addr: pointer absolute $46): word;
procedure ESaveFile(fi: pointer absolute $40; addr: pointer absolute $46; size: word absolute $48);
procedure ELoadFile(fi: pointer absolute $40; addr: pointer absolute $46): word;
procedure PostbackWidget(addr: pointer absolute $42; btntext: pointer absolute $40);
procedure LogHTML(msg: pointer absolute $40);
procedure LogVersion(ver: word absolute $40);
procedure AddRunHook(s: pointer absolute $40);
procedure AddIndex(s: pointer absolute $40);
procedure AddTag(tag: pointer absolute $40; addr: pointer absolute $42);

procedure SetMemCard(mcfile: pointer absolute $1c00; blksize: word absolute $1c02);
procedure FreeMemCard;
procedure LoadPRGBlock(blkid: byte registerA): pointer;
procedure LoadFromBlock(blkid: byte registerA; addr: pointer absolute $46): word;
procedure SaveToBlock(blkid: byte registerA; addr: pointer absolute $46; size: word absolute $48);
procedure LoadASIFromBlock(blkid: byte registerA; addr: pointer absolute $46): word;
procedure SaveASIToBlock(blkid: byte registerA; addr: pointer absolute $46; size: word absolute $48);
procedure ELoadFromBlock(blkid: byte registerA; addr: pointer absolute $46): word;
procedure ESaveToBlock(blkid: byte registerA; addr: pointer absolute $46; size: word absolute $48);

procedure isNull(ptr: pointer absolute $1a): boolean;
procedure StrEqual(src: pointer absolute $20; dest: pointer absolute $22): boolean;
procedure StrCat(dest: pointer absolute $22; src: pointer absolute $20);

procedure WebGet(url: pointer absolute $40; dest: pointer absolute $46): word;
procedure WebPut(url: pointer absolute $40; buf: pointer absolute $46; size: word absolute $48): word;

procedure EndRequest;

implementation

procedure Write(s: pointer absolute $40);
begin
  asm 
	  LDY #$0
    JMP $ffd0 
  end; 
end; 

procedure WriteLn(s: pointer absolute $40);
begin
  asm 
	  LDY #$1
    JMP $ffd0 
  end; 
end; 

procedure WriteHex(s: pointer absolute $40);
begin
  asm 
	  LDY #$2
    JMP $ffd0 
  end; 
end; 

procedure WriteWord(s: pointer absolute $40);
begin
  asm 
	  LDY #$3
    JMP $ffd0 
  end; 
end; 

procedure WriteTemplate(s: pointer absolute $40);
begin
  asm 
	  LDY #$4
    JMP $ffd0 
  end; 
end; 

procedure GetQuery(s: pointer absolute $42);
begin
  asm 
	  LDY #$20
    JMP $ffe0 
  end; 
end;

procedure IsQuery(s: pointer absolute $42; s2: pointer absolute $44): boolean;
begin
  asm 
	  LDY #$21
    JMP $ffe0
  end; 
end; 

procedure GetPost(s: pointer absolute $42);
begin
  asm 
	  LDY #$22
    JMP $ffe0 
  end; 
end; 

procedure IsPost(s: pointer absolute $42; s2: pointer absolute $44): boolean;
begin
  asm 
	  LDY #$23
    JMP $ffe0 
  end; 
end; 

procedure SetSession(s: pointer absolute $42; s2: pointer absolute $40);
begin
  asm 
	  LDY #$30
    JMP $ffd0 
  end; 
end; 

procedure GetSession(s: pointer absolute $42);
begin
  asm 
	  LDY #$30
    JMP $ffe0 
  end; 
end; 

procedure IsSession(s: pointer absolute $42; s2: pointer absolute $44): boolean;
begin
  asm 
	  LDY #$31
    JMP $ffe0 
  end; 
end; 

procedure GetPRGName;
begin
  asm 
	  LDY #$10
    JMP $ffe0 
  end; 
end; 

procedure GetPathInfo;
begin
  asm 
	  LDY #$11
    JMP $ffe0 
  end; 
end;

procedure GetPrefix;
begin
  asm 
	  LDY #$12
    JMP $ffe0 
  end; 
end; 

procedure FileExists(fi: pointer absolute $40): boolean;
begin
  asm 
	  LDY #$f
    JMP $ffc0; 
  end; 
end; 

procedure LoadPRGFile(fi: pointer absolute $40): pointer;
begin
  asm 
	  LDY #0
    JSR $ffc0 
  end;
  Exit(LOAD_ADDR); 
end; 

procedure WriteFile(s: pointer absolute $40; pv: pointer absolute $42);
begin
  asm 
	  LDY #$b
    JSR $ffc0 
  end; 
end; 

procedure SaveFile(fi: pointer absolute $40; addr: pointer absolute $46; size: word absolute $48);
begin
  asm 
	  LDY #$d
    JMP $ffc0
  end; 
end; 

procedure LoadFile(fi: pointer absolute $40; addr: pointer absolute $46): word;
var
  FSIZE: word absolute $48;
begin
  asm 
	  LDY #$e
    JSR $ffc0
  end; 
  exit(FSIZE);
end; 

procedure ESaveFile(fi: pointer absolute $40; addr: pointer absolute $46; size: word absolute $48);
begin
  asm 
	  LDY #$30
    JMP $ffc0
  end; 
end; 

procedure ELoadFile(fi: pointer absolute $40; addr: pointer absolute $46): word;
var
  FSIZE: word absolute $48;
begin
  asm 
	  LDY #$31
    JSR $ffc0
  end; 
  exit(FSIZE);
end; 

procedure PostbackWidget(addr: pointer absolute $42; btntext: pointer absolute $40);
begin
  asm 
	  LDY #$80
    JMP $ffd0 
  end; 
end;

procedure LogHTML(msg: pointer absolute $40);
begin
  asm 
	  LDY #$81
    JMP $ffd0 
  end; 
end; 

procedure LogVersion(ver: word absolute $40);
begin
  asm 
	  LDY #$82
    JMP $ffd0 
  end; 
end; 

procedure SetMemCard(mcfile: pointer absolute $1c00; blksize: word absolute $1c02);
begin
  asm 
	  LDY #$40
    JMP $ffc0 
  end; 
end; 

procedure FreeMemCard;
begin
  asm 
	  LDY #$41
    JMP $ffc0 
  end; 
end; 

procedure LoadPRGBlock(blkid: byte registerA): pointer;
var
  addr: pointer absolute $60;
begin
  asm 
	  LDY #$42
    JSR $ffc0
  end;
  Exit(addr); 
end; 

procedure LoadFromBlock(blkid: byte registerA; addr: pointer absolute $46): word;
var
  FSIZE: word absolute $48;
begin
  asm 
	  LDY #$43
    JSR $ffc0
  end; 
  exit(FSIZE);
end; 

procedure SaveToBlock(blkid: byte registerA; addr: pointer absolute $46; size: word absolute $48);
begin
  asm 
	  LDY #$44
    JMP $ffc0 
  end; 
end;

procedure LoadASIFromBlock(blkid: byte registerA; addr: pointer absolute $46): word;
var
  FSIZE: word absolute $48;
begin
  asm 
	  LDY #$45
    JSR $ffc0
  end; 
  exit(FSIZE);
end; 

procedure SaveASIToBlock(blkid: byte registerA; addr: pointer absolute $46; size: word absolute $48);
begin
  asm 
	  LDY #$46
    JMP $ffc0 
  end; 
end;

procedure ELoadFromBlock(blkid: byte registerA; addr: pointer absolute $46): word;
var
  FSIZE: word absolute $48;
begin
  asm 
	  LDY #$47
    JSR $ffc0
  end; 
  exit(FSIZE);
end; 

procedure ESaveToBlock(blkid: byte registerA; addr: pointer absolute $46; size: word absolute $48);
begin
  asm 
	  LDY #$48
    JMP $ffc0 
  end; 
end;

procedure isNull(ptr: pointer absolute $1a): boolean;
begin
  asm
    LDY #0 
	  LDA (ptr), Y
    BEQ null
    INY
    LDA (ptr), Y
    BEQ null
    LDA #0
    RTS
null: LDA #$ff
  end; 
end;

procedure AddRunHook(s: pointer absolute $40);
begin
  asm 
	  LDY #$80
    JMP $ffc0
  end; 
end;

procedure AddIndex(s: pointer absolute $40);
begin
  asm 
	  LDY #$81
    JMP $ffc0
  end; 
end; 

procedure AddTag(tag: pointer absolute $40; addr: pointer absolute $42);
begin
  asm 
	  LDY #$82
    JMP $ffc0 
  end; 
end; 

procedure EndRequest;
begin
  asm jmp $fff0 end;
end; 

procedure StrEqual(src: pointer absolute $20; dest: pointer absolute $22): boolean;
begin
  asm 
	  LDY #0
l:  LDA (src), Y
    PHP
    CMP (dest), Y
    BNE d1
    PLP
    BEQ d2
    INY
    BNE l
d1: PLP
    LDA #0
    RTS
d2: LDA #$ff
  end;
end; 

procedure StrCat(dest: pointer absolute $22; src: pointer absolute $20);
var
  tmpy: byte;
begin
  asm 
	  LDY #0
l:  LDA (dest), Y
    BEQ d1
    INY
    BNE l
d1: STY tmpy
    LDA dest
    ADC tmpy
    BCC d2
    INC dest+1
d2: STA dest
    LDY #0
l2: LDA (src), Y
    STA (dest), Y
    BEQ d3
    INY
    BNE l2
d3: 
  end; 
end; 

procedure WebGet(url: pointer absolute $40; dest: pointer absolute $46): word;
var
  FSIZE: word absolute $48;
begin
  asm 
	  LDY #$80
    JSR $ffe0 
  end;
  exit(FSIZE); 
end; 

procedure WebPut(url: pointer absolute $40; buf: pointer absolute $46; size: word absolute $48): word;
begin
  asm 
	  LDY #$81
    JSR $ffe0 
  end;
  exit(size);
end; 

end.

