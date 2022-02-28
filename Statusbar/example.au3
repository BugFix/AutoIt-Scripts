;-- TIME_STAMP   2022-02-28 14:53:49

Opt('MustDeclareVars', 1)

#include 'statusbar_small.au3'

Global $g_aStBar, $g_iPartTime, $g_idMsg, $g_idNext

_Example_1()
_Example_2()
_Example_3()
_Example_4()
_Example_5()
_Example_6()
_Example_7()


Func _Example_1()
	Local $hGui = GUICreate('Test Statusbar small - [ 1 ]', -1, -1, -1, -1, 0x00040000)
	GUICtrlCreateButton('', 0, 0, 1, 1) ; catch focus
	GUICtrlCreateEdit('• size of parts as array passed' & @CRLF & _
	                  '• text of parts as string passed' & @CRLF & _
	                  '• align for parts as string passed' & @CRLF & _
	                  '• font + style defined' & @CRLF, _
	                  10, 10, 380, 150)
	GUICtrlSetFont(-1, 9, Default, Default, 'Consolas')
    $g_idMsg = GUICtrlCreateInput('', 10, 180, 380, 20)
    $g_idNext = GUICtrlCreateLabel('', 10, 220, 300, 17)
    GUICtrlSetColor(-1, 0xFF0000)

	Local $aParts[] = [-1,-1,-1,80] ; 4.th part fix
	$g_aStBar = _StatusbarCreate($hGui, _
	          $aParts, _
			  'Date|' & StringFormat('%d-%02d-%d', @YEAR, @MON, @MDAY) & '|Time|' & StringFormat('%02d:%02d:%02d', @HOUR, @MIN, @SEC), _
			  'l|c|l|c', _    ; Align: left|center|left|center
			  'Verdana|11|3') ; bold+italic

	$g_iPartTime = 3
	AdlibRegister(_Time, 1000)
	GUISetState()

    _Msg("Font: Verdana, Size: 11, Style: bold & italic, Align: center")
    Local $timer = TimerInit()
	Do
		If TimerDiff($timer) >= 3000 And GUICtrlRead($g_idNext) = '' Then
            _Next("Close window to display the next example.")
		EndIf
	Until GUIGetMsg() = -3
	AdlibUnRegister(_Time)
	GUIDelete($hGui)

	Return
EndFunc


Func _Example_2()
	Local $hGui = GUICreate('Test Statusbar small - [ 2 OnTop]', -1, -1, -1, -1, 0x00040000)
	GUICtrlCreateButton('', 0, 0, 1, 1) ; catch focus

	Local $aParts[] = [-1,-1,-1,80] ; 4.th part fix
	$g_aStBar = _StatusbarCreate($hGui, _
	          $aParts, _
			  'Date|' & StringFormat('%d-%02d-%d', @YEAR, @MON, @MDAY) & '|Time|' & StringFormat('%02d:%02d:%02d', @HOUR, @MIN, @SEC), _
			  'l|c|l|c', _          ; Align: left|center|left|center
			  'Verdana|11|3', _     ; bold+italic
              True)                 ; position On Top
    Local $yTop = $g_aStBar[0][2]   ; the height of the status bar
	GUICtrlCreateEdit('• position on top' & @CRLF & _
                      '• size of parts as array passed' & @CRLF & _
	                  '• text of parts as string passed' & @CRLF & _
	                  '• align for parts as string passed' & @CRLF & _
	                  '• font + style defined' & @CRLF, _
	                  10, $yTop+10, 380, 150)
	GUICtrlSetFont(-1, 9, Default, Default, 'Consolas')
    $g_idMsg = GUICtrlCreateInput('', 10, $yTop+180, 380, 20)
    $g_idNext = GUICtrlCreateLabel('', 10, $yTop+220, 300, 17)
    GUICtrlSetColor(-1, 0xFF0000)


	$g_iPartTime = 3
	AdlibRegister(_Time, 1000)
	GUISetState()

    _Msg("Font: Verdana, Size: 11, Style: bold & italic, Align: center")
    Local $timer = TimerInit()
	Do
		If TimerDiff($timer) >= 3000 And GUICtrlRead($g_idNext) = '' Then
            _Next("Close window to display the next example.")
		EndIf
	Until GUIGetMsg() = -3
	AdlibUnRegister(_Time)
	GUIDelete($hGui)

	Return
