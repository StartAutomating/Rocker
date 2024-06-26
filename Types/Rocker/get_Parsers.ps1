$Wildcard = '?*ocker*'
$Pattern  = 'Parse'
$TypeName = 'Rocker.Parser'
$CollectionTypeName = 'Rocker.Parsers'


$Collection = [Ordered]@{PSTypeName=$CollectionTypeName}

@(
    foreach ($typeData in Get-TypeData -TypeName $Wildcard) {
        $potentialParsers = @($typeData.Members.Keys -match $Pattern)
        foreach ($potentialParser in $typeData.Members[$potentialParsers]) {
            if ($potentialParser -is [management.automation.runspaces.ScriptMethodData]) {
                $parserFullName = "$($typeData.TypeName).$($potentialParser.Name)"
                $Collection[$parserFullName] = $potentialParser | 
                    Add-Member NoteProperty TypeName $typeData.TypeName -Force -PassThru |
                    Add-Member NoteProperty Name $parserFullName -Force -PassThru
                $Collection[$parserFullName].pstypenames.add($TypeName)
            }
        }
    }

    $foundCommands = @($ExecutionContext.SessionState.InvokeCommand.GetCommands($Wildcard, 'Alias,Function,Cmdlet', $true) -match $Pattern)
    if ($foundCommands) {
        foreach ($commandFound in $foundCommands) {
            if (-not $commandFound.Name) { continue }
            $Collection[$commandFound.Name] = $commandFound
            $Collection[$commandFound.Name].pstypenames.add($TypeName)
        }
    }
        
)

[PSCustomObject]$Collection