unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Math, ExtCtrls, ActnList, Contnrs,
  uInterpreter, uToken, uNodes, uValues, System.Actions;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    ActionList1: TActionList;
    acSelectAllXml: TAction;
    Panel1: TPanel;
    btCompil: TButton;
    btRun: TButton;
    btSaveXml: TButton;
    btLoadXml: TButton;
    btEventCall: TButton;
    Label4: TLabel;
    Panel2: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TreeView1: TTreeView;
    TabSheet3: TTabSheet;
    Memo2: TMemo;
    TabSheet4: TTabSheet;
    meXml: TMemo;
    Memo1: TMemo;
    Splitter1: TSplitter;
    procedure acSelectAllXmlExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btCompilClick(Sender: TObject);
    procedure btEventCallClick(Sender: TObject);
    procedure btLoadXmlClick(Sender: TObject);
    procedure btRunClick(Sender: TObject);
    procedure btSaveXmlClick(Sender: TObject);
  private
    { Déclarations privées }
    procedure AddToTree(ParentNode: TTreeNode; n: TNode);
  public
    FInterpreter: TInterpreter;
    procedure FunctionCall(Sender: TObject; AFunctionName: String; AIndex: Integer; AArgsCount: Integer); //: TValue;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  uEnvironment, uStack, uGmXml;

procedure TForm1.acSelectAllXmlExecute(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to ComponentCount-1 do
    if Components[i] is TMemo then
      if TMemo(Components[i]).Focused then
        TMemo(Components[i]).SelectAll;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FInterpreter);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FInterpreter := TInterpreter.Create;

  FInterpreter.Environment.AddFunctionCall('clear', []);
  FInterpreter.Environment.AddFunctionCall('circle', [false, false]);
  FInterpreter.Environment.AddFunctionCall('square', [false, false, false]);
  FInterpreter.Environment.AddFunctionCall('color', [false, false]);
  FInterpreter.Environment.AddFunctionCall('text', [false, false]);
  FInterpreter.Environment.AddFunctionCall('sin', [false]);
  FInterpreter.Environment.AddFunctionCall('cos', [false]);

  FInterpreter.Environment.AddFunctionCall('memo_add', [false]);
  FInterpreter.Environment.AddFunctionCall('memo_clear', []);
  FInterpreter.Environment.AddFunctionCall('out_test', [true, true]);
  FInterpreter.Environment.AddFunctionCall('count', [false]);
  FInterpreter.Environment.AddFunctionCall('set_length', [true, false]);
  FInterpreter.Environment.AddFunctionCall('get_type', [false]);  

  FInterpreter.OnFunctionCall := FunctionCall;
end;

// REMARQUES :
// - les paramètres sont sur la pile de l'environnement
//   le premier est en haut de la pile
// - A la fin, si une valeur doit être retourner, la mettre dans Env.result
// - Tous les paramètres doivent rester sur la pile pour être ensuite traiter
//   pour les paramètres référencés
// - le numéro d'index correspond à l'ordre lors de l'ajout par t.Environnement.AddFunctionCall
//
procedure TForm1.FunctionCall(Sender: TObject; AFunctionName: String; AIndex: Integer; AArgsCount: Integer);
var
  NewSize: Integer;
  Env: TEnvironment;
  p, ChangeArrayValue: TValue;
  x: Extended;
  s, type_res: String;
const
  MyColor: array[0..15] of TColor = ($000000,$800000,$008000,$808000,$000080,$800080,$008080,$c0c0c0,
                                     $808080,$FF0000,$00FF00,$FFFF00,$0000FF,$FF00FF,$00FFFF,$FFFFFF);
