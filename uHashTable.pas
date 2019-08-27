unit uHashTable;

interface

uses
  Classes, SysUtils;

type
  TDeleteType = (dtDelete, dtDetach);

  THashItem = record
    key: longint;
    obj: TObject;
  end;

  PHashItemList = ^THashItemList;
  THashItemList = array [0 .. 0] of THashItem;

  THashList = class(TObject)
  private
    FList: PHashItemList;
    FCount: integer;
    FCapacity: integer;
    FMemSize: longint;
    FDeleteType: TDeleteType;
  protected
    procedure Error;
    function Get(Index: integer): THashItem;
    procedure Grow;
    procedure Put(Index: integer; const Item: THashItem);
    procedure SetCapacity(NewCapacity: integer);
    procedure SetCount(NewCount: integer);
  public
    constructor Create;
    destructor Destroy; override;

    function Add(const Item: THashItem): integer;
    procedure Clear(dt: TDeleteType);
    procedure Detach(Index: integer);
    procedure Delete(Index: integer);
    function Expand: THashList;
    function IndexOf(key: longint): integer;
    procedure Pack;

    property DeleteType: TDeleteType read FDeleteType write FDeleteType;
    property Capacity: integer read FCapacity write SetCapacity;
    property Count: integer read FCount write SetCount;
    property Items[Index: integer]: THashItem read Get write Put; default;
  end;

  THashTable = class(TObject)
  private
    FTable: THashList;
    procedure Error;
    function GetCount: integer;
    procedure SetCount(Count: Integer);
    function GetCapacity: integer;
    procedure SetCapacity(Capacity: Integer);
    function GetItem(Index: Integer): TObject;
    procedure SetItem(Index: Integer; AObject: TObject);
    function GetDeleteType: TDeleteType;
    procedure SetDeleteType(ADeleteType: TDeleteType);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(const AKey: String; AValue: TObject);
    function Get(const AKey: String): TObject;
    procedure Detach(const AKey: String);
    procedure Delete(const AKey: String);
    procedure Clear(ADeleteType: TDeleteType);
    procedure Pack;

    property DeleteType: TDeleteType read GetDeleteType write SetDeleteType;
    property Count: integer read GetCount write SetCount;
    property Capacity: integer read GetCapacity write SetCapacity;
    property Items[index: integer]: TObject read GetItem write SetItem;
    property Table: THashList read FTable;
  end;

Function Hash(Str: String): longint;
// function hash(key: Pointer; length: longint; level: longint): longint;

implementation
{
type
  longArray = packed array [0 .. 3] of byte;
  longArrayPtr = ^longArray;

  array12 = packed array [0 .. 11] of byte;
  array12Ptr = ^array12;

  longPtr = ^longint;
}

constructor THashList.Create;
begin
  FDeleteType := dtDelete;
  FCapacity := 0;
  FCount := 0;
  FMemSize := 4;
  FList := AllocMem(FMemSize);
  SetCapacity(100);
end;

{ ----------------------------------------------------------------------------- }
destructor THashList.Destroy;
begin
  Clear(FDeleteType);
  FreeMem(FList, FMemSize);
end;


{ ----------------------------------------------------------------------------- }
function THashList.Add(const Item: THashItem): integer;
begin
  Result := FCount;

  if (Result = FCapacity) then
    Grow;

  FList^[Result].key := Item.key;
  FList^[Result].obj := Item.obj;
  Inc(FCount);
end;

{ ----------------------------------------------------------------------------- }
procedure THashList.Clear(dt: TDeleteType);
var
  i: integer;
begin
  if (dt = dtDelete) then
    for i := FCount - 1 downto 0 do
      if (Items[i].obj <> nil) then
        Items[i].obj.Free;
  { FreeMem(FList, FMemSize);
    FMemSize:= 4;
    FList:= AllocMem(FMemSize); }
  FCapacity := 0;
  FCount := 0;
end;

{ ----------------------------------------------------------------------------- }
{
  Detach remove the item from the list without disposing the object
}
procedure THashList.Detach(Index: integer);
begin
  if ((Index < 0) or (Index >= FCount)) then
    Error;
  Dec(FCount);
  if (Index < FCount) then
    System.Move(FList^[Index + 1], FList^[Index],
      (FCount - Index) * SizeOf(THashItem));
end;

