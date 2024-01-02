;-- TIME_STAMP   2013-03-10 13:39:29

; == Menu IDs.
; == These are located 100 apart. No one will want more than 100 in each menu ;)
Global Const $IDM_MRUFILE           = 1000
; ! Global Const $IDM_TOOLS         = 1100
; ! -start-[ToolsMax]
Global Const $IDM_TOOLS             = 9000
Global Const $IDM_TOOLSMAX          = 9300
; ! -end-[ToolsMax]
Global Const $IDM_BUFFER            = 1200
Global Const $IDM_IMPORT            = 1300
Global Const $IDM_LANGUAGE          = 1400

; == File
Global Const $IDM_NEW               = 101
Global Const $IDM_OPEN              = 102
Global Const $IDM_OPENSELECTED      = 103  ; == Open Selected Filename
Global Const $IDM_REVERT            = 104
Global Const $IDM_CLOSE             = 105
Global Const $IDM_SAVE              = 106
Global Const $IDM_SAVEAS            = 110
Global Const $IDM_SAVEASHTML        = 111
Global Const $IDM_SAVEASRTF         = 112
Global Const $IDM_SAVEASPDF         = 113
Global Const $IDM_FILER             = 114
Global Const $IDM_SAVEASTEX         = 115
Global Const $IDM_SAVEACOPY         = 116
Global Const $IDM_SAVEASXML         = 117
Global Const $IDM_COPYPATH          = 118
Global Const $IDM_MRU_SEP           = 120
Global Const $IDM_PRINTSETUP        = 130  ; == Page Setup
Global Const $IDM_PRINT             = 131
Global Const $IDM_LOADSESSION       = 132
Global Const $IDM_SAVESESSION       = 133
Global Const $IDM_QUIT              = 140
Global Const $IDM_ENCODING_DEFAULT  = 150  ; == Code Page Property
Global Const $IDM_ENCODING_UCS2BE   = 151  ; == UTF-16 Big Endian
Global Const $IDM_ENCODING_UCS2LE   = 152  ; == UTF-16 Little Endian
Global Const $IDM_ENCODING_UTF8     = 153  ; == UTF-8 with BOM
Global Const $IDM_ENCODING_UCOOKIE  = 154  ; ==	UTF-8

Global Const $MRU_START             = 17
Global Const $IMPORT_START          = 20
Global Const $TOOLS_START           = 3

; == Edit
Global Const $IDM_UNDO              = 201
Global Const $IDM_REDO              = 202
Global Const $IDM_CUT               = 203
Global Const $IDM_COPY              = 204
Global Const $IDM_PASTE             = 205
Global Const $IDM_CLEAR             = 206  ; == Delete!
Global Const $IDM_SELECTALL         = 207
Global Const $IDM_PASTEANDDOWN      = 208
Global Const $IDM_FIND              = 210
Global Const $IDM_FINDNEXT          = 211
Global Const $IDM_FINDNEXTBACK      = 212  ; == Find Previous
Global Const $IDM_FINDNEXTSEL       = 213
Global Const $IDM_FINDNEXTBACKSEL   = 214
Global Const $IDM_FINDINFILES       = 215
Global Const $IDM_REPLACE           = 216
Global Const $IDM_GOTO              = 220
Global Const $IDM_BOOKMARK_NEXT     = 221
Global Const $IDM_BOOKMARK_TOGGLE   = 222
Global Const $IDM_BOOKMARK_PREV     = 223
Global Const $IDM_BOOKMARK_CLEARALL = 224
Global Const $IDM_BOOKMARK_NEXT_SELECT  = 225
Global Const $IDM_BOOKMARK_PREV_SELECT  = 226
Global Const $IDM_MATCHBRACE        = 230
Global Const $IDM_SELECTTOBRACE     = 231
Global Const $IDM_SHOWCALLTIP       = 232
Global Const $IDM_COMPLETE          = 233
Global Const $IDM_COMPLETEWORD      = 234
Global Const $IDM_EXPAND            = 235  ; == Toggle current fold
Global Const $IDM_TOGGLE_FOLDALL    = 236
Global Const $IDM_TOGGLE_FOLDRECURSIVE          = 237
Global Const $IDM_EXPAND_ENSURECHILDRENVISIBLE  = 238
Global Const $IDM_UPRCASE           = 240  ; == Make Selection Uppercase
Global Const $IDM_LWRCASE           = 241  ; == Make Selection Lowercase
Global Const $IDM_ABBREV            = 242  ; == Expand Abbreviation
Global Const $IDM_BLOCK_COMMENT     = 243  ; == Block Comment or Uncomment
Global Const $IDM_STREAM_COMMENT    = 244
Global Const $IDM_COPYASRTF         = 245
Global Const $IDM_BOX_COMMENT       = 246
Global Const $IDM_INS_ABBREV        = 247  ; == Insert Abbreviation
Global Const $IDM_JOIN              = 248
Global Const $IDM_SPLIT             = 249
Global Const $IDM_DUPLICATE         = 250
Global Const $IDM_INCSEARCH         = 252  ; == Incremental Search
Global Const $IDM_ENTERSELECTION    = 256

