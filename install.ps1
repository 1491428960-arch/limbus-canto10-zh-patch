[CmdletBinding()]
param(
    [string]$GamePath,
    [string]$PatchRoot,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($PatchRoot)) {
    $PatchRoot = Join-Path $PSScriptRoot 'patch'
}

function Stop-Install {
    param([string]$Message)
    throw $Message
}

function Resolve-GameRoot {
    param([string]$InputPath)

    if ([string]::IsNullOrWhiteSpace($InputPath)) {
        $InputPath = Read-Host '请输入游戏根目录 / Enter the Limbus Company game folder'
    }
    if ([string]::IsNullOrWhiteSpace($InputPath)) {
        Stop-Install '未输入游戏目录，安装已取消。 / No game folder was entered; installation cancelled.'
    }

    $InputPath = $InputPath.Trim().Trim('"')
    try {
        $resolved = (Resolve-Path -LiteralPath $InputPath -ErrorAction Stop).Path
    }
    catch {
        Stop-Install "找不到游戏目录：$InputPath / Game folder not found: $InputPath"
    }

    $executable = Join-Path $resolved 'LimbusCompany.exe'
    $dataFolder = Join-Path $resolved 'LimbusCompany_Data'
    if (-not (Test-Path -LiteralPath $executable -PathType Leaf) -or
        -not (Test-Path -LiteralPath $dataFolder -PathType Container)) {
        Stop-Install "这不是《边狱巴士》的游戏根目录：$resolved`nExpected a folder containing LimbusCompany.exe and LimbusCompany_Data."
    }

    $running = @(Get-Process -Name 'LimbusCompany' -ErrorAction SilentlyContinue | Where-Object {
        try {
            $_.Path -and ((Resolve-Path -LiteralPath $_.Path -ErrorAction Stop).Path -eq $executable)
        }
        catch {
            $false
        }
    })
    if ($running.Count -gt 0) {
        Stop-Install '检测到游戏仍在运行，请先退出游戏后重新执行安装。 / Limbus Company is running; close it and run the installer again.'
    }

    return $resolved
}

function Get-ValidatedPatchFiles {
    param([string]$Root)

    if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
        Stop-Install "补丁目录不存在：$Root`nPatch folder not found: $Root"
    }

    $files = @(Get-ChildItem -LiteralPath $Root -Filter '*.json' -File -Recurse | Sort-Object FullName)
    if ($files.Count -eq 0) {
        Stop-Install "补丁目录中没有 JSON 文件：$Root`nNo JSON patch files were found in: $Root"
    }

    foreach ($file in $files) {
        try {
            $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
            if ([string]::IsNullOrWhiteSpace($content)) {
                throw 'file is empty'
            }
            $null = $content | ConvertFrom-Json
        }
        catch {
            Stop-Install "JSON 校验失败：$($file.FullName)`nInvalid JSON: $($file.FullName)`n$($_.Exception.Message)"
        }
    }

    return $files
}

function Get-RelativePatchPath {
    param([string]$Root, [string]$FullPath)

    $prefix = $Root.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
    if (-not $FullPath.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
        Stop-Install "补丁文件不在补丁目录内：$FullPath / Patch file is outside the patch folder: $FullPath"
    }
    return $FullPath.Substring($prefix.Length).TrimStart('\', '/')
}

try {
    $gameRoot = Resolve-GameRoot $GamePath
    $patchRootResolved = (Resolve-Path -LiteralPath $PatchRoot -ErrorAction Stop).Path
    $patchFiles = @(Get-ValidatedPatchFiles $patchRootResolved)
    $targetRoot = Join-Path $gameRoot 'LimbusCompany_Data\Lang\LLC_zh-CN'
    $targetExisted = Test-Path -LiteralPath $targetRoot -PathType Container

    $planned = @()
    foreach ($file in $patchFiles) {
        $relative = Get-RelativePatchPath $patchRootResolved $file.FullName
        $destination = Join-Path $targetRoot $relative
        $planned += [pscustomobject]@{
            Source = $file.FullName
            Relative = $relative
            Destination = $destination
            Exists = Test-Path -LiteralPath $destination -PathType Leaf
        }
    }

    $existing = @($planned | Where-Object { $_.Exists })
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss-fff'
    $backupRoot = Join-Path $gameRoot ("_limbus_canto10_zh_backup_$stamp")

    Write-Host "检测到 $($patchFiles.Count) 个 JSON 补丁文件。 / Found $($patchFiles.Count) JSON patch files."
    Write-Host "目标目录：$targetRoot / Target: $targetRoot"

    if ($DryRun) {
        Write-Host 'Dry run：只检查，不复制文件。 / Dry run: validation only; no files will be copied.'
        exit 0
    }

    $copiedNew = @()
    $targetCreated = $false
    try {
        if ($existing.Count -gt 0) {
            New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
            foreach ($item in $existing) {
                $backupFile = Join-Path $backupRoot $item.Relative
                $backupParent = Split-Path -Parent $backupFile
                New-Item -ItemType Directory -Path $backupParent -Force | Out-Null
                Copy-Item -LiteralPath $item.Destination -Destination $backupFile -Force
            }
        }

        if (-not $targetExisted) {
            New-Item -ItemType Directory -Path $targetRoot -Force | Out-Null
            $targetCreated = $true
        }

        foreach ($item in $planned) {
            $parent = Split-Path -Parent $item.Destination
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
            Copy-Item -LiteralPath $item.Source -Destination $item.Destination -Force
            if (-not $item.Exists) {
                $copiedNew += $item
            }
        }
    }
    catch {
        foreach ($item in $existing) {
            $backupFile = Join-Path $backupRoot $item.Relative
            if (Test-Path -LiteralPath $backupFile -PathType Leaf) {
                Copy-Item -LiteralPath $backupFile -Destination $item.Destination -Force
            }
        }
        foreach ($item in $copiedNew) {
            if (Test-Path -LiteralPath $item.Destination -PathType Leaf) {
                Remove-Item -LiteralPath $item.Destination -Force
            }
        }
        if ($targetCreated -and (Test-Path -LiteralPath $targetRoot -PathType Container) -and
            @((Get-ChildItem -LiteralPath $targetRoot -Force -Recurse -ErrorAction SilentlyContinue)).Count -eq 0) {
            Remove-Item -LiteralPath $targetRoot -Force
        }
        throw "安装失败，已尝试恢复原文件。 / Installation failed; original files were restored where possible.`n$($_.Exception.Message)"
    }

    if ($existing.Count -gt 0) {
        Write-Host "已备份 $($existing.Count) 个旧文件：$backupRoot / Backed up $($existing.Count) existing files to: $backupRoot"
    }
    else {
        Write-Host '没有同名旧文件需要备份。 / No existing files needed a backup.'
    }
    Write-Host "安装完成：已复制 $($planned.Count) 个文件。 / Installation complete: copied $($planned.Count) files."
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