{ ----------------------------------------------------------------------------- }
{
  Delete remove the item from the list AND dispose the object
}
procedure THashList.Delete(Index: integer);
begin
  if ((Index < 0) or (Index >= FCount)) then
    Error;
  Dec(FCount);
  if (Index < FCount) then
  begin
    FList^[Index].obj.Free;
    System.Move(FList^[Index + 1], FList^[Index],
      (FCount - Index) * SizeOf(THashItem));
  end;
end;

{ ----------------------------------------------------------------------------- }
procedure THashList.Error;
begin
  // raise EListError.CreateRes(SListIndexError);
end;

{ ----------------------------------------------------------------------------- }
function THashList.Expand: THashList;
begin
  if (FCount = FCapacity) then
    Grow;
  Result := Self;
end;

{ ----------------------------------------------------------------------------- }
function THashList.Get(Index: integer): THashItem;
begin
  if ((Index < 0) or (Index >= FCount)) then
    Error;
  Result.key := FList^[Index].key;
  Result.obj := FList^[Index].obj;
end;

{ ----------------------------------------------------------------------------- }
procedure THashList.Grow;
var
  Delta: integer;
begin
  if FCapacity > 8 then
    Delta := 16
  else if FCapacity > 4 then
    Delta := 8
  else
    Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

{ ----------------------------------------------------------------------------- }
function THashList.IndexOf(key: longint): integer;
begin
  Result := 0;
  while (Result < FCount) and (FList^[Result].key <> key) do
    Inc(Result);
  if Result = FCount then
    Result := -1;
end;

{ ----------------------------------------------------------------------------- }
procedure THashList.Put(Index: integer; const Item: THashItem);
begin
  if (Index < 0) or (Index >= FCount) then
    Error;
  FList^[Index].key := Item.key;
  FList^[Index].obj := Item.obj;
end;

{ ----------------------------------------------------------------------------- }
procedure THashList.Pack;
var
  i: integer;
begin
  for i := FCount - 1 downto 0 do
    if Items[i].obj = nil then
      Delete(i);
end;

{ ----------------------------------------------------------------------------- }
procedure THashList.SetCapacity(NewCapacity: integer);
begin
  if ((NewCapacity < FCount) or (NewCapacity > MaxListSize)) then
    Error;
  if (NewCapacity <> FCapacity) then
  begin
    { FList:= } ReallocMem(FList, { FMemSize, } NewCapacity * SizeOf(THashItem));
    FMemSize := NewCapacity * SizeOf(THashItem);
    FCapacity := NewCapacity;
  end;
end;

{ ----------------------------------------------------------------------------- }
procedure THashList.SetCount(NewCount: integer);
begin
  if ((NewCount < 0) or (NewCount > MaxListSize)) then
    Error;
  if (NewCount > FCapacity) then
    SetCapacity(NewCount);
  if (NewCount > FCount) then
    FillChar(FList^[FCount], (NewCount - FCount) * SizeOf(THashItem), 0);
  FCount := NewCount;
end;

{ --- Class THashTable ---
  it's just a list of THashItems.
  you provide a key (string) and an object;
  a unique numeric key (longint) is compute (see hash);
  when you get an object, you provide string key, and as fast as possible
  the object is here.
  Really fast;
  Really smart, because of string keys.
}

{ ----------------------------------------------------------------------------- }
constructor THashTable.Create;
begin
  inherited Create;

  FTable := THashList.Create;
end;

{ ----------------------------------------------------------------------------- }
destructor THashTable.Destroy;
begin
  FTable.Free;

  inherited Destroy;
end;

{ ----------------------------------------------------------------------------- }
procedure THashTable.Error;
begin
  // Writeln('ERROR');
  //raise EListError.CreateRes(SListIndexError);
end;

{ ----------------------------------------------------------------------------- }
{
  Add 'AValue' object with AKey 'AKey'
}
procedure THashTable.Add(const AKey: String; AValue: TObject);
var
  Item: THashItem;
begin
  Item.key := Hash(AKey);
  Item.obj := AValue;
  FTable.Add(Item);
end;

{ ----------------------------------------------------------------------------- }
{
  Get object with AKey 'AKey'
}
function THashTable.Get(const AKey: String): TObject;
var
  index: integer;
begin
  Result := nil;
  index := FTable.IndexOf(Hash(AKey));
  if (index < 0) then
    Error
  else
    Result := FTable[index].obj;
end;

