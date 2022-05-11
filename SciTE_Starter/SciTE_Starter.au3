;-- TIME_STAMP   2022-05-11 09:56:23   v 0.3

Opt('MustDeclareVars', 1)
#include <GuiListBox.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>

; ACHTUNG! Die Ini-Datei NICHT per Hand bearbeiten, sondern ausschliesslich über das Programm!
; Der 1.te Eintrag MUSS die Standardinstallation sein ("SciTEUser.properties" in "SciTE_USERHOME" >> "C:\Users\<USER>\AppData\Local\AutoIt v3\SciTE" )
#cs   "SciTE_Starter.ini"    - wird bei erstem Start interaktiv erstellt
[SciTE4AutoIt]
name=SciTE4AutoIt v3.7.3
path=C:\Program Files (x86)\AutoIt3\SciTE
file=SciTE.exe

[SciTE_5.0_x86]
name=SciTE 5.0 32bit
path=C:\CODE\SciTE5.0\SciTE_5.0_x86
file=SciTE32.exe

[SciTE_5.0_x64]
name=SciTE 5.0 64bit
path=C:\CODE\SciTE5.0\SciTE_5.0_x64
file=SciTE.exe
#ce

Global $INI = @ScriptDir & '\SciTE_Starter.ini'
Global $aSciTEVer[1][3] = [[0]]
Global $aSecNames, $iSel, $iAnswer = 6
If Not FileExists($INI) Then
    While $iAnswer = 6
        If (Not _FirstSetting()) Then
            $iAnswer = MsgBox(4+32+262144, 'Auswahl SciTE4AutoIt', 'Es wurde keine oder keine SciTE-Datei ausgewählt. Soll die Auswahl jetzt erfolgen?') ; Yes/No+Question.ico+TopMost
        Else
            ExitLoop
        EndIf
    WEnd
Else
    $aSecNames = IniReadSectionNames($INI)
    For $i = 1 To $aSecNames[0]
        $aSciTEVer[0][0] += 1
        ReDim $aSciTEVer[$aSciTEVer[0][0]+1][3]
        $aSciTEVer[$aSciTEVer[0][0]][0] = IniRead($INI, $aSecNames[$i], 'name', '')
        $aSciTEVer[$aSciTEVer[0][0]][1] = IniRead($INI, $aSecNames[$i], 'path', '')
        $aSciTEVer[$aSciTEVer[0][0]][2] = IniRead($INI, $aSecNames[$i], 'file', '')
    Next
EndIf


; hier SciTE-Handle speichern für Interaktion durch andere Skripte
Global $gPathInteract = @TempDir & '\SC_starter.hwnd'


Global $hGui = GUICreate('SciTE-Starter', 400, 250)
Global $list = GUICtrlCreateList('', 10, 40, 380, 170, BitOR($WS_BORDER, $WS_VSCROLL)) ; darf nicht sortiert werden! SciTE4AutoIt muss an Pos. 1 sein.
Global $hList = GUICtrlGetHandle($list)
Global $cMenu = GUICtrlCreateContextMenu($list)
Global $idNew = GUICtrlCreateMenuItem('Eintrag Neu', $cMenu)
Global $idDelete = GUICtrlCreateMenuItem('Eintrag Löschen', $cMenu)
Global $showPath = GUICtrlCreateInput('', 10, 220, 380, 20, $ES_READONLY)
GUICtrlSetBkColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, Default, Default, Default, 'Consolas')
GUICtrlCreateLabel('Einträge bearbeiten mit Kontextmenü', 10, 13, 290)
Global $start = GUICtrlCreateButton('Start', 310, 10, 80, 24)

_ListSet()

GUISetState()

