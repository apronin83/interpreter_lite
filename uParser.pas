unit uParser;

interface

uses
  Classes, Contnrs, uToken, Types, SysUtils, uNodes, uValues, uEnvironment,
  uGmXml;

type
  TParser = class(TObjectList)
  private
    FPosInTokens: Integer;
    FTokenList: TTokenList;
    FBufferToken: array[1..2] of TToken;
    FEnvironment: TEnvironment;

    FXmlDocument: TGmXML;

    function GetNode(Index: Integer): TNode;
    procedure AddNode(ANode: TNode);

    procedure AddNodeFromXml(AXmlNode: TGmXmlNode);

    function Match(TokenType: TTokenType): TToken;

    // Перечень функций для определения приоритета операторов и функций...
    function Command: TNode;
    function GetVariable: TNode;
    function GetArray: TNode;

    function Block: TNode;
    function Expression: TNode;
    function Condition: TNode;
    function BoolExpression: TNode;
    function BoolTerm: TNode;
    function BoolFactor: TNode;
    function BoolRelation: TNode;
    function BitwiseShitExpression: TNode;
    function SumExpression: TNode;
    function Term: TNode;
    function Factor: TNode;
    function SignExpression: TNode;
    function Value: TNode;
    function Atom: TNode;
    function FunctionCall: TNode;
    function IfBlock: TNode;
    function ForBlock: TNode;
    function WhileBlock: TNode;
    function BreakBlock: TNode;
    function ContinueBlock: TNode;
    function DefineFunction: TNode;
    function DefineGlobal: TNode;
    function DefineReturn: TNode;
    function SwitchBlock: TNode;
    function CaseBlock: TNode;
    function SwitchElseBlock: TNode;
  public
    constructor Create(Environment: TEnvironment);
    destructor Destroy; override;

    procedure Clear; override;

    procedure Parse(ATokenList: TTokenList);
    function Eval: TValue;

    procedure SaveXML;
    procedure LoadXML;

    property Environment: TEnvironment read FEnvironment write FEnvironment;
    property RootNodes[index: Integer]: TNode read GetNode; default;

    property XmlDocument: TGmXML read FXmlDocument;
 end;

implementation

constructor TParser.Create(Environment: TEnvironment);
begin
  FEnvironment := Environment;

  FXmlDocument := TGmXML.Create;  
end;

function TParser.Match(TokenType: TTokenType): TToken;
var
  i: Integer;
