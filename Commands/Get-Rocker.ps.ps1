[ValidatePattern('rocker')]
param()

function Get-Rocker
{
    <#
    .SYNOPSIS
        Rocks Docker
    .DESCRIPTION
        Rocker extends Docker in PowerShell.

        Here's How:

        * Most output will become extensible objects.
        * Tab completion for all commands and options.
        * Pipeline input can be defined at any point.
    .EXAMPLE 
        $Rocker
    .EXAMPLE
        docker help
    .EXAMPLE
        docker container ls | # List all containers
            docker container pause # unpause them
    .EXAMPLE
        docker container ls | # List all containers
            docker container unpause # and start them up again
    .EXAMPLE
        docker container ls | # List all containers
            docker history # get their history 
    #>
    [ArgumentCompleter({
        param($wordToComplete, $commandAst, $cursorPosition)

        return $rocker.Complete($wordToComplete,$commandAst, $cursorPosition)        
    })]
    [Alias('docker','docker-compose')]
    param()

    begin {
        
        # First, let's capture our current invocation info.
        $myInv = $MyInvocation
        # and then peek up the callstack
        $myCaller = @(Get-PSCallstack)[-1]
        # and try to find the command ast that called us.
        $myCommandAst = if ($myCaller) {
            $MyCaller.InvocationInfo.MyCommand.ScriptBlock.Ast.FindAll({
                param($ast) 
                    $ast.Extent.StartLineNumber -eq $myInv.ScriptLineNumber -and
                    $ast.Extent.StartColumnNumber -eq $myInv.OffsetInLine -and 
                    $ast -is [Management.Automation.Language.CommandAst]
            },$true)
        }

        # Next, we'll want a filter to get only the script methods from a type data object.
        filter OnlyScriptMethods {
            param($typedata)
            
            if ($_ -is [Management.Automation.Runspaces.ScriptMethodData]) {
                $_
            } elseif (
                ($_ -is [Management.Automation.Runspaces.AliasPropertyData]) -and
                ($TypeData.Members[$_.ReferencedMemberName] -is
                [Management.Automation.Runspaces.ScriptMethodData])
            ) {
                $TypeData.Members[$_.ReferencedMemberName]
            }            
        }

        # Rocker should be able to rock multiple applications, but this might be the first time we're called.
        if (-not $rocker.'.ApplicationMap') {
            # If it is, use our attributes
            foreach ($attribute in @($MyInvocation.MyCommand.ScriptBlock.Attributes)) {
                if ($attribute -is [Alias]) {
                    # and add any aliases to Rocker.
                    $rocker.Add($attribute)
                }
            }
        }
    }

    process {
        # First, let's capture our current input object.
        # (even though this function is freeform and does not have strongly defined parameters, it still can accept pipeline input.)
        $CurrentInputObject = $_
        
        # Next, let's capture the current invocation information.
        $myInv = $MyInvocation

        # And pick out a little bit of contextual information.
        $myLine = $MyInvocation.Line.Substring(
            $MyInvocation.OffsetInLine - 1
        ) -replace '\|.+?$' -replace '\)\]$'


        # Now we get the first words passed to the command
        $myFirstWords = @(
            if ($myCommandAst) { # If we have an AST, we can get the command elements
                foreach ($commandElement in $myCommandAst.CommandElements) {
                    if ($commandElement.Value -and 
                        $commandElement.Value -is [string] -and # and pick out bare words
                        $commandElement.Value -notmatch '^-' # that do not start with dashes
                    ) {
                        # then that's a word
                        $commandElement.Value
                    } else {
                        # If it's a variable
                        if ($commandElement -is [Management.Automation.Language.VariableExpressionAst]) {
                            # try peeking for the variable
                            $ExecutionContext.SessionState.PSVariable.Get("$($commandElement.VariablePath)").Value
                        }
                        break
                    }
                }
            } else {
                # If we don't have an AST,
                @(foreach ($myWord in $myLine -split # we can just split the line on whitespace
                    '\s+' -notmatch '^[\-\@]' -ne '' # (but not on dashes or splats)
                ) {
                    # skip . and & operators
                    if ($myWord -in '.', '&') { continue }
                    # if it's a variable, try to get the value
                    if ($myWord -match '^\$') {
                        $ExecutionContext.SessionState.PSVariable.Get(("$($myWord -replace '^\$')")).Value
                    } else {
                        # otherwise, it's a word
                        $myWord
                    }
                })
            }
        )
        
        # Now that we know the first words, we can get the matching type names.
        $myTypeNames = @(
            # Walking backwards thru the list of words
            for ($wordNumber = $myFirstWords.Length - 1; $wordNumber -ge 0 ; $wordNumber--) {
                $myFirstWords[0..$wordNumber] -join '.' # we can join them with dots
            }
        )

        # If there were type names, we can get the type data for all of them at once.
        $myTypeData = if ($myTypeNames) { Get-TypeData -TypeName $myTypeNames }

        # Now we can get the help for the command
        $DockerCommandHelp = $rocker.GetApplicationHelp($myFirstWords -notmatch '-{0,2}help')
    
        # If we didn't get help, we can try to get help for a shorter command
        $wordsToSkip = 0
        # by walking backwards thru the list of words
        while (-not $DockerCommandHelp) { # until we get help
            $wordsToSkip++
            $wordRange = $myFirstWords[0..($myFirstWords.Length - $wordsToSkip)]
            if ($wordsToSkip -eq $myFirstWords.Length) {
                break # (if we've run out of words, we're done)
            }
            $DockerCommandHelp = $rocker.GetApplicationHelp($wordRange -notmatch '-{0,2}help')
        }

        # This has the pleasant side effect of giving us the unbound word count
        $unboundWordCount = $myFirstWords.Length - $wordsToSkip        
        

        # Now we can get the command name and the rest of the elements
        $myCommandName, $myCommandElements = $myCommandAst.CommandElements
        $myCommandName = if ($MyCommandName) { $myCommandName.Extent.Text } else { $myFirstWords[0] }

        # And we can get the input methods for the type data
        $inputMethods = 
            foreach ($typeData in $myTypeData) {
                $TypeData.Members[
                    $typeData.Members.Keys -match '(?>^|\p{P})(?>Inputs?|Parameters?)(?>$|\p{P})'
                ] | OnlyScriptMethods -typedata $TypeData
            }

        
        # If we have input methods, we can get the input arguments
        $InputArguments = @(:nextInputMethod foreach ($inputMethod in $inputMethods) {
            $function:InputMethodFunction = $inputMethod.Script
            # We turn each input method into a function
            $InputMethodFunction = $ExecutionContext.SessionState.InvokeCommand.GetCommand('InputMethodFunction', 'Function')
            $inputMethodSplat = [Ordered]@{}

            # and then we can get the input parameters
            foreach ($potentialInputParameter in $InputMethodFunction.Parameters.Values) {
                # and try to get the values from the current input object.
                if ($null -ne $CurrentInputObject.($potentialInputParameter.Name)) {
                    $inputMethodSplat[$potentialInputParameter.Name] = $CurrentInputObject.($potentialInputParameter.Name)
                } elseif ($potentialInputParameter.Aliases) {
                    # (if we fail, we can try to find each of the aliases in the current object)
                    foreach ($aliasName in $potentialInputParameter.Aliases) {
                        if ($null -ne $CurrentInputObject.$aliasName) {
                            $inputMethodSplat[$potentialInputParameter.Name] = $CurrentInputObject.$aliasName
                            break
                        }
                    }
                }
            }

            # If any parameters were found, we can run the input method
            if ($inputMethodSplat.Count) {
                & $function:InputMethodFunction @inputMethodSplat
            }
        })
        
        # Collect all of the arguments
        $myArgs = @(
            $args,$InputArguments | # (the original arguments, and any input arguments we found)
                . { 
                process {
                    # and then we can process them
                    # Preference variables are set to continue
                    if ($_ -match '-{1,2}Verbose') {
                        $VerbosePreference = 'continue'
                    }
                    elseif ($_ -match '-{1,2}Debug') {
                        $DebugPreference = 'continue'
                    }        
                    elseif ($null -ne $_) {
                        # If the argument is not null, we can add it to the list of arguments
                        $_
                    }
                }
            }
        )

        # Now find the application we should call
        $myCommandPattern = "^(?>$([Regex]::Escape($myCommandName))|$([Regex]::Escape($myFirstWords -join '-')))\."

        $CommandToRun = 
            if ($rocker.'.ApplicationMap' -and $rocker.'.ApplicationMap'[$rocker.'.ApplicationMap'.Keys -match $myCommandPattern]) {
                @($rocker.'.ApplicationMap'[$rocker.'.ApplicationMap'.Keys -match $myCommandPattern])[0]
            } else {
                $AppExists = $ExecutionContext.SessionState.InvokeCommand.GetCommand($myCommandName,'Application')
                if ($AppExists) {
                    $rocker.Add($AppExists)
                    $rocker.'.ApplicationMap'[$myCommandName]
                } else {
                    if (-not $script:DockerApplication) {
                        $script:DockerApplication = $ExecutionContext.SessionState.InvokeCommand.GetCommand('docker','Application')
                    }
                    $script:DockerApplication
                }
            }
        
        
        # If we had no application and our command name was 'rocker', return $rocker.
        return if $myInv.InvocationName -match '[^\s]\p{P}?Rocker' -and -not $CommandToRun {
            $rocker           
        }
        
        # If we have a command that supports format, and we're not asking for help, add the format argument.
        if ($DockerCommandHelp.SupportsFormat -and -not ($myfirstWords -match '-{0,2}help')) {
            $myArgs += @("--format", "{{json .}}")
        }    
        
        # Get the parser, based off of the entire command line
        $myCommandLine = @($myFirstWords) + $myArgs
        $parsersForCommand = $rocker.Parsers.ForCommand($myCommandLine -join ' ')

        # If we have no command to run,
        if (-not $CommandToRun) {
            # fall back on the first command in the application map
            $CommandToRun = $rocker.'.ApplicationMap'[0]
            if (($myFirstWords.Length -eq 1) -and -not $parsersForCommand) {
                $parsersForCommand = $rocker.Parsers.ForCommand("docker help")
            }
        }

        # Return if there is no command to run at this point.
        # (if this is the case, docker is probably not installed.)
        return if -not $CommandToRun

        # If there were not parsers for a command, 
        if (-not $parsersForCommand) {
            # just run it and redirect everything to output
            & $commandToRun @myArgs *>&1
            return # and return
        }    

        
        # If there were parsers for the command, we will pipe to them.
        # To do this, we'll need to create a steppable pipeline for each.
        $ParserSteppablePipelines = @(
            foreach ($parser in $parsersForCommand) {
                if ($parser.Script) {
                    { & $parser.Script -CommandLine $myLine}.GetSteppablePipeline()
                    
                } else {
                    { & $parser -CommandLine $myLine}.GetSteppablePipeline()
                }
            }
        )

        # and then begin each steppable pipeline.
        foreach ($ParserSteppablePipeline in $ParserSteppablePipelines) {
            $ParserSteppablePipeline.Begin($true)
        }

        # Then we run the command, redirecting the output to the steppable pipelines.
        & $commandToRun @myArgs *>&1 | . { process {
            $currentOutput = $_

            # Skip remote exceptions
            # (they come back from the pipeline when a command decides to communicate over standard error instead of standard output.)
            if ($currentOutput -is [Management.Automation.RemoteException]) {return}

            # Process each of the outputs
            foreach ($ParserSteppablePipeline in $ParserSteppablePipelines) {
                $ParserSteppablePipeline.Process($currentOutput)
            }
        } }

        # and end each of the steppable pipelines.
        foreach ($ParserSteppablePipeline in $ParserSteppablePipelines) {
            $ParserSteppablePipeline.End()
        }        
    }
}