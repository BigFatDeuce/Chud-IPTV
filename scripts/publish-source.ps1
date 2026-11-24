# Publishes the source code to the public GitHub repo, under GPL-3.0-or-later: every file tracked by Git here,
# in its committed state (HEAD), with packaging/github-README.md as README.md. The public repo keeps its own
# history and its .github/assets screenshots. Never published: CLAUDE.md, CLAUDE.local.md, AGENTS.md, .claude/,
# the local README.md, keys, and any file containing a word from scripts/.private-words (git-ignored: the
# owner's name, e-mail, PC name, local paths). Kingfisher scans the result before anything is pushed.
# No release or tag is created, so installed apps and their updates are not affected.
#
# Usage: powershell -ExecutionPolicy Bypass -File scripts\publish-source.ps1 -Message "Publish the source code"
param([Parameter(Mandatory)][string]$Message)
$Project = Split-Path $PSScriptRoot -Parent
$ErrorActionPreference = 'Stop'
$owner = 'BigFatDeuce'; $repo = 'Chud-IPTV'
if (git -C $Project status --porcelain) { throw 'Commit first: only the committed state is published.' }
$words = Join-Path $PSScriptRoot '.private-words'
if (-not (Test-Path -LiteralPath $words)) { throw 'scripts\.private-words is missing (one private word per line).' }

$clone = Join-Path $env:TEMP 'chud-iptv-public'
if (Test-Path $clone) { cmd /c "rmdir /s /q `"$clone`"" }
cmd /c "git clone --quiet https://github.com/$owner/$repo.git `"$clone`" 2>&1"
if ($LASTEXITCODE -ne 0) { throw 'clone failed' }
# Empty the clone (except .git and the README screenshots), then lay down the committed tree.
Get-ChildItem -LiteralPath $clone -Force | Where-Object { $_.Name -notin '.git', '.github' } | Remove-Item -Recurse -Force
Get-ChildItem -LiteralPath (Join-Path $clone '.github') -Force | Where-Object { $_.Name -ne 'assets' } | Remove-Item -Recurse -Force
$archive = Join-Path $env:TEMP 'chud-iptv-source.tar'
git -C $Project archive --format=tar -o $archive HEAD
tar -xf $archive -C $clone
Remove-Item $archive
foreach ($local in 'CLAUDE.md', 'CLAUDE.local.md', 'AGENTS.md', '.claude') {
  $path = Join-Path $clone $local
  if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Recurse -Force }
}
Copy-Item (Join-Path $Project 'packaging\github-README.md') (Join-Path $clone 'README.md') -Force

Push-Location $clone
try {
  git config user.name $owner
  git config user.email "67258247+$owner@users.noreply.github.com"
  git config core.autocrlf true
  cmd /c "git add -A 2>nul"
  $blocked = git ls-files | Where-Object { $_ -match '(^|/)(CLAUDE(\.local)?\.md|AGENTS\.md|\.claude/|\.env|key\.properties|\.private-words)' -or $_ -match '\.(pem|key|jks|keystore|p12|pfx)$' }
  if ($blocked) { throw "Forbidden files: $blocked" }
  $private = git grep --cached -I -i -l -F -f $words
  if ($private) { throw "Private data found in: $private" }
  $kingfisher = Join-Path $Project 'packaging\windows\kingfisher.exe'
  if (-not (Test-Path $kingfisher)) { $kingfisher = 'C:\Dev\kingfisher\kingfisher.exe' }
  if (Test-Path $kingfisher) {
    & $kingfisher scan . --staged --no-validate --no-update-check
    if ($LASTEXITCODE -ne 0) { throw 'Kingfisher reported findings: review them before publishing.' }
  } else { Write-Warning 'Kingfisher not found: secret scan skipped.' }
  $changed = @(git diff --cached --name-only)
  if (-not $changed.Count) { Write-Output 'Nothing to publish.'; return }
  Write-Output "$($changed.Count) file(s) changed"
  $file = Join-Path $env:TEMP 'chud-iptv-commit.txt'
  [IO.File]::WriteAllText($file, "$Message`n`nCo-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`n", (New-Object Text.UTF8Encoding $false))
  $env:TZ = 'UTC'
  cmd /c "git commit -q -F `"$file`" 2>&1"
  Remove-Item $file
  cmd /c "git push --quiet origin main 2>&1"
  if ($LASTEXITCODE -ne 0) { throw 'push refused' }
  Write-Output "Source published: $(git log -1 --format=%h)"
} finally { Pop-Location }
