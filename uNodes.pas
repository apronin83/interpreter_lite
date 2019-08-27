unit uNodes;

interface

uses
  Classes, Contnrs, Types, SysUtils, uValues, uEnvironment, Math, uGmXml;

type
  TLoopStatus = (lsWork, lsBreak, lsContinue);

  TNodeClass = class of TNode;

  TArrayOfBoolean = array of Boolean;

  TNode = class(TObjectList)
  private
    FPosition: TPoint;
    FName: String;
    function GetCount: Integer;
    function GetNode(AIndex: Integer): TNode;
  public
    constructor Create(APosition: TPoint);
    destructor Destroy; override;
    procedure Clear; override;
    procedure Eval(Env: TEnvironment); virtual; abstract;
    procedure AddNode(ANode: TNode);

    procedure SaveXML(AXmlNodeList: TGmXmlNodeList); virtual;
    procedure SpecialSaveXML(AXmlNodeList: TGmXmlNodeList); virtual;
    procedure LoadXML(AXmlNode: TGmXmlNode); virtual;
    procedure SpecialLoadXML(AXmlNodeList: TGmXmlNodeList); virtual;

    property Position: TPoint read FPosition;
    property Name: String read FName;
    property NodeCount: Integer read GetCount;
    property NodesList[Index: Integer]: TNode read GetNode; default;
  end;

  TOperationNode = class(TNode)
  protected
    FOperatorName: String;
  public
    procedure SpecialSaveXML(AXmlNodeList: TGmXmlNodeList); override;
    procedure SpecialLoadXML(AXmlNodeList: TGmXmlNodeList); override;    
  end;

  TBinaryOpNode = class(TOperationNode)
  public
    constructor Create(APosition: TPoint; AOperationSymbol: String; ALeftExpressionNode, ARightExpressionNode: TNode);
    procedure Eval(Env: TEnvironment); override;
  end;

  TUnaryOpNode = class(TOperationNode)
  public
    constructor Create(APosition: TPoint; AOperationSymbol: String; AExpressionNode: TNode);
    procedure Eval(Env: TEnvironment); override;
  end;

  TVariableNode = class(TNode)
  private
    FVariableName: String;
  public
    constructor Create(APosition: TPoint; AVarName: String);
    procedure Eval(Env: TEnvironment); override;

    procedure SpecialSaveXML(AXmlNodeList: TGmXmlNodeList); override;
    procedure SpecialLoadXML(AXmlNodeList: TGmXmlNodeList); override;    

    function GetVariablePointer(Env: TEnvironment): TValue;
    property VariableName: String read FVariableName;
  end;

  TValueNode = class(TNode)
  private
    FValue: TValue;
  public
    constructor Create(APosition: TPoint; AValue: TValue);
    destructor Destroy; override;
    procedure Eval(Env: TEnvironment); override;

    procedure SpecialSaveXML(AXmlNodeList: TGmXmlNodeList); override;
    procedure SpecialLoadXML(AXmlNodeList: TGmXmlNodeList); override;
  end;

  TArrayNode = class(TNode)
  public
    constructor Create(APosition: TPoint);
    procedure Eval(Env: TEnvironment); override;
  end;

  TAssignNode = class(TNode)
  public
    constructor Create(APosition: TPoint; AVariableNode, AExpressionNode: TNode);
    procedure Eval(Env: TEnvironment); override;
  end;

  TFunctionCallNode = class(TNode)
  private
    FFunctionName: String;
  public
    constructor Create(APosition: TPoint; AFuncName: String);
    procedure Eval(Env: TEnvironment); override;

    procedure SpecialSaveXML(AXmlNodeList: TGmXmlNodeList); override;
    procedure SpecialLoadXML(AXmlNodeList: TGmXmlNodeList); override;
  end;

  TIfNode = class(TNode)
  public
    constructor Create(APosition: TPoint; ACondition, AThenBlock, AElseBlock: TNode);
    procedure Eval(Env: TEnvironment); override;
  end;

  TSwitchNode = class(TNode)
  public
    constructor Create(APosition: TPoint; ASwitchVariable: TNode);
    procedure Eval(Env: TEnvironment); override;
  end;

  TCaseNode = class(TNode)
  public
    constructor Create(APosition: TPoint);
    function ForeEval(Env: TEnvironment; Value: TValue): Boolean;
    procedure Eval(Env: TEnvironment); override;
  end;

  TSwitchElseNode = class(TNode)
  public
    constructor Create(APosition: TPoint);
    procedure Eval(Env: TEnvironment); override;
  end;

  TBlockNode = class(TNode)
  public
    constructor Create(APosition: TPoint);
    procedure Eval(Env: TEnvironment); override;
  end;

  TForNode = class(TNode)
  public
    constructor Create(APosition: TPoint; AVarName: TNode);
    procedure Eval(Env: TEnvironment); override;
  end;

  TWhileNode = class(TNode)
  public
    constructor Create(APosition: TPoint; ACondition, ABlock: TNode);
    procedure Eval(Env: TEnvironment); override;
  end;

  TBreakNode = class(TNode)
  public
    constructor Create(APosition: TPoint);
    procedure Eval(Env: TEnvironment); override;
  end;

  TContinueNode = class(TNode)
  public
    constructor Create(APosition: TPoint);
    procedure Eval(Env: TEnvironment); override;
  end;

  TFunctionNode = class(TNode)
  public
    constructor Create(APosition: TPoint; AFuncName, AParams, ABloock: TNode);
    procedure Eval(Env: TEnvironment); override;
    procedure EvalFunction(Env: TEnvironment);
  end;

  TGlobalNode = class(TNode)
  public
    constructor Create(APosition: TPoint; AVarName, AExpression: TNode);
    procedure Eval(Env: TEnvironment); override;
  end;

  TReturnNode = class(TNode)
  public
    constructor Create(APosition: TPoint; AExpressionNode: TNode);
    procedure Eval(Env: TEnvironment); override;
  end;

  TParamNode = class(TNode)
  private
    FRef: TArrayOfBoolean;
  public
    constructor Create(APosition: TPoint);
    destructor Destroy; override;
    procedure Eval(Env: TEnvironment); override;

    procedure SpecialSaveXML(AXmlNodeList: TGmXmlNodeList); override;
    procedure SpecialLoadXML(AXmlNodeList: TGmXmlNodeList); override;

    procedure AddNode(AParam: TNode; ARef: Boolean); overload;

    property Ref: TArrayOfBoolean read FRef write FRef;
  end;

  TNodeRegGroup = class(TObject)
  private
    FNodeClassList: TList;
    function FindNodeClass(AClassName: String): TNodeClass;
  public
    constructor Create;
    destructor Destroy; override;

    procedure RegisterClass(AClass: TNodeClass);
    function GetNodeClass(AClassName: String): TNodeClass;
  end;

  procedure InitLoop;

