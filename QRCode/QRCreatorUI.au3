;-- TIME_STAMP   2020-05-02 17:16:27   v 0.3

#include "QRCreator.au3"
#include "statusbar_small.au3"
#include <GUIConstants.au3>
#include <GuiSlider.au3>

Opt('MustDeclareVars', 1)

Global $hWnd, $inPath, $btPath, $cbPNG, $inFile, $cbBMP, $cbDummy
Global $r7, $r15, $r25, $r30
Global $editQR
Global $udMargin, $udPtSize, $udScale, $cbResize, $inResize
Global $btPreview, $slPreview, $btCopy2Clip, $btResizeSave, $btFileSave, $btDelete
Global $iValSlider, $aWin

Global $hPreview = GUICreate('QR-Code Preview', -1, -1, -1, -1, BitOR($WS_CAPTION, $WS_SYSMENU))
GUISetBkColor(0xE3E3E3, $hPreview)
Global $iTopBorder, $iSideBorder, $hBitmapPrev, $hGraphicPrev, $hQR_hBitmap
_SystemGetWindowBorder($iTopBorder, $iSideBorder)

Global $bEditEmpty = True, $bPNG = False, $bBMP = False, $iCorrLevel = 0
Global $sPath = @ScriptDir, $sFile, $aMsg, $iErr = 0
Global $aStatusBar

$hWnd = GUICreate("QRCreator User Interface", 500, 570, 150, 100)

GUICtrlCreateGroup(' File Creation ', 10, 10, 480, 83)
GUICtrlCreateLabel('Folder', 25, 33, 50, 17)
$inPath = GUICtrlCreateInput(@ScriptDir, 100, 30, 290, 20, $ES_READONLY)
$btPath = GUICtrlCreateButton('...', 395, 29, 22, 22)
$cbPNG = GUICtrlCreateCheckbox(' *.PNG', 430, 30, 50, 20)
GUICtrlCreateLabel('File (w/o ext.)', 25, 61, 70, 17)
$inFile = GUICtrlCreateInput('', 100, 58, 317, 20)
GUICtrlSendMsg($inFile, 0x1501, 1, "The default name is: QR_YYYYMMDD_hhmmss")
$cbBMP = GUICtrlCreateCheckbox(' *.BMP', 430, 58, 50, 20)
$cbDummy = GUICtrlCreateDummy()
GUICtrlCreateGroup("", -99, -99, 1, 1)

GUICtrlCreateGroup(' Correction up to percentage of damage ', 10, 103, 480, 50)
$r7 = GUICtrlCreateRadio('7 %', 35, 123, 60, 20)
GUICtrlSetState(-1, $GUI_CHECKED)
$r15 = GUICtrlCreateRadio('15 %', 165, 123, 60, 20)
$r25 = GUICtrlCreateRadio('25 %', 305, 123, 60, 20)
$r30 = GUICtrlCreateRadio('30 %', 425, 123, 60, 20)
GUICtrlCreateGroup("", -99, -99, 1, 1)

GUICtrlCreateGroup(' Appearance ', 10, 163, 480, 50)
GUICtrlCreateLabel('Margin size', 35, 186, 60, 17)
$udMargin = GUICtrlCreateInput('4', 95, 183, 50)
GUICtrlCreateUpdown(-1)
GUICtrlSetLimit(-1, 10, 1)
GUICtrlCreateLabel('Size of created points', 250, 186, 110, 17)
$udPtSize = GUICtrlCreateInput('2', 360, 183, 50, 20)
GUICtrlCreateUpdown(-1)
GUICtrlSetLimit(-1, 4, 1)
GUICtrlCreateGroup("", -99, -99, 1, 1)

GUICtrlCreateLabel('Text to encoding:', 10, 223)
$editQR = GUICtrlCreateEdit('', 10, 240, 480, 150, BitOR($ES_WANTRETURN, $ES_MULTILINE, _
                            $WS_VSCROLL, $WS_HSCROLL, $ES_AUTOVSCROLL, $ES_AUTOHSCROLL))