EndFunc


Func _Example_3()
	Local $hGui = GUICreate('Test Statusbar small - [ 3 ]', -1, -1, -1, -1, 0x00040000)
	GUICtrlCreateButton('', 0, 0, 1, 1)
	GUICtrlCreateEdit('• size of parts as string passed' & @CRLF & _
	                  '• text of parts as string passed' & @CRLF & _
	                  '• align for parts as string passed' & @CRLF & _
					  '• font + style defined' & @CRLF, _
	                  10, 10, 380, 150)
	GUICtrlSetFont(-1, 9, Default, Default, 'Consolas')
    $g_idMsg = GUICtrlCreateInput('', 10, 180, 380, 20)
    $g_idNext = GUICtrlCreateLabel('', 10, 220, 300, 17)
    GUICtrlSetColor(-1, 0xFF0000)

	$g_aStBar = _StatusbarCreate($hGui, _
			  '-1|80|-1', _
			  StringFormat('%d-%02d-%d', @YEAR, @MON, @MDAY) & '|Time|' & StringFormat('%02d:%02d:%02d', @HOUR, @MIN, @SEC), _
			  'c|r|c', _            ; Align: center|right|center
			  'Comic Sans MS|11|2') ; italic

	$g_iPartTime = 2
	AdlibRegister(_Time, 1000)
	GUISetState()

    _Msg("Font: Comic Sans MS, Size: 11, Style: italic, Align: center | right | center")
    Local $timer = TimerInit()
	Do
		If TimerDiff($timer) >= 3000 And GUICtrlRead($g_idNext) = '' Then
            _Next("Close window to display the next example.")
		EndIf
	Until GUIGetMsg() = -3
	AdlibUnRegister(_Time)
	GUIDelete($hGui)

	Return
EndFunc


Func _Example_4()
	Local $hGui = GUICreate('Test Statusbar small - [ 4 ]', -1, -1, -1, -1, 0x00040000)
	GUICtrlCreateButton('', 0, 0, 1, 1)
	GUICtrlCreateEdit('• size of parts as string passed' & @CRLF & _
	                  '• text of parts as string passed' & @CRLF & _
	                  '• align for parts as array passed' & @CRLF, _
	                  10, 10, 380, 150)
	GUICtrlSetFont(-1, 9, Default, Default, 'Consolas')
    $g_idMsg = GUICtrlCreateInput('', 10, 180, 380, 20)
    $g_idNext = GUICtrlCreateLabel('', 10, 220, 300, 17)
    GUICtrlSetColor(-1, 0xFF0000)

	Local $aText[] = ['Date',StringFormat('%d-%02d-%d', @YEAR, @MON, @MDAY),'Time',StringFormat('%02d:%02d:%02d', @HOUR, @MIN, @SEC)]
	Local $aAlign[] = ['c','r','c','r']
	$g_aStBar = _StatusbarCreate($hGui, _
			  '-1|90|-1|90', _
			  $aText, _
			  $aAlign) ; Align: center|right|center|right

	$g_iPartTime = 3
	AdlibRegister(_Time, 1000)
	GUISetState()

    _Msg("Font/Size/Style: default(Arial/9/none), Align: center | right | center | right")
    Local $timer = TimerInit()
	Do
		If TimerDiff($timer) >= 3000 And GUICtrlRead($g_idNext) = '' Then
            _Next("Close window to display the next example.")
		EndIf
	Until GUIGetMsg() = -3
	AdlibUnRegister(_Time)
	GUIDelete($hGui)

	Return
EndFunc


