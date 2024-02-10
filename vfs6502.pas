unit vfs6502;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, lib6502, HTTPDefs, iniwebsession, webutil, klogger,
  BlowFish, memcard, fphttpclient, appserver, vfsinfo, fpTemplate;

type
  EVFSRedirect = class(Exception);

var
  FIndexes: TStringList;
  FTemplateTags: TStringList;

function LoadPRGFile(AFile: string): word;
procedure LoadInFile(AFile: string; addr: word);
procedure SetBoot(addr: word);
procedure RunProgram(ARequest: TRequest; ASession: TIniWebSession);
procedure RunRequest;
procedure RunCode(addr: word);
procedure RunApp(const memcard: string; ARequest: TRequest; ASession: TIniWebSession);
function RunFolderRC(AFile: string; ARequest: TRequest; ASession: TIniWebSession): string;
function RunAdminRC(ARequest: TRequest; ASession: TIniWebSession): string;
function RunInfoRC(AFile: string; ARequest: TRequest; ASession: TIniWebSession): string;
function GetOutput: string;
function GetSiteTitle: string;
function GetPageTitle: string;
function GetAdminPass: string;
function IsFolderHidden: boolean;
function IsDownload: boolean;
function GetTemplate: string;
function GetAJAX: boolean;
function GetPrefix: string;
function GetRedirect: string;
function GetMimeType: string;
function GetPort: integer;
function GetRunHook(const ext: string): string;
procedure PrepCALL(ARequest: TRequest; ASession: TIniWebSession);
function CanCALL: boolean;
function GetHeaderCode: string;
function HandleUnknown(ARequest: TRequest; ASession: TIniWebSession; const ext: string): string;
procedure SetTagParam(param: string);
procedure Reset6502;

implementation

type

  { T6502Template }

  T6502Template = class(TFPTemplate)
  protected
    procedure GetParam(Sender: TObject; const ParamName: String; out AValue: String);
      override;
  end;

var
  FMemory: TBytesStream;
  F6502: PM6502;
  FOutput: TStringList;
  FRunning: boolean;
  FRequest: TRequest;
  FSession: TIniWebSession;
  FLastFile: string;
  FRunHooks: TStringList;
  FMemcard: TMemCard;
  FBlock: TMemoryStream;
  F6502Runs: word;
  FOutBuf: string;

function GetString(addr: word): string;
var
  pc: word;
  c: char;
begin
  Result:='';
  pc:=addr;
  repeat
    c:=Chr(FMemory.Bytes[pc]);
    Inc(pc);
    if c <> #0 then
      Result:=Result+c;
  until c = #0;
end;

function SParam1: string;
begin
  Result:=GetString(M6502_getVector(F6502, MEM_PARAM1));
end;

function SParam2: string;
begin
  Result:=GetString(M6502_getVector(F6502, MEM_PARAM2));
end;

function SParam3: string;
begin
  Result:=GetString(M6502_getVector(F6502, MEM_PARAM3));
end;

procedure ReturnBoolean(value: boolean);
begin
  if value then
  begin
    F6502^.registers^.a:=$ff;
    F6502^.registers^.p:=F6502^.registers^.p-[flagZ];
  end
  else
  begin
    F6502^.registers^.a:=0;
    F6502^.registers^.p:=F6502^.registers^.p+[flagZ];
  end;
end;

procedure PostbackWidget(addr: word; btntext: string);
begin
  with FOutput do
  begin
    Add('<form action="/'+GetPrefix+'__CALL__" method="post">');
    Add('<input type="hidden" name="addr" value="'+IntToStr(addr)+'"/>');
    Add('<input type="submit" value="'+btntext+'"/></form>');
  end;
end;

procedure DoNewLine;
begin
  FOutput.Add(FOutBuf+GetString(M6502_getVector(F6502, MEM_PARAM1)));
  FOutBuf:='';
end;

procedure DoWriteTemplate;
var
  buf: string;
  pc: word;
  sp: byte;
begin
  pc:=F6502^.registers^.pc;
  sp:=F6502^.registers^.s;
  WriteLn(sp);
  with T6502Template.Create do
    try
      Template:=GetString(M6502_getVector(F6502, MEM_PARAM1));
      buf:=FOutput.Text+FOutBuf;
      FOutput.Clear;
      FOutBuf:='';
      FOutput.Text:=buf+GetContent;
    finally
      Free;
    end;
  WriteLn(F6502^.registers^.s);
  F6502^.registers^.pc:=pc;
  F6502^.registers^.s:=sp;
  FRunning:=True;
  {$IFDEF DEBUG2}
  LogInfo('WriteTemplate done.');
  {$ENDIF}
