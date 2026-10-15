$r = Invoke-WebRequest -UseBasicParsing 'https://api.github.com/repos/hzyitc/armbian-onecloud/releases/tags/ci-20230424-173029-UTC'
$d = ConvertFrom-Json $r.Content
$d.assets | ForEach-Object { "{0}`t{1}" -f $_.name, $_.browser_download_url }
