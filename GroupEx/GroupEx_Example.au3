;-- TIME_STAMP   2022-04-25 11:58:30

#include <WindowsConstants.au3>
#include <GuiIPAddress.au3>
#include 'GroupEx.au3'

#cs
    You have 4 functions:

    _GuiCtrlGroup_Create ($_sText, $_iX, $_iY, $_iWidth, $_iHeight, $_iBorderCol=Default, $_iForeCol=-1, $_iBackCol=-1, $_iTitleParam=$_GROUPTEXT_LEFT)
        $_sText         - Titel, optional: "Titel<FontName;FontSize>", i.e. "Courier New;10"; Angle brackets inside the title must be masked: "\<something\>".
                          Font name and size can only be specified during creation and are then unchangeable!
        $_iX            - x position
        $_iY            - y position, its the value for top of the title - border starts at: y +7
        $_iWidth        - width
        $_iHeight       - height, its the height from top of title to bottom border
        $_iBorderCol    - [optional] Color for all border elements. Keyword Default = $COLOR_ACTIVEBORDER, -1 = System (invisible)
        $_iForeCol      - [optional] Title text color. Default is -1 (System).
        $_iBackCol      - [optional] Group area background color. Default is -1 (System).
        $_iTitleParam   - [optional] Title align left (default), centered or right or combined with italic style: BitOr($_CONST_ALIGN_, $_GROUPTEXT_ITALIC)
                          Because $_GROUPTEXT_LEFT is the default alignment, you can use $_GROUPTEXT_ITALIC alone, to set italic style left aligned.

    _GuiCtrlGroup_Close ()
        Starts a new group and so the previous group will closed.
        Only required, if outside the group radio buttons following. But it can used to close each group.

    _GuiCtrlGroup_Set (ByRef $_structGroup, $_vValue, $_constFlag, $_aCtrlInside= Null)
        $_structGroup   - Return value from _GuiCtrlGroup_Create()
        $_vValue        - The new value, maybe an empty string with some flag.
        $_constFlag     - The const to identify the action (see constants at top)
        $_aCtrlInside   - [optional] With action flag $_GROUP_MOVE_ABS/$_GROUP_MOVE_REL you can give an array of controls
                          a single control variable) inside this group. This controls will moved too with the delta x/y values.

    _GuiCtrlGroup_SetState (ByRef $_structGroup, $_iState, $_aCtrlInside=Null, $_iTxtColor=Null, $_iBGColor=Null)
        $_structGroup   - Return value from _GuiCtrlGroup_Create()
        $_iState        - The new state ($GUI_SHOW, $GUI_HIDE, $GUI_ENABLE, $GUI_DISABLE)
        $_aCtrlInside   - [optional] When you pass an array of controls (or a single control variable), they are set to the same state as the group itself.
        $_iTxtColor     - [optional] The title color if set to disable/enable. With 'Null' the default/previous color will used. "-1" uses the system color.
        $_iBGColor      - [optional] The background color if set to disable/enable. With 'Null' the default/previous color will used. "-1" uses the system color.

#ce


_Example_1()

_Example_2()

_Example_3()


