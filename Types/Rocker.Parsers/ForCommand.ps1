param(
$CommandLine
)

foreach ($parser in $this.All) {
    if ($parser.Validate -and $parser.Validate($commandLine)) {
        $parser
    }    
}