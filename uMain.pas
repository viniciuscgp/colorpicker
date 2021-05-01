unit uMain;

interface

uses
  system.uiconsts, system.UiTypes,
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, math, Vcl.ExtCtrls;

type
  TfrmMain = class(TForm)
    color: TColorDialog;
    rbFormatGML: TRadioButton;
    edtText: TEdit;
    btnSelectColor: TButton;
    Label1: TLabel;
    rbFormatGMLRGB: TRadioButton;
    btnGetFromScreen: TButton;
    timerMouse: TTimer;
    panelColor: TPanel;
    lblPos: TLabel;
    procedure btnSelectColorClick(Sender: TObject);
    procedure btnGetFromScreenClick(Sender: TObject);
    procedure timerMouseTimer(Sender: TObject);
  private
    { Private declarations }
	 procedure converte;
	 procedure buildCommand(c:TColor);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

function ColorToAlphaColor(Value: TColor): TAlphaColor;
function ColorPixel(P: TPoint): TColor;
Function ButtonIsDown(Button:TMousebutton):Boolean;


implementation
uses uFunctions;


{$R *.dfm}

procedure TfrmMain.btnGetFromScreenClick(Sender: TObject);
begin
	if not timerMouse.Enabled then
   begin
		timerMouse.Enabled       := true;
   	btnGetFromScreen.Caption := 'Click when done';
   end;
end;

procedure TfrmMain.btnSelectColorClick(Sender: TObject);
begin
	color.Execute();
   converte();
end;

procedure TfrmMain.buildCommand(c: TColor);
var
   col:THSL;
   str:string;
   r, g, b:byte;
begin
   if rbFormatGML.Checked then
   begin

		col := ColorToHSLWindow(c);

   	str := 'make_color_hsv(' +
      	  		IntToStr(col.Hue) 		 + ', ' +
	        		IntToStr(col.Saturation) + ', ' +
   	     		IntToStr(col.Lightness)  + ')';
   end else
   begin
		r	:= c;
		g	:= c shr 8;
		b	:= C shr 16;
   	str := 'make_color_rgb(' +
      	  		IntToStr(r)  + ', ' +
	        		IntToStr(g)  + ', ' +
   	     		IntToStr(b)  + ')';
   end;
   edtText.Text := str;
   edtText.SelectAll;
	edtText.CopyToClipboard;
end;

procedure TfrmMain.converte;
var
	c:TColor;
begin
	c := color.Color;
	buildCommand(c);
end;


procedure TfrmMain.timerMouseTimer(Sender: TObject);
var
	p:TPoint;
   c:TColor;
begin
   GetCursorPos(p);
   c                := ColorPixel(p);
   panelColor.Color := c;
   lblPos.Caption   := 'Pos (' + intToStr(p.X) + ',' + intToStr(p.Y) + ')';

   if ButtonIsDown(mbLeft) then
   begin
		buildCommand(c);
		timerMouse.Enabled       := false;
   	btnGetFromScreen.Caption := 'Get from screen';
   end;
end;

function ColorPixel(P: TPoint): TColor;
var
  dc: HDC;
begin
	dc      := GetDC(0);
	result  := GetPixel(dc, p.x, p.y);
	ReleaseDC(0, dc);
end;

function ColorToAlphaColor(Value: TColor): TAlphaColor;
var
  CRec: TColorRec;
  ARec: TAlphaColorRec;
begin
  CRec.Color := Value;
  ARec.A 	 := CRec.A;
  ARec.B 	 := CRec.B;
  ARec.G 	 := CRec.G;
  ARec.R 	 := CRec.R;
  Result 	 := ARec.Color;
end;

Function ButtonIsDown(Button:TMousebutton):Boolean;
var swap :boolean;
    state:short;
begin
	state :=0;
	swap  := GetSystemMetrics(SM_SWAPBUTTON)<>0;
	if swap then
   	case button of
	   	mbLeft :State := getAsyncKeystate(VK_RBUTTON);
   		mbRight:State := getAsyncKeystate(VK_LBUTTON);
	   end
	else
   	case button of
	   mbLeft : State := getAsyncKeystate(VK_LBUTTON);
   	mbRight: State := getAsyncKeystate(VK_RBUTTON);
	   end;

	Result := (state < 0);
end;



end.
