object Form1: TForm1
  Left = 357
  Top = 248
  BorderStyle = bsSingle
  Caption = 'Customizable language interpreter'
  ClientHeight = 558
  ClientWidth = 864
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 7
    Top = 52
    Width = 65
    Height = 13
    Caption = 'Code Source:'
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 864
    Height = 73
    Align = alTop
    TabOrder = 0
    object Label4: TLabel
      Left = 434
      Top = 13
      Width = 423
      Height = 52
      AutoSize = False
      Caption = 'Message interpreter...'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -15
      Font.Name = 'Times New Roman'
      Font.Style = [fsBold]
      ParentFont = False
      WordWrap = True
    end
    object btCompil: TButton
      Left = 10
      Top = 8
      Width = 95
      Height = 25
      Caption = 'Compil'
      TabOrder = 0
      OnClick = btCompilClick
    end
    object btRun: TButton
      Left = 112
      Top = 8
      Width = 97
      Height = 25
      Caption = 'Run'
      TabOrder = 1
      OnClick = btRunClick
    end
    object btSaveXml: TButton
      Left = 216
      Top = 8
      Width = 97
      Height = 25
      Caption = 'Save Xml'
      TabOrder = 2
      OnClick = btSaveXmlClick
    end
    object btLoadXml: TButton
      Left = 320
      Top = 8
      Width = 97
      Height = 25
      Caption = 'Load Xml'
      TabOrder = 3
      OnClick = btLoadXmlClick
    end
    object btEventCall: TButton
      Left = 320
      Top = 40
      Width = 97
      Height = 25
      Caption = 'Event Call'
      TabOrder = 4
      OnClick = btEventCallClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 73
    Width = 864
    Height = 485
    Align = alClient
    Caption = 'Panel2'
    TabOrder = 1
    object Splitter1: TSplitter
      Left = 492
      Top = 1
      Width = 4
      Height = 483
      Align = alRight
      Beveled = True
    end
    object PageControl1: TPageControl
      Left = 496
      Top = 1
      Width = 367
      Height = 483
      ActivePage = TabSheet3
      Align = alRight
      TabOrder = 0
      object TabSheet1: TTabSheet
        Caption = 'Schema'
        object TreeView1: TTreeView
          Left = 0
          Top = 0
          Width = 359
          Height = 455
          Align = alClient
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Courier New'
          Font.Style = []
          Indent = 19
          ParentFont = False
          TabOrder = 0
        end
      end
      object TabSheet3: TTabSheet
        Caption = 'Consol'
        ImageIndex = 2
        object Memo2: TMemo
          Left = 0
          Top = 0
          Width = 359
          Height = 455
          Align = alClient
          ScrollBars = ssBoth
          TabOrder = 0
        end
      end
      object TabSheet4: TTabSheet
        Caption = 'Xml'
        ImageIndex = 3
        object meXml: TMemo
          Left = 0
          Top = 0
          Width = 359
          Height = 455
          Align = alClient
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          Lines.Strings = (
            '<?xml version="1.0"?>'
            '<CC>'
            '  <ChildCount>4</ChildCount>'
            '  <Childs>'
            '    <Node Class="TFunctionCallNode">'
            '      <Name>'#1042#1099#1079#1086#1074' '#1092#1091#1085#1082#1094#1080#1080' &quot;memo_clear&quot;</Name>'
            '      <X>0</X>'
            '      <Y>0</Y>'
            '      <FunctionName>memo_clear</FunctionName>'
            '      <Childs></Childs>'
            '    </Node>'
            '    <Node Class="TAssignNode">'
            '      <Name>'#1055#1088#1080#1089#1074#1072#1080#1074#1072#1085#1080#1077'</Name>'
            '      <X>3</X>'
            '      <Y>3</Y>'
            '      <Childs>'
            '        <Node Class="TVariableNode">'
            '          <Name>'#1055#1077#1088#1077#1084#1077#1085#1085#1072#1103' &quot;n&quot;</Name>'
            '          <X>1</X>'
            '          <Y>3</Y>'
            '          <VariableName>n</VariableName>'
            '          <Childs></Childs>'
            '        </Node>'
            '        <Node Class="TArrayNode">'
            '          <Name>'#1052#1072#1089#1089#1080#1074'</Name>'
            '          <X>5</X>'
            '          <Y>3</Y>'
            '          <Childs>'
            '            <Node Class="TValueNode">'
            '              <Name>'#1063#1080#1089#1083#1086':12</Name>'
            '              <X>6</X>'
            '              <Y>3</Y>'
            '              <TValue Type="1">'
            '                <X>0</X>'
            '                <Y>0</Y>'
            '                <Value>12</Value>'
            '              </TValue>'
            '              <Childs></Childs>'
            '            </Node>'
            '            <Node Class="TValueNode">'
            '              <Name>'#1063#1080#1089#1083#1086':9</Name>'
            '              <X>10</X>'
            '              <Y>3</Y>'
            '              <TValue Type="1">'
            '                <X>0</X>'
            '                <Y>0</Y>'
            '                <Value>9</Value>'
            '              </TValue>'
            '              <Childs></Childs>'
            '            </Node>'
            '          </Childs>'
            '        </Node>'
            '      </Childs>'
            '    </Node>'
            '    <Node Class="TAssignNode">'
            '      <Name>'#1055#1088#1080#1089#1074#1072#1080#1074#1072#1085#1080#1077'</Name>'
            '      <X>6</X>'
            '      <Y>5</Y>'
            '      <Childs>'
            '        '
            #9#9'<Node Class="TVariableNode">'
            '          <Name>'#1055#1077#1088#1077#1084#1077#1085#1085#1072#1103' &quot;n&quot;</Name>'
            '          <X>1</X>'
            '          <Y>5</Y>'
            '          <VariableName>n</VariableName>'
            '          <Childs>'
            '            <Node Class="TValueNode">'
            '              <Name>'#1063#1080#1089#1083#1086':1</Name>'
            '              <X>3</X>'
            '              <Y>5</Y>'
            '              <TValue Type="1">'
            '                <X>0</X>'
            '                <Y>0</Y>'
            '                <Value>1</Value>'
            '              </TValue>'
            '              <Childs></Childs>'
            '            </Node>'
            '          </Childs>'
            '        </Node>'
            #9#9
            '        <Node Class="TValueNode">'
            '          <Name>'#1063#1080#1089#1083#1086':56</Name>'
            '          <X>8</X>'
            '          <Y>5</Y>'
            '          <TValue Type="1">'
            '            <X>0</X>'
            '            <Y>0</Y>'
            '            <Value>56</Value>'
            '          </TValue>'
            '          <Childs></Childs>'
            '        </Node>'
            '      </Childs>'
            '    </Node>'
            '    <Node Class="TFunctionCallNode">'
            '      <Name>'#1042#1099#1079#1086#1074' '#1092#1091#1085#1082#1094#1080#1080' &quot;memo_add&quot;</Name>'
            '      <X>0</X>'
            '      <Y>0</Y>'
            '      <FunctionName>memo_add</FunctionName>'
            '      <Childs>'
            '        <Node Class="TVariableNode">'
            '          <Name>'#1055#1077#1088#1077#1084#1077#1085#1085#1072#1103' &quot;n&quot;</Name>'
            '          <X>10</X>'
            '          <Y>7</Y>'
            '          <VariableName>n</VariableName>'
            '          <Childs></Childs>'
            '        </Node>'
            '      </Childs>'
            '    </Node>'
            '  </Childs>'
            '</CC>'
            '')
          ParentFont = False
          ScrollBars = ssBoth
          TabOrder = 0
          WordWrap = False
        end
      end
    end
    object Memo1: TMemo
      Left = 1
      Top = 1
      Width = 491
      Height = 483
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Courier New'
      Font.Style = []
      Lines.Strings = (
        'memo_clear();'
        ''
        'include "qwerty.pnp";'
        ''
        'memo_add('#39'param1 from include code: '#39' . param1);'
        ''
        '//=================================='
        '// '#1055#1088#1080#1086#1088#1080#1090#1077#1090' '#1086#1087#1077#1088#1072#1094#1080#1081
        ''
        '/*'
        ''
        '| 1 | []'
        '| 2 | - (unary), ~ (bitwise not)'
        '| 3 | ** (involution)'
        '| 4 | *, /, %, & (bitwise and)'
        '| 5 | +, -, ^ (bitwise xor), | (bitwise or), . (concatenate)'
        '| 6 | >> (bitwise shift right), << (bitwise shift left)'
        '| 7 | <, >, ==, !=, >=, <='
        '| 8 | ! (bool not)'
        '| 9 | && (bool and)'
        '|10 | || (bool or)'
        ''
        '*/'
        ''
        '//=================================='
        '// COMMENTS'
        ''
        '// '#1089#1090#1088#1086#1095#1085#1099#1081' '#1082#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
        ''
        '/*'
        '  '#1084#1085#1086#1075#1086#1089#1090#1088#1086#1095#1085#1099#1081' '#1082#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
        '  '#1084#1085#1086#1075#1086#1089#1090#1088#1086#1095#1085#1099#1081' '#1082#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
        '  '#1084#1085#1086#1075#1086#1089#1090#1088#1086#1095#1085#1099#1081' '#1082#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
        '*/'
        ''
        '//=================================='
        '// VARIABLES'
        ''
        'local = '#39#1083#1086#1082#1072#1083#1100#1085#1072#1103' '#1087#1077#1088#1077#1084#1077#1085#1085#1072#1103#39';'
        ''
        'memo_add('#39'local: '#39' . local);'
        ''
        '//-----------------'
        ''
        'global glob = "'#1075#1083#1086#1073#1072#1083#1100#1085#1072#1103' '#1087#1077#1088#1077#1084#1077#1085#1085#1072#1103'"; // '#1076#1086#1089#1090#1091#1087#1085#1072' '#1074#1077#1079#1076#1077
        ''
        'memo_add('#39'glob:'#39' . glob);'
        ''
        '//-----------------'
        '// '#1055#1088#1086#1073#1091#1077#1084' '#1080#1079#1084#1077#1085#1080#1090#1100' '#1079#1085#1072#1095#1077#1085#1080#1103' '#1091' glob '#1080' local'
        ''
        'function change_glob_and_local()'
        '{'
        '  glob = '#39#1085#1086#1074#1086#1077' '#1079#1085#1072#1095#1077#1085#1080#1077#39';'
        '  local = '#39#1085#1086#1074#1086#1077' '#1079#1085#1072#1095#1077#1085#1080#1077#39';'
        '}'
        ''
        'change_glob_and_local();'
        ''
        'memo_add('#39'local: '#39' . local);'
        'memo_add('#39'glob:'#39' . glob);'
        ''
        '//-----------------'
        ''
        '//n_init = "'#1074#1089#1077#1075#1076#1072' '#1088#1072#1074#1085#1072' '#1087#1091#1089#1090#1086#1090#1077' '#39#39' ('#1085#1077' null)";'
        ''
        'memo_add('#39#1085#1077' '#1080#1085#1080#1094#1080#1072#1083#1080#1079#1080#1088#1086#1074#1072#1085#1085#1072#1103' '#1087#1077#1088#1077#1084#1077#1085#1085#1072#1103': ['#39' . n_init . '#39']'#39');'
        ''
        '//=================================='
        '// CONCATENATE'
        ''
        'memo_add('#39#1082#1086#1085#1082#1072#1090#1077#1085#1072#1094#1080#1103' '#39' . '#39#1089#1090#1088#1086#1082#39');'
        ''
        '//=================================='
        '// TYPE VALUE'
        ''
        'digital = 123.123; // '#1055#1088#1086#1089#1090#1086' '#1094#1077#1083#1099#1077' '#1095#1080#1089#1083#1072' '#1085#1077' '#1087#1086#1076#1076#1077#1088#1078#1080#1074#1072#1102#1090#1089#1103
        ''
        'memo_add('#39#1095#1080#1089#1083#1086': '#39' . digital);'
        ''
        '//-----------------'
        ''
        'string = '#39#1058#1077#1082#1089#1090' '#1089#1090#1088#1086#1082#1080#39';'
        ''
        'memo_add('#39#1089#1090#1088#1086#1082#1072': '#39' . string);'
        ''
        '//-----------------'
        ''
        'bool = true;'
        ''
        'memo_add('#39#1083#1086#1075#1080#1095#1077#1089#1082#1080#1081' '#1090#1080#1087': '#39' . bool);'
        ''
        '//-----------------'
        ''
        'array = [1, 2, '#39'Hello'#39', False, ['#39'qwerty'#39', 555]];'
        ''
        'memo_add('#39#1084#1072#1089#1089#1080#1074': '#39' . array);'
        ''
        '//--------'
        ''
        '// '#1048#1085#1076#1077#1082#1089#1072#1094#1080#1103' '#1084#1072#1089#1089#1080#1074#1072' '#1085#1072#1095#1080#1085#1072#1077#1090#1089#1103' '#1089' '#1085#1091#1083#1103
        ''
        'memo_add('#39#1084#1072#1089#1089#1080#1074'[4]: '#39' . array[4]);'
        'memo_add('#39#1084#1072#1089#1089#1080#1074'[4][1]: '#39' . array[4][1]);'
        ''
        '//--------'
        ''
        'array[4] = '#39'New value'#39';'
        ''
        'memo_add('#39#1084#1072#1089#1089#1080#1074'[4]: '#39' . array[4]);'
        ''
        '//=================================='
        '// IF(...) { ... } ELSE { ... }'
        ''
        'f = false;'
        ''
        'if(! f) // '#39'!'#39' '#1083#1086#1075#1080#1095#1077#1089#1082#1086#1077' '#1086#1090#1088#1080#1094#1072#1085#1080#1077
        '{'
        '  memo_add('#39'if: its work'#39');'
        '}'
        ''
        '//-----------------'
        ''
        't = true;'
        ''
        'if(t == true)'
        '{'
        '  memo_add('#39'if: hello'#39');'
        '}'
        'else'
        '{'
        '  memo_add('#39'if: world'#39');'
        '}'
        ''
        '//-----------------'
        ''
        't1 = false;'
        ''
        'if (t1)'
        '  memo_add('#39'if: hello1'#39');'
        'else'
        '  memo_add('#39'if: world1'#39');'
        ''
        '//=================================='
        '// SWITCH(...) {CASE ...: { ... } ELSE { ... }}'
        ''
        'inp = 3;'
        ''
        'switch(inp)'
        '{'
        '  case 1: memo_add('#39'case: 1'#39');'
        '  case 2: memo_add('#39'case: 2'#39');'
        '  case 3: memo_add('#39'case: 3'#39');'
        '  else'
        '    memo_add('#39'case else'#39');'
        '}'
        ''
        '//-----------------'
        ''
        'inp_s = "'#1055#1088#1080#1074#1077#1090'";'
        ''
        'switch(inp_s)'
        '{'
        '  case '#39#1055#1088#1080#1074#1077#1090#39': memo_add('#39'case: '#1055#1088#1080#1074#1077#1090#39');'
        '  case '#39'Hello'#39' : memo_add('#39'case: Hello'#39');'
        '  case '#39'Alloha'#39': memo_add('#39'case: Alloha'#39');'
        '  else'
        '    memo_add('#39'case else'#39');'
        '}'
        ''
        '//=================================='
        '// FOR ... FROM ... TO ... DO { ... }'
        '// FOR ... IN ... DO { ... }'
        ''
        'for i from 2 to 5 do'
        '  memo_add('#39#1094#1080#1082#1083'(i): '#39' . i);'
        ''
        '//-----------------'
        ''
        'for n from 5 to 2 do'
        '  memo_add('#39#1094#1080#1082#1083'(n): '#39' . n);'
        ''
        '//-----------------'
        '// '#1087#1077#1088#1077#1073#1086#1088' '#1084#1072#1089#1089#1080#1074#1072' ('#1080#1090#1077#1088#1072#1090#1086#1088' '#1084#1072#1089#1089#1080#1074#1072')'
        ''
        'arr = [123, '#39'555'#39', true, [1, 2, 3]];'
        ''
        'for cell in arr do'
        '{'
        '  memo_add('#39#1103#1095#1077#1081#1082#1072' '#1084#1072#1089#1089#1080#1074#1072': '#39' . cell);'
        '}'
        ''
        '//=================================='
        '// WHILE ( ... ) { ... }'
        ''
        'k = 0;'
        ''
        'while (k <= 5)'
        '{'
        '  memo_add('#39'k:'#39' . k);'
        '  k = k + 1;'
        '}'
        ''
        '//=================================='
        '// '#1050#1086#1085#1089#1090#1088#1091#1082#1094#1080#1080' '#39'Break'#39' '#1080' '#39'Continue'#39
        ''
        'ar = [1,2,3,4,5,6,7,8,9];'
        ''
        'for cell in ar do'
        '{'
        '  if(cell == 5) continue;'
        ''
        '  if(cell == 7) break;'
        ''
        '  memo_add('#39'cell: '#39' . cell);'
        '}'
        ''
        '//-----------------'
        ''
        'for m from 0 to 10 do'
        '{'
        '  if (m == 3) continue;'
        ''
        '  if (m > 9) break;'
        ''
        '  memo_add('#39'm: '#39' . m);'
        '}'
        ''
        '//-----------------'
        ''
        'h = 0;'
        ''
        'while( h != 10)'
        '{'
        '  if (h == 3)'
        '  {'
        '    h = h + 1;'
        ''
        '    continue;'
        '  }'
        ''
        '  if (h > 7) break;'
        ''
        '  memo_add('#39'h: '#39' . h);'
        ''
        '  h = h + 1;'
        '}'
        ''
        '//=================================='
        '// FUNCTION'
        ''
        'function test_func(ref param1, param2, ref param3)'
        '{'
        '  param1 = '#39#1092#1091#1085#1082#1094#1080#1103' '#39';'
        '  param2 = '#39#1090#1077#1089#1090'_'#39';'
        '  param3 = '#39#1092#1091#1085#1082'()'#39';'
        ''
        '  return (param1 . param2 . param3);'
        '}'
        ''
        '// '#1082#1083#1102#1095#1077#1074#1086#1077' '#1089#1083#1086#1074#1086' '#39'ref'#39' '#1087#1077#1088#1077#1076' '#1087#1072#1088#1072#1084#1077#1090#1088#1086#1084', '
        '// '#1075#1086#1074#1086#1088#1080#1090' '#1086' '#1090#1086#1084' '#1095#1090#1086' '#1076#1072#1085#1085#1099#1081' '#1087#1072#1088#1072#1084#1077#1090#1088' '
        '// '#1087#1077#1088#1077#1076#1072#1077#1090#1089#1103' '#1087#1086' '#1089#1089#1099#1083#1082#1077' '#1080' '#1077#1075#1086' '#1084#1086#1078#1085#1086' '#1080#1079#1084#1077#1085#1080#1090#1100' '#1074' '#1090#1077#1083#1077' '#1092#1091#1085#1082#1094#1080#1080
        '// '#1080' '#1088#1072#1073#1086#1090#1072#1090#1100' '#1089' '#1085#1086#1074#1099#1084' '#1079#1085#1072#1095#1077#1085#1080#1077#1084' '#1074#1085#1077' '#1092#1091#1085#1082#1094#1080#1080
        ''
        'p1 = '#39'function '#39';'
        'p2 = '#39'test_'#39';'
        'p3 = '#39'func()'#39';'
        ''
        'memo_add('#39'p1: '#39' . p1);'
        'memo_add('#39'p2: '#39' . p2);'
        'memo_add('#39'p3: '#39' . p3);'
        ''
        'memo_add('#39'return: '#39' . test_func(p1, p2, p3));'
        ''
        'memo_add('#39'p1: '#39' . p1);'
        'memo_add('#39'p2: '#39' . p2);'
        'memo_add('#39'p3: '#39' . p3);'
        ''
        '//=================================='
        '// INTERNAL FUNCTION'
        ''
        '// memo_clear();    // '#1054#1095#1080#1089#1090#1080#1090#1100' '#1082#1086#1085#1089#1086#1083#1100
        '// memo_add(param); // '#1042#1099#1074#1077#1089#1090#1080' '#1089#1090#1088#1086#1082#1091' '#1074' '#1082#1086#1085#1089#1086#1083#1100
        '// get_type(param): string; // '#1042#1099#1074#1086#1076#1080#1090' '#1090#1080#1087' '#1091#1082#1072#1079#1072#1085#1085#1086#1075#1086' '#1087#1072#1088#1072#1084#1077#1090#1088#1072
        
          '// set_length(array, cell_count): Boolean; // '#1048#1085#1080#1094#1080#1072#1083#1080#1079#1080#1088#1091#1077#1090' '#1084#1072#1089 +
          #1089#1080#1074' '#1079#1072#1076#1072#1085#1085#1086#1081' '#1076#1083#1080#1085#1099', '#1084#1072#1089#1089#1080#1074' '#1087#1091#1089#1090#1099#1093' '#1079#1085#1072#1095#1077#1085#1080#1081'. '#1058#1072#1082' '#1078#1077' '#1084#1086#1078#1085#1086' '#1080#1079#1084#1077#1085#1080#1090 +
          #1100' '#1088#1072#1079#1084#1077#1088' '#1091#1078#1077' '#1089#1091#1097#1077#1089#1090#1074#1091#1102#1097#1077#1075#1086' '#1084#1072#1089#1089#1080#1074#1072' '
        ''
        '//-----------------'
        '// '#1055#1088#1080#1084#1077#1088
        ''
        'ta = [1, 23.95, True, '#39'Hello'#39', [1.2 , 7]];'
        ''
        'for cell in ta do'
        '  memo_add('#39'cell: '#39' . cell . '#39' ['#39' . get_type(cell) . '#39']'#39');'
        ''
        
          'memo_add('#39'not_init_variable[type]: '#39' . get_type(not_init_variabl' +
          'e)); // '#1074#1099#1074#1086#1076' '#39'none'#39
        '  '
        '//-----------------'
        ''
        
          'set_length(new_array, 8); // '#1048#1085#1080#1094#1080#1072#1083#1080#1079#1080#1088#1091#1077#1090' '#1084#1072#1089#1089#1080#1074' '#1079#1072#1076#1072#1085#1085#1086#1081' '#1076#1083#1080#1085 +
          #1099', '#1084#1072#1089#1089#1080#1074' '#1087#1091#1089#1090#1099#1093' '#1079#1085#1072#1095#1077#1085#1080#1081
        ''
        'new_array_count = count(new_array);'
        ''
        'memo_add('#39'new_array_count: '#39' . new_array_count);'
        'memo_add('#39'new_array: '#39' . new_array);'
        ''
        'for i from 0 to new_array_count-1 do'
        '  new_array[i] = '#39'cell #'#39' . i;'
        ''
        'memo_add('#39'new_array: '#39' . new_array);'
        ''
        
          'set_length(new_array, 5); // '#1058#1072#1082' '#1078#1077' '#1084#1086#1078#1085#1086' '#1080#1079#1084#1077#1085#1080#1090#1100' '#1088#1072#1079#1084#1077#1088' '#1084#1072#1089#1089#1080#1074 +
          #1072
        ''
        'memo_add('#39'new_array: '#39' . new_array);'
        ''
        '//=================================='
        '// SCRIPT EVENT AND SYSTEM CALL EVENT'
        ''
        
          '// '#1057#1086#1073#1099#1090#1080#1103' '#1088#1077#1072#1083#1080#1079#1086#1074#1072#1085#1085#1099#1077' '#1074' '#1089#1082#1088#1080#1087#1090#1077', '#1085#1086' '#1074#1099#1079#1099#1074#1072#1077#1084#1099#1077' '#1080#1079' '#1080#1085#1090#1077#1088#1087#1088#1077#1090#1072#1090 +
          #1086#1088#1072
        '// "Compil" -> "Run" -> Click Button '#39'Event Call'#39
        ''
        'function test_event(ref aparam)'
        '{'
        '  memo_add(aparam . '#39' Hello Pronin'#39');'
        ''
        '  aparam = '#39'Nice Day'#39';'
        ''
        '  return '#39'BINGO'#39';'
        '}')
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 1
      WantTabs = True
    end
  end
  object ActionList1: TActionList
    Left = 768
    Top = 80
    object acSelectAllXml: TAction
      Caption = 'acSelectAllXml'
      ShortCut = 16449
      OnExecute = acSelectAllXmlExecute
    end
  end
end
