Add-Type -AssemblyName System.Drawing
$assets = "C:\Users\Colorful\Doubao\chats\2026-10-15\new-chat\xiaonan-browser\assets"
$log = Join-Path $assets "alpha_check.txt"
$lines = @()
foreach ($f in @("iphone.png","ipad.png","macbook.png")) {
    $p = Join-Path $assets $f
    $bmp = New-Object System.Drawing.Bitmap($p)
    # 采样 4 角 + 中心
    $w = $bmp.Width; $h = $bmp.Height
    $pts = @(@(0,0), @($w-1,0), @(0,$h-1), @($w-1,$h-1), @([int]($w/2),[int]($h/2)))
    $alphas = @()
    foreach ($pt in $pts) {
        $px = $bmp.GetPixel($pt[0], $pt[1])
        $alphas += "$($pt[0]),$($pt[1]):A=$($px.A)"
    }
    $lines += "$f  ($w x $h)  " + ($alphas -join "  ")
    $bmp.Dispose()
}
[System.IO.File]::WriteAllLines($log, $lines, (New-Object System.Text.UTF8Encoding $false))
Get-Content -LiteralPath $log -Encoding UTF8
