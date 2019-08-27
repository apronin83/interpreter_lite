// преобразует строку символов в лексемы (элементы простым языком)

unit uToken;

interface

uses
  Classes, Contnrs, Types, SysUtils;

type
  TTokenType = (ttComment,
                ttEndCommand,
                ttEmpty,
                ttVariable,
                ttOper_PLUS,
                ttOper_MINUS,
                ttOper_MULTIPLY,
                ttOper_DIVIDE,
                ttOper_MODULE,
                ttOper_Involution,
                ttOper_Concat,
                ttOper_ASSIGN,
                ttParenthesisLeft,
                ttParenthesisRight,
                ttBracketLeft,
                ttBracketRight,
                ttBraceLeft,
                ttBraceRight,
                ttComma,

                ttOper_Bit_SHIFT_LEFT,
                ttOper_Bit_SHIFT_RIGHT,
                ttOper_Bit_NOT,
                ttOper_Bit_AND,
                ttOper_Bit_OR,
                ttOper_Bit_XOR,

                ttOper_NOT,
                ttOper_AND,
                ttOper_OR,

                ttOper_LESS,
                ttOper_LESS_EQUAL,
                ttOper_EQUAL,
                ttOper_GREAT_EQUAL,
                ttOper_GREAT,
                ttOper_NO_EQUAL,

                ttNumber,
                ttString,
                ttTrue,
                ttFalse,

                ttInstr_IF,
                ttInstr_ELSE,
                ttInstr_SWITCH,
                ttInstr_CASE,
                ttColon,
                ttInstr_WHILE,
                ttInstr_FOR,
                ttInstr_IN,
                ttInstr_FROM,
                ttInstr_TO,
                ttInstr_DO,
                ttInstr_BREAK,
                ttInstr_CONTINUE,
                ttInstr_FUNCTION,
                ttInstr_RETURN,
                ttInstr_GLOBAL,
                ttInstr_REFERENCE);

  TTokenPossibleVariants = set of TTokenType;

const
  CTokenTypeStr: array[TTokenType] of String =
               ('Comment',
                'EndCommand',
                'Empty',
                'Variable',
                'Oper_PLUS',
                'Oper_MINUS',
                'Oper_MULTIPLY',
                'Oper_DIVIDE',
                'Oper_MODULE',
                'Oper_Involution',
                'Oper_Concat',
                'Oper_ASSIGN',
                'ParenthesisLeft',
                'ParenthesisRight',
                'BracketLeft',
                'BracketRight',
                'BraceLeft',
                'BraceRight',
                'Comma',

                'Oper_Bit_SHIFT_LEFT',
                'Oper_Bit_SHIFT_RIGHT',
                'Oper_Bit_NOT',
                'Oper_Bit_AND',
                'Oper_Bit_OR',
                'Oper_Bit_XOR',

                'Oper_NOT',
                'Oper_AND',
                'Oper_OR',

                'Oper_LESS',
                'Oper_LESS_EQUAL',
                'Oper_EQUAL',
                'Oper_GREAT_EQUAL',
                'Oper_GREAT',
                'Oper_NO_EQUAL',

                'Number',
                'String',
                'True',
                'False',
                
                'Instr_IF',
                'Instr_ELSE',
                'Instr_SWITCH',
                'Instr_CASE',
                'Colon',
                'Instr_WHILE',
                'Instr_FOR',
                'Instr_IN',
                'Instr_FROM',
                'Instr_TO',
                'Instr_DO',
                'Instr_BREAK',
                'Instr_CONTINUE',
                'Instr_FUNCTION',
                'Instr_RETURN',
                'Instr_GLOBAL',
                'Instr_REFERENCE');


