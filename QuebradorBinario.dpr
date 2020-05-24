program QuebradorBinario;

uses
  System.StartUpCopy,
  FMX.Forms,
  Principal in 'Principal.pas' {FMXForm} ,
  Linux.Utils in 'Lib\Linux.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFMXForm, FMXForm);
  Application.Run;

end.
