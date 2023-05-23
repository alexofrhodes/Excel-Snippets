VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "aDesigner"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

'* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'* Module     : aDesigner
'* Author     : Anastasiou Alex
'* Contacts   : AnastasiouAlex@gmail.com
'*
'* BLOG       : https://alexofrhodes.github.io/
'* GITHUB     : https://github.com/alexofrhodes/
'* YOUTUBE    : https://www.youtube.com/channel/UC5QH3fn1zjx0aUjRER_rOjg
'* VK         : https://vk.com/video/playlist/735281600_1
'*
'* Modified   : Date and Time       Author              Description
'* Created    : 04-05-2023 12:18    Alex
'* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


Option Explicit

Private oModule As VBComponent

Function Active() As aDesigner
    Set Active = Me
    Class_Initialize
End Function

Private Sub Class_Initialize()
    Set oModule = ActiveModule
    If oModule.Type <> vbext_ct_MSForm Then End
End Sub

Private Sub Class_Terminate()
'exit
End Sub

Function SelectedControl() As MSForms.control
    If SelectedControls.Count = 1 Then
        Dim ctl    As control
        For Each ctl In oModule.Designer.SELECTED
            Set SelectedControl = ctl
            Exit Function
        Next ctl
    End If
End Function

Function SelectedControls() As Collection
    Dim ctl    As control
    Dim out As New Collection
    For Each ctl In oModule.Designer.SELECTED
        out.Add ctl
    Next ctl
    Set SelectedControls = out
End Function

Function SelectedFrameControl() As MSForms.control
    Dim ctl    As control, c As control
    Dim out As New Collection
    For Each ctl In oModule.Designer.SELECTED
        For Each c In ctl.Controls
            out.Add c
        Next
    Next ctl
    If out.Count = 0 Then Exit Function
    Set SelectedFrameControl = out(1)
End Function

Function SelectedFrameControls() As Collection
    Dim ctl    As control, c As control
    Dim out As New Collection
    For Each ctl In oModule.Designer.SELECTED
        For Each c In ctl.Controls
            out.Add c
        Next
    Next ctl
    Set SelectedFrameControls = out
End Function

'Function RealActiveControl(oForm As Variant) As MSForms.control
''Jaafar Tribak
'
'    Dim oControl As MSForms.control
'
'    On Error Resume Next
'    Set oControl = oForm.ActiveControl
'    Do
'        Set oControl = CallByName(oControl, "ActiveControl", VbGet)
'    Loop Until TypeName(oControl) <> "Frame"
'    Set RealActiveControl = oControl
'End Function

Sub RemoveCaption()
    Dim c As MSForms.control
    For Each c In SelectedControls
        c.Caption = ""
    Next
End Sub

Sub SetHandCursor()
    Dim ctr As MSForms.control
    For Each ctr In SelectedControls
        AssignHandCursor ctr
    Next
End Sub

Private Sub AssignHandCursor(control As MSForms.control)
    On Error GoTo Catch
    With control
        .MouseIcon = LoadPicture("C:\Users\acer\Dropbox\SOFTWARE\EXCEL\0 Alex\icons\Hand Cursor Pointer.ico")
        .MousePointer = fmMousePointerCustom
    End With
Catch:
End Sub

Sub SwitchNames()
    If SelectedControls.Count <> 2 Then Exit Sub

    Dim ctrls As Collection
    Set ctrls = SelectedControls
    If ctrls.Count <> 2 Then Exit Sub
    Dim tmp1 As String
    tmp1 = ctrls(1).Name
    Dim tmp2 As String
    tmp2 = ctrls(2).Name
    ctrls(1).Name = "tmp1"
    ctrls(2).Name = "tmp2"
    ctrls(1).Name = tmp2
    ctrls(2).Name = tmp1
End Sub

