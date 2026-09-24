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

function Read-DataList {
    param([string]$Path)
    Assert-True (Test-Path -LiteralPath $Path -PathType Leaf) "resource file exists: $Path"
    $root = Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
    Assert-True ($null -ne $root.dataList) "resource has dataList: $Path"
    return @($root.dataList)
}

function Find-Entry {
    param([object[]]$Entries, [string]$Id)
    return @($Entries | Where-Object { $_.id.ToString() -eq $Id })
}

function Assert-EntryIds {
    param([object[]]$Entries, [string[]]$Ids, [string]$Label)
    foreach ($id in $Ids) {
        Assert-Equal @(Find-Entry $Entries $id).Count 1 "$Label contains $id exactly once"
    }
}

function Assert-NoHangul {
    param([object[]]$Entries, [string]$Label)
    $content = $Entries | ConvertTo-Json -Depth 20 -Compress
    Assert-True (-not ($content -match '[\uAC00-\uD7AF]')) "$Label has no Korean Hangul in new entries"
}

$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$patchRoot = Join-Path (Split-Path -Parent $baseDir) 'patch'

# 这批人格资源属于 Part 1 时代；Part 2 补丁只含新增主线资源，不含它们。
# 零协 Part 1 官方包已覆盖这些文件，因此补丁切到 Part 2 之后这里不再有可校验的对象 —— 跳过而不是失败。
$personalitiesPath = Join-Path $patchRoot 'Personalities.json'
if (-not (Test-Path -LiteralPath $personalitiesPath -PathType Leaf)) {
    Write-Output 'SKIP: this patch no longer ships the Part 1 personality resources (owned upstream by the Zero Association Part 1 pack)'
    exit 0
}

$personalities = Read-DataList $personalitiesPath
$ryoshu = @(Find-Entry $personalities '10416')
$ishmael = @(Find-Entry $personalities '10816')
$ryoshuName = -join ([char]0x826F, [char]0x79C0)
$ishmaelName = -join ([char]0x4EE5, [char]0x5B9E, [char]0x739B, [char]0x5229)
$ryoshuTitle = -join ([char]0x52D2, [char]0x52AA, [char]0x74E6, [char]0x5C14)
$ishmaelTitle = -join ([char]0x52D2, [char]0x9C81, [char]0x65E5)
Assert-Equal $ryoshu.Count 1 'Ryoshu personality exists exactly once'
Assert-Equal $ishmael.Count 1 'Ishmael personality exists exactly once'
Assert-Equal $ryoshu[0].name $ryoshuName 'Ryoshu personality uses the established Chinese name'
Assert-Equal $ishmael[0].name $ishmaelName 'Ishmael personality uses the established Chinese name'
Assert-True ($ryoshu[0].title -match [regex]::Escape($ryoshuTitle)) 'Ryoshu title is translated'
Assert-True ($ishmael[0].title -match [regex]::Escape($ishmaelTitle)) 'Ishmael title is translated'
Assert-NoHangul ($ryoshu + $ishmael) 'personalities'

$passives = Read-DataList (Join-Path $patchRoot 'Passives.json')
$passiveIds = @('1041601','1041602','1041603','1041604','1041621','1081601','1081602','1081621')
Assert-EntryIds $passives $passiveIds 'passives'
Assert-NoHangul @($passives | Where-Object { $passiveIds -contains $_.id.ToString() }) 'passives'

$ryoshuSkills = Read-DataList (Join-Path $patchRoot 'Skills_personality-04.json')
$ryoshuSkillIds = @('1041601','1041602','1041603','1041604','1041605')
Assert-EntryIds $ryoshuSkills $ryoshuSkillIds 'Ryoshu skills'
Assert-NoHangul @($ryoshuSkills | Where-Object { $ryoshuSkillIds -contains $_.id.ToString() }) 'Ryoshu skills'

$ishmaelSkills = Read-DataList (Join-Path $patchRoot 'Skills_personality-08.json')
$ishmaelSkillIds = @('1081601','1081602','1081603','1081604','1081605')
Assert-EntryIds $ishmaelSkills $ishmaelSkillIds 'Ishmael skills'
Assert-NoHangul @($ishmaelSkills | Where-Object { $ishmaelSkillIds -contains $_.id.ToString() }) 'Ishmael skills'

