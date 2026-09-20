param(
    [Parameter(Mandatory = $true)]
    [string]$SpecPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $SpecPath -PathType Leaf)) {
    throw "Spec file not found: $SpecPath"
}

$spec = Get-Content -LiteralPath $SpecPath -Raw -Encoding UTF8 | ConvertFrom-Json

function Get-AbapBool([object]$value) {
    if ($null -eq $value) { return $false }
    return [bool]$value
}

function Add-Line([System.Collections.Generic.List[string]]$lines, [string]$text = '') {
    $lines.Add($text)
}

$program = if ($spec.program) { [string]$spec.program } else { 'z_template_classic_alv' }
$dbTable = if ($spec.dbTable) { [string]$spec.dbTable } else { 'mara' }
$lineType = if ($spec.lineType) { [string]$spec.lineType } else { 'ty_data' }
$dataTable = if ($spec.dataTable) { [string]$spec.dataTable } else { 'gt_data' }

$controls = @()
if (Get-AbapBool $spec.controls.selection) { $controls += @{ name = 'sel'; type = 'char1'; layout = "gs_layout-box_fname  = 'SEL'." } }
if (Get-AbapBool $spec.controls.count) { $controls += @{ name = 'count'; type = 'i'; layout = "gs_layout-countfname = 'COUNT'." } }
if (Get-AbapBool $spec.controls.rowColor) { $controls += @{ name = 'line_color'; type = 'c LENGTH 4'; layout = "gs_layout-info_fname = 'LINE_COLOR'." } }
if (Get-AbapBool $spec.controls.cellColor) { $controls += @{ name = 'cell_color'; type = 'lvc_t_scol'; layout = "gs_layout-ctab_fname = 'CELL_COLOR'." } }
if (Get-AbapBool $spec.controls.editStyle) { $controls += @{ name = 'cellstyles'; type = 'lvc_t_styl'; layout = "gs_layout-stylefname = 'CELLSTYLES'." } }
if (Get-AbapBool $spec.controls.checkbox) { $controls += @{ name = 'checkbox'; type = 'char1'; layout = $null } }
if (Get-AbapBool $spec.controls.dropdown) { $controls += @{ name = 'dd_handle'; type = 'int4'; layout = $null } }
if (Get-AbapBool $spec.controls.resultFlag) { $controls += @{ name = 'sep_flag'; type = 'char10'; layout = $null } }

$lines = [System.Collections.Generic.List[string]]::new()
Add-Line $lines "REPORT $program."
Add-Line $lines ''
Add-Line $lines 'TYPES:'
Add-Line $lines "  BEGIN OF $lineType,"
foreach ($control in $controls) {
    Add-Line $lines ("    {0,-10} TYPE {1}," -f $control.name, $control.type)
}
Add-Line $lines "    INCLUDE STRUCTURE $dbTable,"
Add-Line $lines "  END OF $lineType."
Add-Line $lines ''
Add-Line $lines "DATA $dataTable TYPE STANDARD TABLE OF $lineType."
Add-Line $lines 'DATA gs_layout TYPE lvc_s_layo.'
Add-Line $lines 'DATA gt_fieldcat TYPE lvc_t_fcat.'
Add-Line $lines ''
Add-Line $lines 'START-OF-SELECTION.'
Add-Line $lines "  SELECT * FROM $dbTable INTO CORRESPONDING FIELDS OF TABLE @$dataTable UP TO 10 ROWS."
Add-Line $lines ''
Add-Line $lines '  PERFORM frm_set_layout.'
Add-Line $lines '  PERFORM frm_set_fieldcat.'
Add-Line $lines '  CALL FUNCTION ''REUSE_ALV_GRID_DISPLAY_LVC'''
Add-Line $lines '    EXPORTING'
Add-Line $lines '      i_callback_program = sy-repid'
Add-Line $lines '      is_layout_lvc       = gs_layout'
Add-Line $lines '      it_fieldcat_lvc     = gt_fieldcat'
Add-Line $lines '    TABLES'
Add-Line $lines "      t_outtab            = $dataTable."
Add-Line $lines ''
Add-Line $lines 'FORM frm_set_layout.'
Add-Line $lines '  CLEAR gs_layout.'
Add-Line $lines '  gs_layout-cwidth_opt = abap_true.'
foreach ($control in $controls) {
    if ($control.layout) { Add-Line $lines "  $($control.layout)" }
}
Add-Line $lines 'ENDFORM.'
Add-Line $lines ''
Add-Line $lines 'FORM frm_set_fieldcat.'
Add-Line $lines '  CLEAR gt_fieldcat.'
foreach ($field in @($spec.fields)) {
    $refTable = if ($field.refTable) { [string]$field.refTable } else { '' }
    $refField = if ($field.refField) { [string]$field.refField } else { '' }
    $name = [string]$field.name
    $text = [string]$field.text
    Add-Line $lines "  PERFORM set_fieldcat USING '$refTable' '$refField' '$name' '$text'."
}
Add-Line $lines 'ENDFORM.'
Add-Line $lines ''
Add-Line $lines 'FORM set_fieldcat USING'
Add-Line $lines '  VALUE(p_ref_table)'
Add-Line $lines '  VALUE(p_ref_field)'
Add-Line $lines '  VALUE(p_fieldname)'
Add-Line $lines '  VALUE(p_text).'
Add-Line $lines '  DATA ls_fieldcat TYPE lvc_s_fcat.'
Add-Line $lines '  ls_fieldcat-ref_table = p_ref_table.'
Add-Line $lines '  ls_fieldcat-ref_field = p_ref_field.'
Add-Line $lines '  ls_fieldcat-fieldname = p_fieldname.'
Add-Line $lines '  ls_fieldcat-coltext   = p_text.'
Add-Line $lines '  ls_fieldcat-seltext   = p_text.'
Add-Line $lines '  APPEND ls_fieldcat TO gt_fieldcat.'
Add-Line $lines 'ENDFORM.'

$parent = Split-Path -Parent $OutputPath
New-Item -ItemType Directory -Path $parent -Force | Out-Null
[System.IO.File]::WriteAllLines($OutputPath, $lines, [System.Text.UTF8Encoding]::new($false))
Write-Output "Generated $OutputPath"
