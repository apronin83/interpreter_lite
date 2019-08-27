unit uValues;

interface

uses
  Classes, Types, SysUtils, uGmXml, Dialogs;

type
  TTypeValue = (tvNone, tvNumber, tvString, tvBoolean, tvArray);

  TValue = class(TObject)
  private
    FTypeValue: TTypeValue;
    FPosition: TPoint;
    FNumber: Extended;
    FBoolean: Boolean;
    FString: String;
    FCount: Integer;
    FArray: array of TValue;

    function GetNumberValue: Extended;
    procedure SetNumberValue(Value: Extended);

    function GetStringValue: String;
    procedure SetStringValue(Value: String);

    function GetBooleanValue: Boolean;
    procedure SetBooleanValue(Value: Boolean);

    function GetArrayValue(Index: Integer): TValue;
    procedure SetArrayValue(Index: Integer; Value: TValue);
  public
    constructor Create; overload;
    constructor Create(APosition: TPoint); overload;
    constructor Create(APosition: TPoint; aValue: Extended); overload;
    constructor Create(APosition: TPoint; AValue: String); overload;
    constructor Create(APosition: TPoint; AValue: Boolean); overload;
    constructor Create(APosition: TPoint; AValue: TValue); overload;
    constructor Create(AValue: Extended); overload;
    constructor Create(AValue: String); overload;
    constructor Create(AValue: Boolean); overload;
    constructor Create(AValue: TValue); overload;

    destructor Destroy; override;

    procedure AddArrayItem(Value: TValue);
    procedure DeleteArrayItems(EndCount: Integer);

    procedure SaveXML(AXmlNodeList: TGmXmlNodeList);
    procedure LoadXML(AXmlNode: TGmXmlNode);

    function ToString: String;
    function ToNumber: Extended;
    function ToBoolean: Boolean;
    property ArrayLenght: Integer read FCount;
    property TypeValue: TTypeValue read FTypeValue;
    property Position: TPoint read FPosition;
    property NumberValue: Extended read GetNumberValue write SetNumberValue;
    property StringValue: String read GetStringValue write SetStringValue;
    property BooleanValue: Boolean read GetBooleanValue write SetBooleanValue;
    property ArrayValue[Index: Integer]: TValue read GetArrayValue write SetArrayValue;
    function IsString: Boolean;
    function IsNumber: Boolean;
    function IsBoolean: Boolean;
    function IsArray: Boolean;
    function Assign(Value: TValue): TValue;
  end;

var
  ValueCount: Integer;
  SL: TStringList;  

implementation

// TValue TValue TValue TValue TValue TValue TValue TValue TValue TValue TValue
//==============================================================================

constructor TValue.Create(APosition: TPoint);
begin
  FPosition := APosition;
  FTypeValue := tvNone;
  FNumber := 0;
  FBoolean := false;
  FString := '';
  FCount := 0;
  FArray := nil;

  Inc(ValueCount);
end;

constructor TValue.Create;
begin
  Create(Point(-1, -1));

  FTypeValue := tvNone;
end;

constructor TValue.Create(APosition: TPoint; AValue: Extended);
begin
  Create(APosition);

  FTypeValue := tvNumber;
  FNumber := AValue;
end;

constructor TValue.Create(APosition: TPoint; AValue: String);
begin
  Create(APosition);

  FTypeValue := tvString;
  FString := AValue;
end;

constructor TValue.Create(APosition: TPoint; AValue: Boolean);
begin
  Create(APosition);

  FTypeValue := tvBoolean;
  FBoolean := AValue;
end;

constructor TValue.Create(APosition: TPoint; AValue: TValue);
var
  i: Integer;
begin
  Create(APosition);

  FTypeValue := AValue.FTypeValue;
  FNumber := AValue.FNumber;
  FBoolean := AValue.FBoolean;
  FString := AValue.FString;

  for i := 0 to AValue.FCount-1 do AddArrayItem(AValue.FArray[i]);
