{ +--------------------------------------------------------------------------------
  Esse Software foi escrito por romerito morais no RAD Studio Delphi Rio 10.3.3
  linkedIn: https://www.linkedin.com/in/romeritomorais/
  email: Romeritomorais@outlook.com.br
  Fone: 91 9 9994-2079
  +-------------------------------------------------------------------------------- }

unit Principal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Menus, FMX.StdCtrls, FMX.Edit, FMX.Controls.Presentation, FMX.ListBox,
  FMX.ComboEdit, FMX.Effects, FMX.Filter.Effects, FMX.Objects, FMX.EditBox,
  FMX.ComboTrackBar;

type
  TFMXForm = class(TForm)
    OpenFile: TOpenDialog;
    EditSize: TEdit;
    EditCaminho: TEdit;
    Procurar: TSearchEditButton;
    SaveFiles: TSaveDialog;
    Layout1: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    ComboTipo: TComboEdit;
    Layout4: TLayout;
    TextSize: TText;
    RecLayout: TRectangle;
    Layout6: TLayout;
    ShadowEffect1: TShadowEffect;
    ShadowEffect2: TShadowEffect;
    Layout5: TLayout;
    Rectangle1: TRectangle;
    ShadowEffect3: TShadowEffect;
    TextExec: TText;
    RecConfirmacao: TRectangle;
    Layout7: TLayout;
    Layout8: TLayout;
    Layout9: TLayout;
    Rectangle2: TRectangle;
    TextResult: TText;
    TextMensagem: TText;
    Layout10: TLayout;
    TextTime: TText;
    ShadowEffect4: TShadowEffect;
    procedure FormCreate(Sender: TObject);
    procedure ComboTipoChange(Sender: TObject);
    procedure ProcurarClick(Sender: TObject);
    procedure TextExecClick(Sender: TObject);
    procedure TextResultClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);

  private
    { Private declarations }
  public
    fTempo: Ttime;
    fMomento: integer;
    { Public declarations }
  end;

var
  FMXForm: TFMXForm;

implementation

{$R *.fmx}

uses Linux.Utils;

const
  OneKB = 1024;
  OneMB = OneKB * OneKB;
  OneGB = OneKB * OneMB;
  OneTB = Int64(OneKB) * OneGB;

type
  TByteStringFormat = (bsfDefault, bsfBytes, bsfKB, bsfMB, bsfGB, bsfTB);

var
  BashLine, SelectDir: String;
  BashResult: TStringList;

  { funcção para medir o tamamho do arquivo selecionado }
function TamanhoArquivo(Arquivo: string): integer;
begin
  with TFileStream.Create(Arquivo, fmOpenRead or fmShareExclusive) do
    try
      Result := Size;
    finally
      Free;
    end;
end;

{ função que verifica se o diretório esta vazio ou não }
function ValidaDiretorio(Dir: string): Boolean;
var
  SR: TSearchRec;
  I: integer;
begin
  Result := False;
  FindFirst(IncludeTrailingPathDelimiter(Dir) + '*', faAnyFile, SR);
  for I := 1 to 2 do
    if (SR.Name = '.') or (SR.Name = '..') then
      Result := FindNext(SR) <> 0;
  FindClose(SR);
end;

{ função que retorna o tamanho do arquivo em em kib, mib, gib etc.... }
function FormatByteString(Bytes: UInt64;
  Format: TByteStringFormat = bsfDefault): string;
begin
  if Format = bsfDefault then
  begin
    if Bytes < OneKB then
    begin
      Format := bsfBytes;
    end
    else if Bytes < OneMB then
    begin
      Format := bsfKB;
    end
    else if Bytes < OneGB then
    begin
      Format := bsfMB;
    end
    else if Bytes < OneTB then
    begin
      Format := bsfGB;
    end
    else
    begin
      Format := bsfTB;
    end;
  end;

  case Format of
    bsfBytes:
      Result := System.SysUtils.Format('%d bytes', [Bytes]);
    bsfKB:
      Result := System.SysUtils.Format('%.1n KB', [Bytes / OneKB]);
    bsfMB:
      Result := System.SysUtils.Format('%.1n MB', [Bytes / OneMB]);
    bsfGB:
      Result := System.SysUtils.Format('%.1n GB', [Bytes / OneGB]);
    bsfTB:
      Result := System.SysUtils.Format('%.1n TB', [Bytes / OneTB]);
  end;
end;

