;-- TIME_STAMP   2022-02-28 11:44:58   v 0.2
#include-once
#include <GDIPlus.au3>
#include <WinAPISysWin.au3>

;---------------------------------------------------------------------------------------------------
;  _StatusbarCreate
;    Creates a simple status bar, position default on bottom border, can also be on top border
;  _StatusbarSetText
;    Sets values for one / more parts based on the 0-based index
;  _StatusbarSetAlign
;    Sets the alignment of one or more parts
;  _StatusbarSetColors
;    Sets text and / or background color for one / several parts
;  _StatusbarSetOnEvent
;    Sets OnEvent function for parts by passed indexes (default: all)
;---------------------------------------------------------------------------------------------------

#cs History
    v 0.3   added:  _StatusbarSetOnEvent
            added:  $g_iStatusAlignLeft, holds the default status of a new created part
            fixed:  Error while changig between non-default status (__StatusbarSetPartAlign)
    v 0.2   added:  Font -name, -size, -style definable during creation, valid for the entire status bar
                    Text and/or background color can be set for single/multiple parts
#ce


Global $g_iStatusAlignLeft


; #FUNCTION# ====================================================================================================================
; Name ..........: _StatusbarCreate
; Description ...: Creates a simple status bar
; Parameters ....: $_hWnd        Window in which the status bar is to be created
; ...............: $_vParts      Array or separator-separated string with the width specifications for the parts.
;                                Enter the values for all parts. The last part may be corrected to the remaining space.
;                                For a one-part status bar, "-1" must be passed.
;                                Instead of the exact size, "-1" can be passed, this part(s) will then be calculated proportionally.
;                                E.g: [-1,60,40,-1] are 4 Parts, Part2 = 60, Part3 = 40, Part 1 and 4 share the remaining space.
; ...............: $_vText       Array or separator separated string with the contents for the parts.
; ...............: $_vAlign      Array or separator separated string with the alignment for the parts.
;                                '' or 'l' = left (default), 'c' = centered, 'r' = right. Parts not specified are aligned on the left.
; ...............: $_vFont       Array or separator separated string with "Font", "Size", "Style" (attribute in GUICtrlSetFont)
; ...............: $_bTopBorder  Position of the status bar, default (False): bottom border. With "True" will used the top border.
; ...............: $_sDelim      Separator for $_vParts and $_vText, $_vFont, default: Opt('GuiDataSeparatorChar')
; Return values .: Array with the parts. [[ID-Part1, Text-Part1, Height Bar], [ID-Part2, Text-Part2], .., [ID-PartN, Text-PartN]]
;                  The individual Ctrl of the parts can be addressed directly via ID: $aBar[$Index-0-based][0]
;                  The height of the status bar is saved under: $aBar[0][2] (useful for the following controls when the statusbar is positioned on top)
; Author ........: BugFix
; ===============================================================================================================================
Func _StatusbarCreate($_hWnd, $_vParts=-1, $_vText='', $_vAlign='', $_vFont='', $_bTopBorder=False, $_sDelim=Opt('GuiDataSeparatorChar'))
	If Not IsArray($_vParts) Then ; as string passed
		If StringInStr($_vParts, $_sDelim) Then
			$_vParts = StringSplit($_vParts, $_sDelim, 1+2)
		EndIf
	EndIf
	If Not IsArray($_vParts) Then ; -> one part
		Local $aTmp[] = [-1]
		$_vParts = $aTmp
		Local $aID[1][3]
	Else
		ReDim $_vParts[UBound($_vParts)]
		Local $aID[UBound($_vParts)][3]
	EndIf

	If Not IsArray($_vText) Then
		Local $aText = StringSplit($_vText, $_sDelim, 1+2)
	Else
		Local $aText = $_vText
	EndIf
	If UBound($aText) < UBound($aID) Then ReDim $aText[UBound($aID)] ; sync count of parts

	If Not IsArray($_vAlign) Then
		Local $aAlign = StringSplit($_vAlign, $_sDelim, 1+2)
	Else
		Local $aAlign = $_vAlign
	EndIf
	If UBound($aAlign) < UBound($aID) Then ReDim $aAlign[UBound($aID)] ; sync count of parts

	Local $aFontDef[] = ['Arial','9','0']
	If Not IsArray($_vFont) Then
		If $_vFont = '' Then
			Local $aFont = $aFontDef
		Else
			Local $aFont = StringSplit($_vFont, $_sDelim, 1+2)
		EndIf
	Else
		Local $aFont = $_vFont
	EndIf
	If UBound($aFont) <> 3 Then ; font parameter passed wrong
		Local $aFont = $aFontDef
	EndIf

	; calculate the width
	Local $iWidth = WinGetClientSize($_hWnd)[0]
	Local $iHeigth = WinGetClientSize($_hWnd)[1]
	Local $iDiffBorder = (UBound($aID) -1) *1 ; count of gaps
	Local $iCtrlWidth = $iWidth -$iDiffBorder ; available width for parts
	Local $iRest = $iCtrlWidth                ; remaining width available
	Local $iSum                               ; used width

	; number of parts for automatic width
	Local $iDivisor = 0                       ; divisor for dividing the remaining width
	Local $iPartCorrect = UBound($_vParts) -1 ; the last part is used for correction by default
	If UBound($_vParts) > 1 Then
		For $i = 0 To UBound($_vParts) -1
			If $_vParts[$i] = -1 Then
				$iDivisor += 1
				$iPartCorrect = $i            ; the last part defined with '-1' is used for correction
			Else
				$iRest -= $_vParts[$i]        ; defined width is subtracted from the remaining width
			EndIf
		Next
	Else
		$iDivisor = 1
	EndIf

	Local $iCalcPart = Int($iRest/$iDivisor)  ; width for calculated parts
	For $i = 0 To UBound($_vParts) -1         ; assign width to parts
		If $_vParts[$i] = -1 Then $_vParts[$i] = $iCalcPart
		$iSum += $_vParts[$i]
	Next

	Local $iCorrect = $iCtrlWidth -$iSum      ; correction value, difference can arise through automatic calculation
	$_vParts[$iPartCorrect] += $iCorrect      ; for correction Ctrl correction value is applied

	; determine the height of the bar
	Local $iBarHeight = __MeasureFont($_hWnd, $aFont[0], $aFont[1], $aFont[2])
	If $iBarHeight < 17 Then $iBarHeight = 17

	Local $hWndPrev = GUISwitch($_hWnd)

	Local $x = 0, $y = $iHeigth - $iBarHeight ; positioning the bar
	Local $iDock = 512+64                     ; $GUI_DOCKHEIGHT 512, $GUI_DOCKBOTTOM 64
	$aID[0][2] = $iBarHeight                  ; save height
	If $_bTopBorder Then
		$aID[0][2] += 1                       ; if top-border: add 1 px, starts at y=1
		$y = 1                                ; position on top border
		$iDock = 512+32                       ; $GUI_DOCKHEIGHT 512, $GUI_DOCKTOP 32
	EndIf
    Local $bStatusAlignStored = False
	For $i = 0 To UBound($_vParts) -1
		$aID[$i][0] = GUICtrlCreateLabel('', $x, $y, $_vParts[$i], $iBarHeight, Default, 0x00000200) ; $WS_EX_CLIENTEDGE
		GUICtrlSetResizing(-1, $iDock)
		GUICtrlSetFont(-1, $aFont[1], (BitAND($aFont[2], 1)?600:400), $aFont[2], $aFont[0])
		GUICtrlSetBkColor(-1, 0xFAFAFA)
		$aID[$i][1] = $aText[$i]
        If Not $bStatusAlignStored Then
            Local $aStyle = GUICtrlGetStyle($aID[$i][0])
            $g_iStatusAlignLeft = $aStyle[0]
            $bStatusAlignStored = True
        EndIf
		__StatusbarSetPartAlign($aID, $i, $aAlign[$i]) ; set align and text
		$x += 1+$_vParts[$i]
	Next

	GUISwitch($hWndPrev)

	Return $aID