end;

constructor TValue.Create(AValue: Extended);
begin
  Create(Point(-1,-1), AValue);
end;

constructor TValue.create(AValue: String);
begin
  Create(Point(-1,-1), AValue);
end;

constructor TValue.Create(AValue: Boolean);
begin
  Create(Point(-1,-1), AValue);
end;

constructor TValue.Create(AValue: TValue);
begin
  Create(Point(-1,-1), AValue);
end;

function TValue.ToString: String;
begin
  FString := GetStringValue;
  FTypeValue := tvString;
  FCount := 0;
  SetLength(FArray, 0);
  Result := FString;
end;

function TValue.ToNumber: extended;
begin
  FNumber := GetNumberValue;
  FTypeValue := tvNumber;
  FCount := 0;
  SetLength(FArray, 0);
  Result := FNumber;
end;

function TValue.ToBoolean:Boolean;
begin
  FBoolean := GetBooleanValue;
  FTypeValue := tvBoolean;
  FCount := 0;
  Setlength(FArray, 0);
  Result := FBoolean;
end;

destructor TValue.Destroy;
var
  i: Integer;
begin
  for i := 0 to FCount-1 do FArray[i].Free;

  SetLength(FArray, 0);

  Dec(ValueCount);

  inherited;
end;

function TValue.Assign(Value: TValue): TValue;
var
  i: Integer;
begin
  FTypeValue := Value.FTypeValue;
  FNumber := Value.FNumber;
  FBoolean := Value.FBoolean;
  FString := Value.FString;

  for i := 0 to FCount-1 do FArray[i].Free;

  FCount := 0;

  SetLength(FArray, 0);

  for i := 0 to Value.FCount-1 do AddArrayItem(Value.FArray[i]);

  Result := Self;
end;

function TValue.IsString: Boolean;
begin
  Result := FTypeValue = tvString;
end;

function TValue.IsNumber: Boolean;
begin
  Result := FTypeValue = tvNumber;
end;

function TValue.IsBoolean: Boolean;
begin
  Result := Ftypevalue = tvBoolean;
end;

function TValue.IsArray: Boolean;
begin
  Result := Ftypevalue = tvArray;
end;

procedure TValue.AddArrayItem(Value: TValue);
begin
  FTypeValue := tvArray;

  Inc(FCount);

  SetLength(FArray, FCount);

  FArray[FCount-1] := TValue.Create(Value);
end;

function TValue.GetNumberValue: Extended;
begin
  case FTypeValue of
  tvNone   : Result := 0;
  tvNumber : Result := FNumber;
  tvString :
    begin
      if not TryStrToFloat(StringReplace(FString, '.', ',', [rfReplaceAll]), Result) then
        raise Exception.CreateFmt('Невозможно преобразовать "%s" в номер (%d,%d)', [FString, FPosition.X, FPosition.Y]);
    end;
  tvBoolean: if FBoolean then Result := 1 else Result := 0;
  tvArray  : Result := FCount;
  end;
end;

procedure TValue.SetNumberValue(Value: Extended);
begin
  FTypeValue := tvNumber;
  FNumber := Value;
end;

function TValue.GetStringValue: String;
var
  i: Integer;
begin
  case FTypevalue of
  tvNone   : Result := '';
  tvNumber : Result := StringReplace(FloatToStr(FNumber), ',', '.', [rfReplaceAll]);
  tvString : Result := FString;
  tvBoolean: if FBoolean then Result := 'TRUE' else Result := 'FALSE';
  tvArray  :
    begin
      Result := '[';
      for i := 0 to FCount-1 do
        begin
          Result := Result + FArray[i].GetStringValue;
          if i <> FCount-1 then Result := Result + ',';
        end;
      Result := Result + ']';
    end;
  end;
end;

procedure TValue.SetStringValue(Value: String);
begin
  FTypeValue := tvString;
  FString := Value;
end;

