param(
    [string]$SkillsRoot = (Join-Path $PSScriptRoot '..' '..')
)

$ErrorActionPreference = 'Stop'
$errors = @()
Get-ChildItem -LiteralPath $SkillsRoot -Directory | ForEach-Object {
    $skillFile = Join-Path $_.FullName 'SKILL.md'
    if (-not (Test-Path -LiteralPath $skillFile)) {
        $errors += "Missing SKILL.md: $($_.Name)"
        return
    }
    $text = Get-Content -LiteralPath $skillFile -Raw -Encoding UTF8
    if ($text -notmatch '(?ms)^---\s*\r?\n.*?^name:\s*([^\r\n]+).*?^description:\s*.+?^---') {
        $errors += "Invalid frontmatter: $($_.Name)"
    }
    if ($text -notmatch '\[元数据层 Metadata\]|\[元数据层\]') { $errors += "Missing metadata marker: $($_.Name)" }
    if ($text -notmatch '\[指令层 Instruction\]|\[指令层\]') { $errors += "Missing instruction marker: $($_.Name)" }
    if ($text -notmatch '\[资源层 Resource\]|\[资源层\]') { $errors += "Missing resource marker: $($_.Name)" }
}
if ($errors.Count) { $errors | ForEach-Object { Write-Error $_ }; exit 1 }
Write-Output 'Agen Skill three-layer structure passed.'