EndFunc  ;==>_StatusbarCreate


; #FUNCTION# ====================================================================================================================
; Name ..........: _StatusbarSetOnEvent
; Description ...: Sets OnEvent function for parts by passed indexes (default: all)
; Parameters ....: $_aStBar       Return value of _StatusbarCreate
; ...............: $_sOnEventFunc The function that will called if the event occurs.
; ...............: $_iStart       The first index from statusbar parts, that is set to the event (default: 0)
; ...............: $_iEnd         The last index from statusbar parts, that is set to the event (default: -1, the last index)
; Return values .: Success        1
; ...............: Failure        0 @error: 1 - "GUIOnEventMode" is'nt active
; ...............:                          2 - "GUICtrlSetOnEvent" has failed one or more times, @extended = count of fails
; Requirement ...: Opt("GUIOnEventMode") = 1
; Author ........: BugFix
; ===============================================================================================================================
Func _StatusbarSetOnEvent($_aStatusbar, $_sOnEventFunc, $_iStart=0, $_iEnd=-1)
	If Opt("GUIOnEventMode") = 0 Then Return SetError(1,0,0)
	If $_iEnd = -1 Or $_iEnd > (UBound($_aStatusbar) -1) Then $_iEnd = UBound($_aStatusbar) -1
	Local $iRet = 0, $nItem = 0
	For $i = $_iStart To $_iEnd
		$nItem += 1
		$iRet += GUICtrlSetOnEvent($_aStatusbar[$i][0], $_sOnEventFunc)
	Next
	Local $bErr = ($iRet < $nItem)
	Return SetError(($bErr ? 2 : 0), $nItem-$iRet,($bErr ? 0 : 1))
