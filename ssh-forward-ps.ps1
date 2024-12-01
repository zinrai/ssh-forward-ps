[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string]$local,

    [Parameter(Mandatory=$false)]
    [string]$remote,

    [Parameter(Mandatory=$false)]
    [int]$port = 22,

    [Parameter(Mandatory=$false)]
    [string]$user = $env:USERNAME,

    [Parameter(Mandatory=$false)]
    [string]$host = "127.0.0.1"
)

# Function to parse ports from comma-separated string
function Parse-Ports {
    param (
        [string]$portsString
    )

    if ([string]::IsNullOrWhiteSpace($portsString)) {
        return @()
    }

    return $portsString.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
}

# Function to handle SSH process
function Start-SshConnection {
    param (
        [string]$sshCommand
    )

    try {
        Write-Host "Executing: $sshCommand" -ForegroundColor Yellow

        # Start SSH process
        $process = Start-Process -FilePath "ssh.exe" -ArgumentList $sshCommand.Substring(4) -NoNewWindow -PassThru

        # Handle Ctrl+C
        $null = [Console]::TreatControlCAsInput = $true

        # Wait for process while checking for Ctrl+C
        while (!$process.HasExited) {
            if ([Console]::KeyAvailable) {
                $key = [Console]::ReadKey($true)
                if (($key.Modifiers -band [ConsoleModifiers]::Control) -and ($key.Key -eq 'C')) {
                    Write-Host "`nKeyboard interrupt received. Terminating SSH connection." -ForegroundColor Yellow
                    $process.Kill()
                    break
                }
            }
            Start-Sleep -Milliseconds 100
        }
    }
    finally {
        if (!$process.HasExited) {
            $process.Kill()
            $process.WaitForExit(5000)
            if (!$process.HasExited) {
                $process.Kill()
            }
        }
        Write-Host "SSH connection closed. Exiting wrapper." -ForegroundColor Yellow
    }
}

# Main script
try {
    # Validate that at least one of local or remote is specified
    if (!$local -and !$remote) {
        throw "At least one of -local or -remote must be specified"
    }

    $forwarding = @()

    # Handle local port forwarding
    if ($local) {
        $localPorts = Parse-Ports -portsString $local
        $forwarding += $localPorts | ForEach-Object { "-L ${_}:localhost:${_}" }
    }

    # Handle remote port forwarding
    if ($remote) {
        $remotePorts = Parse-Ports -portsString $remote
        $forwarding += $remotePorts | ForEach-Object { "-R ${_}:localhost:${_}" }
    }

    # Construct SSH command
    $portForwarding = $forwarding -join " "
    $sshCommand = "ssh $portForwarding -p $port ${user}@${host}"

    # Start SSH connection
    Start-SshConnection -sshCommand $sshCommand
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}
