{覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧抑
{ Project : Alpha.dpr                                                     }
{ Comment :                                                               }
{                                                                         }
{    Date : 03/10/2009 00:47:00                                           }
{  Author : Cirec http://www.delphifr.com/auteur/CIREC/311214.aspx        }
{覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧抑
{ Last modified                                                           }
{    Date : %MDAT%                                                        }
{  Author : %MAUT%                                                        }
{覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧抑
program Alpha;

uses
  Forms,
  AlphaWnd in 'AlphaWnd.pas' {frmAlpha};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmAlpha, frmAlpha);
  Application.Run;
end.
