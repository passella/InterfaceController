unit untPrincipal;

interface

uses
   Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
   Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
   TfrmPrincipal = class(TForm)
      btnTeste: TButton;
      procedure btnTesteClick(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
   end;

var
   frmPrincipal: TfrmPrincipal;

implementation

uses
   untInterfaceController, untIMyInterface;

{$R *.dfm}

procedure TfrmPrincipal.btnTesteClick(Sender: TObject);
begin
   ShowMessage(TInterfaceController.CreateInterface<IMyInterface>().Get());
end;

end.
