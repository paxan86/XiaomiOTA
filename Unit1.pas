unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Samples.Spin,  Vcl.StdCtrls,
  Vcl.ComCtrls , inifiles, ShellApi, IdHTTP, unit2, System.Threading, System.SyncObjs, System.Types, ClipBrd;
//
  const
  const_MYMESSAGE = WM_USER + 100;

type
  TForm1 = class(TForm)
    ListBoxLINKS: TListBox;
    Memo1: TMemo;
    Panel1: TPanel;
    LabelStatus: TLabel;
    ProgressBar1: TProgressBar;
    Panel2: TPanel;
    LabelMy_Build: TLabel;
    LabelDevice: TLabel;
    LabelPlatform_ID: TLabel;
    ComboBoxDevice: TComboBox;
    ButtonFIND: TButton;
    SpinEditPlatform_ID: TSpinEdit;
    SpinEditMy_Build: TSpinEdit;
    LabelEditRange: TLabeledEdit;
    Panel3: TPanel;
    LabelEditTO_Obr: TLabeledEdit;
    LabelEditDO_Obr: TLabeledEdit;
    LabelEditMyBuild_Obr: TLabeledEdit;
    ButtonObrSearch: TButton;
    ButtonSearchFULLOTA: TButton;
    ButtonClear: TButton;
    Button2: TButton;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ThreadTerminate(Sender: TObject);
    procedure ButtonFINDClick(Sender: TObject);
    procedure ListBoxLINKSDblClick(Sender: TObject);
    procedure ListBoxLINKSMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button1Click(Sender: TObject);
    function IsZip (Generated_build: Integer): boolean;
    procedure ButtonObrSearchClick(Sender: TObject);
    procedure ButtonSearchFULLOTAClick(Sender: TObject);
    procedure LabelEditTO_ObrKeyPress(Sender: TObject; var Key: Char);
    procedure LabelEditDO_ObrKeyPress(Sender: TObject; var Key: Char);
    procedure LabelEditMyBuild_ObrKeyPress(Sender: TObject; var Key: Char);
    procedure LabelEditRangeKeyPress(Sender: TObject; var Key: Char);
    procedure SpinEditPlatform_IDKeyPress(Sender: TObject; var Key: Char);
    procedure SpinEditMy_BuildKeyPress(Sender: TObject; var Key: Char);
    procedure LabelStatusClick(Sender: TObject);
    procedure ButtonClearClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure MyMessage(var Msg: TMessage); message const_MYMESSAGE;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
   MaxCountThread , CountThread : Byte;
 pathINI, Version_Android : string;
 IniFile : TIniFile;
 ClipBoard1 :TClipboard;


implementation

{$R *.dfm}

procedure TForm1.ThreadTerminate(Sender: TObject);
begin
 Inc(countThread);
 ProgressBar1.Position := CountThread;
 if CountThread = MaxCountThread then
 begin
   form1.ButtonFIND.Enabled := True;
   form1.ButtonSearchFULLOTA.Enabled := True;
   form1.ButtonObrSearch.Enabled := True;
   form1.LabelStatus.Caption:= '���������: ������';
   CountThread := 0;
   if ListBoxLINKS.Items.Count = 0 then
     ListBoxLINKS.Items.Append('���������� OTA �� �������!');
     LabelEditMyBuild_Obr.Enabled := True;
 end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  total, my_build, max: integer;
begin
form1.ListBoxLINKS.Clear;
   total := 0;
   max := StrToInt(LabelEditRange.Text);
    //ShowMessage('3');
    my_build := StrToInt(form1.SpinEditMy_Build.Text) + 1;
   max := max + my_build;
   TParallel.For(my_build, max, procedure(i: Integer)
      begin
     // ShowMessage('2');
       //  IsZip           WParam(PChar(Value))

         if IsZip(i) then
            TInterlocked.Increment(total);
          //  IniFile := TIniFile.Create(pathINI);
          //  IniFile.WriteString('LOG', 'CountFor', IntToStr(i));
           // IniFile.Free;
      end
  );
   ShowMessage('���������� ��������� Zip''��: ' + IntToStr(total));
end;

procedure TForm1.ButtonObrSearchClick(Sender: TObject);
 var
  Threads: array of TMyThread;
  i: Byte;
  st, en, en2: integer;
  My_build_threadOUT : string;
  IdHTTP: TIdHTTP;