end;

function StdOut(mpu: PM6502; address: word; data: byte): longint; cdecl;
begin
  case mpu^.registers^.y of
    $0: FOutBuf:=FOutBuf+GetString(M6502_getVector(F6502, MEM_PARAM1));
    $1: DoNewLine;
    $2: FOutBuf:=FOutBuf+'$'+HexStr(M6502_getVector(F6502, MEM_PARAM1), 4);
    $3: FOutBuf:=FOutBuf+IntToStr(M6502_getVector(F6502, MEM_PARAM1));
    $4: DoWriteTemplate;
    $20: DumpRequest(FRequest, FOutput, False);
    $30: FSession.Variables[GetString(M6502_getVector(F6502, MEM_PARAM2))]:=GetString(M6502_getVector(F6502, MEM_PARAM1));
    $80: PostbackWidget(M6502_getVector(F6502, MEM_PARAM2), GetString(M6502_getVector(F6502, MEM_PARAM1)));
    $81: FOutput.Add('<!-- '+SParam1+' -->');
    $82: FOutput.Add('<!-- '+GetPageTitle+' Version '+IntToStr(M6502_getVector(F6502, MEM_PARAM1))+' -->');
  end;
  Result:=M6502_RTS(F6502);
  {$IFDEF DEBUG2}
  LogInfo('Return from Stdout: $'+HexStr(Result, 4));
  {$ENDIF}
end;

procedure GetQueryVar;
var
  vname, vvalue: string;
begin
  vname:=GetString(M6502_getVector(F6502, MEM_PARAM2));
  vvalue:=FRequest.QueryFields.Values[vname]+#0;
  Move(vvalue[1], FMemory.Bytes[M6502_getVector(F6502, MEM_PARAM3)], Length(vvalue));
end;

procedure GetQueryInt;
var
  v: integer;
begin
  if TryStrToInt(FRequest.QueryFields.Values[SParam1], v) then
    M6502_setVector(F6502, MEM_PARAM3, v)
  else
    M6502_setVector(F6502, MEM_PARAM3, 0);
end;

procedure IsQueryVar;
var
  vname, vvalue: string;
begin
  vname:=GetString(M6502_getVector(F6502, MEM_PARAM2));
  vvalue:=FRequest.QueryFields.Values[vname];
  if vvalue = GetString(M6502_getVector(F6502, MEM_PARAM3)) then
    ReturnBoolean(True)
  else
    ReturnBoolean(False);
end;

procedure GetPostVar;
var
  vname, vvalue: string;
begin
  vname:=GetString(M6502_getVector(F6502, MEM_PARAM2));
  vvalue:=FRequest.ContentFields.Values[vname]+#0;
  Move(vvalue[1], FMemory.Bytes[M6502_getVector(F6502, MEM_PARAM3)], Length(vvalue));
end;

procedure GetPostInt;
var
  v: integer;
begin
  if TryStrToInt(FRequest.ContentFields.Values[SParam1], v) then
    M6502_setVector(F6502, MEM_PARAM3, v)
  else
    M6502_setVector(F6502, MEM_PARAM3, 0);
end;

procedure IsPostVar;
var
  vname, vvalue: string;
begin
  vname:=GetString(M6502_getVector(F6502, MEM_PARAM2));
  vvalue:=FRequest.ContentFields.Values[vname];
  if vvalue = GetString(M6502_getVector(F6502, MEM_PARAM3)) then
    ReturnBoolean(True)
  else
    ReturnBoolean(False);
end;

procedure GetSessionVar;
var
  vname, vvalue: string;
begin
  vname:=GetString(M6502_getVector(F6502, MEM_PARAM2));
  vvalue:=FSession.Variables[vname]+#0;
  Move(vvalue[1], FMemory.Bytes[M6502_getVector(F6502, MEM_PARAM3)], Length(vvalue));
end;

procedure IsSessionVar;
var
  vname, vvalue: string;
begin
  vname:=GetString(M6502_getVector(F6502, MEM_PARAM2));
  vvalue:=FSession.Variables[vname];
  if vvalue = GetString(M6502_getVector(F6502, MEM_PARAM3)) then
    ReturnBoolean(True)
  else
    ReturnBoolean(False);
