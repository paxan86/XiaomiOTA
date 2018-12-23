unit Unit2;

interface

uses
  System.Classes, IdHTTP, SysUtils, Dialogs;

type
  TMyThread = class(TThread)

  private
    StartIteration: integer;
    EndIteration: integer;
	My_build_thread: String;
  M: integer;
  StartInteration : integer;
  protected
    procedure Execute; override;
  public
    property StartIterationOUT: integer write StartIteration;
    property EndIterationOUT: integer write EndIteration;
	property My_build_threadOUT: string write My_build_thread;
  property M_OUT: integer write M;
  property StartInterationOUT: integer write StartInteration;
  end;
implementation
  uses unit1 ;

procedure TMyThread.Execute;
  var
  IdHTTP: TIdHTTP;
  K: Integer;
  Platform_id, Device, Generated_build, Generated_build2, My_build, Build_Date, Content_Length, Version_AndroidThread: String;
begin
  NameThreadForDebugging('TMyThread');
  IdHTTP := TIdHTTP.Create;
  platform_id := form1.SpinEditPlatform_ID.Text;
  Device := form1.ComboBoxDevice.Items[form1.ComboBoxDevice.ItemIndex];
  Version_AndroidThread:= Version_Android;
for K := StartIteration  to EndIteration do
begin
  Generated_build2 := IntToStr( StartInteration  + K );
  if M = 1 then
  begin
    Generated_build := IntToStr(StrToInt( My_build_thread ) + K );
  try IdHTTP.Head(Format('%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ['http://ota.cdn.pandora.xiaomi.com/rom/', Platform_id, '/', Device, '/user/', Version_AndroidThread, Generated_build, '/', Version_AndroidThread, My_build_thread, '/package-', Version_AndroidThread, My_build_thread, '-', Version_AndroidThread, Generated_build, '.zip']));
  except
    on pe: EIdHTTPProtocolException do  continue;//ShowMessage(pe.Message);  //ShowMessage(IntToStr(pe.ErrorCode));
    on e: Exception do  continue;//ShowMessage(e.Message);
  end;
  end
  else if M = 2  then
  begin
  try IdHTTP.Head(Format('%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ['http://ota.cdn.pandora.xiaomi.com/rom/', Platform_id, '/', Device, '/user/', Version_AndroidThread, My_build_thread, '/', Version_AndroidThread, Generated_build2, '/package-', Version_AndroidThread, Generated_build2, '-', Version_AndroidThread, My_build_thread, '.zip']));
  except
    on pe: EIdHTTPProtocolException do  continue;
    on e: Exception do  continue;
  end;
end
  else if M = 3  then
  begin
  try IdHTTP.Head(Format('%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ['http://ota.cdn.pandora.xiaomi.com/rom/', Platform_id, '/', Device, '/user/', Version_AndroidThread, Generated_build2, '/', Version_AndroidThread, Generated_build2, '/RELEASE_NOTES-', Version_AndroidThread, Generated_build2, '.zip']));
  except
    on pe: EIdHTTPProtocolException do  continue;
    on e: Exception do  continue;
  end;
 end;

  DateTimeToString(Build_Date, 'dd/mm/yyyy', idhttp.Response.LastModified);
  Content_Length := IntToStr(Round(idhttp.Response.ContentLength /1024 /1024));
  if M = 1 then
  Synchronize(procedure
                begin
                  form1.Memo1.Lines.Append(Format('%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ['http://ota.cdn.pandora.xiaomi.com/rom/', Platform_id, '/', Device, '/user/', Version_AndroidThread, Generated_build, '/', Version_AndroidThread, My_build_thread, '/package-', Version_AndroidThread, My_build_thread, '-', Version_AndroidThread, Generated_build, '.zip']));
                  form1.ListBoxLINKS.Items.Add(Format('%s%s%s%s%s%s%s%s%s%s', ['package-', Version_Android, My_build_thread, '-', Version_Android, Generated_build, '.zip ', Content_Length, 'Ã¡ Œ“ ', build_date]));
                  form1.ListBoxLINKS.Selected[form1.ListBoxLINKS.Items.Count-1]:=True;
                end)
  else if M = 2  then
   Synchronize(procedure
                begin
                  form1.Memo1.Lines.Append(Format('%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ['http://ota.cdn.pandora.xiaomi.com/rom/', Platform_id, '/', Device, '/user/', Version_AndroidThread, My_build_thread, '/', Version_Android, Generated_build2, '/package-', Version_AndroidThread, Generated_build2, '-', Version_AndroidThread, My_build_thread, '.zip']));
                  form1.ListBoxLINKS.Items.Add(Format('%s%s%s%s%s%s%s%s%s%s', ['package-', Version_Android, Generated_build2, '-', Version_Android, My_build_thread, '.zip ', Content_Length, 'Ã¡ Œ“ ', build_date]));
                  form1.ListBoxLINKS.Selected[form1.ListBoxLINKS.Items.Count-1]:=True;
                end)
    else if M = 3  then
   Synchronize(procedure
                begin
                Content_Length := IntToStr(idhttp.Response.ContentLength);
                  form1.Memo1.Lines.Append(Format('%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ['http://ota.cdn.pandora.xiaomi.com/rom/', Platform_id, '/', Device, '/user/', Version_AndroidThread, Generated_build2, '/', Version_AndroidThread, Generated_build2, '/RELEASE_NOTES-', Version_AndroidThread, Generated_build2, '.zip']));
                  form1.ListBoxLINKS.Items.Add(Format('%s%s%s%s%s',[ Version_Android,Generated_build2, ' '+Content_Length, ' ¡ Œ“ ', build_date ]));
                  form1.ListBoxLINKS.Selected[form1.ListBoxLINKS.Items.Count-1]:=True;
                end);
end;
  FreeOnTerminate := True;
  IdHTTP.Free;
  Terminate;
end;

end.
