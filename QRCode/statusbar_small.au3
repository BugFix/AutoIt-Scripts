;-- TIME_STAMP   2020-04-08 13:39:13   v 0.2
#include-once
#include <GDIPlus.au3>

; #FUNCTION# ====================================================================================================================
; Name ..........: _StatusbarCreate
; Description ...: Erstellt eine einfache Statusbar
; Parameters ....: $_hWnd      Fenster in dem die Statusbar erstellt werden soll
; ...............: $_vParts    Array oder Separator getrennter String mit den Breitenangaben für die Parts.
;                              Anzugeben sind die Werte für alle Parts. Der letzte Part wird ggf. korrigiert auf den verbleibenden Platz.
;                              Für eine einteilige Statusbar ist "-1" zu übergeben.
;                              Statt genauer Größe kann "-1" übergeben werden, diese(r) Part(s) wird/werden dann anteilmäßig berechnet.
;                              Bsp: [-1,60,40,-1] sind 4 Parts, Part2=60, Part3=40, Part 1 und 4 teilen sich den verbleibenden Platz.
; ...............: $_vText     Array oder Separator getrennter String mit den Inhalten für die Parts.
; ...............: $_vAlign    Array oder Separator getrennter String mit der Ausrichtung für die Parts.
;                              '' od. 'l'=links(Standard), 'c'=zentriert, 'r'=rechts. Nicht angegebene Parts werden links ausgerichtet.
; ...............: $_vFont     Array oder Separator getrennter String mit "Font","Size","Style"
; ...............: $_sDelim    Separator für $_vParts und $_vText, $_vFont, Standard: Opt('GuiDataSeparatorChar')
; Return values .: Array mit den Parts. [[ID-Part1,Text-Part1,Höhe Bar],[ID-Part2,Text-Part2],..,[ID-PartN,Text-PartN]]
;                  Die einzelnen Ctrl der Parts sind bei Bedarf direkt ansprechbar über ID: $aBar[$Index-0-basiert][0]
;                  Die Höhe der Statusbar ist gespeichert unter: $aBar[0][2]
; Author ........: BugFix
; ===============================================================================================================================
Func _StatusbarCreate($_hWnd, $_vParts=-1, $_vText='', $_vAlign='', $_vFont='', $_sDelim=Opt('GuiDataSeparatorChar'))
	If Not IsArray($_vParts) Then ; als String übergeben
		If StringInStr($_vParts, $_sDelim) Then
			$_vParts = StringSplit($_vParts, $_sDelim, 1+2)
		EndIf
	EndIf
	If Not IsArray($_vParts) Then ; konnte nicht gesplittet werden -> nur ein Part
		Local $aTmp[] = [-1]
		$_vParts = $aTmp
		Local $aID[1][3]
	Else                          ; als Array übergeben oder gesplitteter String
		ReDim $_vParts[UBound($_vParts)]
		Local $aID[UBound($_vParts)][3] ; [[ID, Text]]    an [0][2] wird die Höhe der StatusBar zurückgegeben
	EndIf

	If Not IsArray($_vText) Then  ; Text als String übergeben
		Local $aText = StringSplit($_vText, $_sDelim, 1+2)
	Else
		Local $aText = $_vText
	EndIf
	If UBound($aText) < UBound($aID) Then ReDim $aText[UBound($aID)] ; anpassen auf Anzahl Parts

	If Not IsArray($_vAlign) Then
		Local $aAlign = StringSplit($_vAlign, $_sDelim, 1+2)
	Else
		Local $aAlign = $_vAlign
	EndIf
	If UBound($aAlign) < UBound($aID) Then ReDim $aAlign[UBound($aID)] ; anpassen auf Anzahl Parts

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
	If UBound($aFont) <> 3 Then ; Fontparameter nicht korrekt übergeben
		Local $aFont = $aFontDef
	EndIf

	; Breite kalkulieren
	Local $iWidth = WinGetClientSize($_hWnd)[0]
	Local $iHeigth = WinGetClientSize($_hWnd)[1]
	Local $iDiffBorder = (UBound($aID) -1) *1 ; Anzahl Zwischenränder
	Local $iCtrlWidth = $iWidth -$iDiffBorder ; für Parts verfügbare Breite
	Local $iRest = $iCtrlWidth                ; restliche verfügbare Breite
	Local $iSum                               ; genutzte Breite

	; wieviel Parts für automatische Breite
	Local $iDivisor = 0                       ; Divisor zum Aufteilen der restlichen Breite
	Local $iPartCorrect = UBound($_vParts) -1 ; standardmäßig wird letzter Part zur Korrektur genutzt
	If UBound($_vParts) > 1 Then
		For $i = 0 To UBound($_vParts) -1
			If $_vParts[$i] = -1 Then
				$iDivisor += 1
				$iPartCorrect = $i            ; der letzte mit '-1' definierte Part wird zur Korrektur genutzt
			Else
				$iRest -= $_vParts[$i]        ; definierte Breite wird von Restbreite abgezogen
			EndIf
		Next
	Else
		$iDivisor = 1
	EndIf

	Local $iCalcPart = Int($iRest/$iDivisor)  ; Breite für kalkulierte Parts
	For $i = 0 To UBound($_vParts) -1         ; Breite den Parts zuweisen
		If $_vParts[$i] = -1 Then $_vParts[$i] = $iCalcPart
		$iSum += $_vParts[$i]
	Next

	Local $iCorrect = $iCtrlWidth -$iSum      ; Korrekturwert, durch autom. Kalkulation kann Diff. entstehen
	$_vParts[$iPartCorrect] += $iCorrect      ; für Korrektur-Ctrl wird Korrekturwert angewendet

	; Höhe der Bar ermitteln
	Local $iBarHeight = __MeasureFont($_hWnd, $aFont[0], $aFont[1], $aFont[2])
	If $iBarHeight < 17 Then $iBarHeight = 17

	Local $x = 0, $y = $iHeigth - $iBarHeight ; Positionierung der Bar
	$aID[0][2] = $iBarHeight                  ; Rückgabe der Höhe
	For $i = 0 To UBound($_vParts) -1
		$aID[$i][0] = GUICtrlCreateLabel('', $x, $y, $_vParts[$i], $iBarHeight, Default, 0x00000200) ; $WS_EX_CLIENTEDGE
		GUICtrlSetResizing(-1, 512+64)  ; $GUI_DOCKHEIGHT 512, $GUI_DOCKBOTTOM 64
		GUICtrlSetFont(-1, $aFont[1], (BitAND($aFont[2], 1)?600:400), $aFont[2], $aFont[0])
		GUICtrlSetBkColor(-1, 0xFAFAFA)
		$aID[$i][1] = $aText[$i]
		__StatusbarSetPartAlign($aID, $i, $aAlign[$i]) ; Align und Text setzen
		$x += 1+$_vParts[$i]
	Next

	Return $aID
