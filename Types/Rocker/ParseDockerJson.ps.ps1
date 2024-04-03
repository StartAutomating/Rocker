[ValidatePattern('--format \{\{json \.\}\}')]
param(
[vfp()]
[string]
$Content,

[string]
$CommandLine
)


begin {
    $myLine = $CommandLine
    $myFirstWords = @($myLine -split '\s' -match '^\w[\w\-]+$')
    $myTypeNames = @(for ($wordNumber = $myFirstWords.Length - 1; $wordNumber -ge 0 ; $wordNumber--) {
        $myFirstWords[0..$wordNumber] -join '.'
    })


    
}
process {
    try {

        $dockerCommandOutput = $content | ConvertFrom-Json

        foreach ($dockerCmdOut in $dockerCommandOutput) {
            $dockerCmdOut.pstypenames.clear()
            foreach ($myTypeName in $myTypeNames) {
                $dockerCmdOut.pstypenames.add($myTypeName)
            }
            $dockerCmdOut           
        }
    } catch {
        $convertError = $_
        Write-Debug "Error Converting from JSON: $($_ | Out-String)"
        $content
    }
}