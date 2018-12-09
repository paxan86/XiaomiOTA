unit Unit2;

interface

uses
  System.Classes, IdHTTP, SysUtils, Dialogs;

type
  TMyThread = class(TThread)

  private // количество итераций цикла
    StartIteration: integer;
    EndIteration: integer;
  protected
    procedure Execute; override;
  public
    property StartIterationOUT: integer write StartIteration;
    property EndIterationOUT: integer write EndIteration;
  end;
implementation
  uses
    unit1 ;

procedure TMyThread.Execute;
  var
  IdHTTP: TIdHTTP;
  K, Range: byte;
  Platform_id, Device, Generated_build, My_build, Build_Date, Content_Length, Version_AndroidThread: String;
begin
  NameThreadForDebugging('TMyThread');
  IdHTTP := TIdHTTP.Create;
  platform_id := form1.SpinEditPlatform_ID.Text;
  Device := form1.ComboBoxDevice.Items[form1.ComboBoxDevice.ItemIndex];
  My_build := form1.SpinEditMy_Build.Text;;
  Range := StrToInt( form1.LabelEditRange.Text );
  Version_AndroidThread:= Version_Android;
for K := StartIteration to EndIteration do
begin
  Generated_build := IntToStr(StrToInt( My_build ) + K );
  //ShowMessage(Platform_id+ '-' +Device+ '-'+ Version_AndroidThread+ Generated_build+ '+'+ Version_Android+ My_build+ '+'+ Version_AndroidThread+ My_build+ '-'+ Version_AndroidThread+ Generated_build);
// form1.Memo1.Lines.Append(    format('%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ['http://ota.cdn.pandora.xiaomi.com/rom/', Platform_id, '/', Device, '/user/', Version_AndroidThread, Generated_build, '/', Version_Android, My_build, '/package-', Version_AndroidThread, My_build, '-', Version_AndroidThread, Generated_build, '.zip']));
  try IdHTTP.Head(Format('%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ['http://ota.cdn.pandora.xiaomi.com/rom/', Platform_id, '/', Device, '/user/', Version_AndroidThread, Generated_build, '/', Version_Android, My_build, '/package-', Version_AndroidThread, My_build, '-', Version_AndroidThread, Generated_build, '.zip']));
  except
    on pe: EIdHTTPProtocolException do  continue;//ShowMessage(pe.Message);  //ShowMessage(IntToStr(pe.ErrorCode));
    on e: Exception do  continue;//ShowMessage(e.Message);
  end;
  DateTimeToString(Build_Date, 'dd/mm/yyyy', idhttp.Response.LastModified);
  Content_Length := IntToStr(Round(idhttp.Response.ContentLength /1024 /1024));
  Synchronize(procedure
                begin
                  form1.Memo1.Lines.Append(Format('%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ['http://ota.cdn.pandora.xiaomi.com/rom/', Platform_id, '/', Device, '/user/', Version_AndroidThread, Generated_build, '/', Version_AndroidThread, My_build, '/package-', Version_AndroidThread, My_build, '-', Version_AndroidThread, Generated_build, '.zip']));
                  form1.ListBoxLINKS.Items.Add(Format('%s%s%s%s%s%s%s%s%s%s', ['package-', Version_Android, My_build, '-', Version_Android, Generated_build, '.zip ', Content_Length, 'МБ ОТ ', build_date]));
                end);
end;
  FreeOnTerminate := True;
  IdHTTP.Free;
  Terminate;
end;

end.