Sub SwitchPositions()
    If SelectedControls.Count <> 2 Then Exit Sub
    Dim ctrls As Collection
    Set ctrls = SelectedControls
    If ctrls.Count <> 2 Then Exit Sub
    Dim left1 As Long, left2 As Long
    Dim top1 As Long, top2 As Long
    left1 = ctrls(1).Left
    top1 = ctrls(1).Top
    left2 = ctrls(2).Left
    top2 = ctrls(2).Top
    ctrls(1).Left = left2
    ctrls(1).Top = top2
    ctrls(2).Left = left1
    ctrls(2).Top = top1
End Sub





Sub EditObjectProperties(ParamArray Args() As Variant)
    Rem EditObjectProperties "left",0,"top",0
    Dim obj As control: Set obj = SelectedControl
    If obj Is Nothing Or SelectedControls.Count <> 1 Then Exit Sub
    If Not WorksheetFunction.IsEven(UBound(Args)) Then Exit Sub
    Dim i As Long: i = 0
    Do While i < UBound(Args)
        CallByName obj, Args(i), VbLet, _
                    IIf(IsNumeric(Args(i + 1)), _
                    CLng(Args(i + 1)), _
                    Args(i + 1))
        i = i + 2
    Loop
End Sub

Sub EditObjectsProperty(objProperty As String, ParamArray Args() As Variant)
    Dim obj As New Collection: Set obj = SelectedControls
    If obj.Count <> UBound(Args) + 1 Then
        Toast "selected controls count <> arguements count"
        Exit Sub
    End If
    Dim ArgItem
    Dim i As Long
    i = obj.Count
    Dim element As Variant
    For Each element In obj
        CallByName element, objProperty, VbLet, _
                    IIf(IsNumeric(Args(i - 1)), _
                    CLng(Args(i - 1)), _
                    Args(i - 1))
        i = i - 1
    Next
End Sub

Sub RenameControlAndCode()
    Dim ctr As MSForms.control: Set ctr = SelectedControl
    If ctr Is Nothing Then Exit Sub
    Dim OldName As String: OldName = ctr.Name
    Dim NewName As String: NewName = InputboxString
    If NewName = "" Then Exit Sub
    ctr.Name = NewName
    Dim CountOfLines As Long: CountOfLines = oModule.CodeModule.CountOfLines
    If CountOfLines = 0 Then Exit Sub
    Dim strline As String
    Dim i As Long
    For i = 1 To CountOfLines
        strline = oModule.CodeModule.Lines(i, 1)
        If InStr(1, strline, " " & OldName & "_") > 0 Then
            oModule.CodeModule.ReplaceLine (i), Replace(strline, OldName, NewName)
        End If
    Next
End Sub

Sub SortControlsHorizontally()
    SortControls False
End Sub

Sub SortControlsVertivally()
    SortControls True
End Sub

Private Sub SortControls(Optional SortVertically As Boolean = True)
    Rem call from immediate window while looking at userform
    Dim ctr As MSForms.control
    Dim coll As New Collection
    Dim lastTop As Long
    Dim lastLeft As Long
    Dim element As Variant
    For Each element In SelectedControls
        coll.Add element.Name
    Next
    Set coll = aCollection.Init(coll).Sort.Items
    lastTop = 2000
    For Each element In coll
        If oModule.Designer.Controls(element).Top < lastTop Then lastTop = oModule.Designer.Controls(element).Top
        If oModule.Designer.Controls(element).Left < lastLeft Then lastLeft = oModule.Designer.Controls(element).Left
    Next
    For Each element In coll
        If SortVertically = True Then
            lastTop = lastTop + oModule.Designer.Controls(element).Height + 6
        Else
            lastLeft = lastLeft + oModule.Designer.Controls(element).Width + 6
        End If
        oModule.Designer.Controls(element).Top = lastTop
        oModule.Designer.Controls(element).Left = lastLeft
    Next
End Sub