type
  TToken = class(TObject)
  private
    FFileName: String;
    FPosition: TPoint;
    FTokenType: TTokenType;
    FValue: String;
  public
    property Value: String read FValue;
    property FileName: String read FFileName;
    property Position: TPoint read FPosition;
    property TokenType: TTokenType read FTokenType;
    constructor Create(AFileName: String; APosition: TPoint; ATokenType: TTokenType; AString: String);
    procedure Assign(Source: TToken);
  end;

  TTokenList = class(TObjectList)
  private
    FFileName: String;
    FSource: String;
    FIndexInSource: Integer;
    FPositionInSource: TPoint;
    FBufferChar: array[1..2] of Char;

    function GetFileName: String;
    procedure PrepareInclude;

    function GetToken(Index: Integer): TToken;
    function GetLastToken: TToken;

    procedure GetLineComment;
    procedure GetBlockComment;
    procedure GetString;
    procedure GetNumber;
    procedure GetIdentifier;
    function GetChar: char;
    procedure AddToken(TokenType: TTokenType; AString: String);
    procedure RaiseExceptionChar(n: Integer);
  public
    procedure Add(APosition: TPoint; ATokenType: TTokenType; AString: String); overload;
    function IsEmpty: Boolean;
    procedure Tokenize(AFileName, ACodeSource: String);
    property Token[Index: Integer]: TToken read GetToken; default;
    property LastToken: TToken read GetLastToken;
  end;

implementation

//TToken TToken TToken TToken TToken TToken TToken TToken
//========================================================
procedure TToken.Assign(Source: TToken);
begin
  FFileName := Source.FileName;
  FPosition := Source.Position;
  FTokenType := Source.TokenType;
  FValue := Source.Value;
end;

constructor TToken.Create(AFileName: String; APosition: TPoint; ATokenType: TTokenType; AString: String);
begin
  FFileName := AFileName;
  FPosition := APosition;
  FTokenType := ATokenType;
  FValue := AString;
end;

//TTokenList TTokenList TTokenList TTokenList TTokenList
//=======================================================

procedure TTokenList.Add(APosition: TPoint; ATokenType: TTokenType; AString: String);
begin
  Add(TToken.Create(FFileName, APosition, ATokenType, AString));
end;

function TTokenList.IsEmpty: Boolean;
begin
  Result := Count = 0;
end;      

function TTokenList.GetToken(Index: Integer): TToken;
begin
  if (Index < 0) or (Index >= Count) then
    Result := TToken.Create('', Point(-1, -1), ttEmpty, '')
  else
    Result := Items[Index] as TToken;
end;

function TTokenList.GetLastToken: TToken;
begin
  if Count = 0 then
    Result := nil
  else
    Result := Token[Count-1];
end;

function TTokenList.GetChar: char;
begin
  FBufferChar[1] := FBufferChar[2];

  Inc(FIndexInSource);

  if FIndexInSource+1 > Length(FSource) then
    FBufferChar[2] := #0
  else
    FBufferChar[2] := FSource[FIndexInSource+1];

  Result := FBufferChar[1];

  if Result = #10 then
    FPositionInSource := Point(0, FPositionInSource.Y+1)
  else
    Inc(FPositionInSource.X);
end;

procedure TTokenList.AddToken(TokenType: TTokenType; AString: String);
var
  i: integer;
begin
  Add(FPositionInSource, TokenType, AString);

  for i := 1 to Length(AString) do GetChar;
end;

procedure TTokenList.RaiseExceptionChar(n: Integer);
begin
  raise Exception.CreateFmt('Неправильный символ ''%s'' (%d,%d)  файл: %s', [FBufferChar[n], FPositionInSource.X+n-1, FPositionInSource.Y, FFileName]);
end;