Global Const $IDC_INCFINDTEXT       = 253
Global Const $IDC_INCFINDBTNOK      = 254
Global Const $IDC_EDIT1             = 1000
Global Const $IDC_STATIC            = -1


Global Const $IDM_PREVMATCHPPC          = 260
Global Const $IDM_SELECTTOPREVMATCHPPC  = 261
Global Const $IDM_NEXTMATCHPPC          = 262
Global Const $IDM_SELECTTONEXTMATCHPPC  = 263

; == Tools
Global Const $IDM_COMPILE           = 301
Global Const $IDM_BUILD             = 302
Global Const $IDM_GO                = 303
Global Const $IDM_STOPEXECUTE       = 304
Global Const $IDM_FINISHEDEXECUTE   = 305
Global Const $IDM_NEXTMSG           = 306
Global Const $IDM_PREVMSG           = 307

Global Const $IDM_MACRO_SEP         = 310
Global Const $IDM_MACRORECORD       = 311
Global Const $IDM_MACROSTOPRECORD   = 312
Global Const $IDM_MACROPLAY         = 313
Global Const $IDM_MACROLIST         = 314

Global Const $IDM_ACTIVATE          = 320

Global Const $IDM_SRCWIN            = 350
Global Const $IDM_RUNWIN            = 351
Global Const $IDM_TOOLWIN           = 352
Global Const $IDM_STATUSWIN         = 353
Global Const $IDM_TABWIN            = 354

; == Options
Global Const $IDM_SPLITVERTICAL     = 401
Global Const $IDM_VIEWSPACE         = 402  ; == Whitespace
Global Const $IDM_VIEWEOL           = 403
Global Const $IDM_VIEWGUIDES        = 404  ; == Indentation Guides
Global Const $IDM_SELMARGIN         = 405
Global Const $IDM_FOLDMARGIN        = 406
Global Const $IDM_LINENUMBERMARGIN  = 407
Global Const $IDM_VIEWTOOLBAR       = 408
Global Const $IDM_TOGGLEOUTPUT      = 409
Global Const $IDM_VIEWTABBAR        = 410
Global Const $IDM_VIEWSTATUSBAR     = 411
Global Const $IDM_TOGGLEPARAMETERS  = 412
Global Const $IDM_OPENFILESHERE     = 413
Global Const $IDM_WRAP              = 414
Global Const $IDM_WRAPOUTPUT        = 415
Global Const $IDM_READONLY          = 416

Global Const $IDM_CLEAROUTPUT       = 420
Global Const $IDM_SWITCHPANE        = 421

Global Const $IDM_EOL_CRLF          = 430
Global Const $IDM_EOL_CR            = 431
Global Const $IDM_EOL_LF            = 432
Global Const $IDM_EOL_CONVERT       = 433  ; == Convert Line End Characters

Global Const $IDM_TABSIZE           = 440  ; == Change Indentation Settings

Global Const $IDM_MONOFONT          = 450

Global Const $IDM_OPENLOCALPROPERTIES       = 460
Global Const $IDM_OPENUSERPROPERTIES        = 461
Global Const $IDM_OPENGLOBALPROPERTIES      = 462
Global Const $IDM_OPENABBREVPROPERTIES      = 463
Global Const $IDM_OPENLUAEXTERNALFILE       = 464  ; == Open Lua Startup Script
Global Const $IDM_OPENDIRECTORYPROPERTIES   = 465