Func _Example_1()
    Local $gui = GUICreate('GroupEx Example - Main', 550, 560, 200, 200)
    Local $btChild = GUICtrlCreateButton('Show Child', 460, 528, 80, 22)

    ; create a default group with red title color
    Local $g1 = _GuiCtrlGroup_Create('Title', 10, 10, 250, 80, -1, 0xFF0000)
    ; set different colors for borders left&bottom and top&right
    _GuiCtrlGroup_Set($g1, 0x00008B, BitOR($_GROUPBORDER_LEFT,$_GROUPBORDER_BOTTOM))
    _GuiCtrlGroup_Set($g1, 0xFF1234, BitOR($_GROUPBORDER_TOP,$_GROUPBORDER_RIGHT))
    GUICtrlCreateLabel('Controls inside the group', 20, 25)
    Local $g1_in = GUICtrlCreateInput('Input', 20, 50, 100, 20)

    ; create group with centered title
    Local $g2 = _GuiCtrlGroup_Create('Title', 10, 100, 250, 80, -1, 0xFF0000, -1, $_GROUPTEXT_CENTER)
    _GuiCtrlGroup_Set($g2, 0x00008B, BitOR($_GROUPBORDER_LEFT,$_GROUPBORDER_BOTTOM))
    _GuiCtrlGroup_Set($g2, 0xFF1234, BitOR($_GROUPBORDER_TOP,$_GROUPBORDER_RIGHT))
    Local $g2_btn = GUICtrlCreateButton('New Title', 20, 140, 70, 20)
    Local $g2_r1 = GUICtrlCreateRadio(' 1', 120, 141, 50)
    GUICtrlSetState(-1, $GUI_CHECKED)
    Local $g2_r2 = GUICtrlCreateRadio(' 2', 180, 141, 50)

    ; create group with title right aligned
    Local $g3 = _GuiCtrlGroup_Create('Title', 10, 190, 250, 80, -1, 0xFF0000, -1, $_GROUPTEXT_RIGHT)
    _GuiCtrlGroup_Set($g3, 0x00008B, BitOR($_GROUPBORDER_LEFT,$_GROUPBORDER_BOTTOM))
    _GuiCtrlGroup_Set($g3, 0xFF1234, BitOR($_GROUPBORDER_TOP,$_GROUPBORDER_RIGHT))
    Local $g3_r1 = GUICtrlCreateRadio(' A', 20, 230, 50)
    GUICtrlSetState(-1, $GUI_CHECKED)
    Local $g3_r2 = GUICtrlCreateRadio(' B', 80, 230, 50)

    Local $g4 = _GuiCtrlGroup_Create('Title italic', 290, 10, 250, 80, -1, 0x00008B, 0xD8D1EE, BitOR($_GROUPTEXT_RIGHT, $_GROUPTEXT_ITALIC))
    _GuiCtrlGroup_Set($g4, 0x00008B, BitOR($_GROUPBORDER_TOP,$_GROUPBORDER_RIGHT))

    ; pass font name & size appended as: <name;size>
    Local $g5 = _GuiCtrlGroup_Create('Other Font and Size<Consolas;12>', 290, 100, 250, 80, -1, 0xFF0000, 0xD8D1EE, $_GROUPTEXT_CENTER)
    _GuiCtrlGroup_Set($g5, 0x00008B, BitOR($_GROUPBORDER_TOP,$_GROUPBORDER_RIGHT))

    Local $g6 = _GuiCtrlGroup_Create('Title', 290, 190, 250, 80, -1, 0x00008B, 0xD8D1EE)
    _GuiCtrlGroup_Set($g6, 0x00008B, BitOR($_GROUPBORDER_TOP,$_GROUPBORDER_RIGHT))

    Local $g7 = _GuiCtrlGroup_Create('Title', 10, 290, 250, 80, -1, 0x00008B, 0xFFFFFF)
    _GuiCtrlGroup_Set($g7, 0xFF0000, BitOR($_GROUPBORDER_LEFT,$_GROUPBORDER_RIGHT))
    Local $g7_bt = GUICtrlCreateButton('Change Background', 30, 330, 120, 20)

    Local $g8 = _GuiCtrlGroup_Create('Title italic', 10, 380, 250, 80, -1, 0x00008B, 0xFFFFFF, BitOR($_GROUPTEXT_CENTER, $_GROUPTEXT_ITALIC))
    _GuiCtrlGroup_Set($g8, 0xFF0000, BitOR($_GROUPBORDER_LEFT,$_GROUPBORDER_RIGHT))

    Local $g9 = _GuiCtrlGroup_Create('Title', 10, 470, 250, 80, -1, 0x00008B, 0xFFFFFF, $_GROUPTEXT_RIGHT)
    _GuiCtrlGroup_Set($g9, 0xFF0000, BitOR($_GROUPBORDER_LEFT,$_GROUPBORDER_RIGHT))

    ; to use angle brackets in the title (without specifying font/size), mask the brackets with a backslash: "Title \<something\>"
    Local $g10 = _GuiCtrlGroup_Create('Title \<click me\>', 290, 290, 250, 80, -1, 0x00008B, 0xFFFFFF)
    _GuiCtrlGroup_Set($g10, 0xFF0000, BitOR($_GROUPBORDER_TOP,$_GROUPBORDER_BOTTOM))

    Local $g11 = _GuiCtrlGroup_Create('Title', 290, 380, 250, 80, -1, 0x00008B, 0xFFFFFF, $_GROUPTEXT_CENTER)
    _GuiCtrlGroup_Set($g11, 0xFF0000, BitOR($_GROUPBORDER_TOP,$_GROUPBORDER_BOTTOM))
    Local $g11_bt = GUICtrlCreateButton('Switch normal/italic', 310, 420, 140, 22)

    Local $gui2 = GUICreate('GroupEx Example - Child', 400, 120, 20, 20, -1, $WS_EX_MDICHILD, $gui)
    Local $gCh1 = _GuiCtrlGroup_Create('Group on Child', 10, 10, 250, 80, -1, 0xFF0000)
    _GuiCtrlGroup_Set($gCh1, $GUI_BKCOLOR_TRANSPARENT, $_GROUPBACKGROUND)
    _GuiCtrlGroup_Set($gCh1, 0x00008B, BitOR($_GROUPBORDER_LEFT,$_GROUPBORDER_BOTTOM))
    _GuiCtrlGroup_Set($gCh1, 0xFF1234, BitOR($_GROUPBORDER_TOP,$_GROUPBORDER_RIGHT))
    Local $lbChild = GUICtrlCreateLabel('Click Label for Test', 20, 45, 100, 17)

    GUISetState(@SW_SHOW, $gui)
    Local $g2_n = 0
    Local $g7_n = 0
    Local $g7_aCol[] = [0xFFFFFF, 0xFFFF00]
    Local $g11_bItalic = False, $aMsg

    While True
        $aMsg = GUIGetMsg(1)
        Switch $aMsg[1]
            Case $gui
                Switch $aMsg[0]
                    Case -3
                        GUIDelete($gui2)
                        GUIDelete($gui)
                        ExitLoop
                    Case $g2_btn
                        $g2_n += 1
                        _GuiCtrlGroup_Set($g2, 'New Title [' & $g2_n & ']', $_GROUPTEXT_TEXT)
                    Case $g7_bt
                        $g7_n = Abs($g7_n -1)
                        _GuiCtrlGroup_Set($g7, $g7_aCol[$g7_n], $_GROUPBACKGROUND)
                    Case $g10.Text
                        MsgBox(0, 'Clicked', 'Group 10 - Title clicked')
                    Case $g11_bt
                        $g11_bItalic = Not $g11_bItalic
                        $flag = $g11_bItalic ? $_GROUPTEXT_ITALIC : $_GROUPTEXT_DEFAULT
                        _GuiCtrlGroup_Set($g11, '', BitOR($_GROUPTEXT_CENTER, $flag))
                    Case $btChild
                        GUISetState(@SW_SHOW, $gui2)
                        GUISetState(@SW_HIDE, $gui)
                EndSwitch
            Case $gui2
                Switch $aMsg[0]
                    Case -3
                        GUISetState(@SW_HIDE, $gui2)
                        GUISetState(@SW_SHOW, $gui)
                    Case $lbChild
                        MsgBox(0, 'Clicked', 'Click on Label')
                EndSwitch
        EndSwitch
    WEnd
