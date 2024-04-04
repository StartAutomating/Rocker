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
    $StageStack = @()
}

process {
    $lineOut = "$content"
    if ($lineOut -match 'The handle is invalid.\s{0,}$') { return }
    if ("$lineOut" -match "\[(?<StageNumber>\d+)/(?<StageCount>\d+)\]") {
        $MatchInfo = [Ordered]@{} + $matches
        $MatchInfo.StageNumber = $MatchInfo.StageNumber -as [int]
        $MatchInfo.StageCount = $MatchInfo.StageCount -as [int]
        $PercentComplete = [math]::Round(($MatchInfo.StageNumber / $MatchInfo.StageCount) * 100)
        Write-Progress -Activity "$lineOut" -Status "$(
            if ($MatchInfo.StageNumber) {"[$($matchInfo.StageNumber)/$($matchInfo.StageCount)]"}
            ' '
        )"  -id $ProgressId -PercentComplete $PercentComplete
    } else {
        Write-Progress -Activity "$lineOut" -Status " " -id $ProgressId 
    }
    Start-Sleep -Milliseconds 1
    "$lineOut"        
}

end {
    Write-Progress -Activity "Docker Build" -Status "Complete" -id $ProgressId -Completed
}