begin

if (length(LabelEditTO_Obr.Text)=0) or (length(LabelEditDO_Obr.text)=0)  or (length(LabelEditMyBuild_Obr.text)=0) then
begin
  ShowMessage('������� �� ��� ������!');
  Exit;
end;
  IdHTTP := TIdHTTP.Create;
  form1.ButtonObrSearch.Enabled := false;
  form1.ButtonSearchFULLOTA.Enabled := false;
  form1.ButtonFIND.Enabled := false;
  //memo1.Clear;
  //ListBoxLINKS.Clear;
  MaxCountThread := 20;   //������������ ����� �������      20
  ProgressBar1.max := MaxCountThread;
  SetLength(Threads, MaxCountThread);
  st:=0;
  en:=Round((StrToInt(LabelEditDO_Obr.Text) - StrToInt(LabelEditTO_Obr.Text)) / MaxCountThread);  //920 -900 1
  if en = 0 then
  begin
    en := StrToInt(LabelEditDO_Obr.Text) - StrToInt(LabelEditTO_Obr.Text);
    MaxCountThread := 1;
    SetLength(Threads, MaxCountThread);
    ProgressBar1.max := MaxCountThread;
  end;
 // if (StrToInt(LabelEditDO_Obr.Text) - StrToInt(LabelEditTO_Obr.Text)) < MaxCountThread * 2 then
 // begin

//  end;
  en2:=en;       //1
  My_build_threadOUT := LabelEditMyBuild_Obr.Text;

  try
    IdHTTP.Head('http://ya.ru');
  except
    on pe: EIdHTTPProtocolException do
    begin
        if pe.ErrorCode <> 302 then
        begin
          LabelStatus.Caption:= '���������: ������ ����';
          exit;
        end;
    end;
      on e: Exception do
  end;

  Version_Android:='6.0.1.';

  if Form1.ComboBoxDevice.ItemIndex = 10 then
  Version_Android:='4.4.4.';

  if Form1.ComboBoxDevice.ItemIndex = 15 then
  Version_Android:='5.1.';

  for i := 0 to MaxCountThread - 1 do
  begin
    Threads[i] := TMyThread.Create(True);
    Threads[i].StartIterationOUT:=st;
    Threads[i].EndIterationOUT:=en2;
    //form1.ListBoxLINKS.Items.Add(IntToStr(st)+ '   ' + IntToStr(en2));
    Threads[i].My_build_threadOUT := My_build_threadOUT;
    //Threads[i].priority := tpnormal;
    Threads[i].M_OUT := 2;
    Threads[i].StartInterationOUT := StrToInt(LabelEditTO_Obr.Text);
    st:= en2 + 1 ;
    en2:=en2 + en;
    Threads[i].OnTerminate := ThreadTerminate;
    form1.LabelStatus.Caption:= '���������: �����!';
    Threads[i].Start;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
{$J+}
const a : BOOL = false;
{$J-}
begin
if a = false then
begin
  Form1.Width := 800;
  a := true;
end
else
begin
  Form1.Width := 473;
  a := false;
end;
end;

procedure TForm1.ButtonClearClick(Sender: TObject);
begin
SpinEditMy_Build.Text := '';
SpinEditPlatform_ID.text := '';
LabelEditRange.text := '';
memo1.Clear;
ListBoxLINKS.Clear;
LabelStatus.Caption := '���������: ����� � ������!';
end;

procedure TForm1.ButtonFINDClick(Sender: TObject);
 var
  Threads: array of TMyThread;
  i: Byte;
  st, en, en2 : integer;
  My_build_threadOUT: string;
  IdHTTP: TIdHTTP;
begin
if (length(SpinEditMy_Build.Text)=0) or (length(SpinEditPlatform_ID.text)=0)  or (length(LabelEditRange.text)=0) then
begin
  ShowMessage('������� �� ��� ������!');
  Exit;