Func _Example_5()
	Local $hGui = GUICreate('Test Statusbar small - [ 5 ]', -1, -1, -1, -1, 0x00040000)
	GUICtrlCreateButton('', 0, 0, 1, 1)
	GUICtrlCreateEdit('• statusbar with one part' & @CRLF & _
	                  '• change align 4 times (each 3s)' & @CRLF, _
	                  10, 10, 380, 150)
	GUICtrlSetFont(-1, 9, Default, Default, 'Consolas')
    $g_idMsg = GUICtrlCreateInput('', 10, 180, 380, 20)
    $g_idNext = GUICtrlCreateLabel('', 10, 220, 300, 17)
    GUICtrlSetColor(-1, 0xFF0000)

	$g_aStBar = _StatusbarCreate($hGui, -1, StringFormat('%02d:%02d:%02d', @HOUR, @MIN, @SEC)) ; Align: left

	$g_iPartTime = 0
	Local $done = 0, $timer = TimerInit()
	AdlibRegister(_Time, 1000)
	GUISetState()

    _Msg("Align: left")


	Do
		If TimerDiff($timer) >= 12000 And $done = 3 Then
			_StatusbarSetAlign($g_aStBar, '0', 'l')
			$done = 4
            _Msg("Align changed to: left")
            _Next("Close window to display the next example.")
		EndIf
		If TimerDiff($timer) >= 9000 And $done = 2 Then
			_StatusbarSetAlign($g_aStBar, '0', 'c')
			$done = 3
            _Msg("Align changed to: center")
		EndIf
		If TimerDiff($timer) >= 6000 And $done = 1 Then
			_StatusbarSetAlign($g_aStBar, '0', 'r')
			$done = 2
            _Msg("Align changed to: right")
		EndIf
		If TimerDiff($timer) >= 3000 And $done = 0 Then
			_StatusbarSetAlign($g_aStBar, '0', 'c')
			$done = 1
            _Msg("Align changed to: center")
		EndIf
	Until GUIGetMsg() = -3
	AdlibUnRegister(_Time)
	GUIDelete($hGui)

	Return
EndFunc


Func _Example_6()
	Local $hGui = GUICreate('Test Statusbar small - [ 6 ]', -1, -1, -1, -1, 0x00040000)
	GUICtrlCreateButton('', 0, 0, 1, 1)
	GUICtrlCreateEdit('• set colors 5 times (each 3s)' & @CRLF, _
	                  10, 10, 380, 150)
	GUICtrlSetFont(-1, 9, Default, Default, 'Consolas')
    $g_idMsg = GUICtrlCreateInput('', 10, 180, 380, 20)
    $g_idNext = GUICtrlCreateLabel('', 10, 220, 300, 17)
    GUICtrlSetColor(-1, 0xFF0000)

	$g_aStBar = _StatusbarCreate($hGui, _
			  '-1|-1', _
			  StringFormat('%02d.%02d.%d', @MDAY, @MON, @YEAR) & '|' & StringFormat('%02d:%02d:%02d', @HOUR, @MIN, @SEC), _
			  'c|c', _               ; Align: center
			  'Times New Roman|12|0') ; Style 0=normal

	$g_iPartTime = 1
	Local $done = 0, $timer = TimerInit()
	AdlibRegister(_Time, 1000)
	GUISetState()

    _Msg("Start with default colors")

	Do
		If TimerDiff($timer) >= 15000 And $done = 4 Then
			_StatusbarSetColors($g_aStBar, 1, 0x0022FF, 0xEFEF00)   ; blue/yellow Part 2
			$done = 5
            _Msg("Colouring right part change: FG-Blue | BG-Yellow")
            _Next("Close window to display the next example.")
		EndIf
		If TimerDiff($timer) >= 12000 And $done = 3 Then
			_StatusbarSetColors($g_aStBar, 0, 0xEFEF00, 0x0022FF)   ; yellow/blue Part 1
			$done = 4
            _Msg("Colouring left part change: FG-Yellow | BG-Blue")
		EndIf
		If TimerDiff($timer) >= 9000 And $done = 2 Then
			_StatusbarSetColors($g_aStBar)                         ; default colors all parts
			$done = 3
            _Msg("Colouring all parts change: Default")
		EndIf
		If TimerDiff($timer) >= 6000 And $done = 1 Then
			_StatusbarSetColors($g_aStBar, -1, 0x0022AA, 0xFF0000) ; blue/red
			$done = 2
            _Msg("Colouring all parts change: FG-Blue | BG-Red")
		EndIf
		If TimerDiff($timer) >= 3000 And $done = 0 Then
			_StatusbarSetColors($g_aStBar, -1, 0xFF0000, 0x0022AA) ; red/blue
			$done = 1
            _Msg("Colouring all parts: FG-Red | BG-Blue")
		EndIf
	Until GUIGetMsg() = -3
	AdlibUnRegister(_Time)
	GUIDelete($hGui)

	Return
