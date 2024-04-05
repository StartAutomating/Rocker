#requires -Module PSSVG

$AssetsPath = $PSScriptRoot | Split-Path | Join-Path -ChildPath "Assets"

if (-not (Test-Path $AssetsPath)) {
    New-Item -ItemType Directory -Path $AssetsPath | Out-Null
}


$fontName = 'Rajdhani'

$bpm = 107.7
$bpmDuration = 60 / $bpm

foreach ($variant in "", "animated") {
    svg -content $(
        $commonParameters = [Ordered]@{
            Fill        = '#4488FF'
            Class       = 'foreground-fill'
        }
    
        SVG.GoogleFont -FontName $fontName
    
        svg.symbol -Id psChevron -Content @(
            svg.polygon -Points (@(
                "40,20"
                "45,20"
                "60,50"
                "35,80"
                "32.5,80"
                "55,50"
            ) -join ' ')
        ) -ViewBox 100, 100    
        
        svg.use -Href '#psChevron' -X 0% -Y 37.5% @commonParameters -Height 25% -Opacity .9
        
        svg.text -Text 'Rocker' -X 50% -Y 50% -FontSize 36em -FontFamily sans-serif @commonParameters -DominantBaseline 'middle' -TextAnchor 'middle' -Style "font-family:'$fontName',sans-serif"    
    
        $RectSplat = [Ordered]@{Fill='#4488ff';Class='foreground-fill'}
        $LargerRectSplat = [Ordered]@{}
        $SmallerRectSplat = [Ordered]@{}
        foreach ($rectCount in 1..30) {
            if ($variant -match 'animate') {
                $LargerRectSplat.Content = @(
                    svg.animate -AttributeName 'rx' -Values '0;7;0' -Dur "${bpmDuration}" -RepeatCount 'indefinite'
                    svg.animate -AttributeName 'ry' -Values '7;0;7' -Dur "${bpmDuration}" -RepeatCount 'indefinite'
                    svg.animate -AttributeName 'height' -Values '2%;1.5%;2%' -Dur "${bpmDuration}" -RepeatCount 'indefinite'
                )
                $SmallerRectSplat.Content = @(
                    svg.animate -AttributeName 'ry' -Values '0;7;0' -Dur "${bpmDuration}" -RepeatCount 'indefinite'
                    svg.animate -AttributeName 'rx' -Values '7;0;7' -Dur "${bpmDuration}" -RepeatCount 'indefinite'
                    svg.animate -AttributeName 'height' -Values '1.5%;2%;1.5%' -Dur "${bpmDuration}" -RepeatCount 'indefinite'
                )
            }
            svg.rect -X "$(3.5 + 
                $($rectCount * 3)
            )%" -Y "70%" -Width 2% -Height 2% @RectSplat @LargerRectSplat
    
            svg.rect -X "$(3.75 + 
                $($rectCount * 3)
            )%" -Y "72.5%" -Width 1.5% -Height 1.5% @RectSplat @SmallerRectSplat
        }
    ) -ViewBox 0, 0, 1920, 1080 -OutputPath $(
        Join-Path $assetsPath "Rocker$(if ($variant) { '-' + ($variant -join '-')}).svg"
    )
}



