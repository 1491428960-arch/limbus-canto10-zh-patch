$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) {
        throw "ASSERT FAILED: $Message"
    }
}

function Assert-Equal {
    param($Actual, $Expected, [string]$Message)
    if ($Actual -ne $Expected) {
        throw "ASSERT FAILED: $Message (actual='$Actual', expected='$Expected')"
    }
}

$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$patchRoot = Join-Path (Split-Path -Parent $baseDir) 'patch'
$jsonFiles = @(Get-ChildItem -LiteralPath $patchRoot -Recurse -File -Filter '*.json')
$season = -join ([char]0x8d5b, [char]0x5b63)
$quarter = -join ([char]0x5b63, [char]0x5ea6)
$interpretation = -join ([char]0x5f02, [char]0x60f3, [char]0x89e3, [char]0x6790)
$reading = -join ([char]0x89e3, [char]0x8bfb)

$seasonCount = 0
$quarterCount = 0
foreach ($file in $jsonFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    $seasonCount += [regex]::Matches($content, [regex]::Escape($season)).Count
    $quarterCount += [regex]::Matches($content, [regex]::Escape($quarter)).Count
}

Assert-Equal $seasonCount 0 'published patch uses the corrected quarter terminology'
Assert-True ($quarterCount -gt 0) 'published patch contains the corrected quarter terminology'

$commonPath = Join-Path $patchRoot 'RPGSystem\rpg-loc-dialogue-common-a1c10p1.json'
$floorB2Path = Join-Path $patchRoot 'RPGSystem\rpg-loc-dialogue-floor-b2.json'
$common = Get-Content -LiteralPath $commonPath -Raw -Encoding UTF8
$floorB2 = Get-Content -LiteralPath $floorB2Path -Raw -Encoding UTF8

Assert-Equal ([regex]::Matches($common, [regex]::Escape($reading)).Count) 2 'common RPG dialogue uses the reading term twice'
Assert-Equal ([regex]::Matches($floorB2, [regex]::Escape($reading)).Count) 3 'floor B2 RPG dialogue keeps the existing reading and fixes two more uses'
Assert-True (-not ($common -match [regex]::Escape($interpretation))) 'common RPG dialogue no longer uses the E.G.O system term for interpretation'
Assert-True (-not ($floorB2 -match [regex]::Escape($interpretation))) 'floor B2 RPG dialogue no longer uses the E.G.O system term for interpretation'

$systemTermFiles = @(
    (Join-Path $patchRoot 'Items-a1c10p1.json'),
    (Join-Path $patchRoot 'MainUIText-a1c10p1.json'),
    (Join-Path $patchRoot 'RPGSuicideBoxUI.json')
)
foreach ($file in $systemTermFiles) {
    $content = Get-Content -LiteralPath $file -Raw -Encoding UTF8
    Assert-True ($content -match [regex]::Escape($interpretation)) "system terminology remains in $(Split-Path $file -Leaf)"
}

Write-Output 'PASS: quarter terminology and Ryoshu interpretation wording are corrected without changing the E.G.O system term'