procedure TFMXForm.ProcurarClick(Sender: TObject);
begin
  if ComboTipo.Text = 'quebrar arquivos' then
  begin
    EditSize.Text := '';
    EditSize.TextPrompt := 'exemplo: 10';
    OpenFile.Execute;
    EditCaminho.Text := OpenFile.FileName;
    EditCaminho.selstart := Length(EditCaminho.Text);
    SelectDirectory('Selecione o Diretorio de Saída do Arquivos', '',
      SelectDir);
    TextSize.Text := 'tamanho do aquivo selecionado: ' +
      FormatByteString(TamanhoArquivo(EditCaminho.Text));
    EditSize.SetFocus;
  end
  else
  begin
    EditSize.Text := '';
    EditSize.TextPrompt := 'exemplo: arquivo.zip';
    SelectDirectory('Selecione o Diretorio', '', SelectDir);
    EditCaminho.Text := SelectDir;
    EditSize.SetFocus;
  end;

end;

procedure TFMXForm.TextResultClick(Sender: TObject);
begin
  RecConfirmacao.Visible := False;
end;


procedure TFMXForm.TextExecClick(Sender: TObject);
begin
  TextExec.Enabled:=False;
  if ComboTipo.Text = 'quebrar arquivos' then
  begin
    if (EditCaminho.Text = '') or (EditSize.Text = '') then
    begin
      RecConfirmacao.Visible := True;
      TextMensagem.Text := 'Antes de Executar Preencha Todos os Campos';
    end
    else
    begin

      BashLine := 'split -d --number=' + EditSize.Text + ' ' + EditCaminho.Text
        + ' ' + SelectDir + '/part_';
      BashResult := TLinuxUtils.RunCommandLine(BashLine);
      RecConfirmacao.Visible := True;
      TextMensagem.Text := 'O arquivo quebrado em ' + EditSize.Text +
        ' pedaços se encontra nesse diretório ' + SelectDir + '';
      TextExec.Enabled:=True;
    end;

  end
  else
  begin
    if DirectoryExists(SelectDir) then
    begin
      if ValidaDiretorio(SelectDir) then
        ShowMessage('Diretório esta vazio')
      else
      begin
        BashLine := 'cd ' + SelectDir + '; cat part_ * > ' + EditSize.Text +
          '; echo -e "+ Arquivo unidos com Software "Quebrador Binário"\n+ Desenvolvido por Romerito:\n+ linkedIn: https://www.linkedin.com/in/romeritomorais/\n+ mail:    Romeritomorais@outlook.com.br" > Leia-me.txt';
        BashResult := TLinuxUtils.RunCommandLine(BashLine);
        RecConfirmacao.Visible := True;
        TextMensagem.Text := ' O Arquivo Unido ' + EditSize.Text +
          ' se encontra em ' + SelectDir;
      end;

    end

  end;
  TextExec.Enabled:=True;
end;

procedure TFMXForm.ComboTipoChange(Sender: TObject);
begin
  if ComboTipo.Text = 'quebrar arquivos' then
  begin
    if EditCaminho.Text = '' then
    begin
      EditCaminho.Text := '';
      EditCaminho.TextPrompt := 'selecione o arquivo';
      EditSize.TextPrompt := 'exemplo: 10';
      TextSize.Text := '';
    end
    else
    begin
      EditCaminho.TextPrompt := 'selecione o arquivo';
      EditSize.Text := 'exemplo: dados.zip';
      TextSize.Text := FormatByteString(TamanhoArquivo(EditCaminho.Text));
    end;
  end
  else
  begin
    EditCaminho.Text := '';
    EditCaminho.SetFocus;
    EditCaminho.TextPrompt := 'selecione a pasta com os arquivos';
    EditSize.TextPrompt := 'exemplo: dados.zip';
    TextSize.Text := '';
  end

end;

procedure TFMXForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  EditCaminho.Text := '';
  EditSize.Text := '';
  BashResult.Clear;
  TextMensagem.Text := '';
  SelectDir := '';
end;

procedure TFMXForm.FormCreate(Sender: TObject);
begin
  BashResult := TStringList.Create;
  OpenFile.Filter :=
    'Todos (*.*)|*.*|Arquivos Texto (*.txt)|*.TXT|Arquivos Python (*.py)|*.PY|Arquivos ISO (*.iso)|*.ISO|Arquivos CSV (*.csv)|*.CSV|Arquivos XLS (*.xls)|*.XLS|Arquivos Zip (*.zip)|*.ZIP|Arquivos Rar (*.rar)|*.RAR';
end;

procedure TFMXForm.FormShow(Sender: TObject);
begin
//  Timer1.enabled := False;
end;

end.