EndFunc  ;==>_StatusbarSetOnEvent



; #FUNCTION# ====================================================================================================================
; Name ..........: _StatusbarSetText
; Description ...: Sets values for one / more parts based on the 0-based index
; Parameters ....: $_aStBar    Return value of _StatusbarCreate
; ...............: $_vParts    Array or separator-separated string with the indices for the part (s) in which the text is to be set.
; ...............: $_vText     Array or separator separated string with the contents for the parts.
; ...............: $_sDelim    Separator for $_vParts and $_vText, default: Opt('GuiDataSeparatorChar')
; Return values .: None
; Author ........: BugFix
; ===============================================================================================================================
Func _StatusbarSetText($_aStBar, $_vParts, $_vText='', $_sDelim=Opt('GuiDataSeparatorChar'))
	If Not IsArray($_vParts) Then
		If StringInStr($_vParts, $_sDelim) Then
			$_vParts = StringSplit($_vParts, $_sDelim, 1+2)
		EndIf
	EndIf
	If IsArray($_vParts) Then
		If Not IsArray($_vText) Then $_vText = StringSplit($_vText, $_sDelim, 1+2)
		If UBound($_vText) < UBound($_vParts) Then ReDim $_vText[UBound($_vParts)]
		For $i = 0 To UBound($_vParts) -1
			__StatusbarSetPartText($_aStBar, $_vParts[$i], $_vText[$i])
		Next
	Else
		__StatusbarSetPartText($_aStBar, $_vParts, $_vText)
	EndIf
EndFunc  ;==>_StatusbarSetText


