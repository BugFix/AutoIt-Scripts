;-- TIME_STAMP   2022-04-25 18:58:22   v 0.14

#cs     GroupEx.au3
    You can create a group with:
    • Title
        - Textcolor                         (can be changed)
        - Fontname and -size                (cannot be changed later)
        - Alignment: Left, Centered, Right  (can be changed)
    • Group Area
        - Backgroundcolor                   (can be changed)
    • Border
        - Coloring for each part            (can be changed)
        - Draw:
        - Single border element, i.e. "$_GROUPBORDER_TOPL = top border left from title"
        - Combination of border parts, i.e. "BitOR($_GROUPBORDER_TOPL,$_GROUPBORDER_LEFT) = left from title and the left border"
        - All parts: $_GROUPBORDER_ALL
    • Activate/deactivate the group and (if passed) also the controls contained in it.
    • Moves a group and (if passed) also the controls contained in it with absolute or relative position.
    • Change the groups size with absolute or relative values.
#ce

#cs     History
v 0.14:
    SCRIPT BREAKING CHANCE: The parents GUI no longer needs to be specified.
    changed     - The create function itself recognizes its parent handle.
    changed     - The measurement of the title dimension has been optimized.
    added       - _GuiCtrlGroup_Create() can specify the fontname and -size for the group title.
                  For this purpose, on the title is appended in angle brackets: "<FontName;FontSize>", i.e. "My-Title<Consolas;10>"
                  Angle brackets inside the title must be masked: "\<something\>".
                  Font name and size can only be specified during creation and are then unchangeable!

v 0.12:
    changed     - Disabling/Enabling color management optimized
    fixed       - Flickering on Enable inside - Ctrl removed
    added       - Integration Systemcolor query

v 0.11:
    added       - When Disabling/Enabling, the previous color of text and group area is automatically saved (values no longer returned).
                  Color values can be passed optionally.
                  Without values (or with 'Null') the default values for Disable or the previous Enable colors are used.

v 0.10:
    changed     - Moving and status setting of non-native controls is now possible.
    fixed       - Error while Disable/Enable (non clickable controls)

v 0.8:
    SCRIPT BREAKING CHANCE: Count and type of parameters has changed
    added       - _GuiCtrlGroup_SetState()
                  Sets the state for the group (ENABLE/DISABLE/HIDE/SHOW) and optionally for controls within the group (passed as array).
                  With Disable the color for title text and group background can be passed in the Disable state.
                  There are default values (shades of gray) that are used if no value is passed (see constants in script header).
                  The previous colors are returned and can then be used again on Enable.
    added       - When creating the group, Italic can already be selected as font style (combinable with alignment).
    added       - When moving the group, the contained controls (passed as array) can be moved as well.
    changed     - In _GuiCtrlGroup_Create: "$_iAlign" replaced with "$_iTitleParam" (combinable alignment with style)
                - In _GuiCtrlGroup_Set: The GUI handle is no longer needed. Additional optional parameter "$_aCtrlInside" for moving controls with the group.

v 0.7:
    fixed       - Bug while painting controls inside the group area outside the main GUI

v 0.6:
    SCRIPT BREAKING CHANCE: New parameter for "_GuiCtrlGroup_Create".
    fixed       - Bug with using on multiple GUI.

v 0.5:
    added       Titel can be placed as: $_GROUPTEXT_LEFT (Default), $_GROUPTEXT_CENTER, $_GROUPTEXT_RIGHT
                - use the action flag as additional parameter "$_iTitleParam" with _GuiCtrlGroup_Create()
                - use _GuiCtrlGroup_Set() with empty string as value and action flag "$_GROUPTEXT_LEFT/_CENTER/_RIGHT"
                - set titel combined with alignment: _GuiCtrlGroup_Set($group, 'New-Title', BitOr($_GROUPTEXT_TEXT, $_GROUPTEXT_LEFT/_CENTER/_RIGHT))

v 0.3:
    added       The group control is now moveable with action flags
                - $_GROUPMOVE_ABS (values absolute in the child window) or
                - $_GROUPMOVE_REL (parameter relative to last position/size)
                Parameters can be passed as array or comma separated string. Use "*" for parameters that should not be changed.
                Sequence: x, y, width, height
                Pass only required parameters in the order from left. If only the y-position is to be changed, pass: "*,y".

