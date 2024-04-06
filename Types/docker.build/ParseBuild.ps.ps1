[ValidatePattern("^(?>docker(?:(?>-|\s)compose)?\s{1,}build)")]
param(
[vfp()]
[string]
$Content,

[string]
$CommandLine
)

begin {
    $ProgressId = Get-Random
    $LayerCounter = 0
    $LayerStartTimes = [Ordered]@{}
    $LayerMessages = [Ordered]@{}
    $BuildStartTime = [DateTime]::Now
}

process {
    $lineOut = "$content"
    if ($lineOut -match 'The handle is invalid.\s{0,}$') { return }
    if ($lineOut -match '^\#(?<Layer>\d+)') {
        $layerNumber = $matches.Layer -as [int]
        if ($layerNumber -gt $LayerCounter) {
            $LayerCounter = $layerNumber
        }
        if (-not $LayerStartTimes["$layerNumber"]) {
            $LayerStartTimes["$layerNumber"] = [DateTime]::Now
        }
        if (-not $LayerMessages["$layerNumber"]) {
            $LayerMessages["$layerNumber"] = @()
        }
        $LayerMessages["$layerNumber"] += $lineOut
        $layerProgressId = $ProgressId + $layerNumber
        $timeSince  = [DateTime]::Now - $BuildStartTime
        if ($lineOut -match '^\#\d+\s{1,}done\s{1,}(?<t>[\d\.]+)s') {            
            # Layer is done, now is a good time to output            
            Write-Progress -Activity "$LayerNumber @ $timeSince" -Status "$lineOut" -id $layerProgressId -Completed
        } else {
            Write-Progress -Activity "$LayerNumber @ $timeSince" -Status "$lineOut" -id $layerProgressId
        }
    } else {
        $layerProgressId = $ProgressId
    }
    if ("$lineOut" -match "\[(?<StageNumber>\d+)/(?<StageCount>\d+)\]") {
        $MatchInfo = [Ordered]@{} + $matches
        $MatchInfo.StageNumber = $MatchInfo.StageNumber -as [int]
        $MatchInfo.StageCount = $MatchInfo.StageCount -as [int]
        $PercentComplete = [math]::Round(($MatchInfo.StageNumber / $MatchInfo.StageCount) * 100)
        Write-Progress -Activity "@ $timeSince $lineOut" -Status "$(
            if ($MatchInfo.StageNumber) {"[$($matchInfo.StageNumber)/$($matchInfo.StageCount)]"}
            ' '
        )"  -id $layerProgressId -PercentComplete $PercentComplete
    }
   
    "$lineOut"
}

end {
    
}