end;

procedure GetPRGName;
var
  prg: string;
begin
  prg:=ExtractFileName(FLastFile)+#0;
  Move(prg[1], FMemory.Bytes[M6502_getVector(F6502, MEM_PARAM3)], Length(prg));
end;

procedure GetPathInfo;
var
  pi: string;
begin
  pi:=FRequest.PathInfo+#0;
  Move(pi[1], FMemory.Bytes[M6502_getVector(F6502, MEM_PARAM3)], Length(pi));
end;

procedure DoGetPrefix;
var
  p: string;
begin
  p:=GetPrefix+#0;
  Move(p[1], FMemory.Bytes[M6502_getVector(F6502, MEM_PARAM3)], Length(p));
end;

procedure wget;
var
  buf: string;
begin
  with TFPHTTPClient.Create(Nil) do
  try
    buf:=Get(SParam1);
    Move(buf[1], FMemory.Bytes[M6502_getVector(F6502, $46)], Length(buf));
    M6502_setVector(F6502, $48, Length(buf));
  finally
    Free;
  end;
end;

procedure wput;
var
  buf: string;
  bsize: word;
begin
  bsize:=M6502_getVector(F6502, $48);
  if bsize > 0 then
  begin
    SetLength(buf, bsize);
    Move(FMemory.Bytes[M6502_getVector(F6502, $46)], buf[1], bsize);
  end
  else
    buf:=GetString(M6502_getVector(F6502, $46));
  with TFPHTTPClient.Create(Nil) do
  try
    KeepConnection:=False;
    RequestBody:=TStringStream.Create(buf);
    buf:=Post(SParam1);
    Move(buf[1], FMemory.Bytes[M6502_getVector(F6502, $46)], Length(buf));
    M6502_setVector(F6502, $48, Length(buf));
  finally
    RequestBody.Free;
    Free;
  end;
end;

function StdIn(mpu: PM6502; address: word; data: byte): longint; cdecl;
begin
  case mpu^.registers^.y of
    $10: GetPRGName;
    $11: GetPathInfo;
    $12: DoGetPrefix;
    $20: GetQueryVar;
    $21: IsQueryVar;
    $22: GetPostVar;
    $23: IsPostVar;
    $24: GetQueryInt;
    $25: GetPostInt;
    $30: GetSessionVar;
    $31: IsSessionVar;
    $32: FSession.RemoveVariable('login');
    $80: wget;
    $81: wput;
  end;
  Result:=M6502_RTS(F6502);
end;

function DoHalt(mpu: PM6502; address: word; data: byte): longint; cdecl;
begin
  FRunning:=False;
  Result:=M6502_RTS(F6502);
end;

procedure WriteFile;
var
  buf: string;
begin
  buf:=FRequest.ContentFields.Values[SParam2];
  with TMemoryStream.Create do
    try
      Write(buf[1], Length(buf));
      SaveToFile('siteroot/'+SParam1);
    finally
      Free;
    end;
end;

procedure UploadFile;
var
  f: TUploadedFile;
begin
  if FRequest.Files.Count = 0 then
    Exit;
  f:=FRequest.Files.Files[0];
  LogInfo('Preparing to recieve: '+f.FileName);
  with TMemoryStream.Create do
    try
      LoadFromStream(f.Stream);
      SaveToFile('siteroot/'+SParam1);
    finally
      Free;
    end;
end;

procedure SaveFile;
begin
  LogInfo('SaveFile called: '+SParam1);
  with TMemoryStream.Create do
    try
      Write(FMemory.Bytes[M6502_getVector(F6502, $46)], M6502_getVector(F6502, $48));
      SaveToFile('siteroot/'+SParam1);
    finally
      Free;
    end;
end;

function GetPassphrase: string;
begin
  Result:=FSession.Variables['login'];
end;

procedure ESaveFile;
var
  s: TMemoryStream;
begin
  LogInfo('ESaveFile called: '+SParam1);
  s:=TMemoryStream.Create;
  try
    with TBlowFishEncryptStream.Create(GetPassphrase, s) do
      try
        WriteWord(M6502_getVector(F6502, $48));
        Write(FMemory.Bytes[M6502_getVector(F6502, $46)], M6502_getVector(F6502, $48));
      finally
        Free;
      end;
    s.SaveToFile('siteroot/'+SParam1);
  finally
    s.Free;
  end;
