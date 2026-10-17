$ErrorActionPreference = "Continue"
$dir = "C:\Users\Colorful\Doubao\chats\2026-10-15\new-chat\xiaonan-browser\assets\ios"
$cut = "C:\Users\Colorful\Doubao\chats\2026-10-15\new-chat\xiaonan-browser\assets\ios_cut"
if (-not (Test-Path -LiteralPath $cut)) { New-Item -ItemType Directory -Path $cut | Out-Null }
$files = Get-ChildItem -LiteralPath $dir -Filter *.png | Where-Object { $_.Name -notmatch '_cut' } | Sort-Object Name
$logLines = @()
$i = 0
foreach ($f in $files) {
  $i++
  if (Test-Path -LiteralPath "$cut\$($f.Name)") { $logLines += "SKIP $($f.Name)"; continue }
  $outJson = & mediakit-cli image remove-image-background --image-url $f.FullName --scene general 2>$null | Out-String
  try {
    $obj = $outJson | ConvertFrom-Json
    if ($obj.success -eq $true) {
      curl.exe -L --max-time 120 -o "$cut\$($f.Name)" $obj.image_url | Out-Null
      if (Test-Path -LiteralPath "$cut\$($f.Name)") {
        $logLines += "OK $($f.Name) -> $((Get-Item -LiteralPath "$cut\$($f.Name)").Length)"
      } else { $logLines += "DL-FAIL $($f.Name)" }
    } else { $logLines += "API-FAIL $($f.Name): $outJson" }
  } catch { $logLines += "PARSE-FAIL $($f.Name): $($_.Exception.Message)" }
  Start-Sleep -Milliseconds 600
}
[System.IO.File]::WriteAllLines("C:\Users\Colorful\Doubao\chats\2026-10-15\new-chat\xiaonan-browser\assets\cut_log.txt", $logLines, (New-Object System.Text.UTF8Encoding $false))
Get-Content -LiteralPath "C:\Users\Colorful\Doubao\chats\2026-10-15\new-chat\xiaonan-browser\assets\cut_log.txt" -Encoding UTF8