{ ----------------------------------------------------------------------------- }
{
  Detach (remove item, do not dispose object) object with AKey 'AKey'
}
procedure THashTable.Detach(const AKey: String);
var
  index: integer;
begin
  index := FTable.IndexOf(Hash(AKey));
  if (index >= 0) then
    FTable.Detach(index);
end;

{ ----------------------------------------------------------------------------- }
{
  Delete (remove item, dispose object) object with AKey 'AKey'
}
procedure THashTable.Delete(const AKey: String);
var
  index: integer;
begin
  index := FTable.IndexOf(Hash(AKey));
  if (index >= 0) then
    FTable.Delete(index);
end;

{ ----------------------------------------------------------------------------- }
{
  Clear the list; i.e: remove all the items (detach or delete depending of 'ADeleteType')
}
procedure THashTable.Clear(ADeleteType: TDeleteType);
begin
  FTable.Clear(ADeleteType);
end;

{ ----------------------------------------------------------------------------- }
procedure THashTable.Pack;
begin
  FTable.Pack;
end;

{ ----------------------------------------------------------------------------- }
function THashTable.GetCount: integer;
begin
  Result := FTable.Count;
end;

procedure THashTable.SetCount(Count: Integer);
begin
  FTable.Count := Count;
end;

function THashTable.GetCapacity: integer;
begin
  Result := FTable.Capacity;
end;

procedure THashTable.SetCapacity(Capacity: Integer);
begin
  FTable.Capacity := Capacity;
end;

function THashTable.GetDeleteType: TDeleteType;
begin
  Result := FTable.DeleteType;
end;

procedure THashTable.SetDeleteType(ADeleteType: TDeleteType);
begin
  FTable.DeleteType := ADeleteType;
end;

function THashTable.GetItem(Index: Integer): TObject;
begin
  Result := FTable[Index].obj;
end;

{ ----------------------------------------------------------------------------- }
procedure THashTable.SetItem(Index: Integer; AObject: TObject);
var
  Item: THashItem;
begin
  Item.key := FTable[Index].key;
  Item.obj := AObject;
  FTable[Index] := Item;
end;