end;

  IdHTTP := TIdHTTP.Create;
  form1.ButtonFIND.Enabled := false;
  form1.ButtonObrSearch.Enabled := false;
  form1.ButtonSearchFULLOTA.Enabled := false;
  memo1.Clear;
  ListBoxLINKS.Clear;
  MaxCountThread := 20;   //������������ ����� �������      20
  ProgressBar1.max := MaxCountThread;
  SetLength(Threads, MaxCountThread);
  st:=0;
  en:=Round(StrToInt(LabelEditRange.Text) / MaxCountThread);
  if en = 0 then
  begin
    en := StrToInt(LabelEditRange.Text);
    MaxCountThread := 1;
    SetLength(Threads, MaxCountThread);
    ProgressBar1.max := MaxCountThread;
  end;
  en2:=1 * en;
  My_build_threadOUT := SpinEditMy_Build.Text;
  try
    IdHTTP.Head('http://ya.ru');
  except
    on pe: EIdHTTPProtocolException do
    begin
        if (pe.ErrorCode <> 302) or (pe.ErrorCode = 404) then   /////////////////�� ��������
        begin
          LabelStatus.Caption:= '���������: ������ ����';
          exit;
        end;
    end;
      on e: Exception do
  end;
  Version_Android:='6.0.1.';

  if Form1.ComboBoxDevice.ItemIndex = 10 then
  Version_Android:='4.4.4.';

  if Form1.ComboBoxDevice.ItemIndex = 15 then
  Version_Android:='5.1.';

  for i := 0 to MaxCountThread - 1 do
  begin
    Threads[i] := TMyThread.Create(True);
    Threads[i].StartIterationOUT:=st;
    Threads[i].EndIterationOUT:=en2;
    Threads[i].M_OUT :=  1;
    Threads[i].My_build_threadOUT := My_build_threadOUT;
    //Threads[i].priority := tpnormal;
    st:= en2 + 1 ;
    en2:=en2 + en;
    Threads[i].OnTerminate := ThreadTerminate;
    form1.LabelStatus.Caption:= '���������: �����!';
    Threads[i].Start;
  end;
end;

procedure TForm1.ButtonSearchFULLOTAClick(Sender: TObject);
 var
  Threads: array of TMyThread;
  i: Byte;
  st, en, en2: integer;
  My_build_threadOUT : string;
  IdHTTP: TIdHTTP;
begin
if (length(LabelEditTO_Obr.Text)=0) or (length(LabelEditDO_Obr.text)=0)  then
begin
  ShowMessage('������� �� ��� ������!');
  Exit;
end;
  LabelEditMyBuild_Obr.Enabled := False;
  IdHTTP := TIdHTTP.Create;
  form1.ButtonSearchFULLOTA.Enabled := false;
  form1.ButtonObrSearch.Enabled := false;
  form1.ButtonFIND.Enabled := false;
  //memo1.Clear;
  //ListBoxLINKS.Clear;
  MaxCountThread := 20;   //������������ ����� �������      20
  ProgressBar1.max := MaxCountThread;
  SetLength(Threads, MaxCountThread);
  //st:=0;
  st:=StrToInt(LabelEditTO_Obr.Text);
  en:=Round((StrToInt(LabelEditDO_Obr.Text) - StrToInt(LabelEditTO_Obr.Text)) / MaxCountThread);  //920 -900 1
  if en = 0 then
  begin
    en := StrToInt(LabelEditDO_Obr.Text) - StrToInt(LabelEditTO_Obr.Text);
    MaxCountThread := 1;
    SetLength(Threads, MaxCountThread);
    ProgressBar1.max := MaxCountThread;
  end;
  en2:=st + en;       //1
  My_build_threadOUT := LabelEditMyBuild_Obr.Text;

  try
    IdHTTP.Head('http://ya.ru');
  except
    on pe: EIdHTTPProtocolException do
    begin
        if pe.ErrorCode <> 302 then
        begin
          LabelStatus.Caption:= '���������: ������ ����';
          exit;
        end;
    end;
      on e: Exception do
  end;

  Version_Android:='6.0.1.';

  if Form1.ComboBoxDevice.ItemIndex = 10 then
  Version_Android:='4.4.4.';

  if Form1.ComboBoxDevice.ItemIndex = 15 then
  Version_Android:='5.1.';

  for i := 0 to MaxCountThread - 1 do
  begin
    Threads[i] := TMyThread.Create(True);
    Threads[i].StartIterationOUT:=st;
    Threads[i].EndIterationOUT:=en2;
                 //form1.ListBoxLINKS.Items.Add(IntToStr(st)+ '   ' + IntToStr(en2));
                 //Threads[i].My_build_threadOUT := My_build_threadOUT;
    //Threads[i].priority := tpnormal;
    Threads[i].M_OUT := 3;
    //Threads[i].StartInterationOUT := StrToInt(LabelEditTO_Obr.Text);
    st:= st + en ;
    en2:=en2 + en;
    Threads[i].OnTerminate := ThreadTerminate;
    form1.LabelStatus.Caption:= '���������: �����!';
    Threads[i].Start;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