var
  NodeRegGroup: TNodeRegGroup;
  FunctionReturn, LoopBreak, LoopContinue: Boolean;

implementation

uses
  uStack;

procedure InitLoop;
begin
  LoopBreak := false;
  LoopContinue := false;
end;

function CheckLoopStatus: TLoopStatus;
begin
  Result := lsWork;

  if LoopBreak then
    begin
      Result := lsBreak;
      LoopBreak := false;
      Exit;
    end;

  if LoopContinue then
    begin
      Result := lsContinue;
      LoopContinue := false;
      Exit;
    end;
end; 

// TNode TNode TNode TNode TNode TNode TNode TNode TNode TNode TNode TNode TNode
//==============================================================================

constructor TNode.Create(APosition: TPoint);
begin
  inherited Create;

  FPosition := APosition;
end;

destructor TNode.Destroy;
begin
  Clear;

  inherited Destroy;
end;

procedure TNode.Clear;
var
  i: Integer;
begin
  for i := 0 to Count-1 do (Items[i] as TNode).Clear;

  inherited Clear;
end;

function TNode.GetNode(AIndex: Integer): TNode;
begin
  if (AIndex < 0) or (AIndex >= Count) then
    Result := nil
  else
    Result := Items[AIndex] as TNode;
end;

procedure TNode.AddNode(ANode: TNode);
begin
  Add(ANode);
end;

procedure TNode.SaveXML(AXmlNodeList: TGmXmlNodeList);
var
  i: Integer;
  NewXmlNode: TGmXmlNode;
begin
  with AXmlNodeList do
    begin
      NewXmlNode := AddOpenTag('Node');

      NewXmlNode.Attribute.Name := 'Class';
      NewXmlNode.Attribute.Value := Self.ClassName;

      AddLeaf('Name').AsString := Name;
      AddLeaf('X').AsInteger := Position.X;
      AddLeaf('Y').AsInteger := Position.Y;

      SpecialSaveXML(AXmlNodeList);

      AddOpenTag('Childs');

      for i := 0 to Self.Count-1 do (Items[i] as TNode).SaveXML(CurrentNode.Children);

      AddCloseTag;

      AddCloseTag;
    end;
end;

procedure TNode.SpecialSaveXML(AXmlNodeList: TGmXmlNodeList);
begin
  // Use Child Classes
end;

procedure TNode.LoadXML(AXmlNode: TGmXmlNode);
var
  i, ChildCount: Integer;
  ChildsXmlNode, ChildXmlNode: TGmXmlNode;
  ChildNode: TNode;
begin
  with AXmlNode.Children do
    begin
      FName := NodeByName['Name'].AsString;
      FPosition.X  := NodeByName['X'].AsInteger;
      FPosition.Y  := NodeByName['Y'].AsInteger;

      SpecialLoadXML(AXmlNode.Children);

      ChildsXmlNode := NodeByName['Childs'];

      ChildCount := ChildsXmlNode.Children.Count;

      for i := 0 to ChildCount-1 do
        begin
          ChildXmlNode := ChildsXmlNode.Children[i];

          ChildNode := NodeRegGroup.GetNodeClass(ChildXmlNode.Attribute.Value).Create(Point(-1, -1));
          ChildNode.LoadXML(ChildXmlNode);

          AddNode(ChildNode);
        end;
    end;
