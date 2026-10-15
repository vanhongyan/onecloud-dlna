$udp = New-Object System.Net.Sockets.UdpClient
$udp.EnableBroadcast = $true
$msg = [Text.Encoding]::ASCII.GetBytes("M-SEARCH * HTTP/1.1`r`nHOST: 239.255.255.250:1900`r`nMAN: `"ssdp:discover`"`r`nMX: 3`r`nST: ssdp:all`r`n`r`n")
$udp.Connect("239.255.255.250", 1900)
$udp.Client.ReceiveTimeout = 6000
$udp.Send($msg, $msg.Length) | Out-Null
$udp.Send($msg, $msg.Length) | Out-Null
$ep = New-Object System.Net.IPEndPoint([Net.IPAddress]::Any, 0)
$found = @()
try {
  while ($true) {
    $data = $udp.Receive([ref]$ep)
    $text = [Text.Encoding]::ASCII.GetString($data)
    if ($text -match "OneCloud|MediaRenderer") { $found += "$($ep.Address): " + ($text -split "`n")[0..2] -join " | " }
  }
} catch {}
if ($found) { $found | Select-Object -Unique | ForEach-Object { $_ } } else { Write-Host "NO_DLNA_RESPONSE" }
