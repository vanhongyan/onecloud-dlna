param(
    [Parameter(Mandatory=$true)][string]$Cmd,
    [string]$Host_ = $env:BOX_IP,
    [string]$User = "root",
    [string]$Pass = $env:BOX_PASS,
    [int]$TimeoutSec = 60
)
# Usage: set env vars BOX_IP / BOX_PASS first, then:
#   .\ssh_box.ps1 -Cmd "uptime"
#   .\ssh_box.ps1 -Cmd <local-script-path>   # auto base64 upload & execute
if (-not $Host_ -or -not $Pass) { Write-Host "[ERR] set env vars BOX_IP and BOX_PASS first"; exit 1 }
if ($Cmd -notmatch '[\s;&|]' -and (Test-Path -LiteralPath $Cmd)) {
    $b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes((Get-Content $Cmd -Raw)))
    $Cmd = "echo $b64 | base64 -d | bash"
}
$sec = ConvertTo-SecureString $Pass -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($User, $sec)
try {
    $s = $null
    for ($i = 1; $i -le 5 -and -not $s; $i++) {
        try { $s = New-SSHSession -ComputerName $Host_ -Credential $cred -AcceptKey -ConnectionTimeout 40 -ErrorAction Stop }
        catch { Start-Sleep 5 }
    }
    if (-not $s) { throw "failed to connect after retries" }
    $r = Invoke-SSHCommand -SessionId $s.SessionId -Command $Cmd -TimeOut $TimeoutSec
    Remove-SSHSession -SessionId $s.SessionId | Out-Null
    if ($r.Output) { $r.Output | ForEach-Object { $_ } }
    if ($r.Error)  { $r.Error  | ForEach-Object { "[STDERR] $_" } }
    if ($r.ExitStatus -ne 0) { Write-Host "[EXIT=$($r.ExitStatus)]" }
} catch {
    Write-Host "[SSH-ERROR] $($_.Exception.Message)"
}