end;

procedure TNode.SpecialLoadXML(AXmlNodeList: TGmXmlNodeList);
begin
  // Use Child Classes
end;

// TFunctionCallNode TFunctionCallNode TFunctionCallNode TFunctionCallNode
//=========================================================================
constructor TFunctionCallNode.Create(APosition: TPoint; AFuncName: String);
begin
  inherited Create(position);

  FFunctionName := AFuncName;

  FName := 'Вызов функции "' + AFuncName + '"';
end;

procedure TFunctionCallNode.Eval(Env: TEnvironment);
var
  i: Integer;
  IndexFunction: Integer;
  FuncNode: TFunctionNode;
  arg: TValue;
  IsByRef: Boolean;
begin
  Env.Result.Free;

  FuncNode := nil;
   
  Env.Result := TValue.Create;

  // Поиск функции (внешней или внутренней) по названию
  IndexFunction := Env.IndexOfFunctionCall(FFunctionName);

  if IndexFunction <> -1 then
    begin
      if Env.GetFunctionArgCount(IndexFunction) <> Count then
        raise Exception.CreateFmt('Вызов функции ''%s'' с неверным числом параметров (%d,%d)', [FFunctionName, FPosition.X, FPosition.Y]);
    end
  else
    begin
      FuncNode := TFunctionNode(Env.Functions.GetFunction(FFunctionName));
      
      if FuncNode = nil then
        raise Exception.CreateFmt('Функция ''%s'' не найдена (%d,%d)', [FFunctionName, FPosition.X, FPosition.Y]);

      if FuncNode.NodesList[1].Count <> Count then
        raise Exception.CreateFmt('Вызов функции ''%s'' с неверным числом параметров (%d,%d)', [FFunctionName, FPosition.X, FPosition.Y]);
    end;             

  // Расчет аргументов от последнего к первому
  // первым в стеке будет первый аргумент
  for i := Count-1 downto 0 do
    begin
      if IndexFunction <> -1 then
        IsByRef := Env.FunctionCallRef[IndexFunction, i]
      else
        IsByRef := TParamNode(FuncNode.NodesList[1]).FRef[i];

      if IsByRef and not (NodesList[i] is TVariableNode) then
        raise Exception.CreateFmt('Вызов функции ''%s'' с неверным значением в параметре %d (%d,%d)', [FFunctionName,i,FPosition.X,FPosition.Y]);

      NodesList[i].Eval(Env);
    end;

  // если внешняя функция, то вызываем ее
  if IndexFunction <> -1 then
    begin
      if Assigned(Env.OnFunctionCall) then
        Env.OnFunctionCall(Env, FFunctionName, IndexFunction, Count);
    end
  else // в противном случае, мы вызываем внутренюю функцию
    begin
      FuncNode.EvalFunction(Env);
    end;

  // удаляется из стека и сохраняет аргументы тех, кто имеет ссылки.
  // первым в стеке будет первый аргумент
  for i := 0 to Count-1 do
    begin
      if IndexFunction <> -1 then
        IsByRef := Env.FunctionCallRef[IndexFunction, i]
      else
        IsByRef := TParamNode(FuncNode.NodesList[1]).FRef[i];

      arg := Env.Stack.Pop;

      if IsByRef then
        if Env.Variables.IsExist(TVariableNode(NodesList[i]).FVariableName) then
          Env.Variables.Define(TVariableNode(NodesList[i]).FVariableName, arg)
        else if Env.Globals.IsExist(TVariableNode(NodesList[i]).FVariableName) then
          Env.Globals.Define(TVariableNode(NodesList[i]).FVariableName, arg)
        else
          Env.Variables.Define(TVariableNode(NodesList[i]).FVariableName, arg);  { TODO : Pronin }

      arg.Free;
    end;

  // Добавляем результат в стек
  Env.Stack.Push(TValue.Create(Env.Result));
end;

// TVariableNode TVariableNode TVariableNode TVariableNode TVariableNode
//=======================================================================

constructor TVariableNode.Create(APosition: TPoint; AVarName: String);
begin
  inherited Create(APosition);

  FVariableName := AVarName;
  FName := 'Переменная "' + AVarName + '"';
end;

procedure TVariableNode.Eval(Env: TEnvironment);
var
  i: Integer;
  index, v: TValue;
