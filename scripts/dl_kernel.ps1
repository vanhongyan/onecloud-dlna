$ErrorActionPreference = 'Stop'
$out = 'd:\dsh_work\armbian_box\debs'
New-Item -ItemType Directory -Force -Path $out | Out-Null
$base = 'https://github.com/hzyitc/armbian-onecloud/releases/download/ci-20230424-173029-UTC'
$files = @(
  'linux-image-current-meson_23.05.0-trunk--6.1.25-Sf17b-De8b2-P759b-Cf6d5Hfe66-HK01ba-Va132-B3dc3_armhf.deb',
  'linux-dtb-current-meson_23.05.0-trunk--6.1.25-Sf17b-De8b2-P759b-Cf6d5Hfe66-HK01ba-Va132-B3dc3_armhf.deb'
)
foreach ($f in $files) {
  $dst = Join-Path $out $f
  if ((Test-Path $dst) -and ((Get-Item $dst).Length -gt 1MB)) { Write-Host "SKIP $f"; continue }
  $ok = $false
  foreach ($prefix in @('https://ghproxy.net/', 'https://gh-proxy.com/', '')) {
    try {
      Write-Host "TRY $prefix$f"
      Invoke-WebRequest -UseBasicParsing -Uri ($prefix + $base + '/' + $f) -OutFile $dst
      if ((Get-Item $dst).Length -gt 500KB) { $ok = $true; break }
    } catch { Write-Host "FAIL: $($_.Exception.Message)" }
  }
  if (-not $ok) { throw "download failed: $f" }
  Write-Host "OK $f $((Get-Item $dst).Length)"
}
Get-ChildItem $out
