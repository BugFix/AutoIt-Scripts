# SciTE - Mein Spielplatz
## Was ist SciTE?
> SciTE ist ein auf Scintilla basierender Texteditor. Ursprünglich gebaut, um Scintilla zu demonstrieren, hat er sich zu einem allgemein nützlichen Editor mit Möglichkeiten zur Erstellung und Ausführung von Programmen entwickelt. Er eignet sich am besten für Aufgaben mit einfachen Konfigurationen [^1]

Per 26.12.2023 liegt SciTE in der Version 5.4.1 vor. Gepflegt wird das Projekt von Neil Hodgson. Fragen dazu kann man in der Google Gruppe [SciTE-Interest](https://groups.google.com/g/scite-interest) stellen und diese werden auch zügig beantwortet. :ok_hand:

SciTE liegt in verschiedenen Modifikationen vor, z.B. [SciTE-Ru](https://bitbucket.org/scite-ru/scite-ru.bitbucket.org/wiki/Home) oder [SciTE4AutoIt](https://www.autoitscript.com/site/autoit-script-editor/downloads/).

Im Folgenden werde ich ausschließlich auf *SciTE4AutoIt* Bezug nehmen. Für externen Zugriff kommen AutoIt- und Lua-Skripte zum Einsatz.

## Aufbau von SciTE

![![SciTE Class Names][image_ref_98jwa6k8]](SciTE.png)

Wie die Abbildung zeigt, besteht ein SciTE Fenster aus folgenden Klassen:

<table>
<tr><td>SciTEWindow</td><td>ToolbarWindow32</td><td></td></tr>
<tr><td></td><td>SciTETabCtrl</td><td></td></tr>
<tr><td></td><td>SciTEWindowContent</td><td>Scintilla, Instance1</td></tr>
<tr><td></td><td></td><td>Scintilla, Instance2</td></tr>
<tr><td></td><td>msctls_statusbar32</td><td></td></tr>
</table>


Die Menüleiste ist nicht über eine Windows Fensterklasse implementiert und dadurch nicht mit der WinAPI manipulierbar. Es lassen sich aber alle Menübefehle von extern per IPC aufrufen, darauf werde ich [hier](#menü-kommandos-aufrufen) eingehen. 

## Wie kann ich SciTE extern steuern
> Softwareentwicklung findet nicht nur auf der Ebene einer einzelnen Datei statt, die von SciTE bearbeitet wird. Ein Entwickler wird in der Regel an einer Gruppe von zusammenhängenden Dateien im Rahmen eines Projekts arbeiten. Man könnte SciTE wie andere Editoren mit einer Projektmanagerfunktionalität ausstatten, doch würde dies eine bestimmte Sichtweise auf die Verwaltung von Projekten einschließlich des Formats der Projektdateien vorgeben. Stattdessen verfügt SciTE über eine Schnittstelle, die von Projektmanagern oder ähnlichen Anwendungen genutzt werden kann, um SciTE zu steuern. Jede Anwendung, die SciTE steuert, wird als "Director" bezeichnet. [^2]

Um eine externe Steuerung vornehmen zu können, stellt SciTE als Schnittstelle das "SciTE Director Interface" zur Verfügung.

![![SciTE_Director_Interface][image_ref_s5fu9iy8]](SciTE_Interface.png)

## Bsp. für externen Zugriff
### Handle des aktiven SciTE Fensters abfragen
<details><summary>AutoIt - _GetHwnd_SciTE</summary>

```autoit
Func _GetHwnd_SciTE()
    Local $hScite = WinGetHandle('[ACTIVE]')
    If _WinAPI_GetClassName($hScite) = 'SciTEWindow' Then
        Return $hScite
    Else
        Return SetError(1, 0, Null)
    EndIf
EndFunc
```
</details>

### Handle für das "SciTE Director Interface" abfragen
SciTE speichert dieses Handle in seinen .properties als "WindowID". Von einem externen Programm erlangen wir aber nur über das Director Interface die Möglichkeit Werte aus den .properties abzufragen. Somit fragen wir das Handle über die Fensterbezeichnung ab. Das Code-Bsp. berücksichtigt, dass mehrere Instanzen von SciTE geöffnet sein können.

<details><summary>AutoIt - _GetHwndDirectorExtension</summary>

```autoit
Func _GetHwndDirectorExtension()
    Local $hActive = WinGetHandle('[ACTIVE]')
    Local $PIDActive = WinGetProcess($hActive)
    Local $aExtension = WinList("DirectorExtension")
    Local $PIDExt
    For $i = 1 To $aExtension[0][1]
        $PIDExt = WinGetProcess($aExtension[$i][2])
        If $PIDExt = $PIDActive Then Return $aExtension[$i][2]
    Next
EndFunc
```
</details>

### Interaktion über das Director Interface
Wir benötigen außer dem Handle des Interface Fensters noch eine Funktion, um Nachrichten an SciTE zu senden und eine Callback Funktion, die uns Werte zurück liefert. Die Callbackfunktion muss registriert und eine Globale Variable zum Austausch von Werten bereitgestellt werden.
<details><summary>AutoIt - SendSciTE_Command & MY_WM_COPYDATA</summary>

```autoit
Global $gSciTECmd
GUIRegisterMsg(74, "MY_WM_COPYDATA")  ; $WM_COPYDATA = 74

Func SendSciTE_Command($_sCmd, $Wait_For_Return_Info=0)
    Local $WM_COPYDATA = 74
    Local $Scite_hwnd = _GetHwndDirectorExtension()          ; Get SciTE DIrector Handle
    Local $My_Hwnd = GUICreate("AutoIt3-SciTE interface")    ; Create GUI to receive SciTE info
    Local $My_Dec_Hwnd = Dec(StringTrimLeft($My_Hwnd, 2))    ; Convert my Gui Handle to decimal
    $_sCmd = ":" & $My_Dec_Hwnd & ":" & $_sCmd               ; Add dec my gui handle to commandline to tell SciTE where to send the return info
    Local $CmdStruct = DllStructCreate('Char[' & StringLen($_sCmd) + 1 & ']')
    DllStructSetData($CmdStruct, 1, $_sCmd)
    Local $COPYDATA = DllStructCreate('Ptr;DWord;Ptr')
    DllStructSetData($COPYDATA, 1, 1)
    DllStructSetData($COPYDATA, 2, StringLen($_sCmd) + 1)
    DllStructSetData($COPYDATA, 3, DllStructGetPtr($CmdStruct))
    $gSciTECmd = ''
    DllCall('User32.dll', 'None', 'SendMessage', 'HWnd', $Scite_hwnd, _
            'Int', $WM_COPYDATA, 'HWnd', $My_Hwnd, _
            'Ptr', DllStructGetPtr($COPYDATA))
    GUIDelete($My_Hwnd)
    If $Wait_For_Return_Info Then
        Local $n = 0
        While $gSciTECmd = '' Or $n < 10
            Sleep(20)
            $n += 1
        WEnd
    EndIf
    Return $gSciTECmd
EndFunc   ;==>SendSciTE_Command

Func MY_WM_COPYDATA($hWnd, $msg, $wParam, $lParam)
    Local $COPYDATA = DllStructCreate('Ptr;DWord;Ptr', $lParam)
    Local $gSciTECmdLen = DllStructGetData($COPYDATA, 2)
    Local $CmdStruct = DllStructCreate('Char[' & $gSciTECmdLen+1 & ']',DllStructGetData($COPYDATA, 3))
    $gSciTECmd = StringLeft(DllStructGetData($CmdStruct, 1), $gSciTECmdLen)
EndFunc   ;==>MY_WM_COPYDATA
```
</details>

#### Beispiele
Das Standardbsp. darf natürlich nicht fehlen. :wink:  
Wir weisen SciTE an:   
* Schreibe "Hallo  Welt!" in die Konsole

Dazu verwenden wir den Befehl `output`. Alle mit dem Director Interface ausführbare Aktionen sind auf dieser [Seite (The actions understood by SciTE are:)](https://www.scintilla.org/SciTEDirector.html) gelistet.  
*Im Bsp. "Hallo Welt" ist der kpl. Code. Weitere Bsp. beinhalten nur noch den Inhalt der Region "Command".* 

<details><summary>AutoIt - Hallo Welt</summary>

```autoit
Global $gSciTECmd
GUIRegisterMsg(74, "MY_WM_COPYDATA")  ; $WM_COPYDATA = 74


#Region - Command

; Für "output" sind etwaige @CRLF durch "\n" und @TAB durch "\t" zu ersetzen!
SendSciTE_Command("output:" & 'Hallo Welt!\n')

#EndRegion - Command


Func _GetHwndDirectorExtension()
	Local $hActive = WinGetHandle('[ACTIVE]')
	Local $PIDActive = WinGetProcess($hActive)
	Local $aExtension = WinList("DirectorExtension")
	Local $PIDExt
	For $i = 1 To $aExtension[0][1]
		$PIDExt = WinGetProcess($aExtension[$i][2])
		If $PIDExt = $PIDActive Then Return $aExtension[$i][2]
	Next
EndFunc

; by Jos
Func SendSciTE_Command($_sCmd, $Wait_For_Return_Info=0)
    Local $WM_COPYDATA = 74
    Local $Scite_hwnd = _GetHwndDirectorExtension()          ; Get SciTE DIrector Handle
    Local $My_Hwnd = GUICreate("AutoIt3-SciTE interface")    ; Create GUI to receive SciTE info
    Local $My_Dec_Hwnd = Dec(StringTrimLeft($My_Hwnd, 2))    ; Convert my Gui Handle to decimal
    $_sCmd = ":" & $My_Dec_Hwnd & ":" & $_sCmd               ; Add dec my gui handle to commandline to tell SciTE where to send the return info
    Local $CmdStruct = DllStructCreate('Char[' & StringLen($_sCmd) + 1 & ']')
    DllStructSetData($CmdStruct, 1, $_sCmd)
    Local $COPYDATA = DllStructCreate('Ptr;DWord;Ptr')
    DllStructSetData($COPYDATA, 1, 1)
    DllStructSetData($COPYDATA, 2, StringLen($_sCmd) + 1)
    DllStructSetData($COPYDATA, 3, DllStructGetPtr($CmdStruct))
    $gSciTECmd = ''
    DllCall('User32.dll', 'None', 'SendMessage', 'HWnd', $Scite_hwnd, _
            'Int', $WM_COPYDATA, 'HWnd', $My_Hwnd, _
            'Ptr', DllStructGetPtr($COPYDATA))
    GUIDelete($My_Hwnd)
    If $Wait_For_Return_Info Then
        Local $n = 0
        While $gSciTECmd = '' Or $n < 10
            Sleep(20)
            $n += 1
        WEnd
    EndIf
    Return $gSciTECmd
EndFunc   ;==>SendSciTE_Command

Func MY_WM_COPYDATA($hWnd, $msg, $wParam, $lParam)
    Local $COPYDATA = DllStructCreate('Ptr;DWord;Ptr', $lParam)
    Local $gSciTECmdLen = DllStructGetData($COPYDATA, 2)
    Local $CmdStruct = DllStructCreate('Char[' & $gSciTECmdLen+1 & ']',DllStructGetData($COPYDATA, 3))
    $gSciTECmd = StringLeft(DllStructGetData($CmdStruct, 1), $gSciTECmdLen)
EndFunc   ;==>MY_WM_COPYDATA
```
</details>

<details><summary>AutoIt - Abfrage Dateiname</summary>

```autoit
#Region - Command

SendSciTE_Command("askfilename:")
; der abgefragte Wert wird an die Variable "$gSciTECmd" übergeben

$sFile = StringReplace(StringTrimLeft($gSciTECmd,StringInStr($gSciTECmd, ':', 1, 3)), '\\', '\')
ConsoleWrite('@@_Debug_line' & @TAB & @TAB & @ScriptLineNumber & ' var: ' & '$sFile' & ' --> ' & $sFile & @CRLF)

#EndRegion - Command
```
</details>

<details><summary>AutoIt - Abfrage Properties <a href="https://www.scintilla.org/SciTEDoc.html#DefinedVariables">(Übersicht Properties)</a></summary>

```autoit
#Region - Command

; Die Property Struktur in SciTE ist eine optimale Lösung, um Voreinstellungen differenziert zu speichern.
; Nach jeder Aktion in SciTE, werden die Properties aktualisiert - enthalten somit immer die aktuellen Werte.
; Properties sind intern im Globalen Table "props" gespeichert und lassen sich zur Laufzeit manipulieren.

ConsoleWrite('full path of the current file                          : ' & StringReplace(_ScI_GetProperty('FilePath'), '\\', '\') & @CRLF)
ConsoleWrite('directory of the current file without a trailing slash : ' & StringReplace(_ScI_GetProperty('FileDir'), '\\', '\') & @CRLF)
ConsoleWrite('base name of the current file                          : ' & _ScI_GetProperty('FileName') & @CRLF)
ConsoleWrite('extension of the current file                          : ' & _ScI_GetProperty('FileExt') & @CRLF)
ConsoleWrite('$(FileName).$(FileExt)                                 : ' & _ScI_GetProperty('FileNameExt') & @CRLF)
ConsoleWrite('directory in which the User Options file is found      : ' & StringReplace(_ScI_GetProperty('SciteUserHome'), '\\', '\') & @CRLF)

Func _ScI_GetProperty($_sProperty)
	SendSciTE_Command("askproperty:" & $_sProperty)
	Return StringTrimLeft($gSciTECmd,StringInStr($gSciTECmd, ':', 1, 4))
EndFunc

#EndRegion - Command
```
</details>

##### Der Befehl `extender`

Das wohl mächtigste Kommando ist `extender`. Hiermit erlange ich vollen Zugriff auf die Lua-basierte [Scintilla-API](https://www.scintilla.org/PaneAPI.html).  
Die Funktionen/Properties aus der API sind weitestgehend sowohl für die `editor` als auch `output` Pane verwendbar, unterscheiden sich dann nur im Präfix (editor/output).   

Damit lassen sich einzelne Befehlszeilen, Funktionen oder auch kpl. Skripte ausführen.
Per Default können aber hier keine Ergebniswerte zurückgegeben werden, da die Ausführung in einem separaten Prozeß stattfindet. Ein kleiner Kniff hilft hier: Das Ergebnis wird in eine eigene Property, z.B. *extender.result* geschrieben und diese Property kann dann ganz normal abgefragt werden.

<details><summary>AutoIt - Einfügen Textzeile in Editor</summary>

```autoit
#Region - Command

; Wir fügen hier unter der Zeile mit dem Cursor eine neue Zeile ein mit dem Text "; NEUE ZEILE: #Zeilennummer"
; Die Cursorposition bleibt beibehalten.

; Ermittle Cursorposition und Zeilennummer
SendSciTE_Command("extender:dostring do props['extender.result']=editor.CurrentPos..'|'..editor:LineFromPosition(editor.CurrentPos) end")
$aCursorLine = StringSplit(_GetExtenderResult(), '|', 2)    ; Cursorpos. und Zeilennr. in ein Array splitten

; In neuer Zeile Text einfügen, Cursorpos. zurücksetzen
SendSciTE_Command("extender:dostring do newline = [[; NEUE ZEILE: #]]..tostring(" & $aCursorLine[1] & " +2) " & _
                                       "editor:LineEnd() editor:NewLine() " & _
                                       "editor:InsertText(editor.CurrentPos, newline) " & _
                                       "editor.CurrentPos = " & $aCursorLine[0] & " end")


Func _GetExtenderResult()
    SendSciTE_Command("askproperty:extender.result")
    Return StringTrimLeft($gSciTECmd,StringInStr($gSciTECmd, ':', 1, 4))
EndFunc

#EndRegion - Command
```
</details>

#### Menü Kommandos aufrufen
In der [Scintilla-Doku](https://www.scintilla.org/CommandValues.html) ist eine Übersicht aller Menübefehle vorhanden. Ich habe diese und alle weiteren SciTE-Konstanten für AutoIt als [SciTE_Constants.au3](https://github.com/BugFix/AutoIt-Scripts/blob/main/About_SciTE/SciTE_Constants.au3) erstellt.  
Ein Menükommando wird mit `menucommand` und der entsprechenden Befehls-ID aufgerufen. Die Menü-IDs beginnen alle mit `$IDM_` 
Viele Menübefehle finden sich auch in Funktionen der API wieder. Ob man dann lieber Menükommando oder API-Funktion verwendet ergibt sich meist aus dem Kontext.

<details><summary>AutoIt - menucommand</summary>

```autoit
#Region - Command

; Neuen leeren Tab im Editor öffnen (= Ctrl+N)
SendSciTE_Command("menucommand:" & $IDM_NEW)

; Datei als UTF8 (ohne BOM) kodieren
SendSciTE_Command("menucommand:" & $IDM_ENCODING_UCOOKIE)

; Ausgabe löschen (= Shift+F5)
SendSciTE_Command("menucommand:" & $IDM_CLEAROUTPUT)

; Öffnen des Suchen-Dialogs
SendSciTE_Command("menucommand:" & $IDM_FIND)

#EndRegion - Command
```
</details>

### Das Verhalten / Aussehen von SciTE beeinflussen

#### Toolbar Button für Speichern manipulieren

Der Code ist zu finden im AutoIt-Forum: [Speichern-Button Ausgrauen](https://autoit.de/thread/86492-faq-scite-editor/?postID=695834#post695834)

#### Hervorheben des aktiven Tabs und Markierung ungespeicherter Tabs

Der Code und Bsp.-Bilder sind ebenfalls zu finden im AutoIt-Forum: [SciTE - Farbig hervorheben: Aktuelles Tab Item](https://autoit.de/thread/87999-scite-farbig-hervorheben-aktuelles-tab-item/?postID=710475#post710475)

Quellen:
[^1]: [https://www.scintilla.org/SciTE.html](https://www.scintilla.org/SciTE.html)
[^2]: [https://www.scintilla.org/SciTEDirector.html](https://www.scintilla.org/SciTEDirector.html)

