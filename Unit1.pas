unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Samples.Spin,  Vcl.StdCtrls,
  Vcl.ComCtrls , inifiles, ShellApi, IdHTTP, unit2, System.Threading, System.SyncObjs,
  System.Types, ClipBrd, Vcl.Imaging.pngimage, cm_LSVGauges;
//
  const
  const_MYMESSAGE = WM_USER + 100;

type
  TForm1 = class(TForm)
    ListBoxLINKS: TListBox;
    Memo1: TMemo;
    Panel1: TPanel;
    LabelStatus: TLabel;
    Button1: TButton;
    Image1: TImage;
    LSVGauge14: TLSVGauge;
    PageControl1: TPageControl;
    Main: TTabSheet;
    Обратный: TTabSheet;
    ВсеOTA: TTabSheet;
    ButtonFIND: TButton;
    ComboBoxDevice: TComboBox;
    LabelDevice: TLabel;
    LabelEditRange: TLabeledEdit;
    LabelMy_Build: TLabel;
    LabelPlatform_ID: TLabel;
    SpinEditMy_Build: TSpinEdit;
    SpinEditPlatform_ID: TSpinEdit;
    ButtonObrSearch: TButton;
    LabelEditMyBuild_Obr: TLabeledEdit;
    LabelEditDO_Obr: TLabeledEdit;
    LabelEditTO_Obr: TLabeledEdit;
    ButtonSearchFULLOTA: TButton;
    Button2: TButton;
    ButtonClear: TButton;
    SpinEditTO_ALL: TSpinEdit;
    SpinEditDO_ALL: TSpinEdit;
    LabelTO_ALL: TLabel;
    LabelDO_ALL: TLabel;
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
    procedure ListBoxLINKSDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }
  protected
    procedure MyMessage(var Msg: TMessage); message const_MYMESSAGE;
  public
    { Public declarations }
    Procedure PaintImage(List1 :TListBox; Control: TWinControl; Index: Integer; Rect: TRect);
  end;

var
  Form1: TForm1;
  MaxCountThread , CountThread, Mode : Byte;
  pathINI, Version_Android : string;
  IniFile : TIniFile;
  ClipBoard1 :TClipboard;

implementation

{$R *.dfm}



procedure qSort(var A: Array of Integer; min, max: Integer);
var i, j, supp, tmp : Integer;
tmp2, tmp3 : string;
begin
form1.ListBoxLINKS.Items.BeginUpdate;
form1.Memo1.Lines.BeginUpdate;
supp:=A[max-((max-min) div 2)];
//supp2 :=  form1.ListBoxLINKS.Items[max-((max-min) div 2)];
i:=min; j:=max;
while i<j do
  begin
    while A[i]<supp do i:=i+1;
    while A[j]>supp do j:=j-1;
    if i<=j then
      begin
        tmp:=A[i];
        tmp2:=form1.ListBoxLINKS.Items[i];
        tmp3:=form1.Memo1.Lines[i];
        A[i]:=A[j];
        form1.ListBoxLINKS.Items[i]:=form1.ListBoxLINKS.Items[j];
        form1.Memo1.Lines[i]:=form1.Memo1.Lines[j];
        A[j]:=tmp;
        form1.ListBoxLINKS.Items[j]:=tmp2;
        form1.Memo1.Lines[j]:=tmp3;
        i:=i+1;
        j:=j-1;
      end;
  end;
if min<j then qSort(A, min, j);
if i<max then qSort(A, i, max);
form1.ListBoxLINKS.Items.EndUpdate;
form1.Memo1.Lines.EndUpdate;
end;


function SearchString(const FindStr, SourceString: string; Num: Integer):
  Integer;