Public Sub CopyControlProperties()
    If SelectedControls.Count <> 1 Then Exit Sub
    Dim ctr As control: Set ctr = SelectedControl
    Dim ws As Worksheet: Set ws = CreateOrSetSheet("CopyControlProperties", ThisWorkbook)
    Dim PropertiesArray As Variant
    PropertiesArray = Array("Accelerator", "Alignment", "AutoSize", "AutoTab", "BackColor", "BackStyle", "BorderColor", "BorderStyle", "BoundColumn", _
    "Caption", "Children", "columnCount", "ColumnHeads", "ColumnWidths", "ControlSource", "ControlTipText", "Cycle", "DrawBuffer", "Enabled", "EnterKeyBehavior", "Expanded", _
    "FirstSibling", "FontBold", "FontSize", "ForeColor", "FullPath", "GroupName", "Height", "HelpContextID", "KeepScrollBarsVisible", "LargeChange", "LastSibling", "LineStyle", "ListRows", "Locked", _
    "Max", "MaxLength", "Min", "MouseIcon", "MousePointer", "MultiLine", "MultiSelect", "Next", "Nodes", "Orientation", _
    "Parent", "PasswordChar", "PathSeparator", "Picture", "PictureAlignment", "PictureSizeMode", "PictureTiling", "Previous", "RightToLeft", "Root", "RowSource", _
    "ScrollBars", "ScrollHeight", "ScrollLeft", "ScrollTop", "ScrollWidth", "Selected", "SelectedItem", "ShowModal", "SmallChange", "Sorted", "SpecialEffect", "StartUpPosition", _
    "Style", "Tag", "Text", "TextColumn", "TripleState", "WhatsThisHelp", "Width", "Zoom")
    If ws.Range("A1") = "" Then ws.Range("A1").RESIZE(UBound(PropertiesArray) + 1) = WorksheetFunction.Transpose(PropertiesArray)
    Dim PropertiesRange As Range: Set PropertiesRange = ws.Range("A1").CurrentRegion.RESIZE(, 1)
    Dim Property As Range
    On Error Resume Next
    For Each Property In PropertiesRange
        Property.OFFSET(0, 1) = CallByName(ctr, Property.Value, VbGet)
    Next
End Sub

Public Sub PasteControlProperties()
    Dim control As MSForms.control
    Dim Controls As Collection: Set Controls = SelectedControls
    If Controls.Count = 0 Then Exit Sub
    Dim ws As Worksheet: Set ws = ThisWorkbook.SHEETS("CopyControlProperties")
    If ws.Columns(2).SpecialCells(xlCellTypeConstants).Count = 0 Then
        Toast "You haven't saved properties before"
        Exit Sub
    End If
    Dim PropertiesRange As Range: Set PropertiesRange = ws.Range("A1").CurrentRegion.RESIZE(, 1)
    Dim Property As Range
    On Error Resume Next
    For Each control In Controls
        For Each Property In PropertiesRange
            CallByName control, Property.Value, VbLet, Property.OFFSET(0, 1).Value
        Next
    Next
End Sub





'-------------------



Rem -----------------------------------
Rem Put in userform:
Rem -----------------------------------
Rem Private WithEvents Emitter As EventListeneRemitter
Rem

Rem Private Sub Emitter_LabelMouseOut(Label As MSForms.Label)
Rem     If InStr(1, Label.Tag, "reframe", vbTextCompare) > 0 Then
Rem         If Label.BackColor <> &H80B91E Then Label.BackColor = &H534848
Rem     End If
Rem End Sub
Rem
Rem Private Sub Emitter_LabelMouseOver(Label As MSForms.Label)
Rem     If InStr(1, Label.Tag, "reframe", vbTextCompare) > 0 Then
Rem         If Label.BackColor <> &H80B91E Then Label.BackColor = &H808080
Rem     End If
Rem End Sub
Rem
Rem Sub Emitter_LabelClick(ByRef Label As MSForms.Label)
Rem     If InStr(1, Label.Tag, "reframe", vbTextCompare) > 0 Then Reframe Me, Label
Rem End Sub
Rem