EndFunc


Func _Example_7()
    Opt('GUIOnEventMode', 1)
	Local $hGui = GUICreate('Test Statusbar small - [ 7 OnEvent-Mode ]', -1, -1, -1, -1, 0x00040000)
    GUISetOnEvent(-3, __Ex7_Exit)
	GUICtrlCreateButton('', 0, 0, 1, 1)
	GUICtrlCreateEdit('• All parts of the statusbar assigned with an event' & @CRLF & _
                      '• Click on the parts to see the result' & @CRLF, _
	                  10, 10, 380, 150)
	GUICtrlSetFont(-1, 9, Default, Default, 'Consolas')
    $g_idMsg = GUICtrlCreateInput('', 10, 180, 380, 20)
    $g_idNext = GUICtrlCreateLabel('', 10, 220, 300, 17)
    GUICtrlSetColor(-1, 0xFF0000)

	$g_aStBar = _StatusbarCreate($hGui, _
			  '-1|-1|-1|-1', _
			  'Date|' & StringFormat('%02d.%02d.%d', @MDAY, @MON, @YEAR) & '|Time|' & StringFormat('%02d:%02d:%02d', @HOUR, @MIN, @SEC), _
			  'l|c|l|c', _            ; Align: left|center|left|center
			  'Times New Roman|12|0') ; Style 0=normal
    _StatusbarSetOnEvent($g_aStBar, __Ex7_EventPart_0, 0, 0)
    _StatusbarSetOnEvent($g_aStBar, __Ex7_EventPart_1, 1, 1)
    _StatusbarSetOnEvent($g_aStBar, __Ex7_EventPart_2, 2, 2)
    _StatusbarSetOnEvent($g_aStBar, __Ex7_EventPart_3, 3, 3)

;   or one function for all parts:
;~     _StatusbarSetOnEvent($g_aStBar, __Ex7_EventAllParts)

	$g_iPartTime = 3
	Local $done = 0, $timer = TimerInit()
	AdlibRegister(_Time, 1000)
	GUISetState()

    While True
		If TimerDiff($timer) >= 3000 And GUICtrlRead($g_idNext) = '' Then
            _Next("Close window to exit.")
		EndIf
        Sleep(20)
    WEnd

EndFunc

Func __Ex7_EventPart_0()
    _Msg('Clicked on "Date"')
EndFunc

Func __Ex7_EventPart_1()
    _Msg('Clicked on the Date-Value')
EndFunc

Func __Ex7_EventPart_2()
    _Msg('Clicked on "Time"')
EndFunc

Func __Ex7_EventPart_3()
    _Msg('Clicked on the Time-Value')
EndFunc

Func __Ex7_EventAllParts()
    Switch @GUI_CtrlId
        Case $g_aStBar[0][0] ; ID = [part-index][0]
            _Msg('Clicked on "Date"')
        Case $g_aStBar[1][0]
            _Msg('Clicked on the Date-Value')
        Case $g_aStBar[2][0]
            _Msg('Clicked on "Time"')
        Case $g_aStBar[3][0]
            _Msg('Clicked on the Time-Value')
    EndSwitch
EndFunc

Func __Ex7_Exit()
    Exit
EndFunc


Func _Time()
	_StatusbarSetText($g_aStBar, $g_iPartTime, StringFormat('%02d:%02d:%02d', @HOUR, @MIN, @SEC))
EndFunc


Func _Msg($_sMsg)
    GUICtrlSetData($g_idMsg, $_sMsg)
EndFunc


Func _Next($_sMsg)
    GUICtrlSetData($g_idNext, $_sMsg)
EndFunc
