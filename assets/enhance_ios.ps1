$ErrorActionPreference = "Stop"
$dir = "C:\Users\Colorful\Doubao\chats\2026-10-15\new-chat\xiaonan-browser\assets\ios"
$tmp = "C:\Users\Colorful\Doubao\chats\2026-10-15\new-chat\xiaonan-browser\assets\ios_enh"
if (-not (Test-Path -LiteralPath $tmp)) { New-Item -ItemType Directory -Path $tmp | Out-Null }
$files = Get-ChildItem -LiteralPath $dir -Filter *.png | Sort-Object Name
$logLines = @()
$i = 0
foreach ($f in $files) {
  $i++
  $outJson = & mediakit-cli image enhance-image --image-url $f.FullName --multiple 2 --tool-version standard 2>$null | Out-String
  try {
    $obj = $outJson | ConvertFrom-Json
    if ($obj.success -eq $true) {
      $url = $obj.image_url
      curl.exe -L --max-time 90 -o "$tmp\$($f.Name)" $url | Out-Null
      if (Test-Path -LiteralPath "$tmp\$($f.Name)") {
        $sz = (Get-Item -LiteralPath "$tmp\$($f.Name)").Length
        $logLines += "OK  $($f.Name) -> $sz bytes"
      } else {
        $logLines += "DL-FAIL $($f.Name)"
      }
    } else {
      $logLines += "API-FAIL $($f.Name): $outJson"
    }
  } catch {
    $logLines += "PARSE-FAIL $($f.Name): $($_.Exception.Message)"
  }
  Start-Sleep -Milliseconds 800
}
[System.IO.File]::WriteAllLines("C:\Users\Colorful\Doubao\chats\2026-10-15\new-chat\xiaonan-browser\assets\enhance_log.txt", $logLines, (New-Object System.Text.UTF8Encoding $false))
Get-Content -LiteralPath "C:\Users\Colorful\Doubao\chats\2026-10-15\new-chat\xiaonan-browser\assets\enhance_log.txt" -Encoding UTF8