EndFunc  ;==>_StatusbarCreate


; #FUNCTION# ====================================================================================================================
; Name ..........: _StatusbarSetText
; Description ...: Setzt Werte für einen/mehrere Parts anhand des 0-basierten Index
; Parameters ....: $_aStBar    Rückgabewert von _StatusbarCreate
; ...............: $_vParts    Array oder Separator getrennter String mit den Indizes für den/die Part(s), in denen der Text
;                              gesetzt werden soll.
; ...............: $_vText     Array oder Separator getrennter String mit den Inhalten für die Parts.
; ...............: $_sDelim    Separator für $_vParts und $_vText, Standard: Opt('GuiDataSeparatorChar')
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
; Description ...: Legt die Ausrichtung eines/mehrerer Parts fest
; Parameters ....: $_aStBar    Rückgabewert von _StatusbarCreate
; ...............: $_vParts    Array oder Separator getrennter String mit den Indizes für den/die Part(s), für die die Ausrichtung
;                              festgelegt werden soll.
; ...............: $_vAlign    Array oder Separator getrennter String mit der Ausrichtung für die Parts.
;                              '' od. 'l'=links(Standard), 'c'=zentriert, 'r'=rechts
;                              Werden mehr Indizes übergeben als Align's, werden die restlichen Parts links ausgerichtet.
; ...............: $_sDelim    Separator für $_vParts und $_vAlign, Standard: Opt('GuiDataSeparatorChar')
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
; Description ...: Setzt Text- und/oder Hintergrundfarbe für einen/mehrere Parts
; Parameters ....: $_aStBar    Rückgabewert von _StatusbarCreate
; ...............: $_vParts    Array oder Separator getrennter String mit den Indizes für den/die Part(s), für die die Farbe
;                              festgelegt werden soll (oder einzelner Index). (Standard: "-1", gültig für alle Parts)
; ...............: $_iCol      Textfarbe (Standard: 0x000000)
; ...............: $_iBkCol    Hintergrundfarbe (Standard: 0xFFFFFF)
; ...............: $_sDelim    Separator für $_vParts, Standard: Opt('GuiDataSeparatorChar')
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


#Region - Hilfsfunktionen

Func __StatusbarSetPartText($_aStBar, $_iPart, $_sPart='')
	$_aStBar[$_iPart][1] = $_sPart
	If __IsLeft($_aStBar[$_iPart][0]) Then $_sPart = ' ' & $_sPart
	If __IsRight($_aStBar[$_iPart][0]) Then $_sPart &= ' '
	GUICtrlSetData($_aStBar[$_iPart][0], $_sPart)
EndFunc  ;==>__StatusbarSetPartText

Func __StatusbarSetPartAlign($_aStBar, $_iPart, $_sAlign='')
	Local $iStyle
	Switch $_sAlign
		Case '', 'l' ; left
			$iStyle = 0x0000
		Case 'c' ; center
			$iStyle = 0x01
		Case 'r' ; right
			$iStyle = 0x0002
	EndSwitch
	GUICtrlSetStyle($_aStBar[$_iPart][0], $iStyle)
	__StatusbarSetPartText($_aStBar, $_iPart, $_aStBar[$_iPart][1])
EndFunc  ;==>__StatusbarSetPartAlign

Func __StatusbarSetPartColors($_aStBar, $_iPart, $_iCol=0x000000, $_iBkCol=0xFFFFFF)
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

Func __MeasureFont(ByRef $_hWnd, $_sFont='Arial', $_sSize=9, $_iStyle=0)
	_GDIPlus_Startup()
    Local $hFormat = _GDIPlus_StringFormatCreate(0)
    Local $hFamily = _GDIPlus_FontFamilyCreate($_sFont)
    Local $hFont = _GDIPlus_FontCreate($hFamily, $_sSize, $_iStyle, 3)
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