end;

procedure LoadFile;
begin
  with TMemoryStream.Create do
    try
      LoadFromFile('siteroot/'+SParam1);
      Read(FMemory.Bytes[M6502_getVector(F6502, $46)], Size);
      M6502_setVector(F6502, $48, Size);
    finally
      Free;
    end;
end;

procedure ELoadFile;
var
  s: TMemoryStream;
  sz: word;
begin
  s:=TMemoryStream.Create;
  try
    s.LoadFromFile('siteroot/'+SParam1);
    with TBlowFishDeCryptStream.Create(GetPassphrase, s) do
      try
        sz:=ReadWord;
        Read(FMemory.Bytes[M6502_getVector(F6502, $46)], sz);
        M6502_setVector(F6502, $48, sz);
      finally
        Free;
      end;
  finally
    s.Free;
  end;
end;

procedure SetMemCard;
begin
  if Assigned(FMemcard) then
    Exit;
  FMemcard:=TMemCard.Create('siteroot'+GetString(M6502_getVector(F6502, $1c00)), M6502_getVector(F6502, $1c02));
  M6502_setVector(F6502, $1c02, FMemcard.BlockSize);
end;

procedure FreeMemCard;
begin
  if Assigned(FMemcard) then
    FreeAndNil(FMemcard);
  M6502_setVector(F6502, $1c00, 0);
end;

function LoadPRGBlock(ABlock: byte): word;
var
  addr: word;
  info: TBlockInfo;
begin
  if not Assigned(FMemcard) then
    Exit;
  FLastFile:=GetString($1c80);
  FBlock:=FMemcard.ReadBlock(ABlock);
  FMemcard.GetInfo(ABlock, @info);
  with FBlock do
    try
      addr:=ReadWord;
      Read(FMemory.Bytes[addr], info.total-2);
      {$IFDEF DEBUG}
      LogInfo('Loaded Block '+IntToStr(ABlock)+' from '+FLastFile+' into $'+HexStr(addr, 4));
      {$ENDIF}
    finally
      FreeAndNil(FBlock);
    end;
  Move(info, FMemory.Bytes[$1c04], SizeOf(info));
  Result:=addr;
end;

procedure LoadFromBlock;
var
  info: TBlockInfo;
begin
  if not Assigned(FMemcard) then
    Exit;
  if Assigned(FBlock) then
    FBlock.Free;
  FBlock:=FMemcard.ReadBlock(F6502^.registers^.a);
  FMemcard.GetInfo(F6502^.registers^.a, @info);
  with FBlock do
    try
      Read(FMemory.Bytes[M6502_getVector(F6502, $46)], info.total);
      M6502_setVector(F6502, $48, info.total);
    finally
      FreeAndNil(FBlock);
    end;
  Move(info, FMemory.Bytes[$1c04], SizeOf(info));
end;

procedure SaveToBlock;
var
  info: TBlockInfo;
begin
  if not Assigned(FMemcard) then
    Exit;
  if Assigned(FBlock) then
    FBlock.Free;
  Move(FMemory.Bytes[$1c04], info, SizeOf(info));
  FBlock:=FMemcard.ReadBlock(F6502^.registers^.a);
  try
    FBlock.Write(FMemory.Bytes[M6502_getVector(F6502, $46)], M6502_getVector(F6502, $48));
    info.total:=M6502_getVector(F6502, $48);
    FMemcard.WriteBlock(F6502^.registers^.a, FBlock, @info);
  finally
    FreeAndNil(FBlock);
  end;
end;

procedure LoadASIFromBlock;
var
  info: TBlockInfo;
  s: string;
begin
  if not Assigned(FMemcard) then
    Exit;
  if Assigned(FBlock) then
    FBlock.Free;
  FBlock:=FMemcard.ReadBlock(F6502^.registers^.a);
  FMemcard.GetInfo(F6502^.registers^.a, @info);
  with FBlock do
    try
      s:=ReadAnsiString+#0;
      Move(s[1], FMemory.Bytes[M6502_getVector(F6502, $46)], Length(s));
      M6502_setVector(F6502, $48, Length(s));
    finally
      FreeAndNil(FBlock);
    end;
  Move(info, FMemory.Bytes[$1c04], SizeOf(info));
end;