v 0.2:
    changed     The following operations need no value for parameter "$_vValue". Use empty string.
                - The text can be set to italic style with the $_GROUPTEXT_ITALIC action flag.
                - With flag $_GROUPTEXT_DEFAULT the style is canceled again.
                - BackColor of the text label can be set from color back to transparency with the $_GROUPTEXT_TRANS flag.

#ce


#include-once
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPIGdi.au3>
#include <WinAPI.au3>

; == border color settings
Global Const $_GROUPBORDER_LEFT     = 0x000001   ; == left border
Global Const $_GROUPBORDER_TOPL     = 0x000002   ; == top border left from title
Global Const $_GROUPBORDER_TOPR     = 0x000004   ; == top border right from title
Global Const $_GROUPBORDER_TOP      = BitOR($_GROUPBORDER_TOPL,$_GROUPBORDER_TOPR)  ; == top border
Global Const $_GROUPBORDER_RIGHT    = 0x000008   ; == right border
Global Const $_GROUPBORDER_BOTTOM   = 0x000010   ; == bottom border
Global Const $_GROUPBORDER_ALL      = BitOR($_GROUPBORDER_LEFT,$_GROUPBORDER_TOP,$_GROUPBORDER_RIGHT,$_GROUPBORDER_BOTTOM)  ; == full border

; == text settings
Global Const $_GROUPTEXT_FORE       = 0x000020   ; == sets text fore color
Global Const $_GROUPTEXT_BACK       = 0x000040   ; == sets text BG-color, should be $GUI_BKCOLOR_TRANSPARENT (default), if Group BG-color is diffent to GUI BG-color or same as Group BG-color
Global Const $_GROUPTEXT_TRANS      = 0x000080   ; == sets text BG-color to $GUI_BKCOLOR_TRANSPARENT
Global Const $_GROUPTEXT_TEXT       = 0x000100   ; == sets the title text
Global Const $_GROUPTEXT_ITALIC     = 0x000200   ; == sets text style to italic
Global Const $_GROUPTEXT_DEFAULT    = 0x000400   ; == sets text style back to normal
Global Const $_GROUPTEXT_LEFT       = 0x000800   ; == sets text position to left side (default)
Global Const $_GROUPTEXT_CENTER     = 0x001000   ; == sets text position centered
Global Const $_GROUPTEXT_RIGHT      = 0x002000   ; == sets text position to right side

; == background color group
Global Const $_GROUPBACKGROUND      = 0x004000   ; == sets BG-color inside border area

; == move the whole control
Global Const $_GROUP_MOVE_ABS       = 0x008000   ; == give param as array [x,y,width,height], values that should not change set to "*"
                                                 ;    you can also give values as comma seperated string: "x,y,width,height"
                                                 ;    y,width,height by default has value "*", so you can omit them if not need to change
                                                 ;    (values absolute in the child window)
Global Const $_GROUP_MOVE_REL       = 0x010000   ; == same as before, but given values relative to current position/size

; == default disabling colors
Global Const $_GROUP_DISABLE_BGDEF  = 0xFAFAFA   ; == the default background color value, if disabling the group
Global Const $_GROUP_DISABLE_TXTDEF = _WinAPI_GetSysColor($COLOR_GRAYTEXT) ; == the default title color value, if disabling the group

; == get system metrics
Global $_giTop, $_giSide
__SystemGetWindowBorder($_giTop, $_giSide)

; == get system colors
Global Const $_giActiveWindowBG     = _WinAPI_GetSysColor($COLOR_MENU)  ; "$COLOR_WINDOW - Window background" should be the right, but gives the wrong color.
Global Const $_giEnabledText        = _WinAPI_GetSysColor($COLOR_WINDOWTEXT)
Global Const $_giActiveBorder       = _WinAPI_GetSysColor($COLOR_ACTIVEBORDER)

