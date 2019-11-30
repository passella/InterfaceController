program Demo;

uses
  Vcl.Forms,
  untPrincipal in '..\src\untPrincipal.pas' {frmPrincipal},
  untInterfaceController in '..\..\..\src\untInterfaceController.pas',
  untIMyInterface in '..\..\shared\untIMyInterface.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
