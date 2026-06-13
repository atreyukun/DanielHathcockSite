# Publishes this site to GitHub Pages (always-on, no local server needed).
# Prerequisites: run `gh auth login` once.
param(
  [string]$GitHubUser = "",
  [string]$RepoName = "DanielHathcockSite",
  [string]$Domain = "site.danielhathcock.com"
)

$ErrorActionPreference = "Stop"
$SiteRoot = $PSScriptRoot
Set-Location $SiteRoot

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  throw "GitHub CLI (gh) is not installed. Install from https://cli.github.com/"
}

$auth = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
  Write-Host "GitHub CLI is not logged in. Run this first, then re-run deploy.ps1:"
  Write-Host "  gh auth login"
  exit 1
}

if (-not $GitHubUser) {
  $GitHubUser = (gh api user -q .login)
}

if (-not (Test-Path ".git")) {
  git init -b main
}

git add index.html .nojekyll CNAME .gitignore
git diff --cached --quiet
if ($LASTEXITCODE -ne 0) {
  git commit -m "Publish Daniel Hathcock site to GitHub Pages"
}

$remoteUrl = "https://github.com/$GitHubUser/$RepoName.git"
if (-not (git remote get-url origin 2>$null)) {
  git remote add origin $remoteUrl
}

if (-not (gh repo view "$GitHubUser/$RepoName" 2>$null)) {
  gh repo create $RepoName --public --source=. --remote=origin --push --description "Daniel Hathcock personal site"
} else {
  git push -u origin main
}

gh api --method POST "/repos/$GitHubUser/$RepoName/pages" `
  -f build_type=legacy `
  -f "source[branch]=main" `
  -f "source[path]=/" `
  2>$null

if ($LASTEXITCODE -ne 0) {
  Write-Host "Pages may already be enabled (that's fine)."
}

gh api --method PUT "/repos/$GitHubUser/$RepoName/pages" `
  -f cname=$Domain `
  2>$null

Write-Host ""
Write-Host "Done. Site will be live at:"
Write-Host "  https://$GitHubUser.github.io/$RepoName/  (immediate)"
Write-Host "  https://$Domain  (after DNS update below)"
Write-Host ""
Write-Host "Cloudflare DNS (replace the tunnel CNAME for '$Domain'):"
Write-Host "  Type: CNAME"
Write-Host "  Name: site"
Write-Host "  Target: $GitHubUser.github.io"
Write-Host "  Proxy: DNS only (grey cloud) — required for GitHub Pages SSL"
Write-Host ""
Write-Host "Then in GitHub repo Settings > Pages, confirm custom domain is: $Domain"