procedure SaveASIToBlock;
var
  info: TBlockInfo;
  s: string;
begin
  if not Assigned(FMemcard) then
    Exit;
  if Assigned(FBlock) then
    FBlock.Free;
  Move(FMemory.Bytes[$1c04], info, SizeOf(info));
  SetLength(s, M6502_getVector(F6502, $48));
  Move(FMemory.Bytes[M6502_getVector(F6502, $46)], s[1], M6502_getVector(F6502, $48));
  FBlock:=FMemcard.ReadBlock(F6502^.registers^.a);
  try
    FBlock.WriteAnsiString(s);
    info.total:=M6502_getVector(F6502, $48);
    FMemcard.WriteBlock(F6502^.registers^.a, FBlock, @info);
  finally
    FreeAndNil(FBlock);
  end;
end;

procedure ELoadFromBlock;
var
  info: TBlockInfo;
begin
  if not Assigned(FMemcard) then
    Exit;
  if Assigned(FBlock) then
    FBlock.Free;
  FBlock:=FMemcard.ReadBlock(F6502^.registers^.a);
  FMemcard.GetInfo(F6502^.registers^.a, @info);
  with TBlowFishDeCryptStream.Create(GetPassphrase, FBlock) do
    try
      Read(FMemory.Bytes[M6502_getVector(F6502, $46)], info.total);
      M6502_setVector(F6502, $48, info.total);
    finally
      Free;
    end;
  FreeAndNil(FBlock);
  Move(info, FMemory.Bytes[$1c04], SizeOf(info));
end;

procedure ESaveToBlock;
var
  info: TBlockInfo;
begin
  if not Assigned(FMemcard) then
    Exit;
  if Assigned(FBlock) then
    FBlock.Free;
  Move(FMemory.Bytes[$1c04], info, SizeOf(info));
  FBlock:=FMemcard.ReadBlock(F6502^.registers^.a);
  try
    with TBlowFishEncryptStream.Create(GetPassphrase, FBlock) do
      try
        Write(FMemory.Bytes[M6502_getVector(F6502, $46)], M6502_getVector(F6502, $48));
      finally
        Free;
      end;
    info.total:=M6502_getVector(F6502, $48);
    FMemcard.WriteBlock(F6502^.registers^.a, FBlock, @info);
  finally
    FreeAndNil(FBlock);
  end;
end;

procedure DoFileExists;
begin
  if FileExists('siteroot/'+SParam1) then
    ReturnBoolean(True)
  else
    ReturnBoolean(False);
end;

function DoFileIO(mpu: PM6502; address: word; data: byte): longint; cdecl;
begin
  case F6502^.registers^.y of
    $0: M6502_setVector(F6502, $60, LoadPRGFile(SITEROOT+GetString(M6502_getVector(F6502, $40))));
    $a: CreateDir(SITEROOT+GetString(M6502_getVector(F6502, $40)));
    $b: WriteFile;
    $c: UploadFile;
    $d: SaveFile;
    $e: LoadFile;
    $f: DoFileExists;
    $30: ESaveFile;
    $31: ELoadFile;
    $40: SetMemCard;
    $41: FreeMemCard;
    $42: M6502_setVector(F6502, $60, LoadPRGBlock(F6502^.registers^.a));
    $43: LoadFromBlock;
    $44: SaveToBlock;
    $45: LoadASIFromBlock;
    $46: SaveASIToBlock;
    $47: ELoadFromBlock;
    $48: ESaveToBlock;
    $80: FRunHooks.Add(SParam1);
    $81: FIndexes.Add(SParam1);
    $82: FTemplateTags.Add(SParam1+'='+IntToStr(M6502_getVector(F6502, $42)));
    $b0: FillByte(FMemory.Bytes[M6502_getVector(F6502, $40)], M6502_getVector(F6502, $42), 0);
    $b1: M6502_setVector(F6502, $42, Length(SParam1));
  end;
  Result:=M6502_RTS(F6502);
end;

function DoVFSHalt(mpu: PM6502; address: word; data: byte): longint; cdecl;
begin
  if (address = $fff1) and (data = $7f) then
    Application.Terminate{$IFNDEF SECURE}
  else if (address = $fff1) and (data = $f7) then
    FMemory.SaveToFile(SITEROOT+SParam1){$ENDIF};
  Result:=M6502_RTS(F6502);
end;

procedure LoadState;
var
  fname: string;
