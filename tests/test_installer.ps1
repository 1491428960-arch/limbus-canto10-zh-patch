$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "ASSERT FAILED: $Message" }
}

function Assert-Equal {
    param($Actual, $Expected, [string]$Message)
    if ($Actual -ne $Expected) {
        throw "ASSERT FAILED: $Message (actual='$Actual', expected='$Expected')"
    }
}

function New-TestGame {
    param([string]$Root)
    New-Item -ItemType Directory -Path (Join-Path $Root 'LimbusCompany_Data') -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $Root 'LimbusCompany.exe') -Value 'test executable' -Encoding UTF8
}

function New-TestPatch {
    param([string]$Root, [bool]$Broken = $false)
    New-Item -ItemType Directory -Path (Join-Path $Root 'nested') -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $Root 'Example.json') -Value '{"text":"new translation"}' -Encoding UTF8
    Set-Content -LiteralPath (Join-Path $Root 'nested\Second.json') -Value '{"text":"second translation"}' -Encoding UTF8
    if ($Broken) {
        Set-Content -LiteralPath (Join-Path $Root 'Broken.json') -Value '{ invalid json' -Encoding UTF8
    }
}

function Invoke-Installer {
    param([string]$Script, [string]$GamePath, [string]$PatchRoot)
    $previousErrorAction = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $Script `
            -GamePath $GamePath -PatchRoot $PatchRoot 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorAction
    }
    [pscustomobject]@{
        ExitCode = $exitCode
        Output = ($output -join "`n")
    }
}

$testFilePath = $MyInvocation.MyCommand.Path
$baseDir = Split-Path -Parent $testFilePath
$installerPath = [IO.Path]::GetFullPath((Join-Path $baseDir '..\install.ps1'))
$runRoot = Join-Path (Split-Path -Parent $baseDir) ('.test-tmp-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $runRoot -Force | Out-Null

try {
    # 有效目录：复制全部 JSON，并备份已存在的同名文件。
    New-Item -ItemType Directory -Path (Join-Path -Path $runRoot -ChildPath 'valid-game') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path -Path $runRoot -ChildPath 'valid-patch') -Force | Out-Null
    New-TestGame (Join-Path -Path $runRoot -ChildPath 'valid-game')
    New-TestPatch (Join-Path -Path $runRoot -ChildPath 'valid-patch')
    $target = Join-Path (Join-Path -Path $runRoot -ChildPath 'valid-game') 'LimbusCompany_Data\Lang\LLC_zh-CN'
    New-Item -ItemType Directory -Path $target -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $target 'Example.json') -Value '{"text":"old translation"}' -Encoding UTF8

    $result = Invoke-Installer $installerPath (Join-Path -Path $runRoot -ChildPath 'valid-game') (Join-Path -Path $runRoot -ChildPath 'valid-patch')
    Assert-Equal $result.ExitCode 0 'valid installation exits successfully'
    Assert-True ((Get-Content -Raw -LiteralPath (Join-Path $target 'Example.json')) -match 'new translation') 'new file is installed'
    Assert-True (Test-Path -LiteralPath (Join-Path $target 'nested\Second.json')) 'nested file is installed'
    $backup = Get-ChildItem -Directory -LiteralPath (Join-Path -Path $runRoot -ChildPath 'valid-game') -Filter '_limbus_canto10_zh_backup_*'
    Assert-Equal @($backup).Count 1 'one timestamped backup is created'
    Assert-True ((Get-Content -Raw -LiteralPath (Join-Path $backup.FullName 'Example.json')) -match 'old translation') 'old file is backed up'

    # 错误游戏目录：拒绝安装，不创建备份。
    New-Item -ItemType Directory -Path (Join-Path -Path $runRoot -ChildPath 'bad-game') -Force | Out-Null
    $result = Invoke-Installer $installerPath (Join-Path -Path $runRoot -ChildPath 'bad-game') (Join-Path -Path $runRoot -ChildPath 'valid-patch')
    Assert-True ($result.ExitCode -ne 0) 'invalid game directory is rejected'
    Assert-Equal @(Get-ChildItem -Directory -LiteralPath (Join-Path -Path $runRoot -ChildPath 'bad-game') -Filter '_limbus_canto10_zh_backup_*' -ErrorAction SilentlyContinue).Count 0 'invalid directory creates no backup'

    # 损坏 JSON：整批拒绝，不复制任何有效文件。
    New-Item -ItemType Directory -Path (Join-Path -Path $runRoot -ChildPath 'broken-game'), (Join-Path -Path $runRoot -ChildPath 'broken-patch') -Force | Out-Null
    New-TestGame (Join-Path -Path $runRoot -ChildPath 'broken-game')
    New-TestPatch (Join-Path -Path $runRoot -ChildPath 'broken-patch') $true
    $result = Invoke-Installer $installerPath (Join-Path -Path $runRoot -ChildPath 'broken-game') (Join-Path -Path $runRoot -ChildPath 'broken-patch')
    Assert-True ($result.ExitCode -ne 0) 'broken JSON is rejected'
    $brokenTarget = Join-Path (Join-Path -Path $runRoot -ChildPath 'broken-game') 'LimbusCompany_Data\Lang\LLC_zh-CN'
    Assert-True (-not (Test-Path -LiteralPath $brokenTarget)) 'broken JSON creates no target directory'

    Write-Output 'PASS: valid install, backup, invalid game path, and broken JSON'
}
finally {
    if (Test-Path -LiteralPath $runRoot) {
        Remove-Item -LiteralPath $runRoot -Recurse -Force
    }
}