begin
  Env := TEnvironment(Sender);

  case AIndex of
  0://clear()
    begin
      {
      Image1.Canvas.FillRect(Image1.ClientRect);
      }
    end;
  1://circle([x,y],rayon)
    begin
      {
      p := Env.Stack.Read(0);
      x := p.ArrayValue[0].NumberValue;
      y := p.ArrayValue[1].NumberValue;
      r := Env.Stack.Read(1).NumberValue;
      Image1.Canvas.Ellipse(Round(x-r), Round(y-r), Round(x+r), Round(y+r));
      }
    end;
  2://square([x,y],rayon,angle)
    begin
      {
      p := Env.Stack.Read(0);
      x := p.ArrayValue[0].NumberValue;
      y := p.ArrayValue[1].NumberValue;
      r := Env.Stack.Read(1).NumberValue;
      a := Env.Stack.Read(2).NumberValue + Pi/4;
      pt[0] := Point(Round(x+cos(a)*r), Round(y+sin(a)*r));
      pt[1] := Point(Round(x-sin(a)*r), Round(y+cos(a)*r));
      pt[2] := Point(Round(x-cos(a)*r), Round(y-sin(a)*r));
      pt[3] := Point(Round(x+sin(a)*r), Round(y-cos(a)*r));
      Image1.Canvas.Polygon(pt);
      }
    end;
  3://color(pen,brush)
    begin
      {
      c1 := Env.Stack.Read(0).NumberValue;
      c2 := Env.Stack.Read(1).NumberValue;
      Image1.Canvas.Pen.Color := MyColor[Round(c1)];
      Image1.Canvas.Font.Color := MyColor[Round(c1)];
      Image1.Canvas.Brush.color := MyColor[Round(c2)];
      }
    end;
  4://text([x,y],string)
    begin
      {
      p := Env.Stack.Read(0);
      x := p.ArrayValue[0].NumberValue;
      y := p.ArrayValue[1].NumberValue;
      s := Env.Stack.Read(1).StringValue;
      Image1.Canvas.TextOut(Round(x), Round(y), s);
      }
    end;
  5://cos(x)
    begin
      x := Env.Stack.Read(0).NumberValue;
      Env.Result.NumberValue := cos(x);
    end;
  6://sin(x)
    begin
      x := Env.Stack.Read(0).NumberValue;
      Env.Result.NumberValue := sin(x);
    end;
  7://memo_add(string)
    begin
      s := Env.Stack.Read(0).StringValue;
      Memo2.Lines.Add(s);
    end;
  8://memo_clear()
    begin
      Memo2.Clear;
    end;
  9://out_test(x, y)
    begin
      Env.Stack.Write(0, TValue.Create(12345)); // x
      Env.Stack.Write(1, TValue.Create(54321)); // x      
      Env.Result.StringValue := 'hello pronin';
    end;
  10://count(x)
    begin
      p := Env.Stack.Read(0);
      if p.IsArray then
        Env.Result.NumberValue := p.ArrayLenght
      else
        Env.Result.NumberValue := 0;
    end;
  11://set_length(array, count)
    begin
      ChangeArrayValue := Env.Stack.Read(0);

      NewSize := Round(Env.Stack.Read(1).NumberValue);

      if ChangeArrayValue.ArrayLenght < NewSize then
        while ChangeArrayValue.ArrayLenght < NewSize do
          ChangeArrayValue.AddArrayItem(TValue.Create);

      if ChangeArrayValue.ArrayLenght > NewSize then
        ChangeArrayValue.DeleteArrayItems(NewSize);

      Env.Result.BooleanValue := true;
    end;
  12://get_type(var)
    begin
      case Env.Stack.Read(0).TypeValue of
      tvNone   : type_res := 'none';
      tvNumber : type_res := 'number';
      tvString : type_res := 'string';
      tvBoolean: type_res := 'boolean';
      tvArray  : type_res := 'array';
      else
        type_res := 'none';
      end;

      Env.Result.StringValue := type_res;
    end;
  end;
end;

procedure TForm1.AddToTree(ParentNode: TTreeNode; n: TNode);
var
  i: Integer;
  t: TTreeNode;
begin
  if n = nil then Exit;

  t := TreeView1.Items.AddChild(ParentNode, n.ClassName + '(' + n.Name + ')');

  for i := 0 to n.NodeCount-1 do
    AddToTree(t, n.NodesList[i]);
end;

procedure TForm1.btCompilClick(Sender: TObject);
var
  i: Integer;
begin
  Label4.Caption := '';

  try
    FInterpreter.SetCodeSource('Editor', Memo1.Text);

    TreeView1.Items.Clear;

    for i := 0 to FInterpreter.Parser.Count-1 do
      AddToTree(nil, FInterpreter.Parser.RootNodes[i]);

  except
    on E: Exception do Label4.Caption := E.Message;
  end;
end;

procedure TForm1.btEventCallClick(Sender: TObject);
var
  ParamList: TObjectList;
  Value: TValue;
begin
  Memo2.Lines.Add('Event =================================');

  ParamList := TObjectList.Create;
  try
    Value := TValue.Create('Good Day');

    ParamList.Add(Value);

    Memo2.Lines.Add(FInterpreter.Environment.UserCallFunction('test_event', ParamList).ToString);

    Memo2.Lines.Add('Out param: ' + Value.ToString);

  finally
    FreeAndNil(ParamList);
  end;
end;

procedure TForm1.btLoadXmlClick(Sender: TObject);
var
  i: Integer;
begin
  FInterpreter.Parser.XmlDocument.Text := meXml.Text;

  FInterpreter.Parser.LoadXML;

  //****************************************************

  TreeView1.Items.Clear;

  for i := 0 to FInterpreter.Parser.Count-1 do
    AddToTree(nil, FInterpreter.Parser.RootNodes[i]);
end;

procedure TForm1.btRunClick(Sender: TObject);
var
  start: Cardinal;
begin
  try
    start := GetTickCount;

    FInterpreter.Run;

    Caption := IntToStr(GetTickCount - start);
  except
    on E: Exception do Label4.Caption := E.Message;
  end;
end;

procedure TForm1.btSaveXmlClick(Sender: TObject);
begin
  FInterpreter.Parser.SaveXML;

  meXml.Clear;

  meXml.Lines.Add(FInterpreter.Parser.XmlDocument.Text);
end;

end.