begin
  with Application do
  begin
    if HasOption('f', 'state') then
    begin
      fname:=GetOptionValue('f', 'state');
      if FileExists(fname) then
      begin
        WriteLn(' * Loading State from: '+fname);
        FMemory.LoadFromFile(fname);
      end;
    end;
  end;
end;

procedure init6502;
begin
  FOutput:=Nil;
  FRunHooks:=TStringList.Create;
  FIndexes:=TStringList.Create;
  FTemplateTags:=TStringList.Create;
  F6502Runs:=0;
  FMemcard:=Nil;
  FBlock:=Nil;
  FMemory:=TBytesStream.Create;
  LoadState;
  FMemory.Size:=65536;
  F6502:=M6502_new(Nil, FMemory.Bytes, Nil);
  M6502_setVector(F6502, VEC_IRQ, $fff0);
  M6502_setCallback(F6502, ctCall, $ffc0, @DoFileIO);
  M6502_setCallback(F6502, ctCall, $ffd0, @StdOut);
  M6502_setCallback(F6502, ctCall, $ffe0, @StdIn);
  M6502_setCallback(F6502, ctCall, $fff0, @DoHalt);
  M6502_setCallback(F6502, ctWrite, $fff1, @DoVFSHalt);
  FMemory.Bytes[$fff2]:=VFS_VERSION;
  FMemory.Bytes[$fff3]:={$IFDEF DEBUG}$ff{$ELSE}$0{$ENDIF};
end;

procedure done6502;
begin
  if Assigned(FOutput) then
    FOutput.Free;
  FTemplateTags.Free;
  FIndexes.Free;
  FRunHooks.Free;
  if Assigned(FBlock) then
    FBlock.Free;
  if Assigned(FMemcard) then
    FMemcard.Free;
  M6502_delete(F6502);
  {$IFNDEF SECURE}
  with Application do
    if HasOption('f', 'state') then
      FMemory.SaveToFile(GetOptionValue('f', 'state'));
  {$ENDIF}
  FMemory.Free;
end;

function LoadPRGFile(AFile: string): word;
var
  addr: word;
begin
  FLastFile:=AFile;
  with TMemoryStream.Create do
    try
      LoadFromFile(AFile);
      addr:=ReadWord;
      Read(FMemory.Bytes[addr], Size-2);
      {$IFDEF DEBUG}
      LogInfo('Loaded '+AFile+' into $'+HexStr(addr, 4));
      {$ENDIF}
    finally
      Free;
    end;
  Result:=addr;
end;

procedure Run;
begin
  if Assigned(FOutput) then
    FOutput.Clear
  else
    FOutput:=TStringList.Create;
  FOutBuf:='';
  FRunning:=True;
  {$IFDEF DEBUG}
  LogInfo('Starting program execution from $'+HexStr(F6502^.registers^.pc, 4));
  {$ENDIF}
  Inc(F6502Runs);
  M6502_setVector(F6502, $ac, F6502Runs);
  repeat
    M6502_step(F6502);
    Sleep(1);
  until not FRunning;
  if FOutBuf <> '' then
    FOutput.Add(FOutBuf);
end;

procedure LoadInFile(AFile: string; addr: word);
begin
  with TMemoryStream.Create do
    try
      LoadFromFile(AFile);
      Read(FMemory.Bytes[addr], Size);
      {$IFDEF DEBUG}
      LogInfo('Loaded '+AFile+' into $'+HexStr(addr, 4));
      {$ENDIF}
    finally
      Free;
    end;
end;

procedure SetBoot(addr: word);
begin
  M6502_setVector(F6502, VEC_RST, addr);
  M6502_reset(F6502);
  {$IFDEF DEBUG}
  LogInfo('Boot has been setup: $'+HexStr(addr, 4));
  {$ENDIF}
end;

procedure RunProgram(ARequest: TRequest; ASession: TIniWebSession);
begin
  FRequest:=ARequest;
  FSession:=ASession;
  FMemory.Bytes[$a4]:=0;
  FMemory.Bytes[$a5]:=0;
  FMemory.Bytes[$a6]:=0;
  FMemory.Bytes[$a7]:=0;
  Run;
end;

procedure RunRequest;
var
  ptr: word;
begin
  ptr:=M6502_getVector(F6502, $a4);
  if ptr = 0 then
    Exit;
  RunCode(ptr);
  FreeMemCard;