; #FUNCTION# ====================================================================================================================
; Name ..........: _GuiCtrlGroup_Create
; Description ...: Creates a group control as collection of labels
; Syntax ........: _GuiCtrlGroup_Create($_sText, $_iX, $_iY, $_iWidth, $_iHeight[, $_iBorderCol = -1[, $_iForeCol = -1[,
;                  $_iBackCol = -1[, $_iTitleParam=$_GROUPTEXT_LEFT]]]])
; Parameters ....: $_sText              - Titel, optional: "Titel<FontName;FontSize>", i.e. "Courier New;10"
;                                         Font name and size can only be specified during creation and are then unchangeable!
;                  $_iX                 - x position
;                  $_iY                 - y position, its the value for top of the title - border starts at: y +7
;                  $_iWidth             - width
;                  $_iHeight            - height, its the height from top of title to bottom border
;                  $_iBorderCol         - [optional] Color for all border elements. Keyword Default = $COLOR_ACTIVEBORDER, -1 = System (invisible)
;                  $_iForeCol           - [optional] Title text color. Default is -1 (System).
;                  $_iBackCol           - [optional] Group area background color. Default is -1 (System).
;                  $_iTitleParam        - [optional] Title align left (default), centered or right or combined with italic style: BitOr($_CONST_ALIGN_, $_GROUPTEXT_ITALIC)
;                                         Because $_GROUPTEXT_LEFT is the default alignment, you can use $_GROUPTEXT_ITALIC alone, to set italic style left aligned.
; Return values .: Structure with IDs and settings of all group elements
; Author ........: BugFix
; ===============================================================================================================================
Func _GuiCtrlGroup_Create($_sText, $_iX, $_iY, $_iWidth, $_iHeight, $_iBorderCol=Default, $_iForeCol=-1, $_iBackCol=-1, $_iTitleParam=$_GROUPTEXT_LEFT)
    Local $idDummy = GUICtrlCreateLabel('',0, 0, 1, 1) ; dummy control creation to get the current gui handle
    Local $hGui = _WinAPI_GetParent(GUICtrlGetHandle($idDummy))
    GUICtrlDelete($idDummy)

    $_iY += 7
    Local $guiTmp = GUICreate('TEMP')
    Local $idText, $aSize[1]
    Local $aTextFont, $aFontSize, $sFont = '', $iSize = 8.5, $iH = 17
    If $_sText <> '' Then
        $_sText = StringRegExpReplace(StringRegExpReplace($_sText, '\\<', Chr(1)), '\\>', Chr(2))
        If StringRegExp($_sText, '(.+)(<[^>]+>)$') Then
            $aTextFont = StringRegExp($_sText, '(.+)(<[^>]+>)$', 3)
            $_sText = $aTextFont[0]
            $aFontSize = StringRegExp($aTextFont[1], '([\w ]+);?(\d*)',3)
            $sFont = $aFontSize[0]
            If $aFontSize[1] <> '' Then $iSize = $aFontSize[1]
        EndIf
        $_sText = StringReplace(StringReplace($_sText, Chr(1), '<'), Chr(2), '>')
        GUISetFont($iSize, 400, (BitAND($_iTitleParam, $_GROUPTEXT_ITALIC) ? 2 : 0), $sFont, $guiTmp)
        $idText = GUICtrlCreateLabel('  ' & $_sText, 0, 0)
        $aSize = ControlGetPos($guiTmp, '', $idText)
        If $aSize[3] > 17 Then $iH = $aSize[3]
        GUICtrlDelete($idText)
    Else
        ReDim $aSize[3]
        $aSize[2] = 0
    EndIf
    GUIDelete($guiTmp)
    Local $hPrev = GUISwitch($hGui)
    If $aSize[2] > $_iWidth -12 Then $aSize[2] = $_iWidth -12
    Local $dLeft = 10
    If $aSize[2] > 0 Then
        If BitAND($_iTitleParam, $_GROUPTEXT_CENTER) Then
            $dLeft = Int(($_iWidth-$aSize[2])/2)
        ElseIf BitAND($_iTitleParam, $_GROUPTEXT_RIGHT) Then
            $dLeft = $_iWidth-10-$aSize[2]
        EndIf
    EndIf
    Local $idBG     = GUICtrlCreateLabel('', $_iX+1, $_iY+1, $_iWidth-2, $_iHeight-2-7)
    If $_iBackCol > -1 Then GUICtrlSetBkColor($idBG, $_iBackCol)
    GUICtrlSetState($idBG, $GUI_DISABLE)
    Local $idLeft   = GUICtrlCreateLabel('', $_iX,                  $_iY,             1,                         $_iHeight-7)
    Local $idTopL   = GUICtrlCreateLabel('', $_iX+1,                $_iY,             $dLeft-1,                  1)
    Local $idTopR   = GUICtrlCreateLabel('', $_iX+$dLeft+$aSize[2], $_iY,             $_iWidth-$aSize[2]-$dLeft, 1)
    Local $idRight  = GUICtrlCreateLabel('', $_iX+$_iWidth,         $_iY,             1,                         $_iHeight-7)
    Local $idBottom = GUICtrlCreateLabel('', $_iX+1,                $_iY+$_iHeight-7, $_iWidth,                  1)
    If IsKeyword($_iBorderCol) Then $_iBorderCol = $_giActiveBorder
    If $_iBorderCol > -1 Then
        GUICtrlSetBkColor($idLeft,   $_iBorderCol)
        GUICtrlSetBkColor($idTopL,   $_iBorderCol)
        GUICtrlSetBkColor($idTopR,   $_iBorderCol)
        GUICtrlSetBkColor($idRight,  $_iBorderCol)
        GUICtrlSetBkColor($idBottom, $_iBorderCol)
    EndIf
    If $_sText <> '' Then $_sText = '  ' & $_sText
    $idText = GUICtrlCreateLabel($_sText, $_iX+$dLeft, $_iY-7, $aSize[2], $iH)
    GUICtrlSetBkColor($idText, $GUI_BKCOLOR_TRANSPARENT)
    GUICtrlSetFont($idText, $iSize, 400, (BitAND($_iTitleParam, $_GROUPTEXT_ITALIC) ? 2 : 0), $sFont)
    If $_iForeCol > -1 Then GUICtrlSetColor($idText, $_iForeCol)
    Local $iLenFont = $sFont = '' ? 1 : StringLen($sFont)
    Local $tagGROUP = "int Text;int Left;int TopL;int TopR;int Right;int Bottom;int Background;int Align;int BGPrev;int TextPrev;float FontSize;char FontName[" & $iLenFont & "]"
    Local $tGROUP   = DllStructCreate($tagGROUP)
    $tGROUP.Text = $idText
    $tGROUP.Left = $idLeft
    $tGROUP.TopL = $idTopL
    $tGROUP.TopR = $idTopR
    $tGROUP.Right = $idRight
    $tGROUP.Bottom = $idBottom
    $tGROUP.Background = $idBG
    $tGROUP.Align = BitXOR($_iTitleParam, $_GROUPTEXT_ITALIC)
    $tGROUP.BGPrev = ($_iBackCol = -1 ? $_giActiveWindowBG : $_iBackCol)
    $tGROUP.TextPrev = ($_iForeCol = -1 ? $_giEnabledText : $_iForeCol)
    $tGROUP.FontSize = $iSize
    $tGROUP.FontName = $sFont
    GUIStartGroup()
    GUISwitch($hPrev)
    Return $tGROUP
