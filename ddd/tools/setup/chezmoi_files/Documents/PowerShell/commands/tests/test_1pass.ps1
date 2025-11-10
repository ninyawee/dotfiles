Describe "1Pass PowerShell Integration" {
    BeforeAll {
        . "$PSScriptRoot/../1pass.ps1"
        $testTitle = "TestDocument"
        $testPath = "$PSScriptRoot/testFolder"
        $testFile = "$testPath/testFile.txt"
        $destinationPath = "$PSScriptRoot/testOutput"
        New-Item -ItemType Directory -Path $testPath -Force
        New-Item -ItemType File -Path $testFile -Value "This is a test file."
    }

    It "Adds a file to 1Password" {
        Add-1PassFileOrFolder -Path $testFile -Title $testTitle
        $docUUID = op document list | Where-Object { $_.title -eq $testTitle } | Select-Object -ExpandProperty id
        $docUUID | Should -Not -BeNullOrEmpty
    }

    It "Reads a file from 1Password" {
        Read-1PassFileOrFolder -Title $testTitle -DestinationPath $destinationPath
        $filePath = Join-Path -Path $destinationPath -ChildPath "testFile.txt"
        Test-Path -Path $filePath | Should -Be $true
        Remove-Item -Path $filePath
    }

    AfterAll {
        Remove-Item -Path $testPath -Recurse
        Remove-Item -Path $destinationPath -Recurse
        # Clean up the document from 1Password, assuming you have a function or command to do so.
    }
}