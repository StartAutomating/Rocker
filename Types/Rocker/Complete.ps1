param($wordToComplete, $commandAst, $cursorPosition)
        

if (-not $this) {
    $this = $Rocker
}

if ($this -and -not $this.'.CompletionCache') {
    $this | Add-Member NoteProperty '.CompletionCache' ([Ordered]@{}) -Force
}
$CompletionCache = $this.'.CompletionCache'
    
if ((-not $wordToComplete) -and $CompletionCache["$CommandAst"]) {
    return $CompletionCache["$CommandAst"]
}

$commandHelp = if ($commandAst.CommandElements.Count -eq 1) {
        $rocker.GetApplicationHelp("$($commandAst.CommandElements[0])")                                
    } elseif ($commandAst.CommandElements.Count -ge 2) {
        for ($commandElementIndex = $commandAst.CommandElements.Count; $commandElementIndex -ge 0; $commandElementIndex--) {
            $combinedElements = @($commandAst.CommandElements[0..$commandElementIndex].Value) -notmatch '^\-'
            $commandHelp = $rocker.GetApplicationHelp($combinedElements)
            if ($commandHelp) {
                break
            }
        }
        
        if ($commandHelp) {                    
            $commandHelp
        }
    }

if ($commandHelp) {
    if ($wordToComplete) {
        if ($wordToComplete -match '^\-') {
            return @($commandHelp.Options.OptionName) -like "$wordToComplete*"
        } else {
            return @($commandHelp.Commands.CommandName) -like "$wordToComplete*"
        }
    } else {
        $CompletionCache["$CommandAst"] = @($commandHelp.Commands.CommandName) -like '?*'
        return $CompletionCache["$CommandAst"]
    }
}        