EndFunc  ;==>_GuiCtrlGroup_Create


; #FUNCTION# ====================================================================================================================
; Name ..........: _GuiCtrlGroup_Close
; Description ...: Starts a new group and so the previous group will closed
; Syntax ........: _GuiCtrlGroup_Close()
; Return values .: None
; Note ..........: Only required, if outside the group radio buttons following. But it can used to close each group.
; Author ........: BugFix
; ===============================================================================================================================
Func _GuiCtrlGroup_Close()
    GUIStartGroup()
EndFunc  ;==>_GuiCtrlGroup_Close


; #FUNCTION# ====================================================================================================================
; Name ..........: _GuiCtrlGroup_Set
; Description ...: Changes values of a _GuiCtrlGroup_Create() created control.
; Syntax ........: _GuiCtrlGroup_Set(ByRef $_structGroup, $_vValue, $_constFlag, $_aCtrlInside)
; Parameters ....: $_structGroup        - Return value from _GuiCtrlGroup_Create()
;                  $_vValue             - The new value, maybe an empty string with some flag.
;                  $_constFlag          - The const to identify the action (see constants at top)
;                  $_aCtrlInside        - [optional] With action flag $_GROUP_MOVE_ABS/$_GROUP_MOVE_REL you can give an array of controls
;                                         (or a single control variable) inside this group. This controls will moved too with the delta x/y values.
; Return values .: None
; Author ........: BugFix
; ===============================================================================================================================
Func _GuiCtrlGroup_Set(ByRef $_structGroup, $_vValue, $_constFlag, $_aCtrlInside= Null)
    Local $hWndGui = _WinAPI_GetParent(GUICtrlGetHandle($_structGroup.Background))
    Local $idText       = $_structGroup.Text
    Local $idLeft       = $_structGroup.Left
    Local $idTopL       = $_structGroup.TopL
    Local $idTopR       = $_structGroup.TopR
    Local $idRight      = $_structGroup.Right
    Local $idBottom     = $_structGroup.Bottom
    Local $idBackground = $_structGroup.Background
    Local $iAlign       = $_structGroup.Align
    Local $iSize        = $_structGroup.FontSize
    Local $sFont        = $_structGroup.FontName
    Local $aSize, $aBott, $sTitle
    If BitAND($_constFlag, $_GROUPBORDER_LEFT)   Then GUICtrlSetBkColor($idLeft,       $_vValue)
    If BitAND($_constFlag, $_GROUPBORDER_TOPL)   Then GUICtrlSetBkColor($idTopL,       $_vValue)
    If BitAND($_constFlag, $_GROUPBORDER_TOPR)   Then GUICtrlSetBkColor($idTopR,       $_vValue)
    If BitAND($_constFlag, $_GROUPBORDER_RIGHT)  Then GUICtrlSetBkColor($idRight,      $_vValue)
    If BitAND($_constFlag, $_GROUPBORDER_BOTTOM) Then GUICtrlSetBkColor($idBottom,     $_vValue)
    If BitAND($_constFlag, $_GROUPBACKGROUND)    Then
        GUICtrlSetBkColor($idBackground, $_vValue)
        $_structGroup.BGPrev = $_vValue
    EndIf
    If BitAND($_constFlag, $_GROUPTEXT_FORE)     Then
        GUICtrlSetColor($idText, $_vValue)
        $_structGroup.TextPrev = $_vValue
    EndIf
    If BitAND($_constFlag, $_GROUPTEXT_BACK)     Then GUICtrlSetBkColor($idText, $_vValue)
    If BitAND($_constFlag, $_GROUPTEXT_TRANS)    Then GUICtrlSetBkColor($idText, $GUI_BKCOLOR_TRANSPARENT)
    If BitAND($_constFlag, $_GROUPTEXT_ITALIC)   Then GUICtrlSetFont   ($idText, $iSize, Default, 2, $sFont)
    If BitAND($_constFlag, $_GROUPTEXT_DEFAULT)  Then GUICtrlSetFont   ($idText, $iSize, Default, Default, $sFont)
    GUISetState(@SW_LOCK, $hWndGui)
    If BitAND($_constFlag, BitOR($_GROUPTEXT_LEFT,$_GROUPTEXT_CENTER,$_GROUPTEXT_RIGHT,$_GROUPTEXT_TEXT)) Then
        If $_constFlag = $_GROUPTEXT_TEXT Then $_constFlag = BitOR($_GROUPTEXT_TEXT, $iAlign)
        $aSize = ControlGetPos($hWndGui, '', $idLeft)
        $aBott = ControlGetPos($hWndGui, '', $idBottom)
        Local $x = $aSize[0], $y = $aSize[1]
        If $_vValue = '' Then
            If BitAND($_constFlag, BitOR($_GROUPTEXT_LEFT,$_GROUPTEXT_CENTER,$_GROUPTEXT_RIGHT)) Then
                $aSize = ControlGetPos($hWndGui, '', $idText)
            Else
                $aSize[2] = 0
            EndIf
        Else
            Local $guiTmp = GUICreate('')
            GUISwitch($guiTmp)
            GUISetFont($iSize, 400, (BitAND($_constFlag, $_GROUPTEXT_ITALIC) ? 2 : 0), $sFont, $guiTmp)
            Local $idTmp = GUICtrlCreateLabel('  ' & $_vValue, 0, 0)
            $aSize = ControlGetPos($guiTmp, '', $idTmp)
            GUICtrlDelete($idTmp)
            GUISwitch($hWndGui)
            GUIDelete($guiTmp)
        EndIf
        Local $dLeft = 10
        If $aSize[2] > $aBott[2] -12 Then $aSize[2] = $aBott[2] -12
        If $aSize[2] > 0 Then
            If BitAND($_constFlag, $_GROUPTEXT_CENTER) Then $dLeft = Int(($aBott[2]-$aSize[2])/2)
            If BitAND($_constFlag, $_GROUPTEXT_RIGHT)  Then $dLeft = $aBott[2]-10-$aSize[2]
        EndIf
        GUICtrlSetPos($idTopL, $x+1,                $y,   $dLeft-1,                     1)
        GUICtrlSetPos($idTopR, $x+$dLeft+$aSize[2], $y,   $aBott[2]+2-$aSize[2]-$dLeft, 1)
        GUICtrlSetPos($idText, $x+$dLeft,           $y-7, $aSize[2],                    17)
        If BitAND($_constFlag, $_GROUPTEXT_TEXT) Then
            If $_vValue <> '' Then $_vValue = '  ' & $_vValue
            GUICtrlSetData($idText, $_vValue)
        EndIf
    EndIf
    If BitAND($_constFlag, BitOR($_GROUP_MOVE_ABS,$_GROUP_MOVE_REL)) Then
        If Not IsArray($_vValue) Then $_vValue = StringSplit($_vValue, ',', 2)
        If UBound($_vValue) < 4 Then
            ReDim $_vValue[4]
            For $i = 1 To 3
                If $_vValue[$i] = '' Then $_vValue[$i] = '*'
            Next
        EndIf
        Local $bRel = False
        If BitAND($_constFlag, $_GROUP_MOVE_REL) Then $bRel = True
        Local $aDelta = __SubCtrlMove($hWndGui, $_structGroup, $_vValue, $bRel, $iAlign)
        ; if an array with controls from inside the group is given - move them too
        If $_aCtrlInside <> Null Then
            If Not IsArray($_aCtrlInside) Then
                Local $aTmp[1] = [$_aCtrlInside]
                $_aCtrlInside = $aTmp
            EndIf
            Local $aSize, $dX = $aDelta[0], $dY = $aDelta[1], $bhWnd, $opt = AutoitSetOption('GUICoordMode', 1)
            For $i = 0 To UBound($_aCtrlInside) -1
                $bhWnd = False
                If IsHWnd($_aCtrlInside[$i]) Then
                    $bhWnd = True
                    $aSize = WinGetPos($_aCtrlInside[$i])
                Else
                    $aSize = ControlGetPos($hWndGui, '', $_aCtrlInside[$i])
                EndIf
                __ControlMove($hWndGui, $bhWnd, $_aCtrlInside[$i], $aSize, $dX, $dY)
            Next
            AutoitSetOption('GUICoordMode', $opt)
        EndIf
    EndIf
    DllCall("user32.dll", "bool", "RedrawWindow", "hwnd", $hWndGui, "struct*", 0, "handle", 0, "uint", 5)
    GUISetState(@SW_UNLOCK, $hWndGui)
