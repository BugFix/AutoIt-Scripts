;-- TIME_STAMP   2020-05-03 18:48:17   v 0.2

;----------------------------------------------------------------------------------------------------------------
; available command line parameters
;----------------------------------------------------------------------------------------------------------------
;  REQUIRED
;    text=Text for encoding
;  OPTIONAL
;    file=path/filename[.ext]  - If ommited, the default will used: @HomeDrive & @HomePath & "\QR_YYYYMMDD_hhmmss"
;    type=png,bmp,clip         - If ommited, 'png' will used. With clip runs CopyToClipboard.
;         or combined png/bmp    If file has .ext and type is passed but is different to .ext than will used type
;    width=int                 - (and height) initializes a resizing of the default created QR-Code
;                                Resizing fails, if passed size is smaller as the default generated file.
;                              REMARK: Only for file creation
;    scale=int                 - Factor for up scaling the QR-Code
;                              REMARK: Only for CopyToClipboard
;    margin=4                  - The margin around the QR-Code in px (Default = 4)
;    corrlevel=0               - Up to 7%, 15%, 25% or 30% damage [0, 1, 2, 3]. (Default = 0)
;    sizept=2                  - The size of the painted pixel itself. The value depends on the correction level.
;                                Only the smallest point size can be used for the largest correction level.
;                                The value will corrected automatically, if wrong.
;----------------------------------------------------------------------------------------------------------------
; return values
;----------------------------------------------------------------------------------------------------------------
; comma separated string with:
;   ERROR=@error
;   RESULT='FullFilePath' or 'CLIPBOARD'
;   SIZE=width x heigth
;   SIZEPT=The really used (may be corrected) size of point
;   MARGIN=The used margin size
;   CORRLEVEL=The used correction level
;----------------------------------------------------------------------------------------------------------------

#include "QRCreator.au3"
#include <WinAPIFiles.au3>

Opt('MustDeclareVars', 1)


;----------------------------------------------------------------------------------------------------------------
Global $sHome = @HomeDrive & @HomePath
Global $sText, $sFile, $sType, $iWidth, $iScale, $iMargin, $iCorrlevel, $iSizePt
Global $bFile = False, $bResize = False, $bClip = False
Global $aMatch, $sOutputResult = '', $idxCall = 0, $tRes
Global $aCall[3][2] ; [['function',$aArgs]]  -- max. 3 operations at once
Global $aArgsPNG[6] = ["CallArgArray"], $aArgsBMP[6] = ["CallArgArray"], $aArgsRE_PNG[7] = ["CallArgArray"]
Global $aArgsRE_BMP[7] = ["CallArgArray"], $aArgsCLIP[6] = ["CallArgArray"]
;----------------------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------------------
If $CMDLINE[0] = 0 Then
	Exit ConsoleWrite(_OutPutResult(1,'Minimum Required a Text Parameter!') & @CRLF)
Else
	$sText      = _ParseForParam('text')
	$sFile      = _OrDefault(_ParseForParam('file'), Null)
	If $sFile <> Null Then $bFile = True
	$sType      = _OrDefault(_ParseForParam('type'), Null)
	If $sType <> Null Then
		If StringInStr($sType, 'png') Or StringInStr($sType, 'png') Then $bFile = True
		If StringInStr($sType, 'clip') Then $bClip = True
	EndIf
	$iWidth     = _OrDefault(_ParseForParam('width'), Null)
	If $iWidth <> Null Then
		$bFile = False
		$bResize = True
	EndIf
	$iScale     = _OrDefault(_ParseForParam('scale'), Null)
	If $iScale <> Null And Not StringInStr($sType, 'clip') Then $bClip = True
	If StringInStr($sType, 'clip') And $iScale = Null Then $iScale = 1
	$iMargin    = _OrDefault(_ParseForParam('margin'), 4)
	$iCorrlevel = _OrDefault(_ParseForParam('corrlevel'), 0)
	$iSizePt    = _OrDefault(_ParseForParam('sizept'), 2)