var
  FirstSym: PChar; //Ссылка на первый символ

  function MyPos(const FindStr, SourceString: PChar; Num: Integer): PChar;
  begin
    Result := AnsiStrPos(SourceString, FindStr);
      //Поиск вхождения подстроки в строку
    if (Result = nil) then
      Exit; //Подстрока не найдена
    Inc(Result); //Смещаем указатель на следующий символ
    if Num = 1 then
      Exit; //Если нужно первое вхождение - заканчиваем
    if num > 1 then
      Result := MyPos(FindStr, Result, num - 1);
    //Рекурсивный поиск следующего вхождения
  end;

begin
  FirstSym := PChar(SourceString);
  //Присваиваем адрес первого символа исходной строки
  Result := MyPos(PChar(FindStr), PChar(SourceString), Num) - FirstSym;
  //Номер позиции в строке
  if Result < 0 then
    Result := 0; //Возвращаем номер позиции
end;


procedure TForm1.ThreadTerminate(Sender: TObject);
var
  n1, n2, nResult, h  : Integer;
  StrF: string;
  t: array of integer;
begin
 Inc(countThread);
 Form1.LSVGauge14.Progress:=CountThread;
 if CountThread = MaxCountThread then
 begin
   form1.ButtonFIND.Enabled := True;
   form1.ButtonSearchFULLOTA.Enabled := True;
   form1.ButtonObrSearch.Enabled := True;
   form1.LabelStatus.Caption:= 'Состояние: Готово';
   CountThread := 0;


 //  ListBoxLINKS.Items.Append('1:' + IntToStr(n1) + '  2:' + IntToStr(n2) + '  3:' + nResult);
   if ListBoxLINKS.Items.Count = 0 then
     ListBoxLINKS.Items.Append('Обновления OTA не найдены!');
     LabelEditMyBuild_Obr.Enabled := True;

   SetLength(t, ListBoxLINKS.Items.Count);
   if (Mode = 1) or (Mode = 2) then
       for h := 0 to ListBoxLINKS.Items.Count - 1 do
         begin
            StrF := Version_Android;
            n1 := SearchString(StrF, ListBoxLINKS.Items[h], 2) + 6;
            StrF := '.zip';
            n2 := SearchString(StrF, ListBoxLINKS.Items[h], 1);
            TryStrToInt(copy(ListBoxLINKS.Items[h], n1, n2 - n1), nResult);
            t[h] := nResult;
         end;

   if Mode = 3 then
     for h := 0 to ListBoxLINKS.Items.Count - 1 do
         begin
            StrF := Version_Android;
            n1 := SearchString(StrF, ListBoxLINKS.Items[h], 1) + 6;
            StrF := ' ';
            n2 := SearchString(StrF, ListBoxLINKS.Items[h], 1);
            TryStrToInt(copy(ListBoxLINKS.Items[h], n1, n2 - n1), nResult);
            t[h] := nResult;
         end;
        qSort(t, 0, ListBoxLINKS.Items.Count - 1);
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
   ShowMessage('Количество найденных Zip''ов: ' + IntToStr(total));
end;

procedure TForm1.ButtonObrSearchClick(Sender: TObject);
 var
  Threads: array of TMyThread;
  i: Byte;
  st, en, en2: integer;
  My_build_threadOUT : string;
  IdHTTP: TIdHTTP;
begin
memo1.Clear;
ListBoxLINKS.Clear;
LSVGauge14.progress:= 1;
if (length(LabelEditTO_Obr.Text)=0) or (length(LabelEditDO_Obr.text)=0)  or (length(LabelEditMyBuild_Obr.text)=0) then
begin
  ShowMessage('Введены не все данные!');
  Exit;
end;
  IdHTTP := TIdHTTP.Create;
  form1.ButtonObrSearch.Enabled := false;
  form1.ButtonSearchFULLOTA.Enabled := false;
  form1.ButtonFIND.Enabled := false;
  //memo1.Clear;
  //ListBoxLINKS.Clear;
  MaxCountThread := 20;   //максимальное число потоков      20
  LSVGauge14.MaxValue:= MaxCountThread;
  SetLength(Threads, MaxCountThread);
  st:=0;
  en:=Round((StrToInt(LabelEditDO_Obr.Text) - StrToInt(LabelEditTO_Obr.Text)) / MaxCountThread);  //920 -900 1
  if en = 0 then
  begin
    en := StrToInt(LabelEditDO_Obr.Text) - StrToInt(LabelEditTO_Obr.Text);
    MaxCountThread := 1;
    SetLength(Threads, MaxCountThread);
    LSVGauge14.MaxValue:= MaxCountThread;
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
          LabelStatus.Caption:= 'Состояние: Ошибка сети';
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
  Mode := 2;
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
    form1.LabelStatus.Caption:= 'Состояние: ПОИСК!';
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
  Form1.Width := 785;
  a := true;