EndFunc  ;==>_GuiCtrlGroup_Set


; #FUNCTION# ====================================================================================================================
; Name ..........: _GuiCtrlGroup_SetState
; Description ...: Changes the state of a _GuiCtrlGroup_Create() created control.
; Syntax ........: _GuiCtrlGroup_SetState(ByRef $_structGroup, $_iState, $_aCtrlInside, $_iTxtColor, $_iBGColor)
; Parameters ....: $_structGroup        - Return value from _GuiCtrlGroup_Create()
;                  $_iState             - The new state ($GUI_SHOW, $GUI_HIDE, $GUI_ENABLE, $GUI_DISABLE)
;                  $_aCtrlInside        - [optional] When you pass an array of controls (or a single control variable), they are set to the same state as the group itself.
;                  $_iTxtColor          - [optional] The title color if set to disable/enable. With 'Null' the default/previous color will used. "-1" uses the system color.
;                  $_iBGColor           - [optional] The background color if set to disable/enable. With 'Null' the default/previous color will used. "-1" uses the system color.
; Return values .: Failure              - returns -1, sets @error = 1 (Wrong state value)
; Author ........: BugFix
; ===============================================================================================================================
Func _GuiCtrlGroup_SetState(ByRef $_structGroup, $_iState, $_aCtrlInside=Null, $_iTxtColor=Null, $_iBGColor=Null)
    If Not BitAND(BitOR($GUI_SHOW, $GUI_HIDE, $GUI_ENABLE, $GUI_DISABLE), $_iState) Then Return SetError(1,0,-1)
    Local Static $aState[4][2] = [[$GUI_SHOW, @SW_SHOW], [$GUI_HIDE, @SW_HIDE], [$GUI_ENABLE, @SW_ENABLE], [$GUI_DISABLE, @SW_DISABLE]]
    Local $hWndGui = _WinAPI_GetParent(GUICtrlGetHandle($_structGroup.Background))
    Switch $_iState  ; select the colors to set in the new state
        Case $GUI_DISABLE
            If $_iTxtColor = Null Then $_iTxtColor = $_GROUP_DISABLE_TXTDEF
            If $_iBGColor = Null Then $_iBGColor = $_GROUP_DISABLE_BGDEF
        Case $GUI_ENABLE
            If $_iTxtColor = Null Then $_iTxtColor = $_structGroup.TextPrev
            If $_iBGColor = Null Then $_iBGColor = $_structGroup.BGPrev
            $_structGroup.TextPrev = ($_iTxtColor = -1 ? $_giEnabledText : $_iTxtColor)
            $_structGroup.BGPrev = ($_iBGColor = -1 ? $_giActiveWindowBG : $_iBGColor)
    EndSwitch
    GUISetState(@SW_LOCK, $hWndGui)
    GuiCtrlSetState($_structGroup.Text, $_iState)
    If $_iState = $GUI_SHOW Or $_iState = $GUI_HIDE Then
        GuiCtrlSetState($_structGroup.Left, $_iState)
        GuiCtrlSetState($_structGroup.TopL, $_iState)
        GuiCtrlSetState($_structGroup.TopR, $_iState)
        GuiCtrlSetState($_structGroup.Right, $_iState)
        GuiCtrlSetState($_structGroup.Bottom, $_iState)
        GuiCtrlSetState($_structGroup.Background, $_iState)
    EndIf
    If $_aCtrlInside <> Null Then
        If Not IsArray($_aCtrlInside) Then
            Local $aTmp[1] = [$_aCtrlInside]
            $_aCtrlInside = $aTmp
        EndIf
        Local $iWinState
        For $i = 0 To UBound($aState) -1
            If $aState[$i][0] = $_iState Then
                $iWinState = $aState[$i][1]
                ExitLoop
            EndIf
        Next
        For $i = 0 To UBound($_aCtrlInside) -1
            If IsHWnd($_aCtrlInside[$i]) Then
                WinSetState($_aCtrlInside[$i], '', $iWinState)
            Else
                GuiCtrlSetState($_aCtrlInside[$i], $_iState)
            EndIf
        Next
    EndIf
    If $_iTxtColor <> Null Then GUICtrlSetColor($_structGroup.Text, $_iTxtColor)
    If $_iBGColor <> Null Then GUICtrlSetBkColor($_structGroup.Background, $_iBGColor)
    DllCall("user32.dll", "bool", "RedrawWindow", "hwnd", $hWndGui, "struct*", 0, "handle", 0, "uint", 5)
    GUISetState(@SW_UNLOCK, $hWndGui)