function TValue.GetBooleanValue: Boolean;
begin
  Result := false;

  case FTypevalue of
  tvNone   : Result := false;
  tvNumber : Result := FNumber <> 0;
  tvString : Result := FString <> '';
  tvBoolean: Result := FBoolean;
  tvArray  : Result := FCount <> 0;
 end;
end;

procedure TValue.SetBooleanValue(Value: Boolean);
begin
  FTypeValue := tvBoolean;
  FBoolean := Value;
end;

function TValue.GetArrayValue(Index: Integer): TValue;
begin
  if (Index < 0) or (Index > FCount-1) then
    raise Exception.CreateFmt('Индекс вне диапазона (%d,%d)', [FPosition.X, FPosition.Y]);
    
  Result := FArray[Index];
end;

procedure TValue.SetArrayValue(Index: Integer; Value: TValue);
begin
  if (Index < 0) or (Index > FCount-1) then
    raise Exception.CreateFmt('Индекс вне диапазона (%d,%d)', [FPosition.X, FPosition.Y]);

  FArray[Index].Free;

  FArray[Index] := TValue.Create(Value);
end;

procedure TValue.DeleteArrayItems(EndCount: Integer);
var
  i: Integer;
begin
  if EndCount >= FCount then exit;

  for i := EndCount to FCount-1 do FArray[i].Free;

  SetLength(FArray, EndCount);

  FCount := EndCount;
end;

procedure TValue.SaveXML(AXmlNodeList: TGmXmlNodeList);
begin
  with AXmlNodeList do
    begin
      AddOpenTag('TValue');

      CurrentNode.Attribute.Name := 'Type';
      CurrentNode.Attribute.Value := IntToStr(Ord(FTypeValue));

      AddLeaf('X').AsInteger := FPosition.X;
      AddLeaf('Y').AsInteger := FPosition.Y;      

      case FTypeValue of
      tvNone   : AddLeaf('Value').AsInteger := 0;
      tvNumber : AddLeaf('Value').AsFloat := FNumber;
      tvString : AddLeaf('Value').AsString := FString;
      tvBoolean: AddLeaf('Value').AsBoolean := FBoolean;
      tvArray  : raise Exception.Create('Обработка была не предусмотрена');
      {
        begin
          AddOpenTag('Value');

          for i := Low(FArray) to High(FArray) do FArray[i].SaveXML(CurrentNode.Children);

          AddCloseTag;
        end;
      }
      else
        raise Exception.CreateFmt('Не поддерживаемый Тип данных Index[%d]', [Ord(FTypeValue)]);
      end;

      AddCloseTag;
    end;
end;

procedure TValue.LoadXML(AXmlNode: TGmXmlNode);
begin
  if AXmlNode.Attribute.Name <> 'Type' then
    raise Exception.Create('Не описан Тип значения');

  FPosition.X := AXmlNode.Children.NodeByName['X'].AsInteger;
  FPosition.Y := AXmlNode.Children.NodeByName['Y'].AsInteger;

  FTypeValue := TTypeValue(StrToInt(AXmlNode.Attribute.Value));

  case FTypeValue of
  tvNone   : ;
  tvNumber : FNumber := AXmlNode.Children.NodeByName['Value'].AsFloat;
  tvString : FString := AXmlNode.Children.NodeByName['Value'].AsString;
  tvBoolean: FBoolean := AXmlNode.Children.NodeByName['Value'].AsBoolean;
  tvArray  : raise Exception.Create('Обработка была не предусмотрена');
  else
    raise Exception.CreateFmt('Не поддерживаемый Тип данных Index[%d]', [Ord(FTypeValue)]);
  end;
end;

initialization
  ValueCount := 0;

finalization
  SL := TStringList.Create;
  try
    SL.Text := 'ValueCount: ' + IntToStr(ValueCount);
    SL.SaveToFile('ValueCount.txt');
  finally
    FreeAndNil(SL);
  end;

end.

