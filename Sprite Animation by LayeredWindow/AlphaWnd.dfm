object frmAlpha: TfrmAlpha
  Left = 217
  Top = 126
  BorderStyle = bsNone
  Caption = 'frmAlpha'
  ClientHeight = 43
  ClientWidth = 143
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  PixelsPerInch = 120
  TextHeight = 16
  object AnimateTimer: TTimer
    Enabled = False
    Interval = 40
    OnTimer = AnimateTimerTimer
  end
end