//ClipBoard1:=TClipboard.Create;

  CountThread := 0;
  pathINI:=extractfilepath(application.ExeName)+'\SET.ini';
  if FileExists(pathINI) then //��������� ���� �� ���� INI
   begin
    IniFile := TIniFile.Create(pathINI);
     SpinEditMy_Build.Text := IniFile.ReadString('Param', 'My_Build', '936');
     LabelEditRange.Text := IniFile.readString('Param', 'Range', '300');
     ComboBoxDevice.ItemIndex := ComboBoxDevice.Items.IndexOf(IniFile.readString('Param', 'Device', 'xmen'));
    if ComboBoxDevice.ItemIndex = -1 then //���� � ��� ����� � �������
       ComboBoxDevice.ItemIndex := 29;

     SpinEditPlatform_ID.Text := IniFile.readString('Param', 'Platform_ID', '634');
    IniFile.Free;
    form1.LabelStatus.Caption:= '���������: SET.ini ���������!';
   end
    else
      form1.LabelStatus.Caption:= 'SET.ini �� ������!';

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
    //������� ������ �� ������ INI
  IniFile := TIniFile.Create(pathINI);
  IniFile.WriteString('Param', 'My_Build', SpinEditMy_Build.Text);
  IniFile.WriteString('Param', 'Range', LabelEditRange.Text);
  IniFile.WriteString('Param', 'Device', ComboBoxDevice.Text);
  IniFile.WriteString('Param', 'Platform_ID', SpinEditPlatform_ID.Text);
  IniFile.Free;
end;

function TForm1.IsZip(Generated_build: Integer): boolean;
   var
  IdHTTP: TIdHTTP;
  Platform_id, Device, My_build, Build_Date, Content_Length, ff: String;
begin
  //PostMessage(form1.handle, WM_SETTEXT, Length(Text), Integer(@Text[1]));
  //PostMessage(Handle, WM_SETCAPTION, 0, LParam(PChar('My new caption')));

  IsZip := false;
  IdHTTP := TIdHTTP.Create;
  platform_id := '634';//form1.SpinEditPlatform_ID.Text;
  Device := 'xmen';//form1.ComboBoxDevice.Items[form1.ComboBoxDevice.ItemIndex];
  My_build := '936';//form1.SpinEditMy_Build.Text;;

  ff := Format('%s%s%s%s%s%s%s%s%s%s%s%s%s', ['http://ota.cdn.pandora.xiaomi.com/rom/', Platform_id, '/', Device, '/user/6.0.1.', IntToStr(Generated_build), '/6.0.1.', My_build, '/package-6.0.1.', My_build, '-6.0.1.', IntToStr(Generated_build), '.zip']);
  //showmessage(ff);
  try IdHTTP.Head(Format('%s%s%s%s%s%s%s%s%s%s%s%s%s', ['http://ota.cdn.pandora.xiaomi.com/rom/', Platform_id, '/', Device, '/user/6.0.1.', IntToStr(Generated_build), '/6.0.1.', My_build, '/package-6.0.1.', My_build, '-6.0.1.', IntToStr(Generated_build), '.zip']));
  except
   // on pe: EIdHTTPProtocolException do  Exit;//ShowMessage(pe.Message);//   //ShowMessage(IntToStr(pe.ErrorCode));
  //  on e: Exception do  Exit;//ShowMessage(e.Message);//continue;

  end;
  if idhttp.Response.LastModified > 0 then
  begin
    IsZip := true;
    DateTimeToString(Build_Date, 'dd/mm/yyyy', idhttp.Response.LastModified);
    Content_Length := IntToStr(Round(idhttp.Response.ContentLength /1024 /1024));
    PostMessage(form1.Handle, const_MYMESSAGE, 0, Generated_build);
  end;
  ///Synchronize(syn(Generated_build));
//end;

  IdHTTP.Free;
end;