EndFunc  ;==>_GuiCtrlGroup_SetState


; == for internal use
Func __SubCtrlMove($_hGui, ByRef $_structGroup, $_aVal, $_bRel=False, $_iAlign=$_GROUPTEXT_LEFT)
    Local $idText       = $_structGroup.Text
    Local $idLeft       = $_structGroup.Left
    Local $idTopL       = $_structGroup.TopL
    Local $idTopR       = $_structGroup.TopR
    Local $idRight      = $_structGroup.Right
    Local $idBottom     = $_structGroup.Bottom
    Local $idBackground = $_structGroup.Background
    Local $dX, $dY, $dW, $dH
    Local $aSize = ControlGetPos($_hGui, '', $idLeft)
    Local $aBott = ControlGetPos($_hGui, '', $idBottom)
    If $_bRel Then
        $dX = $_aVal[0]
        $dY = $_aVal[1]
        $dW = $_aVal[2]
        $dH = $_aVal[3]
        If $dX = '*' Then $dX = 0
        If $dY = '*' Then $dY = 0
        If $dW = '*' Then $dW = 0
        If $dH = '*' Then $dH = 0
    Else
        Local $x       = $_aVal[0]
        Local $y       = $_aVal[1]
        Local $width   = $_aVal[2]
        Local $height  = $_aVal[3]
        Local $x0      = $aSize[0]
        Local $y0      = $aSize[1] -7
        Local $width0  = $aBott[2]
        Local $height0 = $aSize[3] +7
        If $x      = '*' Then $x      = $x0
        If $y      = '*' Then $y      = $y0
        If $width  = '*' Then $width  = $width0
        If $height = '*' Then $height = $height0
        $dX = $x - $x0
        $dY = $y - $y0
        $dW = $width - $width0
        $dH = $height - $height0
    EndIf
    GUICtrlSetPos($idLeft, $aSize[0]+($dX), $aSize[1]+($dY), 1, $aSize[3]+($dH))
    GUICtrlSetPos($idBottom, $aBott[0]+($dX), $aBott[1]+($dY)+($dH), $aBott[2]+($dW))

    $aSize = ControlGetPos($_hGui, '', $idTopL)
    GUICtrlSetPos($idTopL, $aSize[0]+($dX), $aSize[1]+($dY))

    $aSize = ControlGetPos($_hGui, '', $idTopR)
    GUICtrlSetPos($idTopR, $aSize[0]+($dX), $aSize[1]+($dY), $aSize[2]+($dW))

    $aSize = ControlGetPos($_hGui, '', $idRight)
    GUICtrlSetPos($idRight, $aSize[0]+($dX)+($dW), $aSize[1]+($dY), 1, $aSize[3]+($dH))

    $aSize = ControlGetPos($_hGui, '', $idBackground)
    GUICtrlSetPos($idBackground, $aSize[0]+($dX), $aSize[1]+($dY), $aSize[2]+($dW), $aSize[3]+($dH))

    $aSize = ControlGetPos($_hGui, '', $idText)
    If ($dX <> 0) Or ($dY <> 0) Then GUICtrlSetPos($idText, $aSize[0]+($dX), $aSize[1]+($dY))

    If $dW <> 0 Then _GuiCtrlGroup_Set($_structGroup, '', $_structGroup.Align)

    Local $aDelta[] = [$dX,$dY]
    Return $aDelta
