param(
    [string]$SkillsRoot = (Join-Path $PSScriptRoot '..' '..')
)

$ErrorActionPreference = 'Stop'
$errors = @()
Get-ChildItem -LiteralPath $SkillsRoot -Directory | ForEach-Object {
    if ($_.Name -eq '00-ARCHITECTURE') { return }
    $skillFile = Join-Path $_.FullName 'SKILL.md'
    if (-not (Test-Path -LiteralPath $skillFile)) {
        $errors += "Missing SKILL.md: $($_.Name)"
        return
    }
    $text = Get-Content -LiteralPath $skillFile -Raw -Encoding UTF8
    if ($text -notmatch '(?ms)^---\s*\r?\n.*?^name:\s*([^\r\n]+).*?^description:\s*.+?^---') {
        $errors += "Invalid frontmatter: $($_.Name)"
    }
}
if ($errors.Count) { $errors | ForEach-Object { Write-Error $_ }; exit 1 }
Write-Output 'Agent ABAP three-layer structure passed.'