procedure TForm1.LabelEditDO_ObrKeyPress(Sender: TObject; var Key: Char);
begin
case Key of

'0'..'9': ; // �����

#8 : ; // ������� <Back Space>

// ��������� ������� � ���������

else Key :=Chr(0); // ������ �� ����������

end;
end;

procedure TForm1.LabelEditMyBuild_ObrKeyPress(Sender: TObject; var Key: Char);
begin
case Key of

'0'..'9': ; // �����

#8 : ; // ������� <Back Space>

// ��������� ������� � ���������

else Key :=Chr(0); // ������ �� ����������

end;
end;

procedure TForm1.LabelEditRangeKeyPress(Sender: TObject; var Key: Char);
begin
case Key of

'0'..'9': ; // �����

#8 : ; // ������� <Back Space>

// ��������� ������� � ���������

else Key :=Chr(0); // ������ �� ����������

end;
end;

procedure TForm1.LabelEditTO_ObrKeyPress(Sender: TObject; var Key: Char);
begin
case Key of

'0'..'9': ; // �����

#8 : ; // ������� <Back Space>

// ��������� ������� � ���������

else Key :=Chr(0); // ������ �� ����������

end;
end;

procedure TForm1.LabelStatusClick(Sender: TObject);
{$J+}
const a : BOOL = false;
{$J-}
begin
if a = false then
begin
  Form1.Width := 800;
  a := true;
end
else
begin
  Form1.Width := 473;
  a := false;
end;
end;

procedure TForm1.ListBoxLINKSDblClick(Sender: TObject);
begin
ShellExecute( Handle, 'open', PChar(Memo1.Lines[ListBoxLINKS.ItemIndex]), nil, nil, SW_NORMAL );
end;

procedure TForm1.ListBoxLINKSMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var H: string;
begin
  if Button = mbRight then
  begin
    ListBoxLINKS.ItemIndex := ListBoxLINKS.ItemAtPos(Point(X, Y), False);
    H := Memo1.Lines[ListBoxLINKS.ItemIndex];
    //if ClipBoard.FormatCount=4 then
    //begin
     //ClipBoard1.Open;
     //                  -ClipBoard1.SetTextBuf(PChar(H));
   //  ClipBoard1.Close;
    //end;
    Clipboard.AsText := H;
  end;
end;


procedure TForm1.MyMessage(var Msg: TMessage);
var
Platform_id, Device, My_build: String;
begin
//MessageDlg('She turned me into a newt!'+IntToStr(Msg.LParamLo),mtInformation, [mbOk], 0);
platform_id := form1.SpinEditPlatform_ID.Text;
  Device := form1.ComboBoxDevice.Items[form1.ComboBoxDevice.ItemIndex];
  My_build := form1.SpinEditMy_Build.Text;;
  form1.Memo1.Lines.Append(Format('%s%s%s%s%s%s%s%s%s%s%s%s%s', ['http://ota.cdn.pandora.xiaomi.com/rom/', Platform_id, '/', Device, '/user/6.0.1.', IntToStr(Msg.LParam), '/6.0.1.', My_build, '/package-6.0.1.', My_build, '-6.0.1.', IntToStr(Msg.LParam), '.zip']));
  //form1.ListBoxLINKS.Items.Add(Format('%s%s%s%s%s%s%s%s', ['package-6.0.1.', My_build, '-6.0.1.', IntToStr(Msg.LParam), '.zip ', Content_Length, '�� �� ', build_date]));
  form1.ListBoxLINKS.Items.Add(Format('%s%s%s%s%s', ['package-6.0.1.', My_build, '-6.0.1.', IntToStr(Msg.LParam), '.zip ']));
//form1.ListBoxLINKS.Items.Append(IntToStr(Msg.LParam));
end;

procedure TForm1.SpinEditMy_BuildKeyPress(Sender: TObject; var Key: Char);
begin
case Key of

'0'..'9': ; // �����

#8 : ; // ������� <Back Space>

// ��������� ������� � ���������

else Key :=Chr(0); // ������ �� ����������

end;
end;

procedure TForm1.SpinEditPlatform_IDKeyPress(Sender: TObject; var Key: Char);
begin
case Key of

'0'..'9': ; // �����

#8 : ; // ������� <Back Space>

// ��������� ������� � ���������

else Key :=Chr(0); // ������ �� ����������

end;
end;

end.
