
function Add-1PassFileOrFolder {
    param (
        [string]$Path,
        [string]$Title
    )
    if (Test-Path -Path $Path -PathType Container) {
        $zipPath = "$Path.zip"
        Compress-Archive -Path $Path -DestinationPath $zipPath
        op document create "$zipPath" --title $Title
        Remove-Item -Path $zipPath
    } else {
        op document create "$Path" --title $Title
    }
}

function Read-1PassFileOrFolder {
    param (
        [string]$Title,
        [string]$DestinationPath
    )
    $docUUID = op document list | Where-Object { $_.title -eq $Title } | Select-Object -ExpandProperty id
    if ($docUUID) {
        $filePath = op document get $docUUID --output $DestinationPath
        if ($filePath.EndsWith('.zip')) {
            Expand-Archive -Path $filePath -DestinationPath $DestinationPath
            Remove-Item -Path $filePath
        }
    } else {
        Write-Output "Document with title '$Title' not found."
    }
}