end
else
begin
  Form1.Width := 514;
  a := false;
end;
end;

procedure TForm1.ButtonClearClick(Sender: TObject);
begin
//SpinEditMy_Build.Text := '';
//SpinEditPlatform_ID.text := '';
//LabelEditRange.text := '';
memo1.Clear;
ListBoxLINKS.Clear;
//LabelStatus.Caption := 'Состояние: Готов к работе!';
//ButtonFIND.Enabled := True;
//ButtonObrSearch.Enabled := True;
//ButtonSearchFULLOTA.Enabled := True;
end;

procedure TForm1.ButtonFINDClick(Sender: TObject);
 var
  Threads: array of TMyThread;
  i: Byte;
  st, en, en2 : integer;
  My_build_threadOUT: string;
  IdHTTP: TIdHTTP;
begin
form1.LSVGauge14.Progress := 1;
if (length(SpinEditMy_Build.Text)=0) or (length(SpinEditPlatform_ID.text)=0)  or (length(LabelEditRange.text)=0) then
begin
  ShowMessage('Введены не все данные!');
  Exit;
end;
  IdHTTP := TIdHTTP.Create;
  form1.ButtonFIND.Enabled := false;
  form1.ButtonObrSearch.Enabled := false;
  form1.ButtonSearchFULLOTA.Enabled := false;
  memo1.Clear;
  ListBoxLINKS.Clear;
  MaxCountThread := 20;   //максимальное число потоков      20
  LSVGauge14.MaxValue:= MaxCountThread;
  SetLength(Threads, MaxCountThread);
  st:=0;
  en:=Round(StrToInt(LabelEditRange.Text) / MaxCountThread);
  if en = 0 then
  begin
    en := StrToInt(LabelEditRange.Text);
    MaxCountThread := 1;
    SetLength(Threads, MaxCountThread);
    LSVGauge14.MaxValue:= MaxCountThread;
  end;
  en2:=1 * en;
  My_build_threadOUT := SpinEditMy_Build.Text;
  try
    IdHTTP.Head('http://ya.ru');
  except
    on pe: EIdHTTPProtocolException do
    begin
        if (pe.ErrorCode <> 302) or (pe.ErrorCode = 404) then   /////////////////не работает
        begin
          LabelStatus.Caption:= 'Состояние: Ошибка сети';
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

  Mode := 1;
  for i := 0 to MaxCountThread - 1 do
  begin
    Threads[i] := TMyThread.Create(True);
    Threads[i].StartIterationOUT:=st;
    Threads[i].EndIterationOUT:=en2;
    Threads[i].M_OUT :=  1;
    Threads[i].My_build_threadOUT := My_build_threadOUT;
    Threads[i].priority := tpnormal;
    st:= en2 + 1 ;
    en2:=en2 + en;
    Threads[i].OnTerminate := ThreadTerminate;
    form1.LabelStatus.Caption:= 'Состояние: ПОИСК!';
    Threads[i].Start;
  end;
end;


procedure ClickCluck(ParamTo, ParamDO, Mode : Integer);
 var
  Threads: array of TMyThread;
  i: Byte;
  st, en, en2 : integer;
  My_build_threadOUT: string;
  IdHTTP: TIdHTTP;
