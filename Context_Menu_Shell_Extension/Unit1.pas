// не забывайте выгружать dll из explorer'а что бы этот проект мог скомпилироваться

unit Unit1;

interface

uses
  Windows, Forms, StdCtrls, ShellApi, SysUtils, Classes, Controls,
  ComServ, ComObj, ShlObj, ActiveX, Dialogs, TlHelp32;

const
  CLSID_ContextMenu: TGUID = '{AB69D961-B907-11D0-B8FA-A85800C10000}';

type
  TFormViewContextMenu = class(TComObject,
      IShellExtInit, IContextMenu)
  private
    FFileName: string;
  public

    function IShellExtInit.Initialize = ShellInit;
    function ShellInit(Folder: PItemIDList;
      DataObject: IDataObject;
      ProgID: HKEY): HResult; stdcall;

    function QueryContextMenu(Menu: HMENU;
      Index, CmdFirst, CmdLast,
      Flags: UINT): HResult; stdcall;
    function GetCommandString(Cmd, Flags: UINT;
      Reserved: PUINT; Name: LPSTR;
      MaxSize: UINT): HResult; stdcall;
    function InvokeCommand(var CommandInfo: TCMInvokeCommandInfo):
      HResult; stdcall;
  end;

implementation

uses
  Registry;

function TFormViewContextMenu.ShellInit(Folder: PItemIDList;
  DataObject: IDataObject;
  ProgID: HKEY): HResult;
var
  Medium: TStgMedium;
  FE: TFormatEtc;
begin
  if DataObject = nil then
  begin
    Result := E_FAIL;
    Exit;
  end;

  with FE do
  begin
    cfFormat := CF_HDROP;
    ptd := nil;
    dwAspect := DVASPECT_CONTENT;
    lindex := -1;
    tymed := TYMED_HGLOBAL;
  end;

  Result := DataObject.GetData(FE, Medium);
  if Failed(Result) then
    Exit;
  try
    if DragQueryFile(Medium.hGlobal, $FFFFFFFF, nil, 0) = 1 then
    begin
      SetLength(FFileName, MAX_PATH);
      DragQueryFile(Medium.hGlobal, 0, PChar(FFileName), MAX_PATH);
      Result := NOERROR;
    end
    else
      Result := E_FAIL;
  finally
    ReleaseStgMedium(Medium);
  end;
end;

function TFormViewContextMenu.QueryContextMenu(Menu: HMENU;
  Index, CmdFirst, CmdLast, Flags: UINT): HResult;
begin
  Result := 0;
  if ((Flags and $0000000F) = CMF_NORMAL) or
    ((Flags and CMF_EXPLORE) <> 0) or ((Flags and CMF_VERBSONLY) <> 0) then
  begin
    InsertMenu(Menu, 0, MF_SEPARATOR or MF_BYPOSITION, CmdFirst, nil);
    InsertMenu(Menu, 1, MF_STRING or MF_BYPOSITION, CmdFirst, PChar('Пункт Меню №1'));
    InsertMenu(Menu, 2, MF_STRING or MF_BYPOSITION, CmdFirst + 1, PChar('Другой Пункт Меню'));
    Result := 3; // сколько добавили пунктов
  end;
end;

function TFormViewContextMenu.GetCommandString(Cmd, Flags: UINT;
  Reserved: PUINT; Name: LPSTR; MaxSize: UINT): HResult;
begin
  case Cmd of
    0:
      begin
        if Flags = GCS_HELPTEXT then
        begin
          StrCopy(Name, '');
        end;
        Result := NOERROR;
      end;
  else
    Result := E_INVALIDARG;
  end;
end;

function TFormViewContextMenu.InvokeCommand(var CommandInfo:
  TCMInvokeCommandInfo): HResult;
begin
  if HiWord(Integer(CommandInfo.lpVerb)) <> 0 then
  begin
    Result := E_FAIL;
    Exit;
  end;
  case LoWord(CommandInfo.lpVerb) of
    0:
      begin
       // FFileName - Файл на котором кликаем в проводнике
        ShowMessage('Пункт Меню №1' + #13#10);
      end;
    1:
      begin
        ShowMessage('Другой Пункт Меню' + #13#10);
      end;
  else
    Result := E_INVALIDARG;
  end;
end;

initialization
  TComObjectFactory.Create(ComServer, TFormViewContextMenu, CLSID_ContextMenu, '', '', ciMultiInstance);
end.

 