; #FUNCTION# ====================================================================================================================
; Name ..........: _StatusbarSetAlign
; Description ...: Sets the alignment of one or more parts
; Parameters ....: $_aStBar    Return value of _StatusbarCreate
; ...............: $_vParts    Array or separator separated string with the indices for the part (s) for which the alignment is to be set.
; ...............: $_vAlign    Array or separator separated string with the alignment for the parts.
;                              '' or 'l' = left (default), 'c' = centered, 'r' = right
;                              If more indices are passed than aligns, the remaining parts are aligned on the left.
; ...............: $_sDelim    Separator for $_vParts and $_vAlign, default: Opt('GuiDataSeparatorChar')
; Return values .: None
; Author ........: BugFix
; ===============================================================================================================================
Func _StatusbarSetAlign($_aStBar, $_vParts, $_vAlign='', $_sDelim=Opt('GuiDataSeparatorChar'))
	If Not IsArray($_vParts) Then
		If StringInStr($_vParts, $_sDelim) Then
			$_vParts = StringSplit($_vParts, $_sDelim, 1+2)
		EndIf
	EndIf
	If IsArray($_vParts) Then
		If Not IsArray($_vAlign) Then $_vAlign = StringSplit($_vAlign, $_sDelim, 1+2)
		If UBound($_vAlign) < UBound($_vParts) Then ReDim $_vAlign[UBound($_vParts)]
		For $i = 0 To UBound($_vParts) -1
			__StatusbarSetPartAlign($_aStBar, $_vParts[$i], $_vAlign[$i])
		Next
	Else
		__StatusbarSetPartAlign($_aStBar, $_vParts, $_vAlign)
	EndIf
EndFunc  ;==>_StatusbarSetAlign


; #FUNCTION# ====================================================================================================================
; Name ..........: _StatusbarSetColors
; Description ...: Sets text and / or background color for one / several parts
; Parameters ....: $_aStBar    Return value of _StatusbarCreate
; ...............: $_vParts    Array or separator separated string with the indices for the part (s) for which the color
;                              is to be defined (or individual index). (default: "-1", valid for all parts)
; ...............: $_iCol      Text color (default: 0x000000)
; ...............: $_iBkCol    Background color (default: 0xFFFFFF)
; ...............: $_sDelim    Separator for $_vParts, default: Opt('GuiDataSeparatorChar')
; Return values .: None
; Author ........: BugFix
; ===============================================================================================================================
Func _StatusbarSetColors($_aStBar, $_vParts=-1, $_iCol=0x000000, $_iBkCol=0xFFFFFF, $_sDelim=Opt('GuiDataSeparatorChar'))
	If Not IsArray($_vParts) Then
		If StringInStr($_vParts, $_sDelim) Then
			$_vParts = StringSplit($_vParts, $_sDelim, 1+2)
		ElseIf $_vParts = -1 Then
			Local $aTmp[UBound($_aStBar)]
			For $i = 0 To UBound($aTmp) -1
				$aTmp[$i] = $i
			Next
			$_vParts = $aTmp
		Else
			Local $aTmp[] = [$_vParts]
			$_vParts = $aTmp
		EndIf
	EndIf
	For $i = 0 To UBound($_vParts) -1
		__StatusbarSetPartColors($_aStBar, $_vParts[$i], $_iCol, $_iBkCol)
	Next
EndFunc  ;==>_StatusbarSetColors



#Region - helper functions

Func __StatusbarSetPartText($_aStBar, $_iPart, $_sPart='')
	$_aStBar[$_iPart][1] = $_sPart
	If __IsLeft($_aStBar[$_iPart][0]) Then $_sPart = ' ' & $_sPart
	If __IsRight($_aStBar[$_iPart][0]) Then $_sPart &= ' '
	GUICtrlSetData($_aStBar[$_iPart][0], $_sPart)
EndFunc  ;==>__StatusbarSetPartText

Func __StatusbarSetPartAlign($_aStBar, $_iPart, $_sAlign='')
	Local $aStyle = GUICtrlGetStyle($_aStBar[$_iPart][0])
	Local $iStyle
	Switch $_sAlign
		Case '', 'l' ; left
			$iStyle = $g_iStatusAlignLeft
		Case 'c'     ; center
			$iStyle = BitOR($g_iStatusAlignLeft, 0x01)
		Case 'r'     ; right
			$iStyle = BitOR($g_iStatusAlignLeft, 0x0002)
	EndSwitch
	GUICtrlSetStyle($_aStBar[$_iPart][0], $iStyle, $aStyle[1])
	__StatusbarSetPartText($_aStBar, $_iPart, $_aStBar[$_iPart][1])
