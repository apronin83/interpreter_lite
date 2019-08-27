unit uFunctions;

interface

uses
  Classes, uHashTable, Contnrs, Types, SysUtils, uValues;

type
  TFunctionsList = class(THashTable)
  public
    destructor Destroy; override;

    function GetFunction(AFunctionName: String): TObject;
    procedure Define(AFunctionName: String; AFunctionNode: TObject);
  end;

  TFunctionsStack = class(TObject)
  private
    FStack: TObjectList;
    function GetCount: Integer;
    function GetLastFunctionsList: TFunctionsList;
  public
    constructor Create;
    destructor Destroy; override;
    property Count: Integer read GetCount;
    function GetFunction(AFunctionName: String): TObject;
    procedure Define(AFunctionName: String; AFunctionNode: TObject);
    function IsExist(AFunctionName: String): Boolean;
    procedure UpStack;
    procedure DownStack;
 end;

implementation

// TFunctionsList TFunctionsList TFunctionsList TFunctionsList TFunctionsList
//============================================================================

function TFunctionsList.GetFunction(AFunctionName: String): TObject;
begin
  Result := Get(AFunctionName);
end;

procedure TFunctionsList.Define(AFunctionName: String; AFunctionNode: TObject);
begin
  Add(AFunctionName, AFunctionNode);
end;

// TVariablesStack TVariablesStack TVariablesStack TVariablesStack
//=================================================================

constructor TFunctionsStack.Create;
begin
  FStack := TObjectList.Create;
end;

destructor TFunctionsStack.Destroy;
begin
  FreeAndNil(FStack);

  inherited;
end;

function TFunctionsStack.GetFunction(AFunctionName: String): TObject;
var
  j, s: Integer;
begin
  s := -1;

  Result := nil;

  for j := 0 to FStack.Count-1 do
    if Assigned((FStack[j] as TFunctionsList).GetFunction(AFunctionName)) then s := j;

  if s <> -1 then Result := (FStack[s] as TFunctionsList).GetFunction(AFunctionName);
end;

procedure TFunctionsStack.Define(AFunctionName: String; AFunctionNode: TObject);
begin
  if Assigned(GetLastFunctionsList.GetFunction(AFunctionName)) then
    raise Exception.CreateFmt('''%s'' уже определен', [AFunctionName]);

  GetLastFunctionsList.Define(AFunctionName, AFunctionNode);
end;


procedure TFunctionsStack.UpStack;
begin
  FStack.Add(TFunctionsList.Create);

  if FStack.Count > 1000 then
    raise Exception.CreateFmt('Превышен размер стека функций Stack Size = %d.', [FStack.Count]);
end;

procedure TFunctionsStack.DownStack;
begin
  FStack.Delete(FStack.Count-1); // Free вызывается внутри метода Notify для TObjectList (OwnsObjects := True)
end;

function TFunctionsStack.GetCount: Integer;
begin
  Result := FStack.Count;
end;

function TFunctionsStack.GetLastFunctionsList: TFunctionsList;
begin
  Result := FStack[FStack.Count-1] as TFunctionsList;
end;


function TFunctionsStack.IsExist(AFunctionName: String): Boolean;
begin
  Result := Assigned(GetLastFunctionsList.Get(AFunctionName));
end;

destructor TFunctionsList.Destroy;
begin
  // Empty for save NodeList Functions

end;

end.