begin
  Result := FTokenList.Token[FPosInTokens];

  if Result.TokenType = ttEmpty then
    raise Exception.CreateFmt('''%s'' ожидалось, но конец файла был достигнут', [CTokenTypeStr[TokenType]])
  else if Result.TokenType <> TokenType then
    raise Exception.CreateFmt('''%s'' ожидалось, но ''%s'' найдены (%d,%d)', [CTokenTypeStr[TokenType], CTokenTypeStr[Result.TokenType], Result.Position.X, Result.Position.Y])
  else
    begin
      Inc(FPosInTokens);

       while (FTokenList.Token[FPosInTokens].TokenType <> ttEmpty) and (FTokenList.Token[FPosInTokens].TokenType = ttComment) do Inc(FPosInTokens);

       FBufferToken[1] := FTokenList.Token[FPosInTokens];

       i := FPosInTokens + 1; 

       while (FTokenList.Token[i].TokenType <> ttEmpty) and (FTokenList.Token[i].TokenType = ttComment) do Inc(i);

       FBufferToken[2] := FTokenList.Token[i];
    end;
end;

procedure TParser.AddNode(ANode: TNode);
begin
  Add(ANode);
end;

function TParser.GetNode(Index: Integer): TNode;
begin
  if (Index < 0) or (Index >= Count) then
    Result := nil
  else
    Result := Items[Index] as TNode;
end;

procedure TParser.Parse(ATokenList: TTokenList);
var
  i: Integer;
begin
  Clear;

  // Считываем два маркера (FBufferToken[1] и FBufferToken[2]) пропуская комментарии
  FTokenList := ATokenlist;

  FPosInTokens := 0;

  while (FTokenList.Token[FPosInTokens].TokenType <> ttEmpty) and (FTokenList.Token[FPosInTokens].TokenType = ttComment) do Inc(FPosInTokens);

  FBufferToken[1] := FTokenList.Token[FPosInTokens];

  i := FPosInTokens + 1;

  while (FTokenList.Token[i].TokenType <> ttEmpty) and (FTokenList.Token[i].TokenType = ttComment) do Inc(i);

  FBufferToken[2] := FTokenList.Token[i];

  // Добавляем команды
  while FBufferToken[1].TokenType <> ttEmpty do AddNode(Command);
end;

function TParser.Command: TNode;
var
  t1,t2: TToken;
  n1,n2: TNode;
  p: TPoint;
begin
  t1 := FBufferToken[1];
  t2 := FBufferToken[2];

  case t1.TokenType of
  ttVariable:
    begin
      if t2.TokenType = ttParenthesisLeft then
        begin
          Result := FunctionCall;
          Match(ttEndCommand);
          Exit;
        end
      else
        begin
          n1 := GetVariable;
          p := Match(ttOper_ASSIGN).Position;
          n2 := Expression;
          Match(ttEndCommand);
          Result := TAssignNode.Create(p, n1, n2);
          Exit;
        end
    end;
  ttInstr_IF      : Result := IfBlock;
  ttInstr_FOR     : Result := ForBlock;
  ttInstr_WHILE   : Result := WhileBlock;
  ttInstr_FUNCTION: Result := DefineFunction;
  ttInstr_RETURN  : Result := DefineReturn;
  ttInstr_GLOBAL  : Result := DefineGlobal;
  ttInstr_SWITCH  : Result := SwitchBlock;
  ttInstr_BREAK   : Result := BreakBlock;
  ttInstr_CONTINUE: Result := ContinueBlock;
  else
    raise Exception.CreateFmt('Некорректный символ: ''%s'' (%d,%d)', [t1.Value, t1.Position.X, t1.Position.Y]);
    //Result := nil;
  end;
end;

function TParser.GetVariable: TNode;
var
  t: TToken;
begin
  t := Match(ttVariable);
  
  Result := TVariableNode.Create(t.Position, t.Value);

  while FBufferToken[1].TokenType = ttBracketLeft do
    begin
      Match(ttBracketLeft);
      Result.AddNode(Expression);
      Match(ttBracketRight);
    end;
end;

function TParser.GetArray: TNode;
var
  t: TToken;
begin
  t := Match(ttBracketLeft);

  Result := TArrayNode.Create(t.Position);

  while FBufferToken[1].TokenType <> ttBracketRight do
    begin
      Result.AddNode(Expression);
      if FBufferToken[1].TokenType <> ttBracketRight then Match(ttComma);
    end;
    
  Match(ttBracketRight);
end;

function TParser.Atom: TNode;
var
  t: TToken;
  v: TValue;
begin
  Result := nil;

  case FBufferToken[1].TokenType of
  ttString:
    begin
      t := Match(FBufferToken[1].TokenType);
      v := TValue.Create(t.Position, t.Value);
      v.ToString;
      Result := TValueNode.Create(t.Position, v);
    end;
  ttNumber:
    begin
      t := Match(FBufferToken[1].TokenType);
      v := TValue.Create(t.Position, t.Value);
      v.ToNumber;
      Result := TValueNode.Create(t.Position, v);
    end;
  ttTrue:
    begin
      t := Match(FBufferToken[1].TokenType);
      Result := TValueNode.Create(t.Position, TValue.Create(t.Position, True));
    end;
  ttFalse:
    begin
      t := Match(FBufferToken[1].TokenType);
      Result := TValueNode.Create(t.Position, TValue.Create(t.Position, False));
    end;
  ttVariable: Result := GetVariable;
  ttParenthesisLeft:
    begin
      Match(ttParenthesisLeft);
      Result := Expression;
      Match(ttParenthesisRight);
    end;
  end;
end;

function TParser.Expression: TNode;
begin
  if FBufferToken[1].TokenType = ttBracketLeft then
    Result := GetArray
  else
    Result := BoolExpression;
end;

function TParser.BoolExpression: TNode;
var
  t: TToken ;
begin
  Result := BoolTerm;

  if FBufferToken[1].TokenType = ttOper_OR then
    begin
      t := Match(ttOper_OR);
      Result := TBinaryOpNode.Create(t.Position, '||', Result, BoolExpression);
    end;
end;

function TParser.BoolTerm: TNode;
var
  t: TToken;
begin
  Result := BoolFactor;

  if FBufferToken[1].TokenType = ttOper_AND then
    begin
      t := Match(ttOper_AND);
      Result := TBinaryOpNode.Create(t.Position, '&&', Result, BoolTerm);
    end;
end;

function TParser.BoolFactor: TNode;
var
  t: TToken ;
begin
  if FBufferToken[1].TokenType = ttOper_NOT then
    begin
      t := Match(ttOper_NOT);
      Result := TUnaryOpNode.Create(t.Position, '!', BoolRelation);
    end
  else
    Result := BoolRelation;
end;

function TParser.BoolRelation: TNode;
var
  t: TToken ;
begin
  Result := BitwiseShitExpression;

  if  FBufferToken[1].TokenType in [ttOper_LESS, ttOper_LESS_EQUAL, ttOper_EQUAL, ttOper_GREAT_EQUAL, ttOper_GREAT, ttOper_NO_EQUAL] then
    begin
      t := Match(FBufferToken[1].TokenType);

      case t.TokenType of
      ttOper_LESS       : Result := TBinaryOpNode.Create(t.Position, '<',  Result, BitwiseShitExpression);
      ttOper_LESS_EQUAL : Result := TBinaryOpNode.Create(t.Position, '<=', Result, BitwiseShitExpression);
      ttOper_EQUAL      : Result := TBinaryOpNode.Create(t.Position, '==', Result, BitwiseShitExpression);
      ttOper_GREAT_EQUAL: Result := TBinaryOpNode.Create(t.Position, '>=', Result, BitwiseShitExpression);
      ttOper_GREAT      : Result := TBinaryOpNode.Create(t.Position, '>',  Result, BitwiseShitExpression);
      ttOper_NO_EQUAL   : Result := TBinaryOpNode.Create(t.Position, '!=', Result, BitwiseShitExpression);
      end;
    end;
end;

function TParser.BitwiseShitExpression: TNode;
var
  t: TToken;
begin
  Result := SumExpression;
                                  
  while FBufferToken[1].TokenType in [ttOper_Bit_SHIFT_LEFT, ttOper_Bit_SHIFT_RIGHT] do
    begin
      t := Match(FBufferToken[1].TokenType);
      case t.TokenType of
      ttOper_Bit_SHIFT_LEFT : Result := TBinaryOpNode.Create(t.Position, '<<', Result, SumExpression);
      ttOper_Bit_SHIFT_RIGHT: Result := TBinaryOpNode.Create(t.Position, '>>', Result, SumExpression);
      end;
    end;
end;

function TParser.SumExpression: TNode;
var
  t: TToken;
begin
  Result := Term;

  while FBufferToken[1].TokenType in [ttOper_PLUS, ttOper_MINUS, ttOper_Concat, ttOper_Bit_OR, ttOper_Bit_XOR] do
    begin
      t := Match(FBufferToken[1].TokenType);
      case t.TokenType of
      ttOper_PLUS   : Result := TBinaryOpNode.Create(t.Position, '+', Result, Term);
      ttOper_MINUS  : Result := TBinaryOpNode.Create(t.Position, '-', Result, Term);

      ttOper_Concat : Result := TBinaryOpNode.Create(t.Position, '.', Result, Term);

      ttOper_Bit_XOR: Result := TBinaryOpNode.Create(t.Position, '^', Result, Term);
      ttOper_Bit_OR : Result := TBinaryOpNode.Create(t.Position, '|', Result, Term);
      end;
    end;
end;

function TParser.Term: TNode;
var
  t: TToken;
begin
  Result := Factor;

  while FBufferToken[1].TokenType in [ttOper_MULTIPLY, ttOper_DIVIDE, ttOper_MODULE, ttOper_Bit_AND] do
    begin
      t := Match(FBufferToken[1].TokenType);

      case t.TokenType of
      ttOper_MULTIPLY: Result := TBinaryOpNode.Create(t.Position, '*', Result, Factor);
      ttOper_DIVIDE  : Result := TBinaryOpNode.Create(t.Position, '/', Result, Factor);
      ttOper_MODULE  : Result := TBinaryOpNode.Create(t.Position, '%', Result, Factor);
      ttOper_Bit_AND : Result := TBinaryOpNode.Create(t.Position, '&', Result, Factor);
      end;
    end;
end;

function TParser.Factor: TNode;
var
  t: TToken;
begin
  Result := SignExpression;

  while FBufferToken[1].TokenType in [ttOper_Involution] do
    begin
      t := Match(ttOper_Involution);
      Result := TBinaryOpNode.Create(t.Position, '**', Result, SignExpression);
    end;
end;

function TParser.SignExpression: TNode;
var
  t: TToken;
begin
  t := nil;

  case FBufferToken[1].TokenType of
  ttOper_MINUS  : t := Match(ttOper_MINUS);
  ttOper_PLUS   : t := Match(ttOper_PLUS);
  ttOper_Bit_NOT: t := Match(ttOper_Bit_NOT);
  end;

  Result := Value;

  if (t <> nil) and (t.TokenType = ttOper_MINUS) then Result := TUnaryOpNode.Create(t.Position, '-', Result);
  if (t <> nil) and (t.TokenType = ttOper_Bit_NOT) then Result := TUnaryOpNode.Create(t.Position, '~', Result);
end;

function TParser.Value: TNode;
begin
  if (FBufferToken[1].TokenType = ttVariable) and (FBufferToken[2].TokenType = ttParenthesisLeft) then
    Result := FunctionCall
  else
    Result := Atom;
end;

function TParser.FunctionCall: TNode;
var
  t1: TToken;
begin
  t1 := Match(ttVariable);
  Match(ttParenthesisLeft);

  Result := TFunctionCallNode.Create(t1.Position, t1.Value);

  if FBufferToken[1].TokenType <> ttParenthesisRight then
    begin
      Result.AddNode(Expression);

      while FBufferToken[1].TokenType = ttComma do
        begin
          Match(ttComma);
          Result.AddNode(Expression);
        end;
    end;
    
  Match(ttParenthesisRight);
end;

function TParser.Condition: TNode;
begin
  Match(ttParenthesisLeft);
  Result := BoolExpression;
  Match(ttParenthesisRight);
end;

function TParser.IfBlock: TNode;
var
  t: TToken;
  n1, n2, n3: TNode;
begin
  t := Match(ttInstr_IF);

  n1 := Condition;

  n2 := Block;

  if FBufferToken[1].TokenType = ttInstr_ELSE then
    begin
      Match(ttInstr_ELSE);
      n3 := Block;
    end
  else
    n3 := nil;

  Result := TIfNode.Create(t.Position, n1, n2, n3);
end;

function TParser.ForBlock: TNode;
var
  t: TToken;
  n: TNode;
begin
  t := Match(ttInstr_FOR);

  n := GetVariable;

  Result := TForNode.Create(t.Position, n);

  if FBufferToken[1].TokenType = ttInstr_IN then
    begin
      Match(ttInstr_IN);

      case FBufferToken[1].TokenType of
      ttVariable   : Result.AddNode(GetVariable);
      ttBracketLeft: Result.AddNode(GetArray);
      end;

      Match(ttInstr_DO);
      Result.AddNode(Block);
    end
  else
    begin
      Match(ttInstr_FROM);
      Result.AddNode(SumExpression);

      Match(ttInstr_TO);
      Result.AddNode(SumExpression);

      Match(ttInstr_DO);
      Result.AddNode(Block);
    end;
end;

function TParser.WhileBlock: TNode;
var
  t: TToken;
  n1, n2: TNode;
begin
  t := Match(ttInstr_WHILE);
  n1 := Condition;
  n2 := Block;
  Result := TWhileNode.Create(t.Position, n1, n2);
end;

function TParser.DefineFunction: TNode;
var
  t1, t2: TToken;
  n, b: TNode;
  p: TParamNode;
  s: String;
  ref: Boolean;
begin
  t1 := Match(ttInstr_FUNCTION);

  n := GetVariable;

  s := TVariableNode(n).VariableName;

  if FEnvironment.IndexOfFunctionCall(s) <> -1 then
    raise Exception.CreateFmt('''%s'' не подключенная функция (%d,%d)', [s, n.Position.X, n.Position.Y]);

  t2 := Match(ttParenthesisLeft);

  p := TParamNode.Create(t2.Position);

  while FBufferToken[1].TokenType <> ttParenthesisRight do
    begin
      ref := FBufferToken[1].TokenType = ttInstr_REFERENCE;

      if ref then Match(ttInstr_REFERENCE);

      p.AddNode(GetVariable, ref);

      if FBufferToken[1].TokenType = ttComma then Match(ttComma);
    end;

  Match(ttParenthesisRight);

  b := Block;

  Result := TFunctionNode.Create(t1.Position, n, p, b);
end;

function TParser.DefineGlobal: TNode;
var
  p: tpoint;
  n1, n2: tnode;
begin
  Match(ttInstr_GLOBAL);
  n1 := GetVariable;

  if FBufferToken[1].TokenType = ttOper_ASSIGN then
    begin
      Match(ttOper_ASSIGN);
      n2 := Expression;
    end
  else
    n2 := nil;

  Match(ttEndCommand);

  Result := TGlobalNode.Create(p, n1, n2);
end;

function TParser.DefineReturn: TNode;
var
  t: TToken;
  n: TNode;
begin
 t := Match(ttInstr_RETURN);

 n := Expression;

 Match(ttEndCommand);

 Result := TReturnNode.Create(t.Position, n);
end;

function TParser.Block: TNode;
var
  t: TToken;
begin
  t := FBufferToken[1];

  Result := TBlockNode.Create(t.Position);

  if t.TokenType = ttBraceLeft then
    begin
      {t := }Match(ttBraceLeft);

      Result.AddNode(Command);

      while FBufferToken[1].TokenType <> ttBraceRight do
        Result.AddNode(Command);

      Match(ttBraceRight);
    end
  else
    Result.AddNode(Command);
end;


function TParser.Eval: TValue;
var
  i: Integer;
begin
  // Инициализируем среду
  FEnvironment.Variables.UpStack;
  FEnvironment.Functions.UpStack;
  FEnvironment.Globals.UpStack;

  // Выполняем каждую команду
  for i := 0 to Count-1 do RootNodes[i].Eval(FEnvironment);

  // Получаем результат вычислений
  Result := FEnvironment.Result;

  FEnvironment.Stack.Clear;

  { TODO -oAPronin -cDebug : Pronin - Раскоментировать }
  {

  FEnvironment.Globals.DownStack;
  FEnvironment.Variables.DownStack;
  FEnvironment.Functions.DownStack;

  //}
end;

function TParser.SwitchBlock: TNode;
var
  t: TToken;
begin
  t := Match(ttInstr_SWITCH);

  Match(ttParenthesisLeft);
  Result := TSwitchNode.Create(t.Position, SumExpression);
  Match(ttParenthesisRight);

  Match(ttBraceLeft);

  while FBufferToken[1].TokenType <> ttBraceRight do
    begin
      if FBufferToken[1].TokenType = ttInstr_CASE then
        Result.AddNode(CaseBlock)
      else if FBufferToken[1].TokenType = ttInstr_ELSE then
        begin
          Result.AddNode(SwitchElseBlock);
          Break;
        end;  
    end;

  Match(ttBraceRight);
end;

function TParser.CaseBlock: TNode;
var
  t: TToken;
begin
  t := Match(ttInstr_CASE);

  Result := TCaseNode.Create(t.Position);

  Result.AddNode(SumExpression);
  Match(ttColon);
  Result.AddNode(Block);
end;

function TParser.SwitchElseBlock: TNode;
var
  t: TToken;
begin
  t := Match(ttInstr_ELSE);

  Result := TSwitchElseNode.Create(t.Position);
  Result.AddNode(Block);
end;

function TParser.BreakBlock: TNode;
var
  t: TToken;
begin
  t := Match(ttInstr_BREAK);
  Result := TBreakNode.Create(t.Position);
  Match(ttEndCommand);
end;

function TParser.ContinueBlock: TNode;
var
  t: TToken;
begin
  t := Match(ttInstr_CONTINUE);
  Result := TContinueNode.Create(t.Position);
  Match(ttEndCommand);  
end;

destructor TParser.Destroy;
begin
  FreeAndNil(FXmlDocument);

  inherited;
end;

procedure TParser.SaveXML;
var
  i: Integer;
begin
  with FXmlDocument.Nodes do
  begin
    Clear;

    AddOpenTag('CC');

    AddLeaf('ChildCount').AsInteger := Self.Count;

    AddOpenTag('Childs');

    for i := 0 to Self.Count-1 do
      RootNodes[i].SaveXML(CurrentNode.Children);

    AddCloseTag;

    AddCloseTag;
  end;
end;

procedure TParser.LoadXML;
var
  i, RootNodeCount: Integer;
begin
  Clear;

  with FXmlDocument.Nodes.Root do
    begin
      RootNodeCount := Children.NodeByName['ChildCount'].AsInteger;

      for i := 0 to RootNodeCount-1 do
        AddNodeFromXml(Children.NodeByName['Childs'].Children[i]);
    end;
end;

procedure TParser.AddNodeFromXml(AXmlNode: TGmXmlNode);
var
  NewNode: TNode;
begin
  NewNode := NodeRegGroup.GetNodeClass(AXmlNode.Attribute.Value).Create(Point(-1, -1));

  NewNode.LoadXML(AXmlNode);

  AddNode(NewNode);
end;

procedure TParser.Clear;
var
  i: Integer;
begin
  for i := 0 to Count-1 do
    RootNodes[i].Clear;

  inherited Clear;
end;

end.