end;

procedure RunCode(addr: word);
begin
  F6502^.registers^.pc:=addr;
  Run;
end;

procedure RunApp(const memcard: string; ARequest: TRequest;
  ASession: TIniWebSession);
var
  blk: integer;
  info: TBlockInfo;
begin
  FreeMemCard;
  Move(memcard[1], FMemory.Bytes[$1c80], Length(memcard));
  FMemory.Bytes[$1c80+Length(memcard)]:=0;
  M6502_setVector(F6502, $1c00, $1c80);
  M6502_setVector(F6502, $1c02, 2048);
  SetMemCard;
  blk:=FMemcard.FindApp($65, @info);
  if blk = 0 then
    Exit;
  if info.typno = $4c then
    SetBoot(LoadPRGBlock(blk))
  else if info.typno = $3f then
  begin
    if Assigned(FBlock) then
      FBlock.Free;
    FBlock:=FMemcard.ReadBlock(blk);
    FBlock.Read(FMemory.Bytes[$2000], info.total);
    FreeAndNil(FBlock);
    SetBoot($2000);
  end
  else
    Exit;
  RunProgram(ARequest, ASession);
end;

function RunFolderRC(AFile: string; ARequest: TRequest; ASession: TIniWebSession
  ): string;
var
  ptr: word;
  buf: string;
begin
  Result:='';
  FillByte(FMemory.Bytes[$1a00], $ff, 0);
  if not FileExists(AFile) then
    Exit;
  LoadInFile(AFile, $1a00);
  ptr:=M6502_getVector(F6502, $a2);
  if ptr = 0 then
    Exit;
  FRequest:=ARequest;
  FSession:=ASession;
  RunCode(ptr);
  buf:=GetOutput;
  if buf <> '' then
    Result:=buf;
end;

function RunAdminRC(ARequest: TRequest; ASession: TIniWebSession): string;
var
  ptr: word;
begin
  ptr:=M6502_getVector(F6502, $aa);
  if ptr = 0 then
    Exit;
  FRequest:=ARequest;
  FSession:=ASession;
  RunCode(ptr);
  Result:=GetOutput;
end;

function RunInfoRC(AFile: string; ARequest: TRequest; ASession: TIniWebSession
  ): string;
var
  ptr: word;
  buf: string;
begin
  Result:='';
  {M6502_setVector(F6502, $52, 0);}
  FillByte(FMemory.Bytes[$1b00], $ff, 0);
  if not FileExists(AFile) then
    Exit;
  LoadInFile(AFile, $1b00);
  M6502_setVector(F6502, $52, $1b00);
  ptr:=M6502_getVector(F6502, $a8);
  if ptr = 0 then
    Exit;
  FRequest:=ARequest;
  FSession:=ASession;
  RunCode(ptr);
  buf:=GetOutput;
  if buf <> '' then
    Result:=buf;
end;

function GetOutput: string;
begin
  Result:=FOutput.Text;
end;

function GetSiteTitle: string;
var
  ptr: word;
begin
  ptr:=M6502_getVector(F6502, $50);
  if ptr = 0 then
    Result:='Untitled Site'
  else
    Result:=GetString(ptr);
end;

function GetPageTitle: string;
var
  ptr: word;
begin
  ptr:=M6502_getVector(F6502, $52);
  if ptr = 0 then
    Result:='Untitled'
  else
    Result:=GetString(ptr);
end;

function GetAdminPass: string;
var
  ptr: word;
begin
  ptr:=M6502_getVector(F6502, $a0);
  if ptr = 0 then
    Result:='password'
  else
    Result:=GetString(ptr);
end;

function IsFolderHidden: boolean;
begin
  if FMemory.Bytes[$1a3d] = $ff then
    Result:=True
  else
    Result:=False;
end;

function IsDownload: boolean;
begin
  if FMemory.Bytes[$1b14] = $ff then
    Result:=True
  else
    Result:=False;
end;

function GetTemplate: string;
var
  ptr: word;
begin
  ptr:=M6502_getVector(F6502, $54);
  if ptr = 0 then
    Result:='NIL'
  else
    Result:=GetString(ptr);
end;

function GetAJAX: boolean;
begin
  if FMemory.Bytes[$56] = $ff then
    Result:=True
  else
    Result:=False;
end;

function GetPrefix: string;
var
  p: string;
