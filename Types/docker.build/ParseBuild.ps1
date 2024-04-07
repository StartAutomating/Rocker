<#
.SYNOPSIS
    Parses the output of `docker build`.
.DESCRIPTION
    Parses the output of `docker build` and writes progress bars for each layer.
#>
[ValidatePattern("^(?>docker(?:(?>-|\s)compose)?\s{1,}build)")]
param(
# The content being parsed.
[Parameter(ValueFromPipeline)]
[string]
$Content,

# The command line that produced the content.
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
        if ($lineOut -match '^\#\d+\s{1,}done\s{1,}(?<t>[\d\.]+)s' -or $lineOut -match '^\#\d+\s{1,}cached') {            
            # Layer is done or cached, complete the progress bar
            Write-Progress -Activity "$LayerNumber @ $timeSince" -Status "$lineOut" -id $layerProgressId -Completed
        } else {
            # Layer is not done or cached, write progress.
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
