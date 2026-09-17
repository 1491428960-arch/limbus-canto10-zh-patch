$ErrorActionPreference = 'Stop'

$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Join-Path (Split-Path -Parent $baseDir) ('.bat-tmp-' + [guid]::NewGuid().ToString('N'))
$gameRoot = Join-Path $root 'game'
$target = Join-Path $gameRoot 'LimbusCompany_Data\Lang\LLC_zh-CN'
$batPath = Join-Path (Split-Path -Parent $baseDir) 'install.bat'
New-Item -ItemType Directory -Path (Join-Path $gameRoot 'LimbusCompany_Data') -Force | Out-Null
Set-Content -LiteralPath (Join-Path $gameRoot 'LimbusCompany.exe') -Value 'test executable' -Encoding UTF8

try {
    $output = & $batPath $gameRoot 2>&1
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        throw "BAT entrypoint failed with exit code $exitCode`n$($output -join "`n")"
    }
    if (-not (Test-Path -LiteralPath $target -PathType Container)) {
        throw 'BAT entrypoint did not create the language target folder'
    }
    $installedCount = @(Get-ChildItem -LiteralPath $target -Filter '*.json' -File -Recurse).Count
    if ($installedCount -ne 91) {
        throw "BAT entrypoint installed $installedCount JSON files instead of 91`n$($output -join "`n")"
    }
    Write-Output 'PASS: install.bat accepts a game path and installs all 91 JSON files'
}
finally {
    if (Test-Path -LiteralPath $root) {
        Remove-Item -LiteralPath $root -Recurse -Force
    }
}
