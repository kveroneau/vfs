unit appserver;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, {$IFDEF HTTP}custhttpapp{$ELSE}custfcgi{$ENDIF}, eventlog,
  vfsinfo;

type

  { TAppServer }

  TAppServer = class({$IFDEF HTTP}TCustomHTTPApplication{$ELSE}TCustomFCgiApplication{$ENDIF})
  protected
    function CreateEventLog: TEventLog; override;
  end;

var
  Application: TAppServer;
  ShowCleanUpErrors : Boolean = False;

const
  SITEROOT='siteroot/';

implementation

uses CustApp;

procedure InitAppServer;
begin
  Application:=TAppServer.Create(Nil);
  if not Assigned(CustomApplication) then
    CustomApplication:=Application;
end;

procedure DoneAppServer;
begin
  if CustomApplication = Application then
    CustomApplication:=Nil;
  try
    FreeAndNil(Application);
  except
    if ShowCleanUpErrors then
      Raise;
  end;
end;

{ TAppServer }

function TAppServer.CreateEventLog: TEventLog;
begin
  Result:=TEventLog.Create(Nil);
  With Result do
  begin
    Name:=Self.Name+'Logger';
    Identification:=Title;
    RegisterMessageFile(ParamStr(0));
    LogType:=ltFile;
    FileName:=SITEROOT+'System/appsrv.log';
    Active:=True;
  end;
end;

initialization
  InitAppServer;

finalization
  DoneAppServer;

end.

