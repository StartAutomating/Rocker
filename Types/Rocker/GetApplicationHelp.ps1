param()

# Unroll our arguments, so we can accept freeform input.
$unrolledArgs = $args | . { process { $_ }}

# Join our arguments into a single string, and treat this as the command line
$commandLine = $unrolledArgs -join ' '

# The first of these arguments should be the name of the actual executable.
$ExecutableName, $CommandNames = $unrolledArgs

# If we don't have an executable, return
if (-not $ExecutableName) {  return }

# If we have a command name, we need to make sure it's not 'help' (to avoid recursion and duplicates)
$commandNames = @($commandNames -ne 'help')

# If we don't have a help cache, create one.
if (-not $this.'.HelpCache') {
    $this | Add-Member -MemberType NoteProperty -Name '.HelpCache' -Value ([Ordered]@{}) -Force
}

# Determine the key in the help cache
$propertyName = ".$commandLine help"

# If we don't have a cached help object, create one.
if (-not $this.'.HelpCache'.$propertyName) {
    # Get the actual executable
    $actualExecutable = $ExecutionContext.SessionState.InvokeCommand.GetCommand($ExecutableName,'Application')
    # If we don't have an actual executable, return
    if (-not $actualExecutable) { return }

    # Create an empty object so we can easily access it's parser.
    $dockerHelp = [PSCustomObject]@{PSTypeName='docker.help'}

    # Call the executable and pass it's output to the parser.
    $parsedHelp = 
        if (-not $CommandNames) {
            & $actualExecutable help *>&1 | & $dockerHelp.Parse.Script -CommandLine $commandLine
        } else {
            # If we have a command name, pass it to the executable, too
            $commandNames = @($commandNames)
            & $actualExecutable help @commandNames *>&1 | & $dockerHelp.Parse.Script -CommandLine $commandLine
        }

    # If we have options or commands, add them to the help cache.
    if ($parsedHelp.Options -or $parsedHelp.Commands) {
        $this.'.HelpCache'[$propertyName] = $parsedHelp
    }    
}

# Return the cached help object.
return $this.'.HelpCache'.$propertyName

