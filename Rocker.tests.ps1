describe Rocker {
    beforeAll {
        docker run --detach @{8080=80} nginx
    }
    it 'Lets you use docker as objects' {
        $containersList = docker container ls

        $containersList |
            Measure-Object |
            Select-Object -ExpandProperty Count |
            Should -BeGreaterOrEqual 1

        $containersList
    }

    it 'Can get system statistics' {
        $systemDiskInfo = docker system df
        $systemDiskInfo | 
            SSelect-Object -First 1 | 
            ForEach-Object {$_.Size -replace '\s' -as [double] } |
            Should -BeGreaterThan 0
    }

    it 'Can pause and unpause all containers' {
        docker container ls | docker container pause
        docker container ls | docker container unpause
    }

    it 'Can parse docker help' {
        $dockerHelpOut = docker help
        $dockerHelpOut.pstypenames | 
            Select-Object -First 1 | 
            Should -Be 'docker.help'
    }
}