EndIf
If Not $bFile And Not $bResize And Not $bClip Then $bFile = True ; only Text passed
;----------------------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------------------
; detect what to do
If $bFile Or $bResize Then
	If $sFile = Null Then $sFile = $sHome & '\' & _QR_FileDefault()
	$aMatch = StringRegExp($sFile, '\.([a-z]+)$', 1)
	If IsArray($aMatch) Then
		$sFile = StringRegExpReplace($sFile, '(\.[a-z]+)$', '')
		If $sType = Null Then $sType = $aMatch[0]
	EndIf
	If $sType = Null Then $sType = 'png'
	If StringInStr($sType, 'png') Then
		$aCall[$idxCall][0] = '_QR_generatePNG'
		$aCall[$idxCall][1] = _FillArgArray(($bResize ? $aArgsRE_PNG : $aArgsPNG), ($bResize ? 'rpng' : 'png'))
		$idxCall += 1
	EndIf
	If StringInStr($sType, 'bmp') Then
		$aCall[$idxCall][0] = '_QR_generateBMP'
		$aCall[$idxCall][1] = _FillArgArray(($bResize ? $aArgsRE_BMP : $aArgsBMP), ($bResize ? 'rbmp' : 'bmp'))
		$idxCall += 1
	EndIf
EndIf

If $bClip Then
	$aCall[$idxCall][0] = '_QR_copyToClipboard'
	$aCall[$idxCall][1] = _FillArgArray($aArgsCLIP, 'clip')
	$idxCall += 1
EndIf
;----------------------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------------------
; execute operation(s) and generate the output
For $i = 0 To $idxCall -1
;== DEBUG
;~     ConsoleWrite('Call: ' & $aCall[$i][0] & @CRLF)
;==/DEBUG
	Call($aCall[$i][0], $aCall[$i][1])
	$tRes = _QR_getLastCall()
	$sOutputResult &= _OutPutResult($tRes.error, ($aCall[$i][0] = '_QR_copyToClipboard' ? 'CLIPBOARD' : _WinAPI_GetFullPathName($tRes.output)), _
	                                $tRes.width, $tRes.sizept, $tRes.margin, $tRes.corrlevel)
Next
;----------------------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------------------
; write result to console
ConsoleWrite($sOutputResult & @CRLF)
;----------------------------------------------------------------------------------------------------------------



;----------------------------------------------------------------------------------------------------------------
; functions

Func _OutPutResult($_iErr, $_sRes, $_iSize=0, $_iSizePt=0, $_iMargin=0, $_iCorrLevel=0)
	Local $sSize = $_iSize > 0 ? ($_iSize & 'x' & $_iSize) : '0'
	Return (StringFormat('ERROR=%s,RESULT=%s,SIZE=%s,SIZEPT=%d,MARGIN=%d,CORRLEVEL=%d', _
	                          $_iErr, $_sRes, $sSize, $_iSizePt, $_iMargin, $_iCorrLevel) & @CRLF)
EndFunc


Func _FillArgArray($_ar, $_type)
	Switch $_type
		Case 'png', 'bmp'
			$_ar[1] = $sText
			$_ar[2] = $sFile
			$_ar[3] = $iMargin
			$_ar[4] = $iSizePt
			$_ar[5] = $iCorrlevel
		Case 'rpng', 'rbmp'
			$_ar[1] = $sText
			$_ar[2] = $sFile
			$_ar[3] = $iMargin
			$_ar[4] = $iSizePt
			$_ar[5] = $iCorrlevel
			$_ar[6] = $iWidth
		Case 'clip'
			$_ar[1] = $sText
			$_ar[2] = $iMargin
			$_ar[3] = $iSizePt
			$_ar[4] = $iCorrlevel
			$_ar[5] = $iScale
	EndSwitch
	Return $_ar
EndFunc


Func _ParseForParam($_sParam)
	For $i = 1 To $CMDLINE[0]
		$aMatch = StringRegExp($CMDLINE[$i], '([^=]+)=(.+)', 1)
		If IsArray($aMatch) And $aMatch[0] = $_sParam Then Return $aMatch[1]
	Next
	Return Null
EndFunc


Func _OrDefault($_vValue, $_vDefault)
	Return ($_vValue <> Null ? $_vValue : $_vDefault)
EndFunc
;----------------------------------------------------------------------------------------------------------------