begin
  form1.LSVGauge14.Progress := 1;
  IdHTTP := TIdHTTP.Create;
  form1.ButtonFIND.Enabled := false;
  form1.ButtonObrSearch.Enabled := false;
  form1.ButtonSearchFULLOTA.Enabled := false;
  Form1.memo1.Clear;
  Form1.ListBoxLINKS.Clear;
  MaxCountThread := 20;   //максимальное число потоков      20
  form1.LSVGauge14.MaxValue:= MaxCountThread;
  SetLength(Threads, MaxCountThread);
  st:=0;
  en:=Round(StrToInt(Form1.LabelEditRange.Text) / MaxCountThread);
  if en = 0 then
  begin
    en := StrToInt(form1.LabelEditRange.Text);
    MaxCountThread := 1;
    SetLength(Threads, MaxCountThread);
    form1.LSVGauge14.MaxValue:= MaxCountThread;
  end;
  en2:=1 * en;
  My_build_threadOUT := form1.SpinEditMy_Build.Text;
  try
    IdHTTP.Head('http://ya.ru');
  except
    on pe: EIdHTTPProtocolException do
    begin
        if (pe.ErrorCode <> 302) or (pe.ErrorCode = 404) then   /////////////////не работает
        begin
          form1.LabelStatus.Caption:= 'Состояние: Ошибка сети';
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
    Threads[i].M_OUT :=  Mode;
    Threads[i].My_build_threadOUT := My_build_threadOUT;
    Threads[i].priority := tpnormal;
    st:= en2 + 1 ;
    en2:=en2 + en;
    Threads[i].OnTerminate := form1.ThreadTerminate;
    form1.LabelStatus.Caption:= 'Состояние: ПОИСК!';
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
memo1.Clear;
ListBoxLINKS.Clear;
LSVGauge14.Progress:= 1;
if (length(SpinEditTO_ALL.Text)=0) or (length(SpinEditDO_ALL.text)=0)  then
begin
  ShowMessage('Введены не все данные!');
  Exit;
end;
  LabelEditMyBuild_Obr.Enabled := False;
  IdHTTP := TIdHTTP.Create;
  form1.ButtonSearchFULLOTA.Enabled := false;
  form1.ButtonObrSearch.Enabled := false;
  form1.ButtonFIND.Enabled := false;
  MaxCountThread := 20;   //максимальное число потоков      20
  LSVGauge14.MaxValue:= MaxCountThread;
  SetLength(Threads, MaxCountThread);
  //st:=0;
  st:=StrToInt(SpinEditTO_ALL.Text);
  en:=Round((StrToInt(SpinEditDO_ALL.Text) - StrToInt(SpinEditTO_ALL.Text)) / MaxCountThread);  //920 -900 1
  if en = 0 then
  begin
    en := StrToInt(SpinEditDO_ALL.Text) - StrToInt(SpinEditTO_ALL.Text);
    MaxCountThread := 1;
    SetLength(Threads, MaxCountThread);
    LSVGauge14.MaxValue:= MaxCountThread;
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
          LabelStatus.Caption:= 'Состояние: Ошибка сети';
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
  if Form1.ComboBoxDevice.ItemIndex = 32 then
  begin
    showmessage('1');
    Version_Android:='8.1.';
  end;
  Mode := 3;
  for i := 0 to MaxCountThread - 1 do
  begin
    Threads[i] := TMyThread.Create(True);
    Threads[i].StartIterationOUT:=st;
    Threads[i].EndIterationOUT:=en2;
    Threads[i].M_OUT := 3;
    st:= st + en ;
    en2:=en2 + en;
    Threads[i].OnTerminate := ThreadTerminate;
    form1.LabelStatus.Caption:= 'Состояние: ПОИСК!';
    Threads[i].Start;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
