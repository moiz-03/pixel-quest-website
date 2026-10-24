# tools/sync-tokens.ps1
# Checks if the website's tokens.css matches the Flutter app's app_colors.dart

# ⚠️ CHANGE THIS PATH to point to your actual Flutter project file
$flutterPath = "E:\pixel_quest\lib\theme\app_colors.dart"
$cssPath = "$PSScriptRoot\..\public\assets\css\tokens.css"

if (-not (Test-Path $flutterPath)) {
    Write-Host "❌ Error: Could not find app_colors.dart at $flutterPath" -ForegroundColor Red
    Write-Host "Please open tools/sync-tokens.ps1 and update the `$flutterPath variable." -ForegroundColor Yellow
    exit
}

$dartContent = Get-Content $flutterPath -Raw
$cssContent = Get-Content $cssPath -Raw

# 1. Extract Flutter Colors (e.g., "primary = Color(0xFF00E5A0)")
$dartColors = @{}
$dartMatches = [regex]::Matches($dartContent, 'static\s+const\s+Color\s+(\w+)\s*=\s*Color\(0xFF([A-Fa-f0-9]{6})\);')
foreach ($match in $dartMatches) {
    $dartColors[$match.Groups[1].Value] = "#$($match.Groups[2].Value.ToUpper())"
}

# 2. Extract CSS Tokens (e.g., "--mint: #00E5A0;")
$cssTokens = @{}
$cssMatches = [regex]::Matches($cssContent, '--([\w-]+):\s*#([A-Fa-f0-9]{6});')
foreach ($match in $cssMatches) {
    $cssTokens[$match.Groups[1].Value] = "#$($match.Groups[2].Value.ToUpper())"
}

# 3. Map Flutter color names to CSS token names
$mapping = @{
    "primary"        = "mint"
    "primaryDark"    = "mint-dark"
    "accentGold"     = "gold"
    "background"     = "ink-0"
    "cardBg"         = "ink-1"
    "surfaceHigh"    = "ink-2"
    "border"         = "ink-3"
    "textPrimary"    = "ink-fg"
    "textSecondary"  = "ink-fg2"
    "textMuted"      = "ink-fg3"
    "error"          = "state-error"
    "badgeBlue"      = "cat-health"
    "badgePink"      = "cat-fitness"
    "badgePurple"    = "cat-skills"
}

# 4. Compare
Write-Host "`n--- Pixel Quest Token Sync Check ---`n" -ForegroundColor Cyan
$mismatch = $false

foreach ($dartName in $mapping.Keys) {
    $cssName = $mapping[$dartName]
    $dartHex = $dartColors[$dartName]
    $cssHex = $cssTokens[$cssName]

    if (-not $dartHex) {
        Write-Host "⚠️  Warning: Flutter color '$dartName' not found in app_colors.dart" -ForegroundColor Yellow
        continue
    }
    if (-not $cssHex) {
        Write-Host "⚠️  Warning: CSS token '--$cssName' not found in tokens.css" -ForegroundColor Yellow
        continue
    }

    if ($dartHex -eq $cssHex) {
        Write-Host "✅ Match: $dartName ($dartHex) == --$cssName" -ForegroundColor Green
    } else {
        Write-Host "❌ MISMATCH: $dartName is $dartHex (Flutter) but --$cssName is $cssHex (Web)" -ForegroundColor Red
        $mismatch = $true
    }
}

Write-Host "`n------------------------------------`n" -ForegroundColor Cyan
if ($mismatch) {
    Write-Host "Please update tokens.css to match the Flutter app." -ForegroundColor Red
    exit 1
} else {
    Write-Host "All tokens perfectly match the Flutter app!" -ForegroundColor Green
    exit 0
}