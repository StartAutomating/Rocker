@{
    "runs-on" = "ubuntu-latest"    
    if = '${{ success() }}'
    steps = @(
        @{
            name = 'Check out repository'
            uses = 'actions/checkout@v4'
        },
        @{
            name = 'GitLogger'
            uses = 'GitLogging/GitLoggerAction@main'
            id = 'GitLogger'
        },
        @{
            name = 'PSSVG'
            uses = 'StartAutomating/PSSVG@main'
            id = 'PSSVG'
        }, 
        @{
            name = 'PipeScript'
            uses = 'StartAutomating/PipeScript@main'
            id = 'PipeScript'
        }, 
        
        'RunEZOut',
        'RunHelpOut'
    )
}