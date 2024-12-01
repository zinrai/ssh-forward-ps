# ssh-forward-ps

A PowerShell implementation of SSH port forwarding wrapper for Windows.

## Features

- Support for multiple port forwarding (comma-separated)
- Local and remote port forwarding
- Default values for username, host, and port

## Notes

- Administrator privileges may be required when using ports below 1024
- The script uses the Windows OpenSSH client (ssh.exe)
- PowerShell execution policy must allow script execution

## Usage

Ensure your PowerShell execution policy allows running scripts:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope Process -Force
```

Local port forwarding:

```powershell
.\ssh-forward-ps.ps1 -local "8080,3000" -host "remote-server.com" -user "username"
```

Remote port forwarding:

```powershell
.\ssh-forward-ps.ps1 -remote "5000,5001" -host "remote-server.com" -user "username"
```

Using custom SSH port:

```powershell
.\ssh-forward-ps.ps1 -local "8080" -port 2222 -host "remote-server.com" -user "username"
```

### Parameters

| Parameter | Description                                           | Default Value            |
|-----------|-------------------------------------------------------|--------------------------|
| `-local`  | Local port forwarding: comma-separated list of ports  | None                     |
| `-remote` | Remote port forwarding: comma-separated list of ports | None                     |
| `-port`   | SSH port                                              | 22                       |
| `-user`   | SSH user                                              | Current Windows username |
| `-host`   | SSH host                                              | 127.0.0.1                |

At least one of `-local` or `-remote` must be specified.

## Examples

1. Forward local port 8080 to remote server:

```powershell
.\ssh-forward-ps.ps1 -local "8080" -host "remote-server.com" -user "username"
```

2. Forward multiple local ports:

```powershell
.\ssh-forward-ps.ps1 -local "8080,3000,5000" -host "remote-server.com" -user "username"
```

3. Set up remote port forwarding:

```powershell
.\ssh-forward-ps.ps1 -remote "5000" -host "remote-server.com" -user "username"
```

4. Combine local and remote port forwarding:

```powershell
.\ssh-forward-ps.ps1 -local "8080,3000" -remote "5000,5001" -host "remote-server.com" -user "username"
```

## License

This project is licensed under the MIT License - see the [LICENSE](https://opensource.org/license/mit) for details.
