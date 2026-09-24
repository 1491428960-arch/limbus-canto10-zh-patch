$ErrorActionPreference = 'Stop'

# Part 2 术语一致性测试。
#
# 口径来源：零协（Zero Association）Part 1 官方中文包 —— 本仓库后续阶段的翻译一律以它为准。
# 因此每个断言都必须是「零协怎么用，我们就怎么用」，而不是沿用 Part 1 时代自创的用词。
# 中文一律用码点构造，避免脚本自身编码影响比对。

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

function New-Cjk {
    param([int[]]$Codes)
    return -join ($Codes | ForEach-Object { [char]$_ })
}

$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$patchRoot = Join-Path (Split-Path -Parent $baseDir) 'patch'
$jsonFiles = @(Get-ChildItem -LiteralPath $patchRoot -Recurse -File -Filter '*.json')

# 赛季（season）/ 季度（quarter）
$season = New-Cjk @(0x8d5b, 0x5b63)
$quarter = New-Cjk @(0x5b63, 0x5ea6)
# 裸体 / 正在排队的客人
$naked = New-Cjk @(0x88f8, 0x4f53)
$queuedGuest = New-Cjk @(0x6b63, 0x5728, 0x6392, 0x961f, 0x7684, 0x5ba2, 0x4eba)
# 异想体 / 扭曲
$abnormality = New-Cjk @(0x5f02, 0x60f3, 0x4f53)
$distortion = New-Cjk @(0x626d, 0x66f2)
# 黑派 / 红派
$blackFaction = New-Cjk @(0x9ed1, 0x6d3e)
$redFaction = New-Cjk @(0x7ea2, 0x6d3e)

# ---------------------------------------------------------------- 结构断言
Assert-Equal $jsonFiles.Count 100 'published patch contains exactly 100 JSON files'

$prefixed = @($jsonFiles | Where-Object { $_.Name -like 'KR_*' })
Assert-Equal $prefixed.Count 0 'no source file keeps the KR_ prefix'

$part1 = @($jsonFiles | Where-Object { $_.Name -like '*a1c10p1*' })
Assert-Equal $part1.Count 0 'published patch no longer ships any Part 1 file'

$part2 = @($jsonFiles | Where-Object { $_.Name -like '*a1c10p2*' })
Assert-True ($part2.Count -gt 0) 'published patch ships Part 2 files'

# ---------------------------------------------------------------- 术语计数
$seasonCount = 0
$quarterCount = 0
$queuedCount = 0
$nakedCount = 0
$abnormalityCount = 0
foreach ($file in $jsonFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    $seasonCount += [regex]::Matches($content, [regex]::Escape($season)).Count
    $quarterCount += [regex]::Matches($content, [regex]::Escape($quarter)).Count
    $queuedCount += [regex]::Matches($content, [regex]::Escape($queuedGuest)).Count
    $nakedCount += [regex]::Matches($content, [regex]::Escape($naked)).Count
    $abnormalityCount += [regex]::Matches($content, [regex]::Escape($abnormality)).Count
}

# 零协基准：시즌 → 赛季（76 次），无一处「季度」
Assert-True ($seasonCount -gt 0) 'uses 赛季, matching the Zero Association baseline for 시즌'
Assert-Equal $quarterCount 0 'does not use 季度 — the baseline always renders 시즌 as 赛季'

# 네이키드 是角色称号，零协译作「裸体」；「正在排队的客人」是另一角色 대기 중인 손님 的译法
Assert-True ($nakedCount -gt 0) 'uses 裸体 for the character 네이키드, matching the baseline'
Assert-Equal $queuedCount 0 'does not leak 正在排队的客人 into the 네이키드 role'

Assert-True ($abnormalityCount -gt 0) 'keeps the established 异想体 rendering for 환상체'

# ---------------------------------------------------------------- 关键文件存在
$mustExist = @(
    'RPGSystem\rpg-loc-dialogue-common-a1c10p2.json',
    'RPGSystem\rpg-loc-dialogue-floor-b2-b.json',
    'Passives_Abnormality-a1c10p2.json',
    'PersonalityVoiceDlg\Voice_Rodion_Contem_10917.json'
)
foreach ($rel in $mustExist) {
    $path = Join-Path $patchRoot $rel
    Assert-True (Test-Path -LiteralPath $path) "Part 2 resource exists: $rel"
}

# 角色扮演楼层对话里，黑派/红派 必须与零协一致
$floorB2 = Get-Content -LiteralPath (Join-Path $patchRoot 'RPGSystem\rpg-loc-dialogue-floor-b2-b.json') -Raw -Encoding UTF8
Assert-True ($floorB2 -match [regex]::Escape($blackFaction)) 'uses 黑派 for 르누아르 in B2F dialogue'

Write-Output 'PASS: Part 2 terminology follows the Zero Association baseline (赛季/裸体/异想体) and ships no Part 1 file'