begin
  p:=GetEnvironmentVariable('VFS_PREFIX');
  if p <> '' then
    Result:=p
  else
    Result:='';
end;

function GetRedirect: string;
var
  ptr: word;
begin
  ptr:=M6502_getVector(F6502, $a6);
  if ptr = 0 then
    Result:=''
  else
    Result:=GetString(ptr);
  M6502_setVector(F6502, $a6, 0);
end;

function GetMimeType: string;
var
  ptr: word;
begin
  ptr:=M6502_getVector(F6502, $b0);
  if ptr = 0 then
    Result:=''
  else
    Result:=GetString(ptr);
  M6502_setVector(F6502, $b0, 0);
end;

function GetPort: integer;
begin
  Result:=M6502_getVector(F6502, $5a);
  if Result = 0 then
    Result:=9000;
end;

function GetRunHook(const ext: string): string;
begin
  Result:=FRunHooks.Values[ext];
end;

procedure PrepCALL(ARequest: TRequest; ASession: TIniWebSession);
begin
  FRequest:=ARequest;
  FSession:=ASession;
  {M6502_setVector(F6502, $90, 0);}
end;

function CanCALL: boolean;
var
  ptr: word;
begin
  Result:=False;
  ptr:=M6502_getVector(F6502, $90);
  if ptr = 0 then
    Exit;
  if FSession.Variables['CALL'] = GetString(ptr) then
    Result:=True;
  M6502_setVector(F6502, $90, 0);
end;

function GetHeaderCode: string;
var
  ptr: word;
begin
  ptr:=M6502_getVector(F6502, $58);
  if ptr = 0 then
    Result:=''
  else
    Result:=GetString(ptr);
end;

function HandleUnknown(ARequest: TRequest; ASession: TIniWebSession;
  const ext: string): string;
var
  {$IFNDEF SHELLSYS}
  addr: word;
  {$ENDIF}
  buf: string;
begin
  {$IFDEF SHELLSYS}
  if not FileExists(SITEROOT+GetPrefix+'System/SHELL.SYS') then
  begin
    Result:='Unhandled file-type and/or missing SHELL.SYS.';
    Exit;
  end;
  {$ELSE}
  addr:=M6502_getVector(F6502, $ae);
  if addr = 0 then
  begin
    Result:='Unhandled file-type.';
    Exit;
  end;
  {$ENDIF}
  FRequest:=ARequest;
  FSession:=ASession;
  {$IFDEF SHELLSYS}
  LoadInFile(SITEROOT+GetPrefix+'System/SHELL.SYS', SHELL_ADDR);
  SetBoot(SHELL_ADDR);
  {$ELSE}
  SetBoot(addr);
  {$ENDIF}
  buf:=ext+#0;
  Move(buf[1], FMemory.Bytes[$401], Length(buf));
  {$IFDEF SHELLSYS}
  RunCode(SHELL_ADDR);
  {$ELSE}
  RunCode(addr);
  {$ENDIF}
  buf:=GetRedirect;
  if buf <> '' then
  begin
    Result:='Redirect: <a href="'+buf+'">'+buf+'</a>';
    Exit;
  end;
  buf:=GetOutput;
  if buf = '' then
    Result:='Unhandled file-type.'
  else
    Result:=buf;
end;

procedure SetTagParam(param: string);
var
  addr: word;
  buf: string;
begin
  addr:=M6502_getVector(F6502, $b4);
  if addr > 0 then
  begin
    buf:=param+#0;
    Move(buf[1], FMemory.Bytes[addr], Length(buf));
  end;
end;

procedure Reset6502;
begin
  FRunHooks.Clear;
  FIndexes.Clear;
  FTemplateTags.Clear;
  if Assigned(FOutput) then
    FreeAndNil(FOutput);
end;

{ T6502Template }

procedure T6502Template.GetParam(Sender: TObject; const ParamName: String; out
  AValue: String);
var
  addr: word;
  buf: string;
begin
  SetTagParam(ParamName);
  addr:=M6502_getVector(F6502, $b2);
  if addr > 0 then
  begin
    buf:=FOutput.Text+FOutBuf;
    FOutput.Clear;
    FOutBuf:='';
    RunCode(addr);
    AValue:=buf+GetOutput;
    FOutput.Text:=buf;
    FOutBuf:='';
  end
  else
    AValue:='';
end;

initialization
  init6502;

finalization
  done6502;

end.