{ ----------------------------------------------------------------------------- }
{ original code from lookup2.c, by Bob Jenkins, December 1996
  http://ourworld.compuserve.com/homepages/bob_jenkins/
  PLEASE, let me know if there is problem with it, or if you have a better one. THANKS.
}
{ function hash(key: Pointer; length: longint; level: longint): longint;
  var
  a,b,c:                longint;
  len:                  longint;
  k:                    array12Ptr;
  lp:                   longPtr;

  begin
  k:= array12Ptr(key);
  len:= length;
  a:= $9E3779B9;
  b:= a;
  c:= level;

  if((longint(key) and 3) <> 0) then begin
  while(len>=12) do begin       {unaligned }
{ inc(a, (longint(k^[00]) +(longint(k^[01]) shl 8) + (longint(k^[02]) shl 16) + (longint(k^[03]) shl 24)));
  inc(b, (longint(k^[04]) +(longint(k^[05]) shl 8) + (longint(k^[06]) shl 16) + (longint(k^[07]) shl 24)));
  inc(c, (longint(k^[08]) +(longint(k^[09]) shl 8) + (longint(k^[10]) shl 16) + (longint(k^[11]) shl 24)));

  {mix(a,b,c); }
{ inc(a , b xor $FFFFFFFF + 1); inc(a , c xor $FFFFFFFF + 1); a:= a xor (c shr 13);
  inc(b , c xor $FFFFFFFF + 1); inc(b , a xor $FFFFFFFF + 1); b:= b xor (a shl 8);
  inc(c , a xor $FFFFFFFF + 1); inc(c , b xor $FFFFFFFF + 1); c:= c xor (b shr 13);
  inc(a , b xor $FFFFFFFF + 1); inc(a , c xor $FFFFFFFF + 1); a:= a xor (c shr 12);
  inc(b , c xor $FFFFFFFF + 1); inc(b , a xor $FFFFFFFF + 1); b:= b xor (a shl 16);
  inc(c , a xor $FFFFFFFF + 1); inc(c , b xor $FFFFFFFF + 1); c:= c xor (b shr 5);
  inc(a , b xor $FFFFFFFF + 1); inc(a , c xor $FFFFFFFF + 1); a:= a xor (c shr 3);
  inc(b , c xor $FFFFFFFF + 1); inc(b , a xor $FFFFFFFF + 1); b:= b xor (a shl 10);
  inc(c , a xor $FFFFFFFF + 1); inc(c , b xor $FFFFFFFF + 1); c:= c xor (b shr 15);

  inc(longint(k),12);
  dec(len,12);
  end;
  end

  else begin
  while(len>=12) do begin       {aligned }
{ lp:= longPtr(k);
  inc(a, lp^); inc(lp,4);
  inc(b, lp^); inc(lp,4);
  inc(c, lp^);

  {mix(a,b,c); }
{ inc(a , b xor $FFFFFFFF + 1); inc(a , c xor $FFFFFFFF + 1); a:= a xor (c shr 13);
  inc(b , c xor $FFFFFFFF + 1); inc(b , a xor $FFFFFFFF + 1); b:= b xor (a shl 8);
  inc(c , a xor $FFFFFFFF + 1); inc(c , b xor $FFFFFFFF + 1); c:= c xor (b shr 13);
  inc(a , b xor $FFFFFFFF + 1); inc(a , c xor $FFFFFFFF + 1); a:= a xor (c shr 12);
  inc(b , c xor $FFFFFFFF + 1); inc(b , a xor $FFFFFFFF + 1); b:= b xor (a shl 16);
  inc(c , a xor $FFFFFFFF + 1); inc(c , b xor $FFFFFFFF + 1); c:= c xor (b shr 5);
  inc(a , b xor $FFFFFFFF + 1); inc(a , c xor $FFFFFFFF + 1); a:= a xor (c shr 3);
  inc(b , c xor $FFFFFFFF + 1); inc(b , a xor $FFFFFFFF + 1); b:= b xor (a shl 10);
  inc(c , a xor $FFFFFFFF + 1); inc(c , b xor $FFFFFFFF + 1); c:= c xor (b shr 15);

  inc(longint(k),12);
  dec(len,12);
  end;
  end;

  inc(c,length);

  if(len>=11) then inc(c, (longint(k^[10]) shl 24));
  if(len>=10) then inc(c, (longint(k^[9]) shl 16));
  if(len>=9) then inc(c, (longint(k^[8]) shl 8));
  if(len>=8) then inc(b, (longint(k^[7]) shl 24));
  if(len>=7) then inc(b, (longint(k^[6]) shl 16));
  if(len>=6) then inc(b, (longint(k^[5]) shl 8));
  if(len>=5) then inc(b, longint(k^[4]));
  if(len>=4) then inc(a, (longint(k^[3]) shl 24));
  if(len>=3) then inc(a, (longint(k^[2]) shl 16));
  if(len>=2) then inc(a, (longint(k^[1]) shl 8));
  if(len>=1) then inc(a, longint(k^[0]));

  {mix(a,b,c); }
{ inc(a , b xor $FFFFFFFF + 1); inc(a , c xor $FFFFFFFF + 1); a:= a xor (c shr 13);
  inc(b , c xor $FFFFFFFF + 1); inc(b , a xor $FFFFFFFF + 1); b:= b xor (a shl 8);
  inc(c , a xor $FFFFFFFF + 1); inc(c , b xor $FFFFFFFF + 1); c:= c xor (b shr 13);
  inc(a , b xor $FFFFFFFF + 1); inc(a , c xor $FFFFFFFF + 1); a:= a xor (c shr 12);
  inc(b , c xor $FFFFFFFF + 1); inc(b , a xor $FFFFFFFF + 1); b:= b xor (a shl 16);
  inc(c , a xor $FFFFFFFF + 1); inc(c , b xor $FFFFFFFF + 1); c:= c xor (b shr 5);
  inc(a , b xor $FFFFFFFF + 1); inc(a , c xor $FFFFFFFF + 1); a:= a xor (c shr 3);
  inc(b , c xor $FFFFFFFF + 1); inc(b , a xor $FFFFFFFF + 1); b:= b xor (a shl 10);
  inc(c , a xor $FFFFFFFF + 1); inc(c , b xor $FFFFFFFF + 1); c:= c xor (b shr 15);

  result:= longint(c);
  end; }

function Hash(Str: String): Longint;
var
  i: Integer;
begin
  Result := 1315423911;

  for i := 1 to Length(Str) do
    Result := Result xor ((Result shl 5) + Ord(Str[i]) + (Result shr 2));

  Result := (Result And $7FFFFFFF);
end;

end.
