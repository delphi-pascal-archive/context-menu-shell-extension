unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  Registry;

const
  CLSID_ContextMenu = '{AB69D961-B907-11D0-B8FA-A85800C10000}'; // здесь и в dll константа должна быть одинакова

procedure TForm1.Button1Click(Sender: TObject);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    with Reg do
    begin
      RootKey := HKEY_CLASSES_ROOT;
      OpenKey('\CLSID\' + CLSID_ContextMenu, True);
      WriteString('', 'Context Menu Shell Extension');
      OpenKey('\CLSID\' + CLSID_ContextMenu + '\InProcServer32', True);
      WriteString('', ExtractFilePath(Application.ExeName) + '\Project1.dll');//полный путь к нашей dll
      WriteString('ThreadingModel', 'Apartment');
      CreateKey('\exefile\shellex\ContextMenuHandlers\' + CLSID_ContextMenu);
      {
      В нашем случае расширение для .exe файлов, например для .txt CreateKey('\>>>txtfile<<<\shellex\ContextMenuHandlers\' + CLSID_ContextMenu);
      Смотрите в редакторе реестра ключ HKEY_CLASSES_ROOT
      }
    end;
  finally
    Reg.Free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    with Reg do
    begin
      RootKey := HKEY_CLASSES_ROOT;
      OpenKey('\CLSID\' + CLSID_ContextMenu, True);
      WriteString('', 'Context Menu Shell Extension');

      OpenKey('\CLSID\' + CLSID_ContextMenu + '\InProcServer32', True);
      WriteString('', ExtractFilePath(Application.ExeName) + '\Project1.dll');
      WriteString('ThreadingModel', 'Apartment');
      DeleteKey('\exefile\shellex\ContextMenuHandlers\' + CLSID_ContextMenu);
    end;
  finally
    Reg.Free;
  end;
end;

end.