; Global Const $IDM_SELECTIONMARGIN = 490
; Global Const $IDM_BUFFEREDDRAW    = 491
; Global Const $IDM_USEPALETTE      = 492

; == Buffers
Global Const $IDM_PREVFILE          = 501
Global Const $IDM_NEXTFILE          = 502
Global Const $IDM_CLOSEALL          = 503
Global Const $IDM_SAVEALL           = 504
Global Const $IDM_BUFFERSEP         = 505
Global Const $IDM_PREVFILESTACK     = 506
Global Const $IDM_NEXTFILESTACK     = 507
Global Const $IDM_MOVETABRIGHT      = 508
Global Const $IDM_MOVETABLEFT       = 509

Global Const $IDM_WHOLEWORD         = 800
Global Const $IDM_MATCHCASE         = 801
Global Const $IDM_REGEXP            = 802
Global Const $IDM_WRAPAROUND        = 803
Global Const $IDM_UNSLASH           = 804
Global Const $IDM_DIRECTIONUP       = 805
Global Const $IDM_DIRECTIONDOWN     = 806

; == Help
Global Const $IDM_HELP              = 901
Global Const $IDM_ABOUT             = 902
Global Const $IDM_HELP_SCITE        = 903

; == Windows specific windowing options
Global Const $IDM_ONTOP             = 960  ; == Always On Top
Global Const $IDM_FULLSCREEN        = 961
Global Const $IDC_TABCLOSE          = 962
Global Const $IDC_SHIFTTAB          = 963
Global Const $IDC_TABDBLCLK         = 964  ; == ! -add-[close_on_dbl_clk]

; == Dialog control IDs
Global Const $IDGOLINE              = 220
Global Const $IDABOUTSCINTILLA      = 221
Global Const $IDFINDWHAT            = 222
Global Const $IDFILES               = 223
Global Const $IDDIRECTORY           = 224
Global Const $IDCURRLINE            = 225
Global Const $IDLASTLINE            = 226
Global Const $IDEXTEND              = 227
Global Const $IDTABSIZE             = 228
Global Const $IDINDENTSIZE          = 229
Global Const $IDUSETABS             = 230

Global Const $IDREPLACEWITH         = 231
Global Const $IDWHOLEWORD           = 232
Global Const $IDMATCHCASE           = 233
Global Const $IDDIRECTIONUP         = 234
Global Const $IDDIRECTIONDOWN       = 235
Global Const $IDREPLACE             = 236
Global Const $IDREPLACEALL          = 237
Global Const $IDREPLACEINSEL        = 238
Global Const $IDREGEXP              = 239
Global Const $IDWRAP                = 240

Global Const $IDUNSLASH             = 241
Global Const $IDCMD                 = 242

; == ID for the browse button in the grep dialog
Global Const $IDBROWSE              = 243

Global Const $IDABBREV              = 244

Global Const $IDREPLACEINBUF        = 244
Global Const $IDMARKALL             = 245

Global Const $IDGOLINECHAR          = 246
Global Const $IDCURRLINECHAR        = 247
Global Const $IDREPLDONE            = 248

Global Const $IDDOTDOT              = 249
Global Const $IDFINDINSTYLE         = 250
Global Const $IDFINDSTYLE           = 251
Global Const $IDCONVERT             = 252

Global Const $IDPARAMSTART          = 300

; == Dialog IDs
Global Const $IDD_FIND              = 400
Global Const $IDD_REPLACE           = 401
Global Const $IDD_BUFFERS           = 402
Global Const $IDD_FIND_ADV          = 403
Global Const $IDD_REPLACE_ADV       = 404

; == Resource IDs
; ! Global Const $IDR_CLOSEFILE = 100
Global Const $IDR_BUTTONS           = 100	; == ! -change-[user.toolbar]
Global Const $IDC_DRAGDROP          = 401
Global Const $IDBM_WORD             = 101
Global Const $IDBM_CASE             = 102
Global Const $IDBM_REGEX            = 103
Global Const $IDBM_BACKSLASH        = 104
Global Const $IDBM_AROUND           = 105
Global Const $IDBM_UP               = 106
