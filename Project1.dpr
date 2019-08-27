program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  uGmXml in 'uGmXml.pas',
  uEnvironment in 'uEnvironment.pas',
  UFunctions in 'uFunctions.pas',
  uInterpreter in 'uInterpreter.pas',
  UNodes in 'uNodes.pas',
  UParser in 'uParser.pas',
  UStack in 'uStack.pas',
  UToken in 'uToken.pas',
  UValues in 'uValues.pas',
  UVariables in 'uVariables.pas',
  uHashTable in 'uHashTable.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