begin
  if not Env.Variables.IsExist(FVariableName) then
    begin
      if not Env.Globals.IsExist(FVariableName) then
        v := Env.Variables.DefineNew(FVariableName)
      else
        v := Env.Globals.GetValue(FVariableName);
    end
  else
    v := Env.Variables.GetValue(FVariableName);

  v := TValue.Create(v);

  for i := 0 to Count-1 do
    begin
      if not v.IsArray then
        raise Exception.CreateFmt('''%s'' не является массивом размерности %d (%d,%d)', [FVariableName, Count, FPosition.X, FPosition.Y]);

      NodesList[i].Eval(Env);
      index := Env.Stack.Pop;
      v := v.ArrayValue[Round(Index.NumberValue)];
      index.Free;
    end;

  Env.Stack.Push(v);
end;
                     
// TArrayNode TArrayNode TArrayNode TArrayNode TArrayNode TArrayNode TArrayNode
//==============================================================================

constructor TArrayNode.Create(APosition: TPoint);
begin
  inherited Create(APosition);
  
  FName := 'Массив';
end;

procedure TArrayNode.Eval(Env: TEnvironment);
var
  i: Integer;
  v, w: TValue;
begin
  v := TValue.Create;

  for i := 0 to Count-1 do
    begin
      NodesList[i].Eval(Env);
      w := Env.Stack.Pop;
      v.AddArrayItem(w);
      w.Free;
    end;
    
  Env.Stack.Push(v);
end;


// TValueNode TValueNode TValueNode TValueNode TValueNode TValueNode TValueNode
//==============================================================================

constructor TValueNode.Create(APosition: TPoint; AValue: TValue);
begin
  inherited Create(APosition);

  case AValue.TypeValue of
  tvNone   : FName := 'Null';
  tvNumber : FName := 'Число:' + AValue.StringValue;
  tvString : FName := 'Строка:''' + AValue.StringValue + '''';
  tvBoolean: FName := 'Логический тип:' + AValue.StringValue;
  tvArray  : FName := 'Массив:' + AValue.StringValue;
  end;

  FValue := AValue;
end;

procedure TValueNode.Eval(Env: TEnvironment);
begin
  Env.Stack.Push(TValue.Create(FValue));
end;

destructor TValueNode.Destroy;
begin
  FValue.Free;

  inherited;
end;

// TAssignNode TAssignNode TAssignNode TAssignNode TAssignNode TAssignNode
//==============================================================================

constructor TAssignNode.Create(APosition: TPoint; AVariableNode, AExpressionNode: TNode);
begin
  inherited Create(APosition);

  FName := 'Присваивание';

  AddNode(AVariableNode); // [0]
  AddNode(AExpressionNode); // [1]
end;

procedure TAssignNode.Eval(Env: TEnvironment);
var
  VariableNode: TVariableNode;
  CurrentValue, NewValue: TValue;
begin
  NodesList[1].Eval(Env); // ExpressionNode

  VariableNode := NodesList[0] as TVariableNode; // VariableNode

  CurrentValue := VariableNode.GetVariablePointer(Env);

  NewValue := Env.Stack.Pop;

  CurrentValue.Assign(NewValue);

  NewValue.Free;
end;

// TBinaryOpNode TBinaryOpNode TBinaryOpNode TBinaryOpNode TBinaryOpNode
//=======================================================================

constructor TBinaryOpNode.Create(APosition: TPoint; AOperationSymbol: String; ALeftExpressionNode, ARightExpressionNode: TNode);
begin
  inherited Create(APosition);

  FName := 'Оператор ' + AOperationSymbol;

  FOperatorName := AOperationSymbol;

  AddNode(ALeftExpressionNode); // 0
  AddNode(ARightExpressionNode); // 1
end;

function MyMod(a, b: Extended): Extended;
begin
  Result := 0;

  if b < 0 then raise Exception.Create('Второе число при делении с остатком не может быть отрицательным.');

  if a > 0 then
    begin
      while a >= b do begin Result := Result + 1; a := a - b; end;
    end
  else
    begin
      while (a < 0) do begin Result := Result + 1; a := a + b; end;
    end;

  Result := a;
end;

procedure TBinaryOpNode.Eval(Env: TEnvironment);
var
  u, v, res: TValue;
begin
  res := nil;

  NodesList[0].Eval(Env);
  NodesList[1].Eval(Env);

  v := Env.Stack.Pop;
  u := Env.Stack.Pop;

  case FOperatorName[1] of
  '.': res := TValue.Create(u.StringValue + v.StringValue);
  '+': res := TValue.Create(u.NumberValue + v.NumberValue);
  '-': res := TValue.Create(u.NumberValue - v.NumberValue);

  '*': if Length(FOperatorName) = 2 then // '*'
         res := TValue.Create(Power(u.NumberValue, v.NumberValue))
       else
         res := TValue.Create(u.NumberValue * v.NumberValue);

  '/': res := TValue.Create(u.NumberValue / v.NumberValue);
  '%': res := TValue.Create(MyMod(u.ToNumber, v.ToNumber));

  '|': if Length(FOperatorName) = 2 then // '|'
         res := TValue.Create(u.BooleanValue or v.BooleanValue)
       else
         res := TValue.Create(Trunc(u.NumberValue) or Trunc(v.NumberValue));

  '&': if Length(FOperatorName) = 2 then // '&'
         res := TValue.Create(u.BooleanValue and v.BooleanValue)
       else
         res := TValue.Create(Trunc(u.NumberValue) and Trunc(v.NumberValue));

  '^': res := TValue.Create(Trunc(u.NumberValue) xor Trunc(v.NumberValue));

  '<':
    begin
      if Length(FOperatorName) = 2 then // '<' or '='
        begin
          case FOperatorName[1] of
          '=': if u.IsString or v.IsString then
                 res := TValue.Create(u.StringValue <= v.StringValue)
               else
                 res := TValue.Create(u.NumberValue <= v.NumberValue);
          '<': res := TValue.Create(Trunc(u.NumberValue) shl Trunc(v.NumberValue));
          end;
        end
      else
        begin
          if u.IsString or v.IsString then
            res := TValue.Create(u.StringValue < v.StringValue)
          else
            res := TValue.Create(u.NumberValue < v.NumberValue);
        end;
    end;
  '>':
    begin
      if Length(FOperatorName) = 2 then // '>' or '='
        begin
          case FOperatorName[1] of
          '=': if u.IsString or v.IsString then
                 res := TValue.create(u.StringValue >= v.StringValue)
               else
                 res := TValue.Create(u.NumberValue >= v.NumberValue);
          '>': res := TValue.Create(Trunc(u.NumberValue) shr Trunc(v.NumberValue));
          end;
        end
      else
        begin
          if u.IsString or v.IsString then
            res := TValue.Create(u.StringValue > v.StringValue)
          else
            res := TValue.Create(u.NumberValue > v.NumberValue);
        end
    end;
  '!':
    begin
      if Length(FOperatorName) = 2 then // '='
        if u.IsString or v.IsString then
          res := TValue.Create(u.StringValue <> v.StringValue)
        else
          res := TValue.create(u.NumberValue <> v.NumberValue);
    end;
  '=':
    begin
      if Length(FOperatorName) = 2 then // '='
        if u.IsString or v.IsString then
          res := TValue.Create(u.StringValue = v.StringValue)
        else
          res := TValue.Create(u.NumberValue = v.NumberValue);
    end;
  end;

 Env.Stack.Push(res);

 u.Free;

 v.Free;
end;

// TUnaryOpNode TUnaryOpNode TUnaryOpNode TUnaryOpNode TUnaryOpNode
//=======================================================================

constructor TUnaryOpNode.Create(APosition: TPoint; AOperationSymbol: String; AExpressionNode: TNode);
begin
  inherited Create(APosition);

  FName := 'Оператор ' + AOperationSymbol;

  FOperatorName := AOperationSymbol;

  AddNode(AExpressionNode); // 0
end;

procedure TUnaryOpNode.Eval(Env: TEnvironment);
var
  u: TValue;

  function BitwiseNot(AValue: Extended): Extended;
  begin
    Result := not Trunc(AValue);
  end;
  
begin
  NodesList[0].Eval(Env);

  u := Env.Stack.Pop;

  case FOperatorName[1] of
  '-': u := TValue.Create(-u.ToNumber);
  '!': u := TValue.Create(not u.ToBoolean);
  '~': u := TValue.Create(BitwiseNot(u.ToNumber));
  end;
  
  Env.Stack.Push(u);
end;

// TIfNode TIfNode TIfNode TIfNode TIfNode TIfNode TIfNode TIfNode TIfNode
//=========================================================================

constructor TIfNode.Create(APosition: TPoint; ACondition, AThenBlock, AElseBlock: TNode);
begin
  inherited Create(APosition);

  FName := 'Условие IF';

  AddNode(ACondition); // 0
  AddNode(AThenBlock); // 1

  if AElseBlock <> nil then AddNode(AElseBlock);
end;

procedure TIfNode.Eval(Env: TEnvironment);
var
  u: TValue;
begin
  NodesList[0].Eval(Env);

  u := Env.Stack.Pop;

  // Вычисление конструкции 'then'
  if u.BooleanValue then
    NodesList[1].Eval(Env) // then Block
  else
    // Вычисление конструкции 'else', если она имеется
    if Count = 3 then NodesList[2].Eval(Env); // else Block
end;

// TBlockNode TBlockNode TBlockNode TBlockNode TBlockNode TBlockNode TBlockNode
//==============================================================================

constructor TBlockNode.Create(APosition: TPoint);
begin
  inherited Create(APosition);

  FName := 'Блок';
end;

procedure TBlockNode.Eval(Env: TEnvironment);
var
  i: Integer;
begin
  for i := 0 to Count-1 do
    begin
      NodesList[i].Eval(Env);

      if LoopBreak or LoopContinue or FunctionReturn then Break;
    end;
end;

// TForNode TForNode TForNode TForNode TForNode TForNode TForNode TForNode
//=========================================================================

constructor TForNode.Create(APosition: TPoint; AVarName: TNode);
begin
  inherited Create(APosition);

  FName := 'Цикл For';

  AddNode(AVarName); // 0
end;

procedure TForNode.Eval(Env: TEnvironment);
var
  v: TValue;
  VarName: String;
  ii: Integer;
  i, start, finish: Extended;
begin
  InitLoop;

  VarName := TVariableNode(NodesList[0]).VariableName; // Variable
  
  // FOR...IN...DO...
  if Count = 3 then
    begin
      NodesList[1].Eval(Env); // VarArray or Array
      v := Env.Stack.Pop;

      for ii := 0 to v.ArrayLenght-1 do
        begin
          Env.Variables.Define(VarName, v.ArrayValue[ii]);
          NodesList[2].Eval(Env); // Block

          if CheckLoopStatus = lsBreak then Break;
        end;

      v.Free;
    end
  else // FOR...FROM...TO...DO
    begin
      NodesList[1].Eval(Env); // From Var

      v := Env.Stack.Pop;
      start := v.ToNumber;
      v.Free;

      NodesList[2].Eval(Env); // To Var

      v := Env.Stack.Pop;
      finish := v.ToNumber;
      v.Free;

      i := start;
      v := TValue.Create(i);
      Env.Variables.Define(VarName, v);

      if start < finish then
        begin
          while i <= finish do
            begin
              NodesList[3].Eval(Env); // Block

              if CheckLoopStatus = lsBreak then Break;

              i := i + 1;

              v.NumberValue := i;

              Env.Variables.Define(VarName, v);
            end;
        end
      else if start > finish then
        while i >= finish do
          begin
            NodesList[3].Eval(Env);

            //-----------------------------------------

            if CheckLoopStatus = lsBreak then Break;

            //-----------------------------------------

            i := i - 1;
            v.NumberValue := i;
            Env.Variables.Define(VarName, v);
          end;

      v.Free;
    end;
end;

// TWhileNode TWhileNode TWhileNode TWhileNode TWhileNode TWhileNode TWhileNode
//==============================================================================

constructor TWhileNode.Create(APosition: TPoint; ACondition, ABlock: TNode);
begin
  inherited Create(APosition);
  
  FName := 'Цикл While';

  AddNode(ACondition); // 0
  AddNode(ABlock); // 1
end;

procedure TWhileNode.Eval(Env: TEnvironment);
var
  u: TValue;
begin
  NodesList[0].Eval(Env);

  InitLoop;

  u := Env.Stack.Pop;

  while (u.BooleanValue) do
    begin
      u.Free;

      NodesList[1].Eval(Env); // Block
      NodesList[0].Eval(Env); // Condition

      u := Env.Stack.Pop;

      if CheckLoopStatus = lsBreak then Break;
    end;

  u.Free;
end;

// TFunctionNode TFunctionNode TFunctionNode TFunctionNode TFunctionNode
//=======================================================================

constructor TFunctionNode.Create(APosition: TPoint; AFuncName, AParams, ABloock: TNode);
begin
  inherited Create(APosition);

  FName := 'Функция';

  AddNode(AFuncName); // 0
  AddNode(AParams); // 1
  AddNode(ABloock); // 2
end;

procedure TFunctionNode.Eval(Env: TEnvironment);
begin
  // Резервный узел в начале функции

  Env.Functions.Define(TVariableNode(NodesList[0]).VariableName, Self);
end;

// Вызов функции
procedure TFunctionNode.EvalFunction(Env: TEnvironment);
var
  i: Integer;
  arg: TValue;
begin
  // Добавляем уровень в стек (функций и переменных)
  Env.Variables.UpStack;
  Env.Functions.UpStack;

  // Каждому аргументу присваеваем значение
  for i := 0 to NodesList[1].Count-1 do // Function Params
    begin
      arg := Env.Stack.Pop;
      Env.Variables.Define(TVariableNode(NodesList[1].NodesList[i]).VariableName, arg);
      arg.Free;
    end;

  FunctionReturn := false;

  NodesList[2].Eval(Env);

  FunctionReturn := false;

  // На каждый аргумент по одной ссылке в стек
  for i := NodesList[1].Count-1 downto 0 do
    Env.Stack.Push(TValue.Create(Env.Variables.GetValue(TVariableNode(NodesList[1].NodesList[i]).VariableName)));

  // Удаление одного уровня в стеке (функций и переменных)
  Env.Variables.DownStack;
  Env.Functions.DownStack;
end;

// TGlobalNode TGlobalNode TGlobalNode TGlobalNode TGlobalNode TGlobalNode
//=========================================================================

constructor TGlobalNode.Create(APosition: TPoint; AVarName, AExpression: TNode);
begin
  inherited Create(APosition);

  FName := 'Глобальная переменная';

  AddNode(AVarName); // 0
  AddNode(AExpression); // 1
end;

procedure TGlobalNode.Eval(Env: TEnvironment);
var
  v: TValue;
begin
  if NodesList[1] = nil then
    v := TValue.Create
  else
    begin
      NodesList[1].Eval(Env);
      v := Env.Stack.Pop;
    end;

  Env.Globals.Define(TVariableNode(NodesList[0]).VariableName, v);

  v.Free;
end;

// TReturnNode TReturnNode TReturnNode TReturnNode TReturnNode TReturnNode
//=========================================================================

constructor TReturnNode.Create(APosition: TPoint; AExpressionNode: TNode);
begin
  inherited Create(APosition);

  FName := 'Return';

  AddNode(AExpressionNode); // 0
end;

procedure TReturnNode.Eval(Env: TEnvironment);
var
  v: TValue;
begin
  NodesList[0].Eval(Env);

  v := Env.Stack.Pop;
  Env.Result.Assign(v);
  v.Free;
  FunctionReturn := true;
end;
           
// TParamNode TParamNode TParamNode TParamNode TParamNode TParamNode TParamNode
//==============================================================================

procedure TParamNode.AddNode(AParam: TNode; ARef: Boolean);
begin
  inherited AddNode(AParam);

  SetLength(FRef, Count);
  FRef[Count-1] := ARef;
end;

constructor TParamNode.Create(APosition: TPoint);
begin
  inherited Create(APosition);

  FName := 'Параметр';
end;

destructor TParamNode.Destroy;
begin
  SetLength(FRef, 0);

  inherited;
end;

procedure TParamNode.Eval(Env: TEnvironment);
begin
 //
end;

{ TSwitchNode }

constructor TSwitchNode.Create(APosition: TPoint; ASwitchVariable: TNode);
begin
  inherited Create(APosition);

  FName := 'Условие Switch';

  AddNode(ASwitchVariable); // 0
end;

procedure TSwitchNode.Eval(Env: TEnvironment);
var
  i: Integer;
  CheckValue: TValue;
  CurNode: TNode;
begin
  NodesList[0].Eval(Env);

  CheckValue := Env.Stack.Pop;

  for i := 1 to Count-1 do  { TODO : Было NodeCount }
    begin
      CurNode := GetNode(i);

      if CurNode is TCaseNode then
        if (CurNode as TCaseNode).ForeEval(Env, CheckValue) then Break;

      if CurNode is TSwitchElseNode then
        begin
          TSwitchElseNode(CurNode).Eval(Env);
          Break;
        end;
    end;

  CheckValue.Free;
end;

{ TCaseNode }

constructor TCaseNode.Create(APosition: TPoint);
begin
  inherited Create(APosition);

  FName := 'Блок Case';
end;

procedure TCaseNode.Eval(Env: TEnvironment);
begin
  NodesList[1].Eval(Env); // Block
end;

function TCaseNode.ForeEval(Env: TEnvironment; Value: TValue): Boolean;
var
  CaseValue: TValue;
begin
  NodesList[0].Eval(Env); // Condition

  CaseValue := Env.Stack.Pop;

  if Value.IsString then
    Result := (Value.StringValue = CaseValue.StringValue)
  else if Value.IsNumber then
    Result := (Value.NumberValue = CaseValue.NumberValue)
  else if Value.IsBoolean then
    Result := (Value.BooleanValue = CaseValue.BooleanValue)
  else
    raise Exception.CreateFmt('Не поддерживаемый тип для конструкции Switch-Case (%d, %d)', [FPosition.X, FPosition.Y]);

  if Result then Eval(Env);

  CaseValue.Free;
end;

{ TSwitchElseNode }

constructor TSwitchElseNode.Create(APosition: TPoint);
begin
  inherited Create(APosition);

  FName := 'Блок Switch Else';
end;

procedure TSwitchElseNode.Eval(Env: TEnvironment);
begin
  NodesList[0].Eval(Env); // Block
end;

{ TBreakNode }

constructor TBreakNode.Create(APosition: TPoint);
begin
  inherited Create(APosition);

  FName := 'Команда Break';
end;

procedure TBreakNode.Eval(Env: TEnvironment);
begin
  inherited;

  LoopBreak := true;
end;

{ TContinueNode }

constructor TContinueNode.Create(APosition: TPoint);
begin
  inherited Create(APosition);

  FName := 'Команда Continue';
end;

procedure TContinueNode.Eval(Env: TEnvironment);
begin
  inherited;

  LoopContinue := true;
end;

function TVariableNode.GetVariablePointer(Env: TEnvironment): TValue;
var
  i: Integer;
  index: TValue;
begin
  if not Env.Variables.IsExist(FVariableName) then
    begin
      if not Env.Globals.IsExist(FVariableName) then
        Result := Env.Variables.DefineNew(FVariableName)
      else
        Result := Env.Globals.GetValue(FVariableName);
    end
  else
    Result := Env.Variables.GetValue(FVariableName);

  for i := 0 to Count-1 do
    begin
      if not Result.IsArray then
        raise Exception.CreateFmt('''%s'' не является массивом размерности %d (%d,%d)', [FVariableName, Count, FPosition.X, FPosition.Y]);

      NodesList[i].Eval(Env);
      index := Env.Stack.Pop;

      Result := Result.ArrayValue[Round(Index.NumberValue)];

      index.Free;
    end;
end;

{ TOperationNode }

procedure TOperationNode.SpecialLoadXML(AXmlNodeList: TGmXmlNodeList);
begin
  FOperatorName := AXmlNodeList.NodeByName['OperatorName'].AsString;
end;

procedure TOperationNode.SpecialSaveXML(AXmlNodeList: TGmXmlNodeList);
begin
  AXmlNodeList.AddLeaf('OperatorName').AsString := FOperatorName;
end;

procedure TVariableNode.SpecialLoadXML(AXmlNodeList: TGmXmlNodeList);
begin
  FVariableName := AXmlNodeList.NodeByName['VariableName'].AsString;
end;

procedure TVariableNode.SpecialSaveXML(AXmlNodeList: TGmXmlNodeList);
begin
  AXmlNodeList.AddLeaf('VariableName').AsString := FVariableName;
end;

procedure TValueNode.SpecialLoadXML(AXmlNodeList: TGmXmlNodeList);
var
  ValueXmlNode: TGmXmlNode;
begin
  FValue := TValue.Create;

  ValueXmlNode := AXmlNodeList.NodeByName['TValue'];

  if Assigned(ValueXmlNode) then
    FValue.LoadXML(ValueXmlNode);
end;

procedure TValueNode.SpecialSaveXML(AXmlNodeList: TGmXmlNodeList);
begin
  FValue.SaveXML(AXmlNodeList);
end;

procedure TFunctionCallNode.SpecialLoadXML(AXmlNodeList: TGmXmlNodeList);
begin
  FFunctionName := AXmlNodeList.NodeByName['FunctionName'].AsString;
end;

procedure TFunctionCallNode.SpecialSaveXML(AXmlNodeList: TGmXmlNodeList);
begin
  AXmlNodeList.AddLeaf('FunctionName').AsString := FFunctionName;
end;

procedure TParamNode.SpecialLoadXML(AXmlNodeList: TGmXmlNodeList);
var
  i: Integer;
begin
  SetLength(FRef, AXmlNodeList.NodeByName['Refs'].Children.Count);

  with AXmlNodeList.NodeByName['Refs'] do
    begin
      for i := 0 to Children.Count-1 do
        FRef[i] := Children[i].AsBoolean; // Tag 'Ref'
    end;
end;

procedure TParamNode.SpecialSaveXML(AXmlNodeList: TGmXmlNodeList);
var
  i: Integer;
begin
  with AXmlNodeList do
    begin
      AddLeaf('RefCount').AsInteger := Length(FRef);

      AddOpenTag('Refs');

      for i := Low(FRef) to High(FRef) do
        AddLeaf('Ref').AsBoolean := FRef[i];

      AddCloseTag;
    end;
end;

{ **************************************************************************** }
{ TNodeRegGroup }

constructor TNodeRegGroup.Create;
begin
  FNodeClassList := TList.Create;
end;

destructor TNodeRegGroup.Destroy;
begin
  FreeAndNil(FNodeClassList);

  inherited;
end;

function TNodeRegGroup.FindNodeClass(AClassName: String): TNodeClass;
var
  i: Integer;
  CLN: String;
begin
  CLN := LowerCase(AClassName);

  for i := 0 to FNodeClassList.Count - 1 do
    begin
      Result := FNodeClassList[I];

      if LowerCase(Result.ClassName) = CLN then Exit;
    end;

  Result := nil;
end;

function TNodeRegGroup.GetNodeClass(AClassName: String): TNodeClass;
begin
  Result := FindNodeClass(AClassName);

  if not Assigned(Result) then
    raise Exception.CreateFmt('Класс не зарегистрирован [%s]', [AClassName]);
end;

procedure TNodeRegGroup.RegisterClass(AClass: TNodeClass);
begin
  if FindNodeClass(AClass.ClassName) = nil then
    FNodeClassList.Add(AClass);
end;
       

function TNode.GetCount: Integer;
begin
  Result := Count;
end;

initialization
  NodeRegGroup := TNodeRegGroup.Create;

  with NodeRegGroup do
    begin
      RegisterClass(TBinaryOpNode);
      RegisterClass(TUnaryOpNode);
      RegisterClass(TVariableNode);
      RegisterClass(TValueNode);
      RegisterClass(TArrayNode);
      RegisterClass(TAssignNode);
      RegisterClass(TFunctionCallNode);
      RegisterClass(TIfNode);
      RegisterClass(TSwitchNode);
      RegisterClass(TCaseNode);
      RegisterClass(TSwitchElseNode);
      RegisterClass(TBlockNode);
      RegisterClass(TForNode);
      RegisterClass(TWhileNode);
      RegisterClass(TBreakNode);
      RegisterClass(TContinueNode);
      RegisterClass(TFunctionNode);
      RegisterClass(TGlobalNode);
      RegisterClass(TReturnNode);
      RegisterClass(TParamNode);
    end;

finalization
  FreeAndNil(NodeRegGroup);

end.