EndFunc

Func _Example_2()
    Local $gui = GUICreate('GroupEx Example Show/Hide, Enable/Disable, Change Pos/Size', 550, 260, 200, 200)
    Local $group = _GuiCtrlGroup_Create('Test', 10, 10, 200, 150, Default, 0xFF0000)
    Local $combo = GUICtrlCreateCombo('Item 1', 20, 40, 180)
    GUICtrlSetData($combo, "Item 2|Item 3|Item 4|Item 5", "Item 2")
    Local $hIPAddress = _GUICtrlIpAddress_Create($gui, 20, 70)
    _GUICtrlIpAddress_Set($hIPAddress, '192.168.178.75')
    Local $btShowHide = GUICtrlCreateButton('Show / Hide  w. Controls', 350, 10, 180, 22)
    Local $btEnDisable = GUICtrlCreateButton('Enable / Disable  w. Controls', 350, 50, 180, 22)
    Local $btMove = GUICtrlCreateButton('Move up / down  w. Controls', 350, 90, 180, 22)
    Local $btDimension = GUICtrlCreateButton('Change width && height', 350, 130, 180, 22)
    Local $bHide = False, $bDisable = False, $iMove = -1, $iDim = -1

    Local $aCtrl[] = [$combo, $hIPAddress]

    GUISetState()
    While 1
        Switch GUIGetMsg()
            Case -3
                GUIDelete()
                ExitLoop
            Case $btShowHide
                $bHide = Not $bHide
                _GuiCtrlGroup_SetState($group, ($bHide ? $GUI_HIDE : $GUI_SHOW), $aCtrl)
            Case $btEnDisable
                $bDisable = Not $bDisable
                _GuiCtrlGroup_SetState($group, ($bDisable ? $GUI_DISABLE : $GUI_ENABLE), $aCtrl)
            Case $btMove
                ; Size & pos param as array [x,y,width,height] or comma separated string "x,y,width,height"
                ; All param values are predefined with "*" - the current value. So you can omit unchanged parameters on the righthand side.
                ; x:unchanged(*), y: +- 80 from current position
                $iMove *= -1
                If $iMove = 1 Then
                    _GuiCtrlGroup_Set($group, '*,80', $_GROUP_MOVE_REL, $aCtrl)
                Else
                    _GuiCtrlGroup_Set($group, '*,-80', $_GROUP_MOVE_REL, $aCtrl)
                EndIf
            Case $btDimension
                ; x,y:unchanged(*), w: +- 100, h: +- 50
                $iDim *= -1
                If $iDim = 1 Then
                    _GuiCtrlGroup_Set($group, '*,*,100,50', $_GROUP_MOVE_REL)
                Else
                    _GuiCtrlGroup_Set($group, '*,*,-100,-50', $_GROUP_MOVE_REL)
                EndIf
        EndSwitch
    WEnd
