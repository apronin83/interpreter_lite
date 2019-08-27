unit uEnvironment;

interface

uses
  Classes, Contnrs, SysUtils, uVariables, uFunctions, uValues, uStack;

type
  TFunctionCallEvent = procedure(Sender: TObject; AFunctionName: String; AIndex: Integer; AArgsCount: Integer) of object;

type
  TEnvironment = class(TObject)
  private
    FVariables: TVariablesStack;
    FGlobals: TVariablesStack;
    FFunctions: TFunctionsStack;

    FStack: TProgStack;

    FResult: TValue;

    FCount: Integer;

    FFunctionCallList: array of String;
    FFunctionCallRef: array of array of Boolean;
    FOnFunctionCall: TFunctionCallEvent;

    function GetFunctionCallRef(Funct, Arg: Integer): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    function GetFunctionArgCount(Funct: Integer): Integer;
    function IndexOfFunctionCall(AName: String): Integer;
    procedure AddFunctionCall(AFuncName: String; const ARefList: array of Boolean);

    function UserCallFunction(AFuncName: String; AParams: TObjectList): TValue;
    property Variables: TVariablesStack read FVariables;
    property Globals: TVariablesStack read FGlobals;
    property Stack: TProgStack read FStack;
    property Functions: TFunctionsStack read FFunctions;
    property FunctionCallRef[Funct, Arg: Integer]: Boolean read GetFunctionCallRef;
    property OnFunctionCall: TFunctionCallEvent read FOnFunctionCall write FOnFunctionCall;

    property Result: TValue read FResult write FResult;
  end;

implementation

uses
  uNodes;

constructor TEnvironment.Create;
begin
  FVariables := TVariablesStack.Create;
  FGlobals := TVariablesStack.Create;
  FFunctions := TFunctionsStack.Create;

  FStack := TProgStack.Create();

  FResult := TValue.Create;

  FOnFunctionCall := nil;

  FCount := 0;

  SetLength(FFunctionCallList, 0);
end;

destructor TEnvironment.Destroy;
var
  i: Integer;
begin
  SetLength(FFunctionCallList, 0);

  for i := Low(FFunctionCallRef) to High(FFunctionCallRef) do
    SetLength(FFunctionCallRef[i], 0);

  SetLength(FFunctionCallRef, 0);

  FVariables.Free;
  FGlobals.Free;

  FFunctions.Free;

  FStack.Free;
  FResult.Free;

  inherited;
end;

procedure TEnvironment.AddFunctionCall(AFuncName: String; const ARefList: array of Boolean);
var
  i: Integer;
begin
  Inc(FCount);

  SetLength(FFunctionCallList, FCount);
  SetLength(FFunctionCallRef, FCount);

  FFunctionCallList[FCount-1] := AFuncName;

  SetLength(FFunctionCallRef[FCount-1], Length(ARefList));

  for i := 0 to High(ARefList) do FFunctionCallRef[FCount-1][i] := ARefList[i];
end;

function TEnvironment.IndexOfFunctionCall(AName: String): Integer;
var
  i: Integer;
begin
  Result := -1;

  for i := 0 to FCount-1 do
    if AName = FFunctionCallList[i] then
      begin
        Result := i;
        Break;
      end;
end;
            
function TEnvironment.GetFunctionCallRef(Funct, Arg: Integer): Boolean;
begin
  Result := false;

  if (Funct < 0) or (Funct >= FCount) then exit;

  if (Arg < 0) or (Arg >= Length(FFunctionCallRef[Funct])) then exit;

  Result := FFunctionCallRef[Funct][Arg];
end;

function TEnvironment.GetFunctionArgCount(Funct: Integer): Integer;
begin
  Result := 0;

  if (Funct < 0) or (Funct >= FCount) then exit;
  
  Result := Length(FFunctionCallRef[Funct]);
end;

function TEnvironment.UserCallFunction(AFuncName: String; AParams: TObjectList): TValue;
var
  i: Integer;
  FunctionNode: TFunctionNode;
  arg: TValue;
  IsByRef: Boolean;
begin
  if Assigned(FResult) then FResult.Free;

  FResult := TValue.Create;

  //---------------------------------------------

  Result := TValue.Create;

  //---------------------------------------------

  FunctionNode := TFunctionNode(FFunctions.GetFunction(AFuncName));

  if FunctionNode = nil then
    raise Exception.CreateFmt('Функция ''%s'' не найдена (%d,%d)', [AFuncName, -1, -1]);

  if FunctionNode.NodesList[1].NodeCount <> AParams.Count then
    raise Exception.CreateFmt('Вызов функции ''%s'' с неверным числом параметров (%d,%d)', [AFuncName, -1, -1]);

  //---------------------------------------------

  for i := AParams.Count-1 downto 0 do
    FStack.Push(TValue.Create(AParams[i] as TValue));

  //---------------------------------------------

  FunctionNode.EvalFunction(Self);

  //---------------------------------------------

  // удаляется из стека и сохраняет аргументы тех, кто имеет ссылки.
  // первым в стеке будет первый аргумент

  for i := 0 to AParams.Count-1 do
    begin
      IsByRef := TParamNode(FunctionNode.NodesList[1]).Ref[i];

      arg := FStack.Pop;

      if IsByRef then (AParams[i] as TValue).Assign(arg);

      arg.Free;
    end;

  //---------------------------------------------

  // Выводим результат
  Result.Assign(FResult);
end;


end.