While True
    Switch GUIGetMsg()
        Case -3
            Exit
        Case $list
            $iSel = _GUICtrlListBox_GetCurSel($hList)
            If $iSel = -1 Then
                GUICtrlSetData($showPath, '')
            Else
                GUICtrlSetData($showPath, $aSciTEVer[$iSel +1][1] & '\' & $aSciTEVer[$iSel +1][2])
            EndIf
        Case $idNew
            If Not _VerManagement(-1, 'new') Then
                MsgBox(16+262144, 'FEHLER', 'Keine oder keine SciTE.exe ausgewählt!')
            Else
                _ListSet()
            EndIf
        Case $idDelete
            $iSel = _GUICtrlListBox_GetCurSel($hList)
            If $iSel = -1 Then
                MsgBox(16+262144, 'FEHLER', 'Kein Eintrag markiert!')
            Else
                If $iSel = 0 Then
                    MsgBox(16+262144, 'FEHLER', 'Erster Eintrag muss die installierte SciTE4AutoIt Version sein und darf nicht gelöscht werden!')
                Else
                    _VerManagement($iSel, 'delete')
                    _ListSet()
                    GUICtrlSetData($showPath, '')
                EndIf
            EndIf
        Case $start
            $iSel = _GUICtrlListBox_GetCurSel($hList)
            If $iSel = -1 Then
                MsgBox(16+262144, 'FEHLER', 'Keine Version markiert!')
            Else
                If _GetSciTEhWndByPID() Then
                    MsgBox(16+262144, 'FEHLER', 'Eine Instanz von SciTE wurde bereits gestartet!')
                Else
                    _SetEnvAndRun($iSel)
                    Exit
                EndIf
            EndIf
    EndSwitch
WEnd


Func _FirstSetting()
    Local $PathFull = FileOpenDialog('SciTE4AutoIt (Die installierte Standardversion)', @ProgramFilesDir, '(*.exe)', 1)
    If @error Or (Not _IsSciTE($PathFull)) Then Return False
    Local $iPos = StringInStr($PathFull, '\', 0, -1)
    Local $File = StringTrimLeft($PathFull, $iPos)
    Local $Path = StringTrimRight($PathFull, StringLen($File)+1)
    Local $Version = FileGetVersion($PathFull)
    Local $Alias = InputBox('Alias', 'Zuweisen eines Alias für diese SciTE Version. (z.B. "SciTE4AutoIt v3.7.3")', StringTrimRight($File, 4) & ' v' & $Version)
    If $Alias = '' Then $Alias = StringTrimRight($File, 4) & ' v' & $Version
    Local $iChoose = 6
    $aSciTEVer[0][0] += 1
    ReDim $aSciTEVer[$aSciTEVer[0][0]+1][3]
    $aSciTEVer[$aSciTEVer[0][0]][0] = $Alias
    $aSciTEVer[$aSciTEVer[0][0]][1] = $Path
    $aSciTEVer[$aSciTEVer[0][0]][2] = $File
    _WriteToIni($Alias, $Path, $File, $Version)
    While $iChoose = 6
        $iChoose = MsgBox(4+32+262144, 'Auswahl SciTE Version', 'Soll eine andere SciTE.exe ausgewählt werden?')
        If $iChoose = 7 Then ExitLoop
        If (Not _VerManagement(-1, 'new')) Then MsgBox(48+4096, 'ACHTUNG', 'Keine oder keine SciTE.exe ausgewählt!')
    WEnd
    Return True
EndFunc


Func _WriteToIni($_Alias, $_Path, $_File, $_Version)
    Local $Section = StringTrimRight($_File, 4) & '_' & $_Version
    IniWrite($INI, $Section, 'name', $_Alias)
    IniWrite($INI, $Section, 'path', $_Path)
    IniWrite($INI, $Section, 'file', $_File)
EndFunc


Func _ListSet()
    _GUICtrlListBox_ResetContent($hList)
    For $i = 1 To $aSciTEVer[0][0]
        _GUICtrlListBox_AddString($hList, $aSciTEVer[$i][0])
    Next
EndFunc


Func _SetEnvAndRun($_i)
    Local Static $UserHomeAu3 = EnvGet('SciTE_USERHOME')
    Local $path = $aSciTEVer[$_i +1][1]
    Local $file = $aSciTEVer[$_i +1][2]
    If $_i > 0 Then                             ; NUR SciTE_HOME belegt: "SciTEGlobal.properties" und "SciTEUser.properties" in diesem Pfad
        EnvSet('SciTE_USERHOME','')
        EnvSet('SciTE_HOME', $path)             ; HIER: Das Verzeichnis, indem sich die SciTE.exe befindet
    Else                                        ; NUR SciTE_USERHOME belegt (Standard): "SciTEUser.properties" in diesem Pfad, "SciTEGlobal.properties" im SciTE-Dir
        EnvSet('SciTE_USERHOME', $UserHomeAu3)  ; Standard: "C:\Users\<USER>\AppData\Local\AutoIt"
        EnvSet('SciTE_HOME', '')
    EndIf
    Local $PID = ShellExecute('"' & $path & '\' & $file & '"', '', '', '', @SW_HIDE)
    Local $hSciTE, $Timer = TimerInit()
    Do
        $hSciTE = _GetSciTEhWndByPID($PID)
        Sleep(20)
    Until $hSciTE <> Null Or TimerDiff($Timer) > 10000
    If $hSciTE = Null Then MsgBox(16+262144, 'FEHLER', '"' & $path & '\' & $file & '"' & @CRLF & 'konnte nicht erfolgreich gestartet werden!')
    Local $fhTmp = FileOpen($gPathInteract, 2+8)  ; Handle speichern für Interaktion durch andere Skripte
    FileWrite($fhTmp, $hSciTE)
    FileClose($fhTmp)
EndFunc


Func _VerManagement($_index, $_mode)
    Switch $_mode
        Case 'new'
            Local $PathFull = FileOpenDialog('Andere SciTE Version', @HomeDrive, '(*.exe)', 1)
            If @error Or (Not _IsSciTE($PathFull)) Then Return False
            Local $iPos = StringInStr($PathFull, '\', 0, -1)
            Local $File = StringTrimLeft($PathFull, $iPos)
            Local $Path = StringTrimRight($PathFull, StringLen($File)+1)
            Local $Version = FileGetVersion($PathFull)
            Local $Alias = InputBox('Alias', 'Zuweisen eines Alias für diese SciTE Version. (z.B. "SciTE4AutoIt v3.7.3")', StringTrimRight($File, 4) & ' v' & $Version)
            If $Alias = '' Then $Alias = StringTrimRight($File, 4) & ' v' & $Version
            $aSciTEVer[0][0] += 1
            ReDim $aSciTEVer[$aSciTEVer[0][0]+1][3]
            $aSciTEVer[$aSciTEVer[0][0]][0] = $Alias
            $aSciTEVer[$aSciTEVer[0][0]][1] = $Path
            $aSciTEVer[$aSciTEVer[0][0]][2] = $File
            _WriteToIni($Alias, $Path, $File, $Version)
            Return True
        Case 'delete'
            If $_index+1 < $aSciTEVer[0][0] Then ; move last entry to index that should removed
                $aSciTEVer[$_index+1][0] = $aSciTEVer[$aSciTEVer[0][0]][0]
                $aSciTEVer[$_index+1][1] = $aSciTEVer[$aSciTEVer[0][0]][1]
                $aSciTEVer[$_index+1][2] = $aSciTEVer[$aSciTEVer[0][0]][2]
            EndIf
            ReDim $aSciTEVer[$aSciTEVer[0][0]][3]
            $aSciTEVer[0][0] -= 1
            $aSecNames = IniReadSectionNames($INI)
            IniDelete($INI, $aSecNames[$_index+1])
    EndSwitch
EndFunc


Func _IsSciTE($_path)
    Local $file = StringTrimLeft($_path, StringInStr($_path, '\', 0, -1))
    Return (StringRegExp($file, '(?i)scite.*\.exe$') = 1)
EndFunc


Func _GetSciTEhWndByPID($_PID=Null)
    Local $aW = WinList("[REGEXPTITLE:(?i)(.*SciTE*.*)]")
    If $_PID = Null Then Return ($aW[0][0] = 0 ? False : True)  ; check only if SciTE is running
    Local $PID
    For $i = 1 To $aW[0][0]
        If $aW[$i][0] = 'SciTE interface' Then ContinueLoop
        $PID = WinGetProcess($aW[$i][0])
        If $PID = $_PID Then Return $aW[$i][1]
    Next
    Return Null
EndFunc