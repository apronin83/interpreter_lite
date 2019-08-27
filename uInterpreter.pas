unit uInterpreter;

interface

uses
  Types, uToken, SysUtils, uParser, uEnvironment, uValues;

type
  TInterpreter = class(TObject)
  private
    FSource: String;
    FTokenList: TTokenList;
    FParser: TParser;
    FEnvironment: TEnvironment;
    function GetSource: String;
    procedure SetFunctionCall(AFunctionCallEvent: TFunctionCallEvent);
    function GetFunctionCall: TFunctionCallEvent;
  public
    constructor Create;
    destructor Destroy; override;
    function Run: TValue;
    property TokenList: TTokenList read FTokenList;
    property Parser: TParser read FParser;
    property Environment: TEnvironment read FEnvironment;
    procedure SetCodeSource(AFileName, ASource: String);    
    property CodeSource: String read GetSource;
    property OnFunctionCall: TFunctionCallEvent read GetFunctionCall write SetFunctionCall;
  end;

implementation   

uses
  Unit1;

constructor TInterpreter.Create;
begin
  FTokenList := TTokenList.Create;
  FEnvironment := TEnvironment.Create;
  FParser := TParser.Create(FEnvironment);
end;

destructor TInterpreter.Destroy;
begin
  FTokenList.Free;
  FEnvironment.Free;
  FParser.Free;

  inherited;
end;

procedure TInterpreter.SetCodeSource(AFileName, ASource: String);
//var
//  i: integer;
begin
  FSource := ASource;
  FTokenList.Tokenize(AFileName, ASource);

  //Form1.Memo2.Clear;

  //for i := 0 to FTokenList.Count-1 do
  //  Form1.Memo2.Lines.Add(FTokenList.Token[i].Value);

  FParser.Parse(FTokenList);
end;

function TInterpreter.GetSource: String;
begin
  Result := FSource;
end;

procedure TInterpreter.SetFunctionCall(AFunctionCallEvent: TFunctionCallEvent);
begin
  FEnvironment.OnFunctionCall := AFunctionCallEvent;
end;

function TInterpreter.GetFunctionCall: TFunctionCallEvent;
begin
  Result := FEnvironment.OnFunctionCall;
end;

function TInterpreter.Run: TValue;
begin
  Result := FParser.Eval;
end;


end.
