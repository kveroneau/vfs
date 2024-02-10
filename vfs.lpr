program vfs;

{$mode objfpc}{$H+}

uses
  classes, sysutils, appserver{$IFDEF HTTP}, fpwebfile{$ENDIF},
  httproute, HTTPDefs, fpTemplate, FileUtil, iniwebsession, vfs6502, klogger,
  vfsinfo, fphttpclient, ScriptSystem;

type

  TPackageType = (ptApp, ptBoot, ptAdmin, ptSystem);

  { TVFSRoute }

  TVFSRoute = class(TRouteObject)
  private
    tmpl: TFPTemplate;
    FRequest: TRequest;
    FAdmin, FParamHook: Boolean;
    FSession: TIniWebSession;
    FIconList: TStringList;
    FScript: TScriptSystem;
    FScrOutput: TStringList;
    FScrTitle, FScrHeader: string;
    procedure NewSession(Sender: TObject);
    procedure SessionExpired(Sender: TObject);
    function GetNavPane: string;
    function GetContent: string;
    function GetDirectory: string;
    function GetHTMLFile: string;
    function GetPRGFile: string;
    function GetScrFile: string;
    function GetTextFile: string;
    function GetFile: string;
    function SaveFile: string;
    function GetTag(param: string): string;
    Procedure GetParam(Sender : TObject; Const ParamName : String; Out AValue : String);
    Procedure ScrGetParam(Sender : TObject; Const ParamName : String; Out AValue : String);
    Procedure GetTagReplace(Sender : TObject; Const TagString : String; TagParams:TStringList; Out ReplaceText : String);
    function FileIcon(const fna: string; IsDirectory: Boolean): string;
    procedure HandleImage(AResponse: TResponse);
    procedure HandleDownload(AResponse: TResponse);
    procedure HandleFile(AResponse: TResponse);
    procedure ScrSetTitle(data: string);
    procedure ScrOutput(data: string);
    function ScrInput: string;
    procedure ScrRunFile(AFile: string);
    procedure ScrOpCode(op: char);
  public
    Constructor Create; override;
    destructor Destroy; override;
    procedure HandleRequest(ARequest: TRequest; AResponse: TResponse); override;
  end;

var
  SessionFactory: TIniSessionFactory;

{ TVFSRoute }

