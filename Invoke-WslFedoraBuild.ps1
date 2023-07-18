[CmdletBinding()]
param()

$scriptRoot = $PSScriptRoot

$fedoraTarPath = Join-Path -Path $scriptRoot -ChildPath "out\fedora-latest.tar"

if (Test-Path -Path $fedoraTarPath) {
    Write-Verbose "Removing existing Fedora TAR file at '$($fedoraTarPath)'."
    Remove-Item -Path $fedoraTarPath -Force
}

$buildGuid = [System.Guid]::NewGuid().Guid.ToString()

Write-Verbose "Starting Fedora container build."
docker build --build-arg="BUILD_SEED=$($buildGuid)" --tag "wsl-fedora:38" "$($scriptRoot)"

Write-Verbose "Creating a Fedora container from the built image."
$null = docker run --tty --name="$($buildGuid)" "wsl-fedora:38" echo "Hello world!"

Write-Verbose "Exporting the Fedora container to '$($fedoraTarPath)'."
$null = docker export "$($buildGuid)" --output "$($fedoraTarPath)"

Write-Verbose "Removing the Fedora container."
$null = docker rm "$($buildGuid)"

Write-Information -InformationAction "Continue" -MessageData "Fedora container exported to '$($fedoraTarPath)'."