EndFunc


Func _Example_3()
    Local $gui = GUICreate('GroupEx Example Radios in- /outside' , 430, 340, 200, 200)
    Local $gr1 = _GuiCtrlGroup_Create('Group 1', 10, 10, 400, 100, Default, 0xFF0000)
    Local $gr1_r1 = GUICtrlCreateRadio(' Group-1, Radio 1', 30, 30)
    GUICtrlSetState(-1, $GUI_CHECKED)
    Local $gr1_r2 = GUICtrlCreateRadio(' Group-1, Radio 2', 200, 30)

    GUIStartGroup() ; starts the outside group
    Local $out_r1 = GUICtrlCreateRadio(' Out-Group, Radio 1', 30, 150)
    Local $out_r2 = GUICtrlCreateRadio(' Out-Group, Radio 2', 200, 150)
    GUICtrlSetState(-1, $GUI_CHECKED)

    Local $gr2 = _GuiCtrlGroup_Create('Group 2', 10, 210, 400, 100, Default, 0xFF0000)
    Local $gr2_r1 = GUICtrlCreateRadio(' Group-2, Radio 1', 30, 230)
    GUICtrlSetState(-1, $GUI_CHECKED)
    Local $gr2_r2 = GUICtrlCreateRadio(' Group-2, Radio 2', 200, 230)

    GUISetState()
    Local $nMsg
    While 1
        $nMsg = GUIGetMsg()
        Switch $nMsg
            Case -3
                GUIDelete()
                ExitLoop
            Case $gr1_r1, $gr1_r2, $gr2_r1, $gr2_r2, $out_r1, $out_r2
                MsgBox(0, 'Clicked', ControlGetText($gui, '', $nMsg))
        EndSwitch
    WEnd
EndFunc
