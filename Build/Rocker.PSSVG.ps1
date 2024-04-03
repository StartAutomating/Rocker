#requires -Module PSSVG

$AssetsPath = $PSScriptRoot | Split-Path | Join-Path -ChildPath "Assets"

if (-not (Test-Path $AssetsPath)) {
    New-Item -ItemType Directory -Path $AssetsPath | Out-Null
}


$fontName = 'Rajdhani'



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
    
    svg.use -Href '#psChevron' -X -50% -Y 35% @commonParameters -Height 25% -Opacity .9
    
    svg.text -Text 'Rocker' -X 50% -Y 50% -FontSize 42em -FontFamily sans-serif @commonParameters -DominantBaseline 'middle' -TextAnchor 'middle' -Style "font-family:'$fontName'"    

    foreach ($rectCount in 1..30) {
        svg.rect -X "$(3.5 + 
            $($rectCount * 3)
        )%" -Y "70%" -Width 2% -Height 2% -Fill '#4488ff'

        svg.rect -X "$(3.75 + 
            $($rectCount * 3)
        )%" -Y "72.5%" -Width 1.5% -Height 1.5% -Fill '#4488ff'
    }
) -ViewBox 0, 0, 1920, 1080 -OutputPath $(
    Join-Path $assetsPath Rocker.svg
)

