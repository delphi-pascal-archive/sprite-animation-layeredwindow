{—————————————————————————————————————————————————————————————————————————}
{ Project : Alpha.dpr                                                     }
{ Comment :                                                               }
{                                                                         }
{    Date : 03/10/2009 00:47:00                                           }
{  Author : Cirec http://www.delphifr.com/auteur/CIREC/311214.aspx        }
{—————————————————————————————————————————————————————————————————————————}
{ Last modified                                                           }
{    Date : 23/10/2009 21:49:46                                           }
{  Author : Cirec http://www.delphifr.com/auteur/CIREC/311214.aspx        }
{—————————————————————————————————————————————————————————————————————————}
unit AlphaWnd;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Forms, ExtCtrls;

type
  TfrmAlpha = class(TForm)
    AnimateTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure AnimateTimerTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Déclarations privées }
    procedure WMEnterSizeMove(var Msg: TMessage); message WM_EnterSizeMove;
    procedure WMExitSizeMove(var Msg: TMessage); message WM_ExitSizeMove;
  protected
    FFullBitmap: TBitmap;
    FBlendFunction: TBlendFunction;
    FBitmapPos, FWindowPos: TPoint;
    FBitmapSize: TSize;

    FBitmapArray: array[Boolean] of array of TBitmap;
    FBitmapNum: Integer;
    FGoRight: Boolean;
    { Déclarations protégées}
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
    procedure GetSpriteData;
  public
    { Déclarations publiques }
  end;


var
  frmAlpha          : TfrmAlpha;
  FullDeskRect      : TRect;  // correspond à tout le bureau même avec 2 écrans

implementation

{$R *.dfm}
uses PngImage, Types, ShellAPI;

type
  TSpriteData = record
    aNAME          : string;  //  Nom du fichier image contenant les Sprites
    aWIDTH         : Integer; //  Largeur d'une Image
    aHEIGHT        : Integer; //  Hauteur   "     "
    aPER_LINE      : Integer; //  Nombre d'image par ligne
    aNUM_LINE      : Integer; //  Nombre de ligne
    aTIMER_INTERVAL: Integer; //  Intervale pour l'animation en Millisecondes
    aMOVE_OFFSET   : Integer; //  Valeur de déplacement en Pixel.
  end;
const
  SpriteDataArray   : array[0..2] of TSpriteData = (
      // un chat qui court
    (aName: '.\runningcat1.png'; aWidth: 512; aHeight: 256; aPer_Line: 2; aNum_Line: 4;
    aTimer_Interval: 100; aMove_Offset: 100),
       // un feu d'artifice
    (aName: '.\toon.png'; aWidth: 96; aHeight: 96; aPer_Line: 10; aNum_Line: 5;
    aTimer_Interval: 30; aMove_Offset: 0),
       // un Schtroumpf marchant
    (aName: '.\smurf_sprite.png'; aWidth: 128; aHeight: 128; aPer_Line: 4; aNum_Line: 4;
    aTimer_Interval: 28; aMove_Offset: 3));



{$IF PngImage.LibraryVersion = '1.56'}
// si on utilise une version plus ancienne de PngImage que celle qui est fournit
// par Delphi(depuis D2009 à Berlin 10.1 PngImage.LibraryVersion = 1.564)
// la classe TPngImage n'est pas connue
// ce qui suit permet d'écrire un code qui est utilisable avec les deux versions
type
  TPngImage = TPngObject;
{$IFEND}

// Avant D2009 le Bitmap 32 bits n'est pas pris en charge
{$IF compilerversion < 20.0}
{$DEFINE 32BitNotAvailable}
{$IFEND}

var
  BMP_NAME          : string;
  BMP_WIDTH,
  BMP_HEIGHT,
  BMP_PER_LINE,
  BMP_NUM_LINE,
  BMP_TIMER_INTERVAL,
  BMP_MOVE_OFFSET   : Integer;



{$IFDEF 32BitNotAvailable}
// préparation des pixels avant l'appel a AlphaBlend
// http://msdn.microsoft.com/en-us/library/ms532306(VS.85).aspx
procedure PreMultiply(aBmp: TBitmap);
var
  PData             : PRGBQuad;
  I, BytesTotal     : Integer;
begin
  BytesTotal := aBMP.Width * aBMP.Height;
  if aBmp.PixelFormat = pf32Bit then
  begin
    PData := aBMP.ScanLine[aBMP.Height - 1];
    for I := 0 to BytesTotal - 1 do
    begin
      with PData^ do
      begin
        if rgbReserved = 0 then
          rgbReserved := 1;
        RGBRed := (RGBRed * rgbReserved) div 255;
        RGBGreen := (RGBGreen * rgbReserved) div 255;
        RGBBlue := (RGBBlue * rgbReserved) div 255;
      end;
      Inc(PData);
    end;
  end;
end;
{$ENDIF}

{******************************************************************************}
  { convertion d'un Png avec canal alpha en Bitmap 32bit }
{******************************************************************************}

procedure PngToBmp32(const SrcPng: TPngImage; out aBmp: TBitmap);
var
  X, Y              : Integer;
  PSrcPixLine       : PRGBTriple;
  PDestPixLine      : PRGBQuad;
begin
  if not assigned(SrcPng) or (SrcPng.TransparencyMode <> ptmPartial) or (SrcPng.Empty) or
    ((SrcPng.Width <= 0) or (SrcPng.Height <= 0)) then
    raise EInvalidGraphicOperation.Create('Png invalide. Impossible à convertir');

  //Result := TBitmap.Create;
  with aBmp do
  try
    PixelFormat := pf32bit;
    Width := SrcPng.Width;
    Height := SrcPng.Height;
    for Y := 0 to SrcPng.Height - 1 do
    begin
      PSrcPixLine := SrcPng.ScanLine[Y];
      PDestPixLine := Scanline[Y];

      for X := 0 to SrcPng.Width - 1 do
      begin
        { cette ligne provoque, très rârement, une erreur ... ??? }
//        PDestPixLine^ := PRGBQuad(PSrcPixLine)^;
        { remplacé par ces 3 lignes et tout va bien }
        PDestPixLine^.rgbBlue := PSrcPixLine^.rgbtBlue;
        PDestPixLine^.rgbGreen := PSrcPixLine^.rgbtGreen;
        PDestPixLine^.rgbRed := PSrcPixLine^.rgbtRed;

        PDestPixLine^.rgbReserved := SrcPng.AlphaScanline[Y]^[X];

        Inc(PSrcPixLine);
        Inc(PDestPixLine);
      end;
    end;
  except
    { TODO :  }
  end;
end;
{******************************************************************************}
{******************************************************************************}

procedure TfrmAlpha.FormCreate(Sender: TObject);
var
  exStyle           : DWORD;
  I, J              : Integer;
  aClipRect,
  bClipRect,
  cClipRect         : TRect;
  b                 : Boolean;
  TmpPng            : TPngImage;
begin
  Randomize;
  GetSpriteData;
  // Active les LayeredWiondow
  // toute "l'astuce" est la
  exStyle := GetWindowLong(Handle, GWL_EXSTYLE);
  if (exStyle and WS_EX_LAYERED = 0) then
    SetWindowLong(Handle, GWL_EXSTYLE, exStyle or WS_EX_LAYERED);

  FFullBitmap := TBitmap.Create;
  try
    TmpPng := TPngImage.Create;
    try
      TmpPng.LoadFromFile(BMP_NAME);
      PngToBmp32(TmpPng, FFullBitmap);
      //FFullBitmap.SaveToFile('.\runningcat.bmp');
    finally
      TmpPng.Free;
    end;
{}
  //  FFullBitmap.LoadFromFile('.\runningcat.bmp');

    for B := False to True do
      for I := Low(FBitmapArray[B]) to High(FBitmapArray[B]) do
      begin
        FBitmapArray[B, I] := TBitmap.Create;
        FBitmapArray[B, I].Width := BMP_WIDTH;
        FBitmapArray[B, I].Height := BMP_HEIGHT;
        FBitmapArray[B, I].PixelFormat := pf32Bit;
      end;

    //on prépare l'image avant de la couper
{$IFDEF 32BitNotAvailable}
    PreMultiply(FFullBitmap);
{$ELSE}
    FFullBitmap.AlphaFormat := afPremultiplied;
{$ENDIF}

    aClipRect := Rect(0, 0, BMP_WIDTH, BMP_HEIGHT);      // représente l'image
    bClipRect := Rect(BMP_WIDTH - 1, 0, -1, BMP_HEIGHT); // représente l'image inversée
    cClipRect := aClipRect;  // représente la position de l'image dans le fichier Sprite
    // Découpe en N images
    for J := 0 to Pred(BMP_NUM_LINE) do
    begin
      for I := 0 to Pred(BMP_PER_LINE) do
      begin
          // image originale
        FBitmapArray[True, I + (J * BMP_PER_LINE)].Canvas.CopyRect(aClipRect,
          FFullBitmap.Canvas, cClipRect);
          // image inversée
        FBitmapArray[False, I + (J * BMP_PER_LINE)].Canvas.CopyRect(bClipRect,
          FFullBitmap.Canvas, cClipRect);
        OffsetRect(cClipRect, BMP_WIDTH, 0); // image suivante
      end;
        // première image de la ligne suivante
      OffsetRect(cClipRect, -BMP_WIDTH * BMP_PER_LINE, BMP_HEIGHT);
    end;
  finally
    FFullBitmap.Free;
  end;

  aClipRect := Screen.Monitors[0].BoundsRect;
  bClipRect := Rect(0, 0, 0, 0);
    // si on a deux écran ...
  if Screen.MonitorCount > 1 then
    bClipRect := Screen.Monitors[1].BoundsRect;
    // on combine les deux ... le perso se déplacera sur les deux
  UnionRect(FullDeskRect, aClipRect, bClipRect);

    // Position du bitmap sur la fiche
  FBitmapPos := Point(0, 0);
    // sa taille
  FBitmapSize.cx := FBitmapArray[True, 0].Width;
  FBitmapSize.cy := FBitmapArray[True, 0].Height;

  //  position à l'écran
  FWindowPos := Point(Random(FullDeskRect.Right - BMP_WIDTH), Random(Screen.Height -
    BMP_HEIGHT));

    // paramètre pour l'AlphaBlend
  FBlendFunction.BlendOp := AC_SRC_OVER;
  FBlendFunction.BlendFlags := 0;
  FBlendFunction.SourceConstantAlpha := 127 + Random(127);
  FBlendFunction.AlphaFormat := AC_SRC_ALPHA;

  FGoRight := Boolean(Random(200) mod 2);
  FBitmapNum := 0;
    // premier affichage
  UpdateLayeredWindow(Handle, 0, @FWindowPos, @FBitmapSize, FBitmapArray[FGoRight,
    FBitmapNum].Canvas.Handle, @FBitmapPos, 0, @FBlendFunction, ULW_ALPHA);

    // Inervale aléatoire ... si lancé plusieurs fois
  AnimateTimer.Interval := BMP_TIMER_INTERVAL + Random(200) mod 10;
  AnimateTimer.Enabled := True;
end;

 {permet de déplacer la fiche en cliquant sur l'image}
procedure TfrmAlpha.WMNCHitTest(var Message: TWMNCHitTest);
begin
  inherited;
  if Message.Result = HTCLIENT then
    Message.Result := HTCAPTION;
end;

procedure TfrmAlpha.FormDestroy(Sender: TObject);
var
  I                 : Integer;
  B                 : Boolean;
begin
  for B := False to True do
    for I := Low(FBitmapArray[B]) to High(FBitmapArray[B]) do
      FBitmapArray[B, I].Free;
end;

procedure TfrmAlpha.AnimateTimerTimer(Sender: TObject);
begin
  AnimateTimer.Enabled := False;
  // passe à l'image suivante
  FBitmapNum := (FBitmapNum + 1) mod (BMP_PER_LINE * BMP_NUM_LINE);

  if (FWindowPos.X > FullDeskRect.Right {-128}) or (FWindowPos.X < -BMP_WIDTH) then
    FGoRight := not FGoRight;
    // déplacement
  if FGoRight then
    Inc(FWindowPos.X, BMP_MOVE_OFFSET)
  else
    Dec(FWindowPos.X, BMP_MOVE_OFFSET);

    // actualisation de l'image à l'écran
  UpdateLayeredWindow(Handle, 0, @FWindowPos, @FBitmapSize, FBitmapArray[FGoRight,
    FBitmapNum].Canvas.Handle, @FBitmapPos, 0, @FBlendFunction, ULW_ALPHA);
  AnimateTimer.Enabled := True;
end;

procedure TfrmAlpha.WMExitSizeMove(var Msg: TMessage);
begin
  FWindowPos := Point(Left, Top);
  inherited;
 { relance l'animation }
  AnimateTimer.Enabled := True;
end;

procedure TfrmAlpha.WMEnterSizeMove(var Msg: TMessage);
begin
  inherited;
 { Stop l'animation durant le déplacement }
  AnimateTimer.Enabled := False;
end;

procedure TfrmAlpha.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: Close;
    VK_RIGHT : FGoRight := True;
    VK_LEFT  : FGoRight := False;
    VK_SPACE : AnimateTimer.Enabled := not AnimateTimer.Enabled;
    VK_UP    : if FWindowPos.Y > 0 then Dec(FWindowPos.Y);
    VK_DOWN  : if FWindowPos.Y < FullDeskRect.Bottom - BMP_HEIGHT then
        Inc(FWindowPos.Y);
  end; // case

end;


{cette procédure ne sert qu'à choisir une image aléatoirement : Alpha.exe
 ou par sélection direct : Alpha.exe 1
 ou encore de démarrer les 3 exemples : Alpha.exe all}
procedure TfrmAlpha.GetSpriteData;
var
  DataNum, I        : Integer;
begin
  if ParamCount > 0 then
  begin
    DataNum := StrToIntDef(ParamStr(1), 0);
  end
  else
    DataNum := Random(3);
  if (DataNum < 0) or (DataNum > 2) then
    DataNum := 2;
  with SpriteDataArray[DataNum] do begin
    BMP_NAME := aName;
    BMP_WIDTH := aWidth;
    BMP_HEIGHT := aHeight;
    BMP_PER_LINE := aPer_Line;
    BMP_NUM_LINE := aNum_Line;
    BMP_TIMER_INTERVAL := aTimer_Interval;
    BMP_MOVE_OFFSET := aMove_Offset;
  end;

  SetLength(FBitmapArray[False], Pred(BMP_PER_LINE * BMP_NUM_LINE * 2));
  SetLength(FBitmapArray[True], Pred(BMP_PER_LINE * BMP_NUM_LINE * 2));

  if (ParamCount > 0) and SameText(ParamStr(ParamCount), 'all') then
  begin
    for I := 0 to High(SpriteDataArray) do
      if I <> DataNum then
        ShellExecute(0, nil, PChar(Application.ExeName), PChar(IntToStr(I)), nil,
          SW_SHOWNORMAL);
  end;
end;

end.
