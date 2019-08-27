unit uStack;

interface

uses
  Contnrs, Types, SysUtils, uValues;

type
  TProgStack = class(TObjectList)
  private
    FMaxStackSize: Integer;
  public
    constructor Create(AMaxStackSize: Integer = 1000);
    destructor Destroy; override;

    function Pop: TValue;
    procedure Push(AValue: TValue);
    function Read(Index: Integer): TValue;
    procedure Write(Index: Integer; AValue: TValue);
  end;

implementation

constructor TProgStack.Create(AMaxStackSize: Integer = 1000);
begin
  inherited Create;

  FMaxStackSize := AMaxStackSize;
end;

destructor TProgStack.Destroy;
var
  i: Integer;
begin
  for i := 0 to Count-1 do Items[i].Free; // перестраховка, хотя он и сам должен их убить

  inherited;
end;

function TProgStack.Pop: TValue;
begin
  Result := TValue.Create(Items[Count-1] as TValue);

  Delete(Count-1);
end;

procedure TProgStack.Push(AValue: TValue);
begin
  Add(AValue);

  if Count > FMaxStackSize then
    raise Exception.CreateFmt('Превышен размер стека Stack Size: %d Max Size: %d.', [Count, FMaxStackSize]);
end;

function TProgStack.Read(Index: Integer): TValue;
begin
  Result := Items[Count - Index - 1] as TValue;
end;

procedure TProgStack.Write(Index: Integer; AValue: TValue);
begin
  (Items[Count - Index - 1] as TValue).Assign(AValue);
end;

end.
