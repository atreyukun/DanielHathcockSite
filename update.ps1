# Push local edits to GitHub Pages.
param(
  [string]$Message = "Update site"
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

git add index.html CNAME .nojekyll .gitignore deploy.ps1 update.ps1
git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
  Write-Host "No changes to publish."
  exit 0
}

git commit -m $Message
git push

Write-Host ""
Write-Host "Published. Live in 1-2 minutes at:"
Write-Host "  https://atreyukun.github.io/DanielHathcockSite/"
Write-Host "  https://site.danielhathcock.com"