$conditions = Read-DataList (Join-Path $patchRoot 'Personality_Get_Condition.json')
$conditionIds = @('10416_getCondition_normal','10416_getCondition_gacksung','10816_getCondition_normal','10816_getCondition_gacksung')
Assert-EntryIds $conditions $conditionIds 'personality conditions'
Assert-NoHangul @($conditions | Where-Object { $conditionIds -contains $_.id.ToString() }) 'personality conditions'

$storyTitles = Read-DataList (Join-Path $patchRoot 'StoryTheaterMirrorWorldStoryTitle.json')
$storyTitleIds = @('MirrorWorld_Story_Title_P10416','MirrorWorld_Story_Title_P10816')
Assert-EntryIds $storyTitles $storyTitleIds 'mirror world story titles'
Assert-NoHangul @($storyTitles | Where-Object { $storyTitleIds -contains $_.id.ToString() }) 'mirror world story titles'

$battleSpeech = Read-DataList (Join-Path $patchRoot 'BattleSpeechBubbleDlg.json')
Assert-EntryIds $battleSpeech @(
    'battle_s3_10816_1_2','battle_s3_10816_1_2-01','battle_s3_10816_1_2-02',
    'battle_s3_10816_1_3','battle_s3_10816_1_3-01','battle_s3_10816_1_3-02',
    'battle_s3_10816_1_4','battle_s3_10816_1_4-01','battle_s3_10416_1_1',
    'battle_s3_10416_1_3','battle_s3_10416_1_4','battle_special_10416_1_3',
    'battle_special_10416_1_4','battle_special_10416_2','battle_special_10816_1',
    'battle_special_10816_2'
) 'battle speech bubbles'
$battleSpeechIds = @(
    'battle_s3_10816_1_2','battle_s3_10816_1_2-01','battle_s3_10816_1_2-02',
    'battle_s3_10816_1_3','battle_s3_10816_1_3-01','battle_s3_10816_1_3-02',
    'battle_s3_10816_1_4','battle_s3_10816_1_4-01','battle_s3_10416_1_1',
    'battle_s3_10416_1_3','battle_s3_10416_1_4','battle_special_10416_1_3',
    'battle_special_10416_1_4','battle_special_10416_2','battle_special_10816_1',
    'battle_special_10816_2'
)
Assert-NoHangul @($battleSpeech | Where-Object { $battleSpeechIds -contains $_.id.ToString() }) 'battle speech bubbles'

$voiceIds = @(
    'get_{0}_1','lobby_morning_{0}_1','lobby_noon_{0}_1','lobby_night_{0}_1',
    'smalltalk_{0}_1','smalltalk_{0}_2','smalltalk_{0}_3','smalltalk_{0}_4','smalltalk_{0}_5',
    'gacksung_{0}_1','neglect_{0}_1','formation_{0}_1','battleentry_{0}_1',
    'battle_select_{0}_1','battle_endcommand_{0}_1','battle_enemy_break_{0}_1',
    'battle_break_{0}_1','battle_kill_{0}_1','battle_dead_{0}_1','choice_success_p_{0}_2',
    'choice_fail_n_{0}_1','battle_clear_{0}_1','battle_clear_ex_{0}_1','battle_defeat_{0}_1'
)
foreach ($voice in @(@('Ryoshu','10416'), @('Ishmael','10816'))) {
    $voicePath = Join-Path $patchRoot ("PersonalityVoiceDlg\Voice_{0}_Contem_{1}.json" -f $voice[0], $voice[1])
    $entries = Read-DataList $voicePath
    $expected = @($voiceIds | ForEach-Object { $_ -f $voice[1] })
    Assert-EntryIds $entries $expected "$($voice[0]) voice"
    Assert-NoHangul $entries "$($voice[0]) voice"
}

Write-Output 'PASS: both new personalities include complete translated resource sets without Korean text'
