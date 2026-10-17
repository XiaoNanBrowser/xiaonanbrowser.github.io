# Process browser icon & wallpaper assets (System.Drawing)
Add-Type -AssemblyName System.Drawing

$assets = "C:\Users\Colorful\Doubao\chats\2026-10-15\new-chat\xiaonan-browser\assets"

function Resize-Image([string]$src, [string]$dst, [int]$maxW, [int]$maxH, [string]$fmt) {
    $img = [System.Drawing.Image]::FromFile($src)
    try {
        $ratio = [Math]::Min($maxW / $img.Width, $maxH / $img.Height)
        if ($ratio -gt 1) { $ratio = 1 }
        $w = [int][Math]::Round($img.Width * $ratio)
        $h = [int][Math]::Round($img.Height * $ratio)
        $bmp = New-Object System.Drawing.Bitmap($w, $h)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.Clear([System.Drawing.Color]::Transparent)
        $g.DrawImage($img, 0, 0, $w, $h)
        $g.Dispose()
        if ($fmt -eq 'png') {
            $bmp.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
        } else {
            $bmp.Save($dst, [System.Drawing.Imaging.ImageFormat]::Jpeg)
        }
        $bmp.Dispose()
        return "OK: $src -> $dst ($w x $h)"
    } finally {
        $img.Dispose()
    }
}

$log = Join-Path $assets "img_log.txt"
$lines = @()
$iconSrc = Join-Path $assets "icon_source.png"
$iconDst = Join-Path $assets "icon.png"
$lines += (Resize-Image $iconSrc $iconDst 512 512 'png')
$wpSrc = Join-Path $assets "wallpaper.jpg"
$wpDst = Join-Path $assets "wallpaper_web.jpg"
$lines += (Resize-Image $wpSrc $wpDst 1920 1080 'jpg')
[System.IO.File]::WriteAllLines($log, $lines, (New-Object System.Text.UTF8Encoding $false))
Get-Content -LiteralPath $log -Encoding UTF8