procedure TVFSRoute.NewSession(Sender: TObject);
begin
  { #todo : Wondering if I should hook these session hooks into 6502 code? }
  LogInfo('New Session started!');
end;

procedure TVFSRoute.SessionExpired(Sender: TObject);
begin
  LogInfo('Looks like the session expired...');
end;

function TVFSRoute.GetNavPane: string;
var
  t: TFPTemplate;
  navfile: string;
begin
  navfile:=SITEROOT+ExtractFileDir(FRequest.PathInfo)+'/nav-pane.widget';
  if not FileExists(navfile) then
    navfile:=SITEROOT+GetPrefix+'System/Widgets/nav-pane.widget';
  t:=TFPTemplate.Create;
  try
    t.FileName:=navfile;
    t.OnGetParam:=@GetParam;
    Result:=t.GetContent;
  finally
    t.Free;
  end;
  navfile:=SITEROOT+GetPrefix+'System/Widgets/admin-pane.widget';
  if FAdmin and FileExists(navfile) then
  begin
    t:=TFPTemplate.Create;
    try
      t.FileName:=navfile;
      t.OnGetParam:=@GetParam;
      Result:=Result+t.GetContent;
    finally
      t.Free;
    end;
  end;
end;

function TVFSRoute.GetContent: string;
begin
  if DirectoryExists(SITEROOT+FRequest.PathInfo) then
    Result:=GetDirectory
  else
    Result:=GetFile;
end;

function TVFSRoute.GetDirectory: string;
var
  dlst, flst: TStringList;
  i: integer;
  fna, ico, buf, ext, PRGLoader: string;
begin
  buf:=RunFolderRC(SITEROOT+FRequest.PathInfo+'/folder.rc', FRequest, FSession);
  if buf <> '' then
  begin
    Result:=buf;
    Exit;
  end;
  buf:=GetRedirect;
  if buf <> '' then
    raise EVFSRedirect.Create(buf);
  dlst:=TStringList.Create;
  with TListDirectoriesSearcher.Create(dlst) do
    try
      Search(SITEROOT+FRequest.PathInfo, '', False);
    finally
      Free;
    end;
  for i:=0 to dlst.Count-1 do
  begin
    fna:=ExtractFileName(dlst.Strings[i]);
    ico:='<img src="/icons/'+FileIcon(fna, True)+'.gif" border="0"/>';
    dlst.Strings[i]:='<a href="'+FRequest.PathInfo+fna+'/">'+ico+fna+'</a><br/>';
    if FileExists(SITEROOT+FRequest.PathInfo+fna+'/folder.rc') then
    begin
      LoadInFile(SITEROOT+FRequest.PathInfo+fna+'/folder.rc', $1a00);
      if IsFolderHidden then
        dlst.Strings[i]:='';
    end;
  end;
  flst:=TStringList.Create;
  with TListFileSearcher.Create(flst) do
    try
      Search(SITEROOT+FRequest.PathInfo, '', False);
    finally
      Free;
    end;
  for i:=0 to flst.Count-1 do
  begin
    fna:=ExtractFileName(flst.Strings[i]);
    ext:=ExtractFileExt(flst.Strings[i]);
    ico:='<img src="/icons/'+FileIcon(fna, False)+'.gif" border="0"/>';
    buf:='   <i>'+IntToStr(FileSize(SITEROOT+FRequest.PathInfo+fna))+' bytes</i>';
    if FAdmin then
    begin
      buf:=buf+'<a href="'+FRequest.PathInfo+fna+'?edit=Y">';
      buf:=buf+'<img src="/'+GetPrefix+'System/Images/edit.gif" border="0"></a>';
      buf:=buf+'<a href="'+FRequest.PathInfo+fna+'?rm=Y">';
      buf:=buf+'<img src="/'+GetPrefix+'System/Images/delete.gif" border="0"></a><br/>';
    end
    else
      buf:=buf+'<br/>';
    PRGLoader:=GetRunHook(ext);
    if (ext = '.gif') or (ext = '.png') or (ext = '.jpg') then
      flst.Strings[i]:='<a href="'+FRequest.PathInfo+fna+'?embed=y">'+ico+fna+'</a>'+buf
    else if PRGLoader <> '' then
      flst.Strings[i]:='<a href="'+PRGLoader+'?file='+FRequest.PathInfo+fna+'">'+ico+fna+'</a>'+buf
    else
      flst.Strings[i]:='<a href="'+FRequest.PathInfo+fna+'">'+ico+fna+'</a>'+buf;
  end;
  if FileExists(SITEROOT+FRequest.PathInfo+'/info.widget') then
  begin
    with TStringStream.Create do
    try
      LoadFromFile(SITEROOT+FRequest.PathInfo+'/info.widget');
      Result:=DataString;
    finally
      Free;
    end;
  end
  else
    Result:='';
  Result:=Result+'<h4>Directory Viewer of '+FRequest.PathInfo+':</h4><br/>';
  if FAdmin then
    Result:=Result+RunAdminRC(FRequest, FSession);
  Result:=Result+dlst.Text+flst.Text;
  flst.Free;
  dlst.Free;
end;

function TVFSRoute.GetHTMLFile: string;
var
  t: TFPTemplate;
begin
  FParamHook:=True;
  t:=TFPTemplate.Create;
  try
    try
      t.StartDelimiter:='{+';
      t.EndDelimiter:='+}';
      t.ParamStartDelimiter:=' ';
      t.ParamEndDelimiter:='"';
      t.ParamValueSeparator:='="';
      t.FileName:=SITEROOT+FRequest.PathInfo;
      t.OnGetParam:=@GetParam;
      t.OnReplaceTag:=@GetTagReplace;
      t.AllowTagParams:=True;
      Result:=t.GetContent;
    except
      On EFOpenError do Result:='404';
    end;
  finally
    t.Free;
  end;
end;

function TVFSRoute.GetPRGFile: string;
begin
  RunRequest;
  Result:=GetOutput;
end;

function TVFSRoute.GetScrFile: string;
begin
  Result:='';
  if not Assigned(FScript) then
    Exit;
  FScript.OnOutput:=@ScrOutput;
  if not Assigned(FScrOutput) then
    FScrOutput:=TStringList.Create
  else
    FScrOutput.Clear;
  FScript.Running:=True;
  repeat
    FScript.Step;
  until not FScript.Running;
  Result:=FScrOutput.Text;
  FScrOutput.Free;
end;

function TVFSRoute.GetTextFile: string;
begin
  with TStringList.Create do
    try
      LoadFromFile(SITEROOT+FRequest.PathInfo);
      Result:=Text;
    finally
      Free;
    end;
end;

function TVFSRoute.GetFile: string;
var
  ext, buf: string;
begin
  if (FRequest.Method = 'POST') and (ExtractFileName(FRequest.PathInfo) = '__CALL__') then
    if CanCALL then
    begin
      RunCode(StrToInt(FRequest.ContentFields.Values['addr']));
      Result:=GetOutput;
      Exit;
    end;
  if not FileExists(SITEROOT+FRequest.PathInfo) then
  begin
    Result:='Object not found.';
    Exit;
  end;
  if FAdmin and (FRequest.QueryFields.Values['rm'] = 'Y') then
  begin
    DeleteFile(SITEROOT+FRequest.PathInfo);
    Result:='<i>File removed.</i>';
    Exit;
  end;
  ext:=ExtractFileExt(FRequest.PathInfo);
  if (ext = '.gif') or (ext = '.png') or (ext = '.jpg') then
  begin
    if FRequest.QueryFields.Values['embed'] = 'y' then
    begin
      Result:='<center><img src="'+FRequest.PathInfo+'" border="0"/><br/>';
      buf:=GetPageTitle;
      if buf = '' then
        buf:=FRequest.PathInfo;
      Result:=Result+'<h2>'+buf+'</h2></center>';
      Exit;
    end;
  end;
  if (FRequest.QueryFields.Values['edit'] <> '') and FAdmin then
  begin
    Result:='<form action="'+FRequest.PathInfo+'" method="post">';
    Result:=Result+'Filename: <input type="text" name="fi" value="'+FRequest.PathInfo+'"><br/>';
    Result:=Result+'Contents: <textarea id="body" name="body" style="width: 548px; height: 333px;">';
    Result:=Result+GetTextFile+'</textarea><br/>';
    Result:=Result+'<input type="submit" name="editit" value="Save Page">';
    Result:=Result+'</form>';
    {$IFDEF TINYMCE}
    if ext = '.html' then
    begin
      Result:=Result+'<script src="/iui/tinymce.min.js"></script>';
      Result:=Result+'<script> tinymce.init({selector: ''#body''}); </script>';
    end;
    {$ENDIF}
    Exit;
  end;
  if (FRequest.ContentFields.Values['editit'] <> '') and FAdmin then
  begin
    Result:=SaveFile;
    if Result <> '' then
      Exit;
  end;
  case ext of
    '.html': Result:=GetHTMLFile;
    '.prg': Result:=GetPRGFile;
    '.eXe': Result:=GetPRGFile;
    '.app': Result:=GetPRGFile;
    '.prx': Result:=GetScrFile;
    '.log': Result:='<pre>'+GetTextFile+'</pre>';
    '.txt': Result:='<pre>'+GetTextFile+'</pre>';
  else
    if IsDownload then
    begin
      Result:='<center><table bgcolor="#aaaaaa" border="1">';
      Result:=Result+'<tr><td bgcolor="#0000ff"><font color="#ffffff">Download file: <b>'+FRequest.PathInfo+'</b></font></td></tr>';
      Result:=Result+'<tr><td><center><form action="'+FRequest.PathInfo+'?dl=y" method="post">';
      Result:=Result+'You are about to download a file from this site.<br/>Please press the button below to begin your download...<br/>';
      Result:=Result+'<input type="submit" value="Download '+FRequest.PathInfo+'"/></form>';
      Result:=Result+'</center></td></tr></table></center>';
      Exit;
    end;
    Result:=HandleUnknown(FRequest, FSession, ext);
  end;
end;

function TVFSRoute.SaveFile: string;
var
  f: TStringList;
  PRGLoader: string;
begin
  f:=TStringList.Create;
  f.Text:=FRequest.ContentFields.Values['body'];
  f.SaveToFile(SITEROOT+FRequest.ContentFields.Values['fi']);
  f.Free;
  PRGLoader:=GetRunHook(ExtractFileExt(FRequest.ContentFields.Values['fi']));
  if PRGLoader <> '' then
    Result:='Saved.  <a href="'+PRGLoader+'?file='+FRequest.ContentFields.Values['fi']+'">View It!</a>'
  else
    Result:='';
end;

function TVFSRoute.GetTag(param: string): string;
var
  addr: word;
begin
  if FTemplateTags.IndexOfName(param) > -1 then
  begin
    addr:=StrToInt(FTemplateTags.Values[param]);
    RunCode(addr);
    Result:=GetOutput;
  end
  else
    Result:='ERR: '+param;
end;

procedure TVFSRoute.GetParam(Sender: TObject; const ParamName: String; out
  AValue: String);
begin
  case ParamName of
    'sitetitle': AValue:=GetSiteTitle;
    'pagetitle': AValue:=GetPageTitle;
    'prefix': AValue:=GetPrefix;
    'pi': AValue:=FRequest.PathInfo;
    'me': AValue:=FRequest.ScriptName;
    'navpane': AValue:=GetNavPane;
    'content': AValue:=GetContent;
    'header': AValue:=GetHeaderCode;
  else
      AValue:=GetTag(ParamName);
  end;
end;

procedure TVFSRoute.ScrGetParam(Sender: TObject; const ParamName: String; out
  AValue: String);
begin
  case ParamName of
    'sitetitle': AValue:=GetSiteTitle;
    'pagetitle': AValue:=FScrTitle;
    'prefix': AValue:=GetPrefix;
    'pi': AValue:=FRequest.PathInfo;
    'me': AValue:=FRequest.ScriptName;
    'navpane': AValue:=GetNavPane;
    'content': AValue:=GetContent;
    'header': AValue:=FScrHeader;
  else
    AValue:=GetTag(ParamName);
  end;
end;

procedure TVFSRoute.GetTagReplace(Sender: TObject; const TagString: String;
  TagParams: TStringList; out ReplaceText: String);
var
  param: string;
  addr: word;
begin
  param:=TagParams.Values['param'];
  if param = '' then
    GetParam(Sender, TagString, ReplaceText)
  else
  begin
    SetTagParam(param);
    ReplaceText:=GetTag(TagString);
    SetTagParam('');
  end;
end;

function TVFSRoute.FileIcon(const fna: string; IsDirectory: Boolean): string;
var
  ext: string;
begin
  if IsDirectory then
    Result:='folder'
  else
    Result:='unknown';
  ext:=ExtractFileExt(fna);
  if FileExists(SITEROOT+GetPrefix+'System/Settings/Icons.conf') then
    if not Assigned(FIconList) then
    begin
      FIconList:=TStringList.Create;
      FIconList.LoadFromFile(SITEROOT+GetPrefix+'System/Settings/Icons.conf');
    end;
  case ext of
    '.gif': Result:='image2';
    '.jpg': Result:='image2';
    '.png': Result:='image2';
    '.widget': Result:='index';
    '.html': Result:='layout';
    '.spa': Result:='portal';
    '.spax': Result:='portal';
    '.SYS': Result:='generic.sec';
    '.OVL': Result:='binary';
    '.app': Result:='box2';
    '.prg': Result:='comp.gray';
    '.eXe': Result:='comp.blue';
    '.prx': Result:='sphere2';
    '.info': Result:='quill';
    '.conf': Result:='script';
    '.rc': Result:='link';
    '.txt': Result:='text';
  end;
  if Assigned(FIconList) and (FIconList.IndexOfName(ext) > -1) then
    Result:=FIconList.Values[ext];
  if (fna = 'System') or (fna = 'Admin') then
    Result:='folder.sec';
end;

procedure TVFSRoute.HandleImage(AResponse: TResponse);
var
  ext: string;
  s: TMemoryStream;
  E: EHTTPRoute;
begin
  if not FileExists(SITEROOT+FRequest.PathInfo) then
  begin
    E:=EHTTPRoute.Create('Image file not found!');
    E.StatusCode:=404;
    raise E;
  end;
  ext:=ExtractFileExt(FRequest.PathInfo);
  AResponse.SetCustomHeader('Pragma', 'public');
  if ext = '.gif' then
  begin
    AResponse.ContentType:='image/gif';
    AResponse.SetCustomHeader('Content-Disposition', 'inline; filename="zyriximage.gif"');
  end
  else if ext = '.png' then
  begin
    AResponse.ContentType:='image/png';
    AResponse.SetCustomHeader('Content-Disposition', 'inline; filename="zyriximage.png"');
  end
  else if ext = '.jpg' then
  begin
    AResponse.ContentType:='image/jpeg';
    AResponse.SetCustomHeader('Content-Disposition', 'inline; filename="zyriximage.jpg"');
  end;
  AResponse.ContentEncoding:='binary';
  s:=TMemoryStream.Create;
  try
    s.LoadFromFile(SITEROOT+FRequest.PathInfo);
    AResponse.ContentLength:=s.Size;
    AResponse.ContentStream:=s;
    AResponse.SendContent;
    AResponse.ContentStream:=Nil;
  finally
    s.Free;
  end;
end;

procedure TVFSRoute.HandleDownload(AResponse: TResponse);
var
  s: TMemoryStream;
begin
  if not FileExists(SITEROOT+FRequest.PathInfo) then
    raise HTTPError.Create('This is not right.');
  AResponse.SetCustomHeader('Pragma', 'public');
  AResponse.ContentType:='application/octet-stream';
  AResponse.ContentEncoding:='binary';
  s:=TMemoryStream.Create;
  try
    s.LoadFromFile(SITEROOT+FRequest.PathInfo);
    AResponse.ContentLength:=s.Size;
    AResponse.ContentStream:=s;
    AResponse.SendContent;
    AResponse.ContentStream:=Nil;
  finally
    s.Free;
  end;
end;

procedure TVFSRoute.HandleFile(AResponse: TResponse);
var
  s: TMemoryStream;
begin
  if not FileExists(SITEROOT+FRequest.PathInfo) then
    raise HTTPError.Create('This is not right.');
  s:=TMemoryStream.Create;
  try
    s.LoadFromFile(SITEROOT+FRequest.PathInfo);
    AResponse.ContentLength:=s.Size;
    AResponse.ContentStream:=s;
    AResponse.SendContent;
    AResponse.ContentStream:=Nil;
  finally
    s.Free;
  end;
end;

procedure TVFSRoute.ScrSetTitle(data: string);
begin

end;

procedure TVFSRoute.ScrOutput(data: string);
begin
  FScrOutput.Add(data);
end;

function TVFSRoute.ScrInput: string;
begin
  if FRequest.QueryFields.Values['ScrInput'] = '' then
  begin
    Result:='';
    FScrOutput.Add('<form action="'+FRequest.PathInfo+'"><input type="text" name="ScrInput" value="'+FScript.SVar+'"/><input type="submit" value="Go"/></form>');
    FScript.Running:=False;
  end
  else
    Result:=FRequest.QueryFields.Values['ScrInput'];
end;

procedure TVFSRoute.ScrRunFile(AFile: string);
begin

end;

procedure TVFSRoute.ScrOpCode(op: char);
begin
  case op of
    'V': ScrOutput(FScript.SVar);
    'T': FScrTitle:=FScript.GetString;
    'H': FScrHeader:=FScript.GetString;
  else
    FScript.Running:=False;
    FScrOutput.Add('Invalid Op at <b>'+IntToStr(FScript.PC)+'</b>');
  end;
end;

constructor TVFSRoute.Create;
var
  s: TResourceStream;
  m: TMemoryStream;
  buf: string;
begin
  inherited Create;
  FScript:=Nil;
  FAdmin:=False;
  FParamHook:=False;
  tmpl:=TFPTemplate.Create;
  FIconList:=Nil;
  with tmpl do
  begin
    buf:=GetTemplate;
    if (buf = 'NIL') or (not FileExists(SITEROOT+buf)) then
    begin
      s:=TResourceStream.Create(HINSTANCE, 'TEMPLATE', RT_HTML);
      try
        SetLength(buf, s.Size);
        s.Read(buf[1], s.Size);
        Template:=buf;
      finally
        s.Free;
      end;
    end
    else
    begin
      m:=TMemoryStream.Create;
      try
        m.LoadFromFile(SITEROOT+buf);
        SetLength(buf, m.Size);
        m.Read(buf[1], m.Size);
        Template:=buf;
      finally
        m.Free;
      end;
    end;
    OnGetParam:=@GetParam;
  end;
end;

destructor TVFSRoute.Destroy;
begin
  if Assigned(FIconList) then
    FIconList.Free;
  if Assigned(FScript) then
    FScript.Free;
  tmpl.Free;
  inherited Destroy;
end;

procedure TVFSRoute.HandleRequest(ARequest: TRequest; AResponse: TResponse);
var
  ext, buf: string;
  i: Integer;
  E: EHTTPRoute;
begin
  if (not FileExists(SITEROOT+ARequest.PathInfo)) and (not DirectoryExists(SITEROOT+ARequest.PathInfo)) then
  begin
    E:=EHTTPRoute.Create('Object not found!');
    E.StatusCode:=404;
    raise E;
  end;
  FRequest:=ARequest;
  LogInfo(FRequest.RemoteAddr+' Requested '+FRequest.PathInfo);
  if DirectoryExists(SITEROOT+FRequest.PathInfo) and (FRequest.QueryFields.Values['vfs'] <> 'y') then
  begin
    for i:=0 to FIndexes.Count-1 do
      if FileExists(SITEROOT+FRequest.PathInfo+FIndexes.Strings[i]) then
      begin
        AResponse.SendRedirect(FRequest.PathInfo+FIndexes.Strings[i]);
        Exit;
      end;
  end;
  if DirectoryExists(SITEROOT+GetPrefix+INFO_DIR) then
    RunInfoRC(SITEROOT+GetPrefix+INFO_DIR+ExtractFileName(FRequest.PathInfo)+'.info', Nil, Nil);
  if FileExists(SITEROOT+FRequest.PathInfo+'.info') then
    RunInfoRC(SITEROOT+FRequest.PathInfo+'.info', Nil, Nil);
  if (FRequest.QueryFields.Values['dl'] = 'y') and IsDownload then
  begin
    HandleDownload(AResponse);
    Exit;
  end;
  ext:=ExtractFileExt(FRequest.PathInfo);
  if (ext = '.gif') or (ext = '.png') or (ext = '.jpg') then
  begin
    if FRequest.QueryFields.Values['embed'] <> 'y' then
    begin
      HandleImage(AResponse);
      Exit;
    end;
  end
  else if ext = '.json' then
  begin
    AResponse.ContentType:='application/json';
    HandleFile(AResponse);
    Exit;
  end
  else if ext = '.js' then
  begin
    AResponse.ContentType:='application/javascript';
    HandleFile(AResponse);
    Exit;
  end
  else if ext = '.css' then
  begin
    AResponse.ContentType:='text/css';
    HandleFile(AResponse);
    Exit;
  end;
  if FRequest.QueryFields.Values['path'] <> '' then
  begin
    AResponse.SendRedirect(FRequest.QueryFields.Values['path']);
    Exit;
  end;
  FSession:=TIniWebSession(SessionFactory.CreateSession(ARequest));
  try
    FSession.InitSession(ARequest, @NewSession, @SessionExpired);
    if FSession.Variables['login'] = GetAdminPass then
      FAdmin:=True;
    if ext = '.prg' then
    begin
      SetBoot(LoadPRGFile(SITEROOT+FRequest.PathInfo));
      RunProgram(FRequest, FSession);
      buf:=GetRedirect;
      if buf <> '' then
      begin
        AResponse.SendRedirect(buf);
        Exit;
      end;
      buf:=GetMimeType;
      if buf <> '' then
        AResponse.ContentType:=buf;
      buf:=GetOutput;
      if buf <> '' then
        tmpl.Template:=buf;
    end
    else if ext = '.eXe' then
    begin
      LoadInFile(SITEROOT+FRequest.PathInfo, $2000);
      SetBoot($2000);
      RunProgram(FRequest, FSession);
      buf:=GetRedirect;
      if buf <> '' then
      begin
        AResponse.SendRedirect(buf);
        Exit;
      end;
      buf:=GetMimeType;
      if buf <> '' then
        AResponse.ContentType:=buf;
      buf:=GetOutput;
      if buf <> '' then
        tmpl.Template:=buf;
    end
    else if ext = '.prx' then
    begin
      if not Assigned(FScript) then
        FScript:=TScriptSystem.Create(Nil);
      with TStringStream.Create do
        try
          LoadFromFile(SITEROOT+FRequest.PathInfo);
          FScript.Script:=DataString;
        finally
          Free;
        end;
      FScript.OnOutput:=@ScrSetTitle;
      FScript.OnInput:=@ScrInput;
      FScript.OnRunFile:=@ScrRunFile;
      FScript.OnOpCode:=@ScrOpCode;
      tmpl.OnGetParam:=@ScrGetParam;
      FScrHeader:='';
      FScrTitle:='Untitled';
      FScript.Run;
    end
    else if ext = '.app' then
    begin
      RunApp(FRequest.PathInfo, ARequest, FSession);
      buf:=GetRedirect;
      if buf <> '' then
      begin
        AResponse.SendRedirect(buf);
        Exit;
      end;
      buf:=GetMimeType;
      if buf <> '' then
        AResponse.ContentType:=buf;
      buf:=GetOutput;
      if buf <> '' then
        tmpl.Template:=buf;
    end
    else if ext = '.spa' then
    begin
      with TMemoryStream.Create do
      try
        LoadFromFile(SITEROOT+FRequest.PathInfo);
        SetLength(buf, Size);
        Read(buf[1], Size);
        tmpl.Template:=buf;
      finally
        Free;
      end;
    end
    else if ext = '.spax' then
    begin
      with TMemoryStream.Create do
      try
        LoadFromFile(SITEROOT+FRequest.PathInfo);
        SetLength(buf, Size);
        Read(buf[1], Size);
        tmpl.Template:=buf;
        AResponse.ContentType:='application/xml';
      finally
        Free;
      end;
    end
    else if ExtractFileName(FRequest.PathInfo) = '__CALL__' then
      PrepCALL(FRequest, FSession);
    { TODO : Parsing of any .info files or meta-data before the template should be here. }
    try
      if (FRequest.QueryFields.Values['ajax'] = 'true') or GetAJAX or (ARequest.GetHTTPVariable(hvXRequestedWith) = 'XMLHttpRequest') then
        AResponse.Content:='<div title="'+GetPageTitle+'" class="panel">'+GetContent+'</div>'
      else if FRequest.QueryFields.Values['cx'] = 'true' then
        AResponse.Content:=GetContent
      else
        AResponse.Content:=tmpl.GetContent;
      FSession.InitResponse(AResponse);
    except
      On EVFSRedirect do AResponse.SendRedirect(Exception(ExceptObject).Message);
      On EHTTPRoute do AResponse.Code:=404;
    end;
  finally
    SessionFactory.DoneSession(TCustomSession(FSession));
  end;
end;

procedure RunBootSys;
var
  f: Text;
begin
  if FileExists(SITEROOT+GetPrefix+'BOOT.SYS') then
  begin
    LoadInFile(SITEROOT+GetPrefix+'BOOT.SYS', BOOT_ADDR);
    SetBoot(BOOT_ADDR);
    RunCode(BOOT_ADDR);
    Assign(f, SITEROOT+GetPrefix+'System/bootmsg.log');
    Rewrite(f);
    Write(f, GetOutput);
    Close(f);
  end;
end;

procedure PkgInstall(const pkg: string; pkgtyp: TPackageType);
var
  f: TMemoryStream;
  path: string;
begin
  case pkgtyp of
    ptApp: path:='Apps/';
    ptBoot: path:='Boot/';
    ptSystem: path:='System/';
    ptAdmin: path:='Admin/';
  end;
  WriteLn(' * Installing package: ',pkg);
  {if not DirectoryExists(SITEROOT+GetPrefix+path) then
  begin
    Application.ShowException(Exception.Create('Create directory: '+path));
    Exit;
  end;}
  with TFPHTTPClient.Create(Nil) do
    try
      f:=TMemoryStream.Create;
      Get('http://reposrv.home.lan/6502/VFS/'+path+pkg, f);
      if pkgtyp = ptBoot then
        f.SaveToFile(SITEROOT+GetPrefix+'BOOT.SYS')
      else
        f.SaveToFile(SITEROOT+GetPrefix+path+pkg);
    finally
      f.Free;
      Free;
    end;
end;

procedure ProcessCommandLine;
var
  ErrorMsg: string;
begin
  with Application do
  begin
    ErrorMsg:=CheckOptions('i:b:s:a:f:', 'install: boot: system: admin: state:');
    if ErrorMsg <> '' then
    begin
      ShowException(Exception.Create(ErrorMsg));
      Halt(2);
    end;
    if HasOption('i', 'install') then
    begin
      PkgInstall(GetOptionValue('i', 'install'), ptApp);
      Free;
      Halt(0);
    end;
    if HasOption('b', 'boot') then
    begin
      PkgInstall(GetOptionValue('b', 'boot'), ptBoot);
      Free;
      Halt(0);
    end;
    if HasOption('s', 'system') then
    begin
      PkgInstall(GetOptionValue('s','system'), ptSystem);
      Free;
      Halt(0);
    end;
    if HasOption('a', 'admin') then
    begin
      PkgInstall(GetOptionValue('a', 'admin'), ptAdmin);
      Free;
      Halt(0);
    end;
  end;
end;

{$IFDEF DEBUG}
Procedure HandleRELOAD(ARequest: TRequest; AResponse: TResponse);
begin
  Logwarn('Resetting 6502...');
  Reset6502;
  LogWarn('Reloading BOOT.SYS...');
  RunBootSys;
  AResponse.SendRedirect('/'+GetPrefix);
end;
{$ENDIF}

{$R *.res}

begin
  ProcessCommandLine;
  SetupLog('siteroot/'+GetPrefix+'System/vfs.log');
  LogInfo('VFS Starting...');
  RunBootSys;
  SessionFactory:=TIniSessionFactory.Create(Nil);
  SessionFactory.SessionDir:='siteroot/sessions/';
  SessionFactory.SessionCookie:='VFSSession';
  SessionFactory.SessionCookiePath:='/'+GetPrefix;
  DefaultStartDelimiter:='{+';
  DefaultEndDelimiter:='+}';
  Application.Title:='vfs';
  {$IFDEF HTTP}
  RegisterFileLocation('icons', '/usr/share/apache2/icons');
  Application.Port:=8000;
  {$ELSE}
  Application.Port:=GetPort;
  {$ENDIF}
  {$IFDEF DEBUG}
  HTTPRouter.RegisterRoute('/'+GetPrefix+'__RELOAD__', @HandleRELOAD);
  HTTPRouter.RegisterRoute('/__VFS__', TVFSRoute, True);
  {$ELSE}
  HTTPRouter.RegisterRoute('*', TVFSRoute);
  {$ENDIF}
  Application.Initialize;
  LogInfo('VFS Initialized on port '+IntToStr(Application.Port)+', application ready.');
  Application.Run;
  LogInfo('VFS Terminated properly.');
  SessionFactory.Free;
end.