Rem Private Sub UserForm_Initialize()
Rem     startFrameForm Me
Rem End Sub

Public Sub addFrameFormCode()
    Dim s As String
    s = aCodeModule.CopyTemplateFromSheet("FrameFormCode")
    If InStr(1, aModule.Init(oModule).Code, oModule.Name & "_Initialize") Then
        Toast "Threre is already _Initialize_ code in this form. Code will be put in cilpboard and immediate window."
        dp s
        CLIP s
    Else
        oModule.CodeModule.AddFromString s
    End If
End Sub

Public Sub CreateFrameMenu()
    Select Case SelectedControls.Count
    Case Is = 0
        ActiveModule.Designer.BackColor = MyColors.FormBackgroundDarkGray
        addFrameSidebar ActiveModule
        addFrameFormCode
    Case Is = 1
        addFrameSidebar SelectedControl
    End Select
End Sub

Private Sub addFrameSidebar(Form As Object, Optional dockRight As Boolean)
    '@INCLUDE askFormMenuElements
    '@INCLUDE UnderlineFrameName
    '@INCLUDE CreateOrSetFrame
    Dim F As MSForms.control
    Dim L As MSForms.control
    Set F = CreateOrSetFrame(Form, "SideBar" & Form.Name)
    F.Tag = "skip"
    F.BackColor = 5457992
    F.ForeColor = vbWhite
    F.BorderStyle = 1
    F.BorderStyle = 0
    F.Width = 80
    If TypeName(Form) = "VBComponent" Then
        F.Height = 800
    Else
        F.Height = Form.Height
    End If
    dockRight = IIf(TypeName(Form) = "VBComponent", False, True)
    If dockRight = True Then
        F.Left = Form.Width - F.Width
    Else
        F.Left = 0
    End If
    UnderlineFrameName Form, F
    If TypeName(Form) = "VBComponent" Then
        Set L = Form.Designer.Controls.Add(ControlIDLabel, "Anchor" & Form.Name)
    Else
        Set L = Form.Controls.Add(ControlIDLabel, "Anchor" & Form.Name)
    End If
    L.Visible = False
    L.Left = IIf(TypeName(Form) = "VBComponent", F.Left + F.Width + 9, 1)
    L.Top = 12
    L.Width = 1
    L.BackColor = vbWhite
    L.Visible = False
    askFormMenuElements Form
End Sub

Private Sub askFormMenuElements(Form As Object)
    '@INCLUDE InputboxString
    '@INCLUDE addFrameMenu
    Dim FormElements As String
    FormElements = InputboxString("Form Menus", "Type comma delimited menu names")
    If FormElements = "" Then Exit Sub
    Dim var
    var = Split(FormElements, ",")
    Dim i As Long
    For i = LBound(var) To UBound(var)
        var(i) = Trim(var(i))
    Next
    Dim coll As New Collection
    Dim element
    On Error Resume Next
    For Each element In var
        If Not IsNumeric(Left(element, 1)) _
            And InStr(1, element, " ") = 0 Then
            coll.Add CStr(element), CStr(element)
        End If
    Next
    On Error GoTo 0
    For Each element In coll
        addFrameMenu Form, CStr(element)
    Next
End Sub