Form1.ListBoxLINKS.ItemHeight:=Form1.ListBoxLINKS.ItemHeight +5;
//SendMessage(ProgressBar1.Handle, PBM_SETBARCOLOR, 0, clGreen); //цвет делений
  ListBoxLINKS.DoubleBuffered := True;
  CountThread := 0;
  pathINI:=extractfilepath(application.ExeName)+'\SET.ini';
  if FileExists(pathINI) then //проверяем есть ли файл INI
   begin
    IniFile := TIniFile.Create(pathINI);
     SpinEditMy_Build.Text := IniFile.ReadString('Param', 'My_Build', '936');
     LabelEditRange.Text := IniFile.readString('Param', 'Range', '300');
     ComboBoxDevice.ItemIndex := ComboBoxDevice.Items.IndexOf(IniFile.readString('Param', 'Device', 'xmen'));
    if ComboBoxDevice.ItemIndex = -1 then //если в ини пусто в девайсе
       ComboBoxDevice.ItemIndex := 29;
     SpinEditPlatform_ID.Text := IniFile.readString('Param', 'Platform_ID', '634');
    IniFile.Free;
    form1.LabelStatus.Caption:= 'Состояние: SET.ini подгружен!';
   end
    else
      form1.LabelStatus.Caption:= 'SET.ini не найден!';

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
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
  IdHTTP.Free;
end;

procedure TForm1.LabelEditDO_ObrKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    '0'..'9': ; // цифра
    #8 : ; // клавиша <Back Space>// остальные символы — запрещены
  else
    Key :=Chr(0); // символ не отображать
  end;
end;

procedure TForm1.LabelEditMyBuild_ObrKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    '0'..'9': ; // цифра
    #8 : ; // клавиша <Back Space>// остальные символы — запрещены
  else
    Key :=Chr(0); // символ не отображать
  end;
end;

procedure TForm1.LabelEditRangeKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    '0'..'9': ; // цифра
    #8 : ; // клавиша <Back Space>// остальные символы — запрещены
  else
    Key :=Chr(0); // символ не отображать
  end;
end;

procedure TForm1.LabelEditTO_ObrKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    '0'..'9': ; // цифра
    #8 : ; // клавиша <Back Space>// остальные символы — запрещены
  else
    Key :=Chr(0); // символ не отображать
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

Procedure TForm1.PaintImage(List1 :TListBox; Control: TWinControl;
 Index: Integer; Rect: TRect);
const W = 16;
      H = 16;
var BMPRect: TRect;
begin
  with (Control as TListBox).Canvas do
  begin
    FillRect(Rect);
    List1.Canvas.Draw(0, Rect.Top, Image1.Picture.Graphic);
    BMPRect := Bounds(Rect.Left, Rect.Top, W, H);
    TextOut(Rect.Left+W, Rect.Top, List1.Items[index]);
  end;
end;

procedure TForm1.ListBoxLINKSDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
PaintImage(ListBoxLINKS, Control, Index, Rect);
end;



procedure TForm1.ListBoxLINKSMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var H: string;
begin
  if Button = mbRight then
  begin
    ListBoxLINKS.ItemIndex := ListBoxLINKS.ItemAtPos(Point(X, Y), False);
    H := Memo1.Lines[ListBoxLINKS.ItemIndex];
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
  //form1.ListBoxLINKS.Items.Add(Format('%s%s%s%s%s%s%s%s', ['package-6.0.1.', My_build, '-6.0.1.', IntToStr(Msg.LParam), '.zip ', Content_Length, 'МБ ОТ ', build_date]));
  form1.ListBoxLINKS.Items.Add(Format('%s%s%s%s%s', ['package-6.0.1.', My_build, '-6.0.1.', IntToStr(Msg.LParam), '.zip ']));
//form1.ListBoxLINKS.Items.Append(IntToStr(Msg.LParam));
end;

procedure TForm1.SpinEditMy_BuildKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    '0'..'9': ; // цифра
    #8 : ; // клавиша <Back Space>// остальные символы — запрещены
  else
    Key :=Chr(0); // символ не отображать
  end;
end;

procedure TForm1.SpinEditPlatform_IDKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    '0'..'9': ; // цифра
    #8 : ; // клавиша <Back Space>// остальные символы — запрещены
  else
    Key :=Chr(0); // символ не отображать
  end;
end;


end.