EndFunc  ;==>__StatusbarSetPartAlign

Func __StatusbarSetPartColors($_aStBar, $_iPart, $_iCol=0x000000, $_iBkCol=0xFFFFFF)
	If $_iCol = -1 Or $_iCol = Default Then $_iCol = 0x000000
	If $_iBkCol = -1 Or $_iBkCol = Default Then $_iBkCol = 0xFFFFFF
	GUICtrlSetColor($_aStBar[$_iPart][0], $_iCol)
	GUICtrlSetBkColor($_aStBar[$_iPart][0], $_iBkCol)
EndFunc  ;==>__StatusbarSetPartColors

Func __IsLeft($_ID)
	Local $iStyle = GUICtrlGetStyle($_ID)[0]
	Return BitAND($iStyle, BitOR(0x01,0x0002)) = 0
EndFunc  ;==>__IsLeft

Func __IsRight($_ID)
	Local $iStyle = GUICtrlGetStyle($_ID)[0]
	Return BitAND($iStyle, 0x0002) <> 0
EndFunc  ;==>__IsRight


; #FUNCTION# =========================================================================================================
; Name...........: GUICtrlGetStyle
; Description ...: Retrieves the Styles/ExStyles value(s) of the control.
; Syntax.........: GUICtrlGetBkColor($iControlID)
; Parameters ....: $iControlID - A valid control ID.
; Requirement(s).: v3.3.2.0 or higher
; Return values .: Success - Returns an Array[2] = [Style, ExStyle] with the Styles/ExStyles value(s).
;                  Failure - Returns an Array with -1 as the 0 & 1 Index's.
; Author ........: guinness & additional information from Melba23.
; Example........; Yes
;=====================================================================================================================
Func GUICtrlGetStyle($iControlID)
    Local $aArray[2] = [-1, -1], $aExStyle, $aStyle, $hControl = $iControlID
	If Not IsHWnd($hControl) Then $hControl = GUICtrlGetHandle($iControlID)
    $aStyle = DllCall("user32.dll", "long", "GetWindowLong", "hwnd", $hControl, "int", 0xFFFFFFF0)
    If Not @error Then
        $aArray[0] = $aStyle[0]
    EndIf
    $aExStyle = DllCall("user32.dll", "long", "GetWindowLong", "hwnd", $hControl, "int", 0xFFFFFFEC)
    If Not @error Then
        $aArray[1] = $aExStyle[0]
    EndIf
    Return $aArray
EndFunc  ;==>GUICtrlGetStyle

Func __MeasureFont(ByRef $_hWnd, $_sFont='Arial', $_iSize=9, $_iStyle=0)
	_GDIPlus_Startup()
    Local $hFormat = _GDIPlus_StringFormatCreate(0)
    Local $hFamily = _GDIPlus_FontFamilyCreate($_sFont)
    Local $hFont = _GDIPlus_FontCreate($hFamily, $_iSize, $_iStyle, 3)
    Local $tLayout = _GDIPlus_RectFCreate(10, 10, 0, 0)
	Local $hGraphic = _GDIPlus_GraphicsCreateFromHWND($_hWnd)
    Local $aInfo = _GDIPlus_GraphicsMeasureString($hGraphic, 'Äg', $hFont, $tLayout, $hFormat)
;~     Local $iWidth = Ceiling(DllStructGetData($aInfo[0], "Width"))
    Local $iHeight = Ceiling(DllStructGetData($aInfo[0], "Height"))
	_GDIPlus_StringFormatDispose($hFormat)
    _GDIPlus_FontDispose($hFont)
    _GDIPlus_FontFamilyDispose($hFamily)
    _GDIPlus_GraphicsDispose($hGraphic)
    _GDIPlus_ShutDown()
	Return $iHeight
EndFunc  ;==>__MeasureFont

#EndRegion
