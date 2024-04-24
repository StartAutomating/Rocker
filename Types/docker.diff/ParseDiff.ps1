<#
.SYNOPSIS
    Parses the output of `docker diff`.
.DESCRIPTION
    Parses the output of `docker diff` and returns a custom object with the following properties:
    
    - CommandLine: The command line that produced the output.
    - ContainerID: The ID of the container being diffed.
    - ChangeType: The type of change (Added, Changed, or Deleted).
    - Path: The path of the changed file.
#>
[ValidatePattern("^docker\s{1,}diff\s{1,}")]
param(
# The content being parsed (this will be piped in line-by-line).
[Parameter(ValueFromPipeline)]
[string]
$Content,

# The command line that produced the content.
[string]
$CommandLine
)

begin {
    $matched = @($CommandLine) -match '(?<id>[0-9a-f]{8,})'    
    $ContainerID = $matches.id
}

process {
    if ($content -cnotmatch '^[ACD]\s') { return $content }
    [PSCustomObject]@{
        PSTypeName = 'docker.diff'
        CommandLine = $CommandLine
        ContainerID = $ContainerID
        ChangeType = switch ($content[0]) {
            'A' { 'Added' }
            'C' { 'Changed' }
            'D' { 'Deleted' }
        }
        Path = $content -replace '^[ACD]\s{1,}'
    }
}
