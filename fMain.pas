unit fMain;
interface
uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FMX.TabControl, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FMX.Effects, FMX.StdCtrls, FMX.Controls.Presentation, FMX.DialogService.Async,
  FireDAC.Stan.StorageBin, Data.Bind.EngExt, Fmx.Bind.DBEngExt, System.Rtti,
  System.Bindings.Outputs, Fmx.Bind.Editors, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  Data.Bind.Components, Data.Bind.DBScope, FMX.ScrollBox, FMX.Memo, FMX.Layouts,
  FMX.Edit, FMX.Memo.Types, System.ImageList, FMX.ImgList,
  System.IOUtils, System.RegularExpressions, System.Threading,
{$IFDEF ANDROID}
  Androidapi.JNI.Bluetooth,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNIBridge,
  Androidapi.Helpers,
  Androidapi.JNI.Widget,
  Androidapi.JNI.Os,
{$ENDIF}
  System.Bluetooth, System.Bluetooth.Components;

type
  TfrmMain = class(TForm)
    MaterialOxfordBlueSB: TStyleBook;
    ToolBar1: TToolBar;
    Label4: TLabel;
    ShadowEffect4: TShadowEffect;
    StateFDMemTable: TFDMemTable;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    BackButton: TButton;
    AddButton: TButton;
    RemoveButton: TButton;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkPropertyToFieldVisible: TLinkPropertyToField;
    LinkPropertyToFieldVisible2: TLinkPropertyToField;
    LinkPropertyToFieldVisible3: TLinkPropertyToField;
    LinkPropertyToFieldTabIndex: TLinkPropertyToField;
    SaveButton: TButton;
    TabItem4: TTabItem;
    LinkPropertyToFieldVisible4: TLinkPropertyToField;
    ListView1: TListView;
    ListView2: TListView;
    RoomsFDMemTable: TFDMemTable;
    BindSourceDB2: TBindSourceDB;
    LinkListControlToField1: TLinkListControlToField;
    ItemsFDMemTable: TFDMemTable;
    DataSource1: TDataSource;
    Label1: TLabel;
    Edit1: TEdit;
    VertScrollBox1: TVertScrollBox;
    Label2: TLabel;
    VertScrollBox2: TVertScrollBox;
    Label3: TLabel;
    Edit2: TEdit;
    Label5: TLabel;
    Memo2: TMemo;
    LinkControlToField2: TLinkControlToField;
    BindSourceDB3: TBindSourceDB;
    LinkControlToField5: TLinkControlToField;
    LinkControlToField6: TLinkControlToField;
    LinkListControlToField2: TLinkListControlToField;
    LinkPropertyToFieldText: TLinkPropertyToField;
    ImageList1: TImageList;
    Bluetooth1: TBluetooth;
    Edit3: TEdit;
    LinkControlToField1: TLinkControlToField;
    AniIndicator1: TAniIndicator;
    Button1: TButton;
    Memo1: TMemo;
    procedure TabControl1Change(Sender: TObject);
    procedure AddButtonClick(Sender: TObject);
    procedure RemoveButtonClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure BackButtonClick(Sender: TObject);
    procedure ListView1ButtonClick(const Sender: TObject;
      const AItem: TListItem; const AObject: TListItemSimpleControl);
    procedure ListView1ItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    dbfilepath: string;
    function NormalizeMAC(mac: string):string;
    function CheckMAC(mac: string):string;
    procedure Loading(isEnable: boolean);
  public
    { Public declarations }
  end;
var
  frmMain: TfrmMain;
const
  DBFILE = 'BTDevices.dat';

implementation
{$R *.fmx}
procedure TfrmMain.AddButtonClick(Sender: TObject);
begin
  if TabControl1.TabIndex = 0 then
  begin
     TabControl1.GotoVisibleTab(2);
     RoomsFDMemTable.Append;
     RoomsFDMemTable.Post;
  end;
end;
procedure TfrmMain.BackButtonClick(Sender: TObject);
begin
  case TabControl1.TabIndex of
    1: begin
         TabControl1.GotoVisibleTab(0);
       end;
    2: begin
         TabControl1.GotoVisibleTab(0);
       end;
  end;
end;
procedure TfrmMain.Button1Click(Sender: TObject);
var adapter: JBluetoothAdapter;
begin
  adapter:=TJBluetoothAdapter.JavaClass.getDefaultAdapter;
  if adapter.isEnabled then
  begin
    Button1.Text := 'Enable';
    adapter.disable;
  end
  else begin
    Button1.Text := 'Disable';
    adapter.enable;
  end;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  RoomsFDMemTable.SaveToFile(dbfilepath);
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  dbfilepath := TPath.Combine(TPath.GetDocumentsPath, DBFILE);
  if FileExists(dbfilepath) then
    RoomsFDMemTable.LoadFromFile(dbfilepath);
end;

procedure TfrmMain.ListView1ButtonClick(const Sender: TObject;
  const AItem: TListItem; const AObject: TListItemSimpleControl);
var status:integer;
    s:string;
    ai:TAniIndicator;
begin
  AniIndicator1.Position.Y := ListView1.Position.Y + AItem.Index * ListView1.ItemAppearance.ItemHeight;
  Memo1.Text:=AniIndicator1.Position.Y.ToString+'-'+ AItem.Height.ToString+' '+AItem.Index.ToString+' '+ListView1.ItemAppearance.ItemHeight.ToString;//+' '+TButton(AObject).Height.ToString);
  ai := TAniIndicator.Create(TCOmponent(Sender));
  //ai.Width:=TButton(Sender).Width;
  //ai.Height:=TButton(Sender).Height;
  TTask.Run(procedure begin
    TThread.Synchronize(TThread.CurrentThread, procedure begin
      ai.Enabled := true;
      ai.Visible := true;
    end);
    loading(true);
//    TThread.Synchronize(TThread.CurrentThread, procedure begin
      var mac := RoomsFDMemTable.FieldByName('Desc').AsString;
      s := CheckMAC(mac);
      if s.IsEmpty then
        status := 2
      else
        status := 1;

      RoomsFDMemTable.Edit;
      RoomsFDMemTable.FieldByName('DeviceName').AsString := s;
      RoomsFDMemTable.FieldByName('Status').AsInteger := status;
      RoomsFDMemTable.FieldByName('LastCheck').AsDateTime := Now;
      RoomsFDMemTable.UpdateRecord;
    loading(false);
    TThread.Synchronize(TThread.CurrentThread, procedure begin
      ai.Enabled := false;
      ai.Free;
    end);
//    end);
  end).Start;

//  TabControl1.GotoVisibleTab(2);
end;

procedure TfrmMain.ListView1ItemClickEx(const Sender: TObject; ItemIndex: Integer;
  const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
begin
  if ItemObject <> nil then
   if ItemObject.ClassName<>'TListItemTextButton' then
     begin
  //     TabControl1.GotoVisibleTab(1);
      TabControl1.GotoVisibleTab(2);
     end;
end;
procedure TfrmMain.RemoveButtonClick(Sender: TObject);
begin
  case TabControl1.TabIndex of
    0: RoomsFDMemTable.Delete;
    1: ItemsFDMemTable.Delete;
  end;
end;
procedure TfrmMain.SaveButtonClick(Sender: TObject);
begin
  if TabControl1.TabIndex = 2 then
  begin
    RoomsFDMemTable.Edit;
    RoomsFDMemTable.FieldByName('Desc').AsString := NormalizeMAC(RoomsFDMemTable.FieldByName('Desc').AsString);
    RoomsFDMemTable.FieldByName('Status').AsInteger := 0;
    RoomsFDMemTable.UpdateRecord;
    RoomsFDMemTable.SaveToFile(dbfilepath);
    TabControl1.GotoVisibleTab(0);
  end;
end;
procedure TfrmMain.TabControl1Change(Sender: TObject);
begin
  StateFDMemTable.Locate('Page',VarArrayOf([TabControl1.TabIndex]));
end;
function TfrmMain.NormalizeMAC(mac: string):string;
begin
  mac := Trim(mac).ToUpper;
  if not mac.Contains(':') then
  begin
    mac := TRegEx.Replace(mac, '(..)', '$1:');
  end;
  mac := mac.Substring(0, mac.Length-1);
  Result := mac;
end;

procedure TfrmMain.Loading(isEnable: boolean);
begin
  TThread.Synchronize(TThread.CurrentThread, procedure begin
    AniIndicator1.Enabled := isEnable;
  end);
end;

function TfrmMain.CheckMAC(mac: string):string;
{$IFDEF ANDROID}
var adapter: JBluetoothAdapter;
    device: JBluetoothDevice;
    sock: JBluetoothSocket;
//    gatt: JBluetoothGatt;
    uid: JUUID;
//    s, p:string;
//    callback: JBluetoothGattCallback;
//    parcels: TJavaObjectArray<JParcelUuid>;
//    parcel: JParcelUuid;
//    t: TThread;
{$ENDIF}
begin
  Result := '';
{$IFDEF ANDROID}
  if trim(mac)='' then exit;

  uid:=TJUUID.JavaClass.fromString(StringToJString('00001101-0000-1000-8000-00805F9B34FB'));
  adapter:=TJBluetoothAdapter.JavaClass.getDefaultAdapter;
  device:=adapter.getRemoteDevice(stringtojstring(mac));
  sock:=device.createRfcommSocketToServiceRecord(uid);
  try sock.connect;
    except begin
    end;
  end;
  Result:=JStringToString(device.getName);

{
  t:=TThread.CreateAnonymousThread( procedure
  var adapter: JBluetoothAdapter;
      device: JBluetoothDevice;
  begin
  //    callback := TJBluetoothGattCallback.Create;
//    callback.onConnectionStateChange := onConnectionStateChange;

//      uid := TJUUID.JavaClass.fromString(StringToJString('00001101-0000-1000-8000-00805F9B34FB'));
      adapter := TJBluetoothAdapter.JavaClass.getDefaultAdapter;
      try
        device := Adapter.getRemoteDevice(StringToJString(mac));
        if device = nil then s:='0'
        else if device.getName = nil then s:='1'
        else begin
          s := '2:'+JStringToString(device.getName);
          if device.toString <> nil then s:=s+':3:'+JStringToString(device.toString);
        end;
      except on e:Exception do
        begin
        //Result := e.Message;
//          memLog.Lines.Append('Error: ' + e.Message);
          s:=e.Message;
        end;
      end;
  end
  );
  t.Start;
  t.WaitFor;
  Result := s;
  exit;
//  var i := device.getType;
//  p := JStringToString(device.getAddress);
  try
    if device = nil then
      Result := '0'
//    else if device.getName = nil then
//      Result := '1'
    else begin
      parcels := device.getUuids;
      if parcels = nil then s:='nil'
      else s:=JStringToString(parcels.Items[0].toString);
//      s := JStringToString(device.getName);
      Result := '2:'+s;
    end;
  except on e:Exception do
    begin
      Result := '3:'+e.Message;
    end;
  end;
}
{$ENDIF}
end;


end.