EndFunc  ;==>__SubCtrlMove


Func __ControlMove($_hWnd, $_bhWnd, $_vCtrl, $_aSize, $_dX, $_dY)
    Local $aParent
    If Not $_bhWnd Then
        GUICtrlSetPos($_vCtrl, $_aSize[0]+($_dX), $_aSize[1]+($_dY))
    Else
        $aParent = WinGetPos($_hWnd)
        WinMove($_vCtrl, '', $_aSize[0]-$aParent[0]-$_giSide+($_dX), $_aSize[1]-$aParent[1]-$_giTop+($_dY))
    EndIf
EndFunc  ;==>__ControlMove


;===============================================================================
; Function Name....: __SystemGetWindowBorder
; Description......: Calculates side and top border of window
; Author(s)........: BugFix
;===============================================================================
Func __SystemGetWindowBorder(ByRef $_iTopBorder, ByRef $_iSideBorder)
    Local Const $SM_CYCAPTION = 4, $SM_CYEDGE = 46, $SM_CYBORDER = 6, $SM_CXBORDER = 5, $SM_CXEDGE = 45
    Local $aMetrics[5][2] = [[$SM_CYCAPTION], [$SM_CYEDGE], [$SM_CYBORDER], [$SM_CXBORDER], [$SM_CXEDGE]]
    Local $dll = DllOpen("user32.dll"), $aRet
    For $i = 0 To 4
        $aRet = DllCall($dll, "int", "GetSystemMetrics", "int", $aMetrics[$i][0])
        If IsArray($aRet) Then $aMetrics[$i][1] = $aRet[0]
    Next
    DllClose($dll)
    $_iTopBorder  = $aMetrics[0][1] + $aMetrics[1][1] + $aMet