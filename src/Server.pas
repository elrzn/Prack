unit Server;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, GatewayServer, ApiServer, Queue, Orchestra;

const
  DEFAULT_GATEWAY_HOST = '0.0.0.0';
  DEFAULT_GATEWAY_PORT = 8080;
  DEFAULT_API_HOST = '0.0.0.0';
  DEFAULT_API_PORT = 4242;
  CRLF = #13#10;

type

  { TPrack }

  TPrack = class
  private
    FApiHost: string;
    FApiPort: integer;
    FApiServer: TApiServer;
    FGatewayHost: string;
    FGatewayPort: integer;
    FGatewayServer: TGatewayServer;
    FOrchestra: TOrchestra;
    FQueue: TPrackQueue;
    procedure PrintBanner;
  public
    Active: boolean;
    constructor Create(GatewayHost: string; GatewayPort: integer;
      ApiHost: string; ApiPort: integer);
    destructor Destroy; override;
    procedure Start;
  end;

implementation

constructor TPrack.Create(GatewayHost: string; GatewayPort: integer;
  ApiHost: string; ApiPort: integer);
begin
  Active := False;
  FQueue := TPrackQueue.Create;
  FOrchestra := TOrchestra.Create(FQueue);
  FGatewayHost := GatewayHost;
  FGatewayPort := GatewayPort;
  FGatewayServer := TGatewayServer.Create(FGatewayHost, FGatewayPort, FQueue);
  FApiHost := ApiHost;
  FApiPort := ApiPort;
  FApiServer := TApiServer.Create(FApiHost, FApiPort, FQueue);
end;

procedure TPrack.Start;
begin
  Active := True;
  TThread.ExecuteInThread(@FGatewayServer.Start);
  TThread.ExecuteInThread(@FApiServer.Start);
  PrintBanner;
end;

destructor TPrack.Destroy;
begin
  FreeAndNil(FGatewayServer);
  FreeAndNil(FApiServer);
  FreeAndNil(FQueue);
  Writeln('(╯°□°）╯︵ ┻━┻', CRLF);
  inherited;
end;

procedure TPrack.PrintBanner;
begin
  Writeln(CRLF,
    '  ________                    ______', CRLF,
    '  ___  __ \____________ _________  /__', CRLF,
    '  __  /_/ /_  ___/  __ `/  ___/_  //_/', CRLF,
    '  _  ____/_  /   / /_/ // /__ _  ,<', CRLF,
    '  /_/     /_/    \__,_/ \___/ /_/|_| Proof of Concept', CRLF);
  Writeln('Public Server listening on http://', FGatewayHost, ':', FGatewayPort);
  Writeln('   API Server listening on http://', FApiHost, ':', FApiPort, CRLF);
end;

end.
