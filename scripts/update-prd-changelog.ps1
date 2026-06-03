# Updates the Git change log section in docs/PRD.md from git history.
# Run from project root after commits: .\scripts\update-prd-changelog.ps1

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$prdPath = Join-Path $root "docs\PRD.md"

if (-not (Test-Path $prdPath)) {
    Write-Error "PRD not found at $prdPath"
}

Push-Location $root

$rows = @()
$log = git log --pretty=format:"%h|%ad|%s" --date=short 2>$null
if ($log) {
    foreach ($line in ($log -split "`n")) {
        $parts = $line -split "\|", 3
        if ($parts.Count -lt 3) { continue }
        $hash = $parts[0]
        $date = $parts[1]
        $msg = $parts[2] -replace '\|', ' '

        $tags = git tag --points-at $hash 2>$null
        $tagStr = if ($tags) { ($tags -split "`n") -join ", " } else { "—" }

        $rows += "| $date | ``$hash`` | $tagStr | $msg |"
    }
}

if ($rows.Count -eq 0) {
    $rows = @("| — | — | — | No commits yet |")
}

$table = @(
    "| Date | Commit | Tag | Summary |",
    "|------|--------|-----|---------|",
    $rows
) -join "`n"

$content = Get-Content $prdPath -Raw
$pattern = '(?s)<!-- CHANGELOG_START -->.*?<!-- CHANGELOG_END -->'
$replacement = "<!-- CHANGELOG_START -->`n$table`n<!-- CHANGELOG_END -->"

if ($content -notmatch '<!-- CHANGELOG_START -->') {
    Write-Error "CHANGELOG markers not found in PRD.md"
}

$newContent = [regex]::Replace($content, $pattern, $replacement)

# Update "Last updated" date
$today = Get-Date -Format "yyyy-MM-dd"
$newContent = $newContent -replace '\*\*Last updated\*\* \| .* \|', "**Last updated** | $today |"

Set-Content -Path $prdPath -Value $newContent -NoNewline -Encoding UTF8

Write-Host "Updated docs/PRD.md change log ($($rows.Count) commit(s))."
Write-Host "Review the file, then commit: git add docs/PRD.md; git commit -m 'docs: update PRD changelog'"

Pop-Location
