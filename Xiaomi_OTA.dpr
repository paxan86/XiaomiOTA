program Xiaomi_OTA;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  windows,
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10 Green');
  Application.CreateForm(TForm1, Form1);
  Application.Run;
  {$SetPEFlags IMAGE_FILE_RELOCS_STRIPPED}
end.