Private Sub addFrameMenu(Form As Object, FrameCaptionNoSpace As String)
    '@INCLUDE Reframe
    '@INCLUDE UnderlineFrameName
    '@INCLUDE CreateOrSetFrame
    '@INCLUDE AvailableFormOrFrameRow
    '@INCLUDE AvailableFormOrFrameColumn
    Dim F As MSForms.control
    Dim L As MSForms.control
    Dim Module As VBComponent
    If TypeName(Form) = "VBComponent" Then
        Set Module = Form
        Set F = Module.Designer.Controls.Add(ControlIDFrame, FrameCaptionNoSpace)
    Else
        Set Module = ThisWorkbook.VBProject.VBComponents(Form.Parent.Name)
        Set F = CreateOrSetFrame(Module.Designer.Controls(Form.Name), FrameCaptionNoSpace)
    End If
    F.Tag = "anchor" & Form.Name
    F.Caption = FrameCaptionNoSpace
    F.ForeColor = vbWhite
    F.Visible = False
    If TypeName(Form) = "VBComponent" Then
        F.Left = AvailableFormOrFrameColumn(Form.Designer)
    Else
        F.Left = 0
    End If
    F.Visible = True
    F.BorderStyle = 1
    F.BorderStyle = 0
    F.Top = 12
    F.Width = 100
    UnderlineFrameName Form, F
    If TypeName(Form) = "VBComponent" Then
        Set L = Module.Designer.Controls("SideBar" & Form.Name).Controls.Add(ControlIDLabel)
    Else
        Set L = Module.Designer.Controls("SideBar" & Form.Name).Add(ControlIDLabel)
    End If
    L.Caption = FrameCaptionNoSpace
    L.ForeColor = vbWhite
    L.Visible = False
    L.Top = AvailableFormOrFrameRow(Module.Designer.Controls("SideBar" & Form.Name))
    L.Left = L.Left + 3
    L.Visible = True
    L.Tag = "reframe"
    L.Width = F.Width
End Sub

Private Sub AddControlsToFrame(isSubFrame As Boolean)
    '@INCLUDE SelectedControl
    '@INCLUDE SelectedControls
    '@INCLUDE SelectedFrameControl
    '@INCLUDE ActiveModule
    '@INCLUDE InputboxString
    If ActiveModule.Type <> vbext_ct_MSForm Then Exit Sub
    Dim ad As New aDesigner
    If ad.SelectedControls.Count <> 1 Then Exit Sub
    If TypeName(ad.SelectedControl) <> "Frame" Then Exit Sub
    Dim Module As VBComponent
    Dim TargetFrame As MSForms.control
    If isSubFrame = False Then
        Set TargetFrame = ad.SelectedControl
        Set Module = ActiveModule
    Else
        Set TargetFrame = ad.SelectedFrameControl
        Set Module = ThisWorkbook.VBProject.VBComponents(TargetFrame.Parent.Parent.Name)
    End If
    Dim ControlNames As String
    ControlNames = InputboxString("Form Menus", "Type comma delimited menu names")
    If ControlNames = "" Then Exit Sub
    Dim var
    var = Split(ControlNames, ",")
    Dim i As Long
    For i = LBound(var) To UBound(var)
        var(i) = Trim(var(i))
    Next
    Dim coll As New Collection
    Dim element
    On Error Resume Next
    For Each element In var
        If Not IsNumeric(Left(element, 1)) _
            And InStr(1, element, " ") = 0 Then
            coll.Add CStr(element), CStr(element)
        End If
    Next
    On Error GoTo 0
    Dim L As MSForms.control
    For Each element In coll
        Set L = Module.Designer.Controls(TargetFrame.Name).Controls.Add(ControlIDCommandButton, element)
        L.Top = 7 + ((TargetFrame.Controls.Count - 1) * L.Height)
        L.BackColor = vbWhite
    Next
End Sub

Private Sub UnderlineFrameName(Form As Object, F As MSForms.control)
    Dim Module As VBComponent
    If TypeName(Form) = "VBComponent" Then
        Set Module = Form
    Else
        Set Module = ThisWorkbook.VBProject.VBComponents(Form.Parent.Name)
    End If
    Dim L As MSForms.Label
    Set L = Module.Designer.Controls(F.Name).Controls.Add(ControlIDLabel)
    L.Top = 6
    L.Height = 1
    L.Width = 100
    L.BackColor = vbWhite
    L.Tag = "skip"
End Sub
