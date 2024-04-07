<#
.SYNOPSIS
    Gets a dictionary as `docker run` input.
.DESCRIPTION
    Converts a dictionary to a list of arguments to `docker run`.

    If the dictionary contains pairs of integers, they are treated as port mappings.
    If the dictionary contains paths, they are treated as volumes.
    Otherwise, they are treated as environment variables.    
#>
param(
# The dictionary
[Parameter(Mandatory)]
[Collections.IDictionary]
$Dictionary
)

if (-not $Dictionary.Count) { return }
foreach ($keyValuePair in $Dictionary.GetEnumerator()) {
    # If it's a pair of digits, treat it as --publish
    if ($keyValuePair.Key -is [int] -and $keyValuePair.Value -is [int]) {
        "--publish"
        "$($keyValuePair.Key):$($keyValuePair.Value)"
    }
    # If it's a path, treat it as a --volume
    elseif ($keyValuePair.Key -match '[\\/]')
    {
        "--volume"
        "$($keyValuePair.Key):$($keyValuePair.Value)"
    }
    # Otherwise, treat it as an environment variable
    else
    {
        "--env"
        "$($keyValuePair.Key)=$($keyValuePair.Value)"
    }
}