procedure TTokenList.Tokenize(AFileName, ACodeSource: String);
begin
  Clear;

  FFileName := AFileName;

  FSource := ACodeSource;

  if Length(FSource) < 1 then FBufferChar[1] := #0 else FBufferChar[1] := FSource[1];
  if Length(FSource) < 2 then FBufferChar[2] := #0 else FBufferChar[2] := FSource[2];

  FIndexInSource := 1;

  FPositionInSource := Point(1, 1);

  while FBufferChar[1] <> #0 do
    begin
      // Пропускаем пустые символы
      if FBufferChar[1] in [#32,#9,#13,#10] then
        begin
          GetChar;
          Continue;
        end;

      // Ищем соответствующее обозначение символа
      case FBufferChar[1] of
      ';': AddToken(ttEndCommand, ';');
      '+': AddToken(ttOper_PLUS, '+');
      '-': AddToken(ttOper_MINUS, '-');
      '*': if FBufferChar[2] = '*' then AddToken(ttOper_Involution, '**')
                                   else AddToken(ttOper_MULTIPLY, '*');
      '%': AddToken(ttOper_MODULE, '%');
      ',': AddToken(ttComma, ',');
      ':': AddToken(ttColon, ':');
      '.': AddToken(ttOper_Concat, '.');
      '(': AddToken(ttParenthesisLeft, '(');
      ')': AddToken(ttParenthesisRight, ')');
      '{': AddToken(ttBraceLeft, '{');
      '}': AddToken(ttBraceRight, '}');
      '[': AddToken(ttBracketLeft, '[');
      ']': AddToken(ttBracketRight, ']');

      '~': AddToken(ttOper_Bit_NOT, '~');
      
      '!': if FBufferChar[2] = '=' then AddToken(ttOper_NO_EQUAL, '!=')
                                   else AddToken(ttOper_NOT, '!');

      '|': if FBufferChar[2] = '|' then AddToken(ttOper_OR, '||')
                                   else AddToken(ttOper_Bit_OR, '|');

      '&': if FBufferChar[2] = '&' then AddToken(ttOper_AND, '&&')
                                   else AddToken(ttOper_Bit_AND, '&');

      '^': AddToken(ttOper_Bit_XOR, '^');

      '/': case FBufferChar[2] of
           '/': GetLineComment;
           '*': GetBlockComment;
           else
             AddToken(ttOper_DIVIDE, '/');
           end;

      '=': if FBufferChar[2] = '=' then AddToken(ttOper_EQUAL, '==')
                                   else AddToken(ttOper_ASSIGN, '=');

      '<': case FBufferChar[2] of
           '=': AddToken(ttOper_LESS_EQUAL, '<=');
           '<': AddToken(ttOper_Bit_SHIFT_LEFT, '<<');
           else
             AddToken(ttOper_LESS, '<');
           end;

      '>': case FBufferChar[2] of
           '=': AddToken(ttOper_GREAT_EQUAL, '>=');
           '>': AddToken(ttOper_Bit_SHIFT_RIGHT, '>>');
           else
             AddToken(ttOper_GREAT, '>');
           end;
      '''','"': GetString;
      '0'..'9': GetNumber;
      'a'..'z','A'..'Z','_': GetIdentifier;
      else
        RaiseExceptionChar(1);
      end;
    end;
end;

procedure TTokenList.GetLineComment;
var
  tpos: TPoint;
  s: String;
begin
  tpos := FPositionInSource;
  
  while not (FBufferChar[1] in [#13,#10,#0]) do
    begin
      s := s + FBufferChar[1];
      GetChar;
    end;

  Add(tpos, ttComment, s);
end;

procedure TTokenList.GetBlockComment;
var
  tpos: TPoint;
  s: String;
begin
  tpos := FPositionInSource;

  while true do
    begin
      if FBufferChar[1] = #0 then
        raise Exception.CreateFmt('*/ ожидалось, но достигнут конец файла (%d,%d) файл: %s', [FPositionInSource.X, FPositionInSource.Y, FFileName]);

      if FBufferChar[1] + FBufferChar[2] = '*/' then Break;

      s := s + FBufferChar[1];

      GetChar;
    end;

  GetChar;
  GetChar;

  s := s + '*/';

  Add(tpos, ttComment, s);
end;

procedure TTokenList.GetString;
var
  tpos: TPoint;
  s: String;
  c: Char;
begin
  tpos := FPositionInSource;

  c := FBufferChar[1];

  GetChar;

  while true do
    begin
      if FBufferChar[1] = #0 then
        raise Exception.CreateFmt('" ожидалось, но достигнут конец файла (%d,%d) файл: %s', [FPositionInSource.X, FPositionInSource.Y, FFileName]);

      if FBufferChar[1] = c then Break;

      if FBufferChar[1] = '/' then GetChar;

      s := s + FBufferChar[1];

      GetChar;
    end;

  GetChar;

  Add(tpos, ttString, s);
end;

procedure TTokenList.GetNumber;
var
  tpos: TPoint;
  s: String;
  flag: Boolean;
begin
  tpos := FPositionInSource;

  flag := false;

  while FBufferChar[1] in ['0'..'9', '.'] do
    begin
      s := s + FBufferChar[1];

      GetChar;

      if FBufferChar[1] = '.' then
        if not flag then
          flag := true
        else
          raise Exception.CreateFmt('Неверный формат числа. Дробный разделитель встречается более одного раза. (%d,%d)  файл: %s', [FpositionInSource.X, FpositionInSource.Y, FFileName]);
    end;

  Add(tpos, ttNumber, s);
end;

procedure TTokenList.GetIdentifier;
var
  tpos: TPoint;
  s: String;
begin
  s := '';

  tpos := FPositionInSource;

  while FBufferChar[1] in ['a'..'z', 'A'..'Z', '_', '0'..'9'] do
    begin
      s := s + FBufferChar[1];

      GetChar;
    end;

  s := AnsiLowerCase(s);

  if s = 'include'  then
    begin
      PrepareInclude;
    end
  else if s = 'true'     then Add(tpos, ttTrue, s)
  else if s = 'false'    then Add(tpos, ttFalse, s)
  else if s = 'if'       then Add(tpos, ttInstr_IF, s)
  else if s = 'else'     then Add(tpos, ttInstr_ELSE, s)
  else if s = 'while'    then Add(tpos, ttInstr_WHILE, s)
  else if s = 'in'       then Add(tpos, ttInstr_IN, s)
  else if s = 'from'     then Add(tpos, ttInstr_FROM, s)
  else if s = 'to'       then Add(tpos, ttInstr_TO, s)
  else if s = 'do'       then Add(tpos, ttInstr_DO, s)
  else if s = 'for'      then Add(tpos, ttInstr_FOR, s)
  else if s = 'function' then Add(tpos, ttInstr_FUNCTION, s)
  else if s = 'return'   then Add(tpos, ttInstr_RETURN, s)
  else if s = 'global'   then Add(tpos, ttInstr_GLOBAL, s)
  else if s = 'ref'      then Add(tpos, ttInstr_REFERENCE, s)
  else if s = 'switch'   then Add(tpos, ttInstr_SWITCH, s)
  else if s = 'case'     then Add(tpos, ttInstr_CASE, s)
  else if s = 'break'    then Add(tpos, ttInstr_BREAK, s)
  else if s = 'continue' then Add(tpos, ttInstr_CONTINUE, s)
  else                        Add(tpos, ttVariable, s);
end;

function TTokenList.GetFileName: String;
var
  tpos: TPoint;
  c: Char;
begin
  Result := '';

  tpos := FPositionInSource;

  c := FBufferChar[1];

  if not (c in ['''','"']) then
    raise Exception.CreateFmt('Ожидался один из символов начала строки ['', "] (%d,%d) файл: %s', [FPositionInSource.X, FPositionInSource.Y, FFileName]);

  GetChar; // Read ' or "

  while true do
    begin
      if FBufferChar[1] = #0 then
        raise Exception.CreateFmt('" ожидалось, но достигнут конец файла (%d,%d) файл: %s', [FPositionInSource.X, FPositionInSource.Y, FFileName]);

      if FBufferChar[1] = c then Break;

      if FBufferChar[1] = '/' then GetChar;

      Result := Result + FBufferChar[1];

      GetChar;
    end;

  GetChar; // Read ' or "

  if FBufferChar[1] <> ';' then
    raise Exception.CreateFmt('Ожидался символ конца выражения '';''(%d,%d) файл: %s', [FPositionInSource.X, FPositionInSource.Y, FFileName]);

  GetChar; // Read ';'
end;

procedure TTokenList.PrepareInclude;
var
  i: Integer;
  fn: String;
  sl: TStringList;
  CopyToken: TToken;
  IncludeTokenList: TTokenList;
begin
  while FBufferChar[1] in [#32,#9,#13,#10] do GetChar;

  fn := GetFileName;

  if not FileExists(fn) then
    if FileExists(ExtractFilePath(ParamStr(0)) + fn) then
      fn := ExtractFilePath(ParamStr(0)) + fn
    else
      raise Exception.CreateFmt('Подключаемый файл не существует (%d,%d) ''%s''', [FPositionInSource.X, FPositionInSource.Y, fn]);

  IncludeTokenList := TTokenList.Create;
  try
    sl := TStringList.Create;
    try
      sl.LoadFromFile(fn);

      IncludeTokenList.Tokenize(fn, sl.Text);

      for i := 0 to IncludeTokenList.Count-1 do
        begin
          CopyToken := TToken.Create('', Point(-1, -1), ttEmpty, '');
          CopyToken.Assign(IncludeTokenList.Token[i]);
          
          Add(CopyToken);
        end;
    finally
      FreeAndNil(sl);
    end;
  finally
    FreeAndNil(IncludeTokenList);
  end;
end;

end.
