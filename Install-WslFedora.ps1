[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$WslDistroName = "Fedora-38",
    [Parameter(Position = 1, Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Username
)

$scriptRoot = $PSScriptRoot

$fedoraTarPath = Join-Path -Path $scriptRoot -ChildPath "out\fedora-latest.tar"

if (!(Test-Path -Path $fedoraTarPath)) {
    $PSCmdlet.ThrowTerminatingError(
        [System.Management.Automation.ErrorRecord]::new(
            [System.IO.FileNotFoundException]::new("Fedora TAR file not found at '$($fedoraTarPath)'.", $fedoraTarPath),
            "FedoraTarNotFound",
            [System.Management.Automation.ErrorCategory]::ObjectNotFound,
            $fedoraTarPath
        )
    )
}

$wslDistroRootOutPath = Join-Path -Path ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile)) -ChildPath ".wsl"
$wslDistroOutPath = Join-Path -Path $wslDistroRootOutPath -ChildPath $WslDistroName

if (!(Test-Path -Path $wslDistroRootOutPath)) {
    Write-Verbose "Creating WSL distro root directory at '$($wslDistroRootOutPath)'."
    $null = New-Item -Path $wslDistroRootOutPath -ItemType "Directory"
}

if (!(Test-Path -Path $wslDistroOutPath)) {
    Write-Verbose "Creating WSL distro directory for '$($WslDistroName)' at '$($wslDistroOutPath)'."
    $null = New-Item -Path $wslDistroOutPath -ItemType "Directory"
}

Write-Verbose "Importing WSL distro '$($WslDistroName)' from '$($fedoraTarPath)' to '$($wslDistroOutPath)'."
$null = wsl --import "$($WslDistroName)" "$($wslDistroOutPath)" "$($fedoraTarPath)" --version 2

Write-Verbose "Running first-time user setup."

wsl --distribution "$($WslDistroName)" --shell-type "login" -- adduser -G wheel $($Username)
wsl --distribution "$($WslDistroName)" --shell-type "login" -- /bin/bash -c "echo -e `"[user]\ndefault=$($Username)`" >> /etc/wsl.conf"
wsl --distribution "$($WslDistroName)" --shell-type "login" -- passwd $($Username)

Write-Verbose "Terminating WSL distro '$($WslDistroName)'."
wsl --terminate "$($WslDistroName)"
