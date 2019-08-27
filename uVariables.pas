unit uVariables;

interface

uses
  Classes, uHashTable, Contnrs, Types, SysUtils, uValues;

type
  TVariablesList = class(THashTable) //(TStringList)
  public
    destructor Destroy; override;

    function GetValue(AVariableName: String): TValue;
    function Define(AVariableName: String; AVariableValue: TValue): TValue;
    function DefineNew(AVariableName: String): TValue;
    function AddVariable(AVariableName: String; AVariableValue: TValue): TValue;
  end;

  TVariablesStack = class(TObject)
  private
    FStack: TObjectList;
    function GetCount: Integer;
    function GetLastVariablesList: TVariablesList;
  public
    constructor Create;
    destructor Destroy; override;

    property Count: Integer read GetCount;
    function GetValue(AVariableName: String): TValue;
    function Define(AVariableName: String; AVariableValue: TValue): TValue;
    function DefineNew(AVariableName: String): TValue;
    function IsExist(AVariableName: String): Boolean;
    procedure UpStack;
    procedure DownStack;
  end;

implementation

destructor TVariablesList.Destroy;
//var
//  i: Integer;
begin
//  for i := 0 to Count-1 do
//    Objects[i].Free;
//
  inherited;
end;

function TVariablesList.GetValue(AVariableName: String): TValue;
begin
  if not Assigned(Get(AVariableName)) then
    Result := nil
  else
    Result := Get(AVariableName) as TValue;
end;

function TVariablesList.Define(AVariableName: String; AVariableValue: TValue): TValue;
begin
  if not Assigned(Get(AVariableName)) then
    Result := AddVariable(AVariableName, AVariableValue)
  else
    Result := (Get(AVariableName) as TValue).Assign(AVariableValue);
end;

function TVariablesList.DefineNew(AVariableName: String): TValue;
begin
  Result := TValue.Create;

  Add(AVariableName, Result);
end;

function TVariablesList.AddVariable(AVariableName: String; AVariableValue: TValue): TValue;
begin
  Result := TValue.Create(AVariableValue);

  Add(AVariableName, Result);
end;

// TVariablesStack TVariablesStack TVariablesStack TVariablesStack
//=================================================================

constructor TVariablesStack.Create;
begin
  FStack := TObjectList.Create;
end;

destructor TVariablesStack.Destroy;
var
  i: Integer;
begin
  for i := FStack.Count-1 downto 0 do FStack[i].Free;

  FreeAndNil(FStack);

  inherited;
end;

function TVariablesStack.GetValue(AVariableName: String): TValue;
begin
  Result := GetLastVariablesList.GetValue(AVariableName);
end;

function TVariablesStack.Define(AVariableName: String; AVariableValue: TValue): TValue;
begin
  Result := GetLastVariablesList.Define(AVariableName, AVariableValue);
end;

function TVariablesStack.DefineNew(AVariableName: String): TValue;
begin
  Result := GetLastVariablesList.DefineNew(AVariableName);
end;

function TVariablesStack.IsExist(AVariableName: String): Boolean;
begin
  Result := Assigned(GetLastVariablesList.Get(AVariableName));
end;

procedure TVariablesStack.UpStack;
begin
  FStack.Add(TVariablesList.Create);

  if FStack.Count > 1000 then
    raise Exception.CreateFmt('Превышен размер стека переменных Stack Size = %d.', [FStack.Count]);
end;

procedure TVariablesStack.DownStack;
begin
  FStack.Delete(FStack.Count-1); // Free вызывается внутри метода Notify для TObjectList (OwnsObjects := True)
end;

function TVariablesStack.GetCount: Integer;
begin
  Result := FStack.Count;
end;

function TVariablesStack.GetLastVariablesList: TVariablesList;
begin
  Result := FStack[FStack.Count-1] as TVariablesList;
end;

end.
