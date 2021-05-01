program XColorPicker;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {frmMain},
  uFunctions in 'uFunctions.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
