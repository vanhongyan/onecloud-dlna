$ErrorActionPreference = 'Stop'
foreach ($prefix in @('https://ghproxy.net/', 'https://gh-proxy.com/', '')) {
  try {
    $r = Invoke-WebRequest -UseBasicParsing -Uri ($prefix + 'https://github.com/hzyitc/armbian-onecloud/releases/download/ci-20230424-173029-UTC/sha256sum')
    $r.Content | Out-String -Width 300 | Write-Output
    break
  } catch { Write-Host "FAIL $prefix : $($_.Exception.Message)" }
}