GUICtrlCreateGroup(' Preview ', 10, 400, 220, 118)
$btPreview = GUICtrlCreateButton('Show QR Code', 55, 420, 130, 22)
GUICtrlSetState(-1, $GUI_DISABLE)
$slPreview = GUICtrlCreateSlider(15, 450, 210, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
_GUICtrlSlider_SetRange($slPreview, 1, 12)
_GUICtrlSlider_SetTicFreq($slPreview, 1)

GUICtrlCreateLabel('Increase view size (only optical)' & @LF & _
                   'Increase output with <Copy To Clipboard>', 20, 480, 200, 28)
GUICtrlCreateGroup("", -99, -99, 1, 1)

$cbResize = GUICtrlCreateCheckbox(' Resize file (width in px)', 240, 395, 160, 20)
$inResize = GUICtrlCreateInput('', 240, 420, 80, 20, BitOR($ES_NUMBER,$ES_CENTER))
GUICtrlSetState(-1, $GUI_DISABLE)
$udScale = GUICtrlCreateInput('1', 270, 484, 50, 20)
GUICtrlCreateUpdown(-1)
GUICtrlSetLimit(-1, 12, 1)
GUICtrlCreateLabel('Up scale Clipboard', 245, 509, 130, 17)
$btResizeSave = GUICtrlCreateButton('Save Resized', 345, 420, 130, 22)
GUICtrlSetState(-1, $GUI_DISABLE)
$btFileSave = GUICtrlCreateButton('Save File(s)', 345, 452, 130, 22)
GUICtrlSetState(-1, $GUI_DISABLE)
$btCopy2Clip = GUICtrlCreateButton('Copy To Clipboard', 345, 484, 130, 22)
GUICtrlSetState(-1, $GUI_DISABLE)
$btDelete = GUICtrlCreateButton('Clear All', 345, 520, 130, 22)

$aStatusBar = _StatusbarCreate($hWnd, '75|75|70|-1', '|||', 'c|c|c|l', 'Consolas|10|0')
_StatusbarSetColors($aStatusBar, -1, 0x001FD3)

GUISetState(@SW_SHOW, $hWnd)

AdlibRegister('_EditChanged')
GuiRegisterMsg($WM_COMMAND, 'WM_COMMAND')

While True
	$aMsg = GUIGetMsg(1)
	Switch $aMsg[0]
		Case -3
			If $aMsg[1] = $hWnd Then
				Exit
			Else
				GUICtrlSetState($slPreview, $GUI_DISABLE)
				GUICtrlSetData($slPreview, 1)
			    GuiSetState(@SW_HIDE, $hPreview)
				_GDIPlus_GraphicsDispose($hGraphicPrev)
				_GDIPlus_BitmapDispose($hBitmapPrev)
				_GDIPlus_Shutdown()
			    _WinAPI_DeleteObject($hQR_hBitmap)
			EndIf
		Case $btPath
            $sPath = FileSelectFolder('Selct storage path for QR-Image', '', 7)
            If $sPath = '' Then $sPath = @ScriptDir
			GUICtrlSetData($inPath, $sPath)
		Case $cbPNG, $cbBMP, $cbDummy
			$bPNG = (BitAND(GUICtrlRead($cbPNG), $GUI_CHECKED) = $GUI_CHECKED)
			$bBMP = (BitAND(GUICtrlRead($cbBMP), $GUI_CHECKED) = $GUI_CHECKED)
			If Not $bEditEmpty Then
				If $bPNG Or $bBMP Then
					GUICtrlSetState($btFileSave, $GUI_ENABLE)
					If BitAND(GUICtrlRead($cbResize), $GUI_CHECKED) Then
						GUICtrlSetState($inResize, $GUI_ENABLE)
						GUICtrlSetState($btResizeSave, $GUI_ENABLE)
					EndIf
				Else
					If BitAND(GUICtrlRead($cbResize), $GUI_CHECKED) Then
						GUICtrlSetState($inResize, $GUI_DISABLE)
						GUICtrlSetState($btResizeSave, $GUI_DISABLE)
						GUICtrlSetData($inResize, '')
					EndIf
				EndIf
			Else
				GUICtrlSetState($btFileSave, $GUI_DISABLE)
				GUICtrlSetState($inResize, $GUI_DISABLE)
				GUICtrlSetState($btResizeSave, $GUI_DISABLE)
				GUICtrlSetData($inResize, '')
			EndIf
		Case $r7
			If BitAND(GUICtrlRead($r7), $GUI_CHECKED) Then
				$iCorrLevel = 0
				GUICtrlSetLimit($udPtSize, 4, 1)
				GUICtrlSetData($udPtSize, 2)
			EndIf
		Case $r15
			If BitAND(GUICtrlRead($r15), $GUI_CHECKED) Then
				$iCorrLevel = 1
				GUICtrlSetLimit($udPtSize, 3, 1)
				GUICtrlSetData($udPtSize, 2)
			EndIf
		Case $r25
			If BitAND(GUICtrlRead($r25), $GUI_CHECKED) Then
				$iCorrLevel = 2
				GUICtrlSetLimit($udPtSize, 2, 1)
				GUICtrlSetData($udPtSize, 2)
			EndIf
		Case $r30
			If BitAND(GUICtrlRead($r30), $GUI_CHECKED) Then
				$iCorrLevel = 3
				GUICtrlSetLimit($udPtSize, 1, 1)
				GUICtrlSetData($udPtSize, 1)
			EndIf
		Case $btPreview
			_CreatePreviewBmp()
			If Not @error Then
				_Preview()
			EndIf
		Case $slPreview
			$iValSlider = GUICtrlRead($slPreview)
			GUICtrlSetData($udScale, $iValSlider)
			_Preview($iValSlider)
		Case $btCopy2Clip
			_QR_copyToClipboard(GUICtrlRead($editQR), GUICtrlRead($udMargin), GUICtrlRead($udPtSize), $iCorrLevel, GUICtrlRead($udScale))
			$iErr = @error
			_StatusbarSetColors($aStatusBar, -1, 0x001FD3)
			_StatusBarShowResult()
			If $iErr Then
				MsgBox(262144+16, 'Error', 'QR-Code creation failed by Dll call.' & @CRLF & _
				($iErr = 1 ? 'HBITMAP handle creation failed' : ($iErr = 2 ? 'Clipboard open failed' : 'Clipboard empty failed')))
			Else
				MsgBox(262144+64, 'Success', 'QR-Code was copied to clipboard.')
			EndIf
		Case $cbResize
			If $bPNG Or $bBMP Then
				If BitAND(GUICtrlRead($cbResize), $GUI_CHECKED) And Not $bEditEmpty Then
					GUICtrlSetState($inResize, $GUI_ENABLE)
					GUICtrlSetState($btResizeSave, $GUI_ENABLE)
				Else
					GUICtrlSetState($inResize, $GUI_DISABLE)
					GUICtrlSetState($btResizeSave, $GUI_DISABLE)
					GUICtrlSetData($inResize, '')
				EndIf
			EndIf
		Case $btResizeSave
			Local $iSize = GUICtrlRead($inResize)
			If $iSize =  '' Then
				_StatusbarSetColors($aStatusBar, '1|3', 0xDB0E00)
				_StatusbarSetText($aStatusBar, '0|1|2|3', 'RESIZED|FAILED||NO SIZE PASSED')
				MsgBox(262144+16, 'Error', 'QR-Code file resizing failed.')
			Else
				If $bPNG Then _QR_generatePNG(GUICtrlRead($editQR), _CreateFullPath() & 'png', GUICtrlRead($udMargin), GUICtrlRead($udPtSize), $iCorrLevel, $iSize)
				$iErr = @error
				If $bBMP Then _QR_generateBMP(GUICtrlRead($editQR), _CreateFullPath() & 'bmp', GUICtrlRead($udMargin), GUICtrlRead($udPtSize), $iCorrLevel, $iSize)
				$iErr += @error
				_StatusbarSetColors($aStatusBar, -1, 0x001FD3)
				_StatusBarShowResult()
				If $iErr Then
					MsgBox(262144+16, 'Error', 'QR-Code file resizing failed.')
				Else
					MsgBox(262144+64, 'Success', 'QR-Code file(s) was resized')
				EndIf
			EndIf
		Case $btFileSave
			If $bPNG Then _QR_generatePNG(GUICtrlRead($editQR), _CreateFullPath() & 'png', GUICtrlRead($udMargin), GUICtrlRead($udPtSize), $iCorrLevel)
			$iErr = @error
			If $bBMP Then _QR_generateBMP(GUICtrlRead($editQR), _CreateFullPath() & 'bmp', GUICtrlRead($udMargin), GUICtrlRead($udPtSize), $iCorrLevel)
			$iErr += @error
			_StatusbarSetColors($aStatusBar, -1, 0x001FD3)
			_StatusBarShowResult()
			If $iErr Then
				MsgBox(262144+16, 'Error', 'QR-Code file creation failed.')
			Else
				MsgBox(262144+64, 'Success', 'QR-Code file(s) was created.')
			EndIf
		Case $btDelete
			_SetDefaults()
	EndSwitch
WEnd


Func _CreateFullPath()
	$sFile = GUICtrlRead($inFile)
	If $sFile = '' Then $sFile = _QR_FileDefault()
	If StringRegExp($sFile, '(?i)\.bmp|png') Then $sFile = StringTrimRight($sFile, 4)
	GUICtrlSetData($inFile, $sFile)
	Return StringFormat('%s\%s.', $sPath, $sFile)
EndFunc


Func _StatusBarShowResult()
	Local Static $iRed = 0xDB0E00, $iGreen = 0x289916
	Local $tRes = _QR_getLastCall()
	_StatusbarSetColors($aStatusBar, 1, ($tRes.success ? $iGreen : $iRed))
	Local $aText[4] = [($tRes.type = 'B' ? 'HBMP': ($tRes.type = 'C' ? 'CLIPBOARD' : ($tRes.type = 'R' ? 'RESIZED' : 'FILECREATE'))), _
	                  ($tRes.success ? 'SUCCES' : 'FAILED'), ($tRes.success ? StringFormat('%dx%d', $tRes.width, $tRes.width) : ''), _
					  ($tRes.type = 'F' ? _ShrinkPath($tRes.output) : '')]
	If $tRes.type = 'R' Then
		$aText[3] = ($tRes.width = -1 ? $tRes.output : _ShrinkPath($tRes.output))
		If $tRes.width = -1 Then _StatusbarSetColors($aStatusBar, 3, $iRed)
	EndIf
	_StatusbarSetText($aStatusBar, '0|1|2|3', $aText)
EndFunc


Func _ShrinkPath($_sPath)
	Local $sLeft = StringLeft($_sPath, 3)
	Local $sRight = StringTrimLeft($_sPath, (StringInStr($_sPath, '\', 0, -1) -1))
	Return StringFormat('%s..%s', $sLeft, $sRight)
EndFunc


Func _CreatePreviewBmp()
	Local $hHBITMAP = _QR_getHBitmap(GUICtrlRead($editQR), GUICtrlRead($udMargin), GUICtrlRead($udPtSize), $iCorrLevel)
	If @error Then Return SetError(@error,0,MsgBox(262144+16, 'Error', 'QR-Code creation failed by Dll call.'))
	_GDIPlus_Startup()
	$hQR_hBitmap = $hHBITMAP
	GuiSetState(@SW_SHOWNA, $hPreview)
	GUICtrlSetState($slPreview, $GUI_ENABLE)
EndFunc


Func _Preview($_iScale=1)
	Local Static $iGreen = 0x289916
	$hBitmapPrev = _GDIPlus_BitmapCreateFromHBITMAP($hQR_hBitmap)
	$hBitmapPrev = _GDIPlus_ImageScale($hBitmapPrev, $_iScale, $_iScale, $GDIP_INTERPOLATIONMODE_NEARESTNEIGHBOR)
    Local $iWidth, $iW = _GDIPlus_ImageGetWidth($hBitmapPrev)
	$iWidth = $iW
	WinSetTitle($hPreview, '', 'QR-Code Preview  [ *' & $_iScale & ' ]')
	If $iWidth < 250 Then $iWidth = 250
	$aWin = WinGetPos($hWnd)
	WinMove($hPreview, '', $aWin[0]+$aWin[2]+20, $aWin[1], 2*$iSideBorder+2*10+$iWidth, $iTopBorder+2*10+$iWidth+$iSideBorder)
	_GDIPlus_GraphicsClear($hGraphicPrev, 0xFFE3E3E3)
    $hGraphicPrev = _GDIPlus_GraphicsCreateFromHWND($hPreview)
    _GDIPlus_GraphicsDrawImage($hGraphicPrev, $hBitmapPrev, 10, 10)
	Local $aText[] = ['PREVIEW','SUCCESS',StringFormat('%dx%d', $iW, $iW), '']
	_StatusbarSetText($aStatusBar, '0|1|2|3', $aText)
	_StatusbarSetColors($aStatusBar, -1, 0x001FD3)
	_StatusbarSetColors($aStatusBar, 1, $iGreen)

	; ==== debugging
;~ 	__consoleResults()
	; ==============
EndFunc


Func _EditChanged()
	Local Static $bLastEmpty = True
	If $bEditEmpty = $bLastEmpty Then Return
	$bLastEmpty = $bEditEmpty
	GUICtrlSendToDummy($cbDummy) ; init a checkbox event to en/disable $btFileSave
	If $bEditEmpty Then
		GUICtrlSetState($btPreview, $GUI_DISABLE)
		GUICtrlSetState($slPreview, $GUI_DISABLE)
		GUICtrlSetState($btCopy2Clip, $GUI_DISABLE)
		GUICtrlSetState($inResize, $GUI_DISABLE)
		GUICtrlSetData($inResize, '')
	Else
		GUICtrlSetState($btPreview, $GUI_ENABLE)
		GUICtrlSetState($btCopy2Clip, $GUI_ENABLE)
		If BitAND(GUICtrlRead($cbResize), $GUI_CHECKED) Then _
			GUICtrlSetState($inResize, $GUI_ENABLE)
	EndIf
EndFunc


Func _SetDefaults()
	GuiSetState(@SW_HIDE, $hPreview)
	GUICtrlSetState($cbPNG, $GUI_UNCHECKED)
	GUICtrlSetState($cbBMP, $GUI_UNCHECKED)
	GUICtrlSetState($cbResize, $GUI_UNCHECKED)
	GUICtrlSetState($r7, $GUI_CHECKED)
	GUICtrlSetState($btPreview, $GUI_DISABLE)
	GUICtrlSetState($slPreview, $GUI_DISABLE)
	GUICtrlSetState($btCopy2Clip, $GUI_DISABLE)
	GUICtrlSetState($btFileSave, $GUI_DISABLE)
	GUICtrlSetState($inResize, $GUI_DISABLE)
	GUICtrlSetData($inPath, @ScriptDir)
	GUICtrlSetData($inFile, '')
	GUICtrlSetData($udMargin, 4)
	GUICtrlSetData($udPtSize, 2)
	GUICtrlSetData($udScale, 1)
	GUICtrlSetData($editQR, '')
	GUICtrlSetData($slPreview, 0)
	GUICtrlSetData($inResize, '')
	$bEditEmpty = True
	$bPNG = False
	$bBMP = False
	$iCorrLevel = 0
	$iErr = 0
	_StatusbarSetText($aStatusBar, '0|1|2|3', '|||')
	_StatusbarSetColors($aStatusBar, -1, 0x001FD3)
EndFunc


Func WM_COMMAND($hWnd, $iMsg, $iwParam, $ilParam)
    Local $hWndFrom = $ilParam
    Local $hWndEdit = GUICtrlGetHandle($editQR)
    Local $iCode = BitShift($iwParam, 16)
    Switch $hWndFrom
        Case $hWndEdit
            Switch $iCode
                Case $EN_CHANGE
						If StringLen(GUICtrlRead($editQR)) = 0 Then
							$bEditEmpty = True
						Else
							$bEditEmpty = False
						EndIf
            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc


Func _SystemGetWindowBorder(ByRef $_iTopBorder, ByRef $_iSideBorder)
	Local Const $SM_CYCAPTION = 4, $SM_CYEDGE = 46, $SM_CYBORDER = 6, $SM_CXBORDER = 5, $SM_CXEDGE = 45
	Local $aMetrics[5][2] = [[$SM_CYCAPTION], [$SM_CYEDGE], [$SM_CYBORDER], [$SM_CXBORDER], [$SM_CXEDGE]]
	Local $dll = DllOpen("user32.dll"), $aRet
	For $i = 0 To 4
		$aRet = DllCall($dll, "int", "GetSystemMetrics", "int", $aMetrics[$i][0])
		If IsArray($aRet) Then $aMetrics[$i][1] = $aRet[0]
	Next
	DllClose($dll)
	$_iTopBorder  = $aMetrics[0][1] + $aMetrics[1][1] + $aMetrics[2][1]
	$_iSideBorder = $aMetrics[3][1] + $aMetrics[4][1]
EndFunc


; only for debugging
Func __consoleResults()
	Local $tRes = _QR_getLastCall()
	ConsoleWrite('.success   ' & $tRes.success   & @CRLF)
	ConsoleWrite('.error     ' & $tRes.error     & @CRLF)
	ConsoleWrite('.width     ' & $tRes.width     & @CRLF)
	ConsoleWrite('.type      ' & $tRes.type      & @CRLF)
	ConsoleWrite('.output    ' & $tRes.output    & @CRLF)
	ConsoleWrite('.margin    ' & $tRes.margin    & @CRLF)
	ConsoleWrite('.sizept    ' & $tRes.sizept    & @CRLF)
	ConsoleWrite('.corrlevel ' & $tRes.corrlevel & @CRLF & @CRLF)
EndFunc

