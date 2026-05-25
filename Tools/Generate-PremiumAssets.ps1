Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$assetRoot = Join-Path $root "AppStoreSubmission"
$shotRoot = Join-Path $assetRoot "Screenshots\iPhone-6.5"
$iPadShotRoot = Join-Path $assetRoot "Screenshots\iPad-12.9"
$iconRoot = Join-Path $assetRoot "Icons"
$subscriptionRoot = Join-Path $assetRoot "SubscriptionImages"
$reviewRoot = Join-Path $assetRoot "SubscriptionReviewScreenshots"
$appIconRoot = Join-Path $root "HiveOSAI\Assets.xcassets\AppIcon.appiconset"

New-Item -ItemType Directory -Force -Path $shotRoot, $iPadShotRoot, $iconRoot, $subscriptionRoot, $reviewRoot, $appIconRoot | Out-Null

function New-Brush($r, $g, $b, $a = 255) {
    New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($a, $r, $g, $b))
}

function New-Pen($r, $g, $b, $a = 255, $width = 1) {
    New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($a, $r, $g, $b)), $width
}

function Draw-HexPattern($graphics, $width, $height) {
    $pen = New-Pen 245 164 42 34 2
    $size = 78
    $hexH = [Math]::Sqrt(3) * $size / 2
    for ($row = -1; $row -lt ($height / $hexH) + 2; $row++) {
        for ($col = -1; $col -lt ($width / ($size * 1.5)) + 2; $col++) {
            $cx = 90 + ($col * $size * 1.5)
            if ($row % 2 -ne 0) { $cx += $size * 0.75 }
            $cy = 80 + ($row * $hexH)
            $points = New-Object System.Drawing.PointF[] 6
            for ($i = 0; $i -lt 6; $i++) {
                $angle = [Math]::PI / 6 + $i * [Math]::PI / 3
                $points[$i] = New-Object System.Drawing.PointF (($cx + [Math]::Cos($angle) * $size / 2), ($cy + [Math]::Sin($angle) * $size / 2))
            }
            $graphics.DrawPolygon($pen, $points)
        }
    }
    $pen.Dispose()
}

function Draw-LightOrb($graphics, $x, $y, $size, $r, $g, $b, $alpha) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddEllipse($x, $y, $size, $size)
    $brush = New-Object System.Drawing.Drawing2D.PathGradientBrush $path
    $brush.CenterColor = [System.Drawing.Color]::FromArgb($alpha, $r, $g, $b)
    $brush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, $r, $g, $b))
    $graphics.FillPath($brush, $path)
    $brush.Dispose()
    $path.Dispose()
}

function Draw-Bee($graphics, $cx, $cy, $scale, $angle, $alpha = 180) {
    $state = $graphics.Save()
    $graphics.TranslateTransform($cx, $cy)
    $graphics.RotateTransform($angle)
    $graphics.ScaleTransform($scale, $scale)

    $wingBrush = New-Brush 255 245 215 ([Math]::Min(125, $alpha))
    $bodyBrush = New-Brush 15 12 7 $alpha
    $goldBrush = New-Brush 246 170 43 ([Math]::Min(235, $alpha + 30))
    $linePen = New-Pen 255 214 122 ([Math]::Min(120, $alpha)) 2
    $darkPen = New-Pen 4 4 3 ([Math]::Min(180, $alpha)) 3

    $graphics.FillEllipse($wingBrush, -58, -46, 72, 42)
    $graphics.FillEllipse($wingBrush, -8, -48, 78, 44)
    $graphics.DrawEllipse($linePen, -58, -46, 72, 42)
    $graphics.DrawEllipse($linePen, -8, -48, 78, 44)

    $graphics.FillEllipse($bodyBrush, -46, -21, 92, 42)
    $graphics.FillEllipse($goldBrush, -33, -20, 14, 40)
    $graphics.FillEllipse($goldBrush, -8, -20, 14, 40)
    $graphics.FillEllipse($goldBrush, 17, -18, 12, 36)
    $graphics.DrawEllipse($darkPen, -46, -21, 92, 42)
    $graphics.FillEllipse($bodyBrush, 38, -14, 30, 28)
    $graphics.DrawLine($linePen, 58, -13, 78, -30)
    $graphics.DrawLine($linePen, 60, 12, 82, 25)

    $darkPen.Dispose(); $linePen.Dispose(); $wingBrush.Dispose(); $bodyBrush.Dispose(); $goldBrush.Dispose()
    $graphics.Restore($state)
}

function Draw-FlightTrail($graphics, $startX, $startY, $width, $height, $alpha = 80) {
    $pen = New-Pen 255 196 84 $alpha 4
    $pen.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dot
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddBezier($startX, $startY, $startX + ($width * 0.35), $startY - ($height * 0.65), $startX + ($width * 0.55), $startY + ($height * 0.75), $startX + $width, $startY)
    $graphics.DrawPath($pen, $path)
    $path.Dispose()
    $pen.Dispose()
}

function Draw-ExoticBeeBackdrop($graphics, $width, $height, $variant) {
    Draw-LightOrb $graphics (-0.18 * $width) (0.05 * $height) (0.78 * $width) 246 170 43 110
    Draw-LightOrb $graphics (0.55 * $width) (-0.08 * $height) (0.62 * $width) 255 196 84 82
    Draw-LightOrb $graphics (0.48 * $width) (0.62 * $height) (0.55 * $width) 255 139 42 60

    $veil = New-Object System.Drawing.Drawing2D.LinearGradientBrush (
        (New-Object System.Drawing.Rectangle 0,0,$width,$height),
        ([System.Drawing.Color]::FromArgb(12, 255, 212, 128)),
        ([System.Drawing.Color]::FromArgb(180, 0, 0, 0)),
        90
    )
    $graphics.FillRectangle($veil, 0, 0, $width, $height)
    $veil.Dispose()

    Draw-FlightTrail $graphics (0.08 * $width) (0.30 * $height) (0.82 * $width) (0.18 * $height) 70
    Draw-FlightTrail $graphics (0.18 * $width) (0.76 * $height) (0.62 * $width) (0.12 * $height) 54

    $beeScale = $width / 1242
    Draw-Bee $graphics (0.78 * $width) (0.18 * $height) (2.2 * $beeScale) -18 120
    Draw-Bee $graphics (0.16 * $width) (0.52 * $height) (1.55 * $beeScale) 24 92
    Draw-Bee $graphics (0.88 * $width) (0.76 * $height) (1.28 * $beeScale) -32 86
    Draw-Bee $graphics (0.26 * $width) (0.12 * $height) (0.92 * $beeScale) 34 76

    if (($variant % 2) -eq 0) {
        Draw-Bee $graphics (0.08 * $width) (0.84 * $height) (1.12 * $beeScale) 18 70
    } else {
        Draw-Bee $graphics (0.92 * $width) (0.42 * $height) (0.98 * $beeScale) -42 72
    }
}

function Draw-RoundedRect($graphics, $brush, $pen, $x, $y, $w, $h, $r) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    if ($brush -ne $null) { $graphics.FillPath($brush, $path) }
    if ($pen -ne $null) { $graphics.DrawPath($pen, $path) }
    $path.Dispose()
}

function Draw-WrappedText($graphics, $text, $font, $brush, $rect, $format = $null) {
    if ($null -eq $format) {
        $format = New-Object System.Drawing.StringFormat
        $format.Trimming = [System.Drawing.StringTrimming]::EllipsisWord
    }
    $graphics.DrawString($text, $font, $brush, $rect, $format)
}

function Save-Png($bitmap, $path) {
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
}

function Save-FlatPng($bitmap, $path) {
    $flat = New-Object System.Drawing.Bitmap $bitmap.Width, $bitmap.Height, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $g = [System.Drawing.Graphics]::FromImage($flat)
    $g.Clear([System.Drawing.Color]::Black)
    $g.DrawImage($bitmap, 0, 0, $bitmap.Width, $bitmap.Height)
    $flat.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $flat.Dispose()
}

function Save-Jpeg($bitmap, $path, $quality = 92) {
    $encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
    $params = New-Object System.Drawing.Imaging.EncoderParameters 1
    $params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), ([int64]$quality)
    $bitmap.Save($path, $encoder, $params)
    $params.Dispose()
}

function New-AppIcon($path) {
    $bmp = New-Object System.Drawing.Bitmap 1024, 1024
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush (
        (New-Object System.Drawing.Rectangle 0,0,1024,1024),
        ([System.Drawing.Color]::FromArgb(255, 5, 4, 3)),
        ([System.Drawing.Color]::FromArgb(255, 58, 34, 8)),
        45
    )
    $g.FillRectangle($bg, 0, 0, 1024, 1024)
    Draw-HexPattern $g 1024 1024

    $gold = New-Pen 246 170 43 230 18
    $glow = New-Pen 246 170 43 80 48
    $center = New-Object System.Drawing.PointF 512, 498
    for ($ring = 0; $ring -lt 3; $ring++) {
        $radius = 150 + $ring * 84
        $points = New-Object System.Drawing.PointF[] 6
        for ($i = 0; $i -lt 6; $i++) {
            $angle = [Math]::PI / 6 + $i * [Math]::PI / 3
            $points[$i] = New-Object System.Drawing.PointF (($center.X + [Math]::Cos($angle) * $radius), ($center.Y + [Math]::Sin($angle) * $radius))
        }
        $g.DrawPolygon($glow, $points)
        $g.DrawPolygon($gold, $points)
    }

    $font = New-Object System.Drawing.Font "Segoe UI", 144, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
    $small = New-Object System.Drawing.Font "Segoe UI", 46, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
    $white = New-Brush 255 248 226
    $amber = New-Brush 246 170 43
    $centerFormat = New-Object System.Drawing.StringFormat
    $centerFormat.Alignment = [System.Drawing.StringAlignment]::Center
    $centerFormat.LineAlignment = [System.Drawing.StringAlignment]::Center
    $g.DrawString("H", $font, $white, (New-Object System.Drawing.RectangleF 0, 315, 1024, 210), $centerFormat)
    $g.DrawString("AI", $small, $amber, (New-Object System.Drawing.RectangleF 0, 515, 1024, 90), $centerFormat)

    Save-Png $bmp $path
    $centerFormat.Dispose(); $font.Dispose(); $small.Dispose(); $white.Dispose(); $amber.Dispose(); $gold.Dispose(); $glow.Dispose(); $bg.Dispose(); $g.Dispose(); $bmp.Dispose()
}

function New-SubscriptionImage($path, $planName, $price, $signal, $accentR, $accentG, $accentB) {
    $bmp = New-Object System.Drawing.Bitmap 1024, 1024
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

    $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush (
        (New-Object System.Drawing.Rectangle 0,0,1024,1024),
        ([System.Drawing.Color]::FromArgb(255, 3, 3, 3)),
        ([System.Drawing.Color]::FromArgb(255, 42, 25, 6)),
        55
    )
    $g.FillRectangle($bg, 0, 0, 1024, 1024)
    Draw-HexPattern $g 1024 1024

    $accent = New-Brush $accentR $accentG $accentB
    $accentPen = New-Pen $accentR $accentG $accentB 230 10
    $glowPen = New-Pen $accentR $accentG $accentB 70 34
    $panel = New-Brush 7 7 6 214
    $panelPen = New-Pen $accentR $accentG $accentB 95 2
    $white = New-Brush 255 248 226
    $muted = New-Brush 194 176 145

    Draw-RoundedRect $g $panel $panelPen 92 102 840 820 42

    $center = New-Object System.Drawing.PointF 512, 352
    foreach ($radius in @(118, 190, 262)) {
        $points = New-Object System.Drawing.PointF[] 6
        for ($i = 0; $i -lt 6; $i++) {
            $angle = [Math]::PI / 6 + $i * [Math]::PI / 3
            $points[$i] = New-Object System.Drawing.PointF (($center.X + [Math]::Cos($angle) * $radius), ($center.Y + [Math]::Sin($angle) * $radius))
        }
        $g.DrawPolygon($glowPen, $points)
        $g.DrawPolygon($accentPen, $points)
    }

    $fontBrand = New-Object System.Drawing.Font "Segoe UI", 38, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
    $fontPlan = New-Object System.Drawing.Font "Segoe UI", 72, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
    $fontPrice = New-Object System.Drawing.Font "Segoe UI", 46, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
    $fontSignal = New-Object System.Drawing.Font "Segoe UI", 30, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
    $centerFormat = New-Object System.Drawing.StringFormat
    $centerFormat.Alignment = [System.Drawing.StringAlignment]::Center
    $centerFormat.LineAlignment = [System.Drawing.StringAlignment]::Center

    $g.DrawString("HiveOS AI", $fontBrand, $accent, (New-Object System.Drawing.RectangleF 0, 152, 1024, 58), $centerFormat)
    $g.DrawString($planName, $fontPlan, $white, (New-Object System.Drawing.RectangleF 120, 600, 784, 100), $centerFormat)
    $g.DrawString($price, $fontPrice, $accent, (New-Object System.Drawing.RectangleF 120, 704, 784, 70), $centerFormat)
    Draw-RoundedRect $g (New-Brush $accentR $accentG $accentB 34) (New-Pen $accentR $accentG $accentB 110 2) 188 812 648 72 36
    $g.DrawString($signal, $fontSignal, $muted, (New-Object System.Drawing.RectangleF 190, 812, 644, 72), $centerFormat)

    Save-FlatPng $bmp $path

    $centerFormat.Dispose(); $fontBrand.Dispose(); $fontPlan.Dispose(); $fontPrice.Dispose(); $fontSignal.Dispose()
    $accent.Dispose(); $accentPen.Dispose(); $glowPen.Dispose(); $panel.Dispose(); $panelPen.Dispose(); $white.Dispose(); $muted.Dispose(); $bg.Dispose()
    $g.Dispose(); $bmp.Dispose()
}

function New-Screenshot($fileName, $headline, $subhead, $screenTitle, $metrics, $module, $badge, $outRoot = $shotRoot, $w = 1242, $h = 2688) {
    $bmp = New-Object System.Drawing.Bitmap $w, $h
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush (
        (New-Object System.Drawing.Rectangle 0,0,$w,$h),
        ([System.Drawing.Color]::FromArgb(255, 4, 4, 3)),
        ([System.Drawing.Color]::FromArgb(255, 42, 27, 9)),
        60
    )
    $g.FillRectangle($bg, 0, 0, $w, $h)
    $variant = 0
    foreach ($char in $fileName.ToCharArray()) { $variant += [int][char]$char }
    Draw-ExoticBeeBackdrop $g $w $h $variant
    Draw-HexPattern $g $w $h

    $white = New-Brush 255 248 228
    $muted = New-Brush 191 174 145
    $gold = New-Brush 246 170 43
    $panel = New-Brush 8 8 7 210
    $panelSoft = New-Brush 255 255 255 14
    $stroke = New-Pen 246 170 43 78 2

    $fontBrand = New-Object System.Drawing.Font "Segoe UI", 34, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
    $fontHero = New-Object System.Drawing.Font "Segoe UI", 88, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
    $fontSub = New-Object System.Drawing.Font "Segoe UI", 38, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
    $fontTitle = New-Object System.Drawing.Font "Segoe UI", 44, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
    $fontMetric = New-Object System.Drawing.Font "Segoe UI", 48, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
    $fontSmall = New-Object System.Drawing.Font "Segoe UI", 28, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
    $fontBadge = New-Object System.Drawing.Font "Segoe UI", 24, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)

    $g.DrawString("HiveOS AI", $fontBrand, $gold, 82, 92)
    Draw-WrappedText $g $headline $fontHero $white (New-Object System.Drawing.RectangleF 80, 180, 1082, 220)
    Draw-WrappedText $g $subhead $fontSub $muted (New-Object System.Drawing.RectangleF 84, 415, 1010, 150)

    Draw-RoundedRect $g $panel $stroke 82 620 1078 1750 34
    Draw-RoundedRect $g $panelSoft $null 126 676 990 112 24
    $g.DrawString($screenTitle, $fontTitle, $white, 162, 708)
    Draw-RoundedRect $g (New-Brush 246 170 43 42) (New-Pen 246 170 43 100 1) 876 700 198 62 31
    $g.DrawString($badge, $fontBadge, $gold, 910, 716)

    $y = 870
    foreach ($metric in $metrics) {
        Draw-RoundedRect $g $panelSoft $stroke 130 $y 982 178 22
        $parts = $metric -split "\|", 2
        $g.DrawString($parts[0], $fontMetric, $gold, 174, ($y + 34))
        if ($parts.Length -gt 1) {
            Draw-WrappedText $g $parts[1] $fontSmall $muted (New-Object System.Drawing.RectangleF 432, ($y + 44), 620, 82)
        }
        $y += 220
    }

    Draw-RoundedRect $g (New-Brush 246 170 43 36) (New-Pen 246 170 43 120 2) 130 1960 982 250 24
    $g.DrawString($module, $fontTitle, $white, 174, 2005)
    Draw-WrappedText $g "Informational agricultural insights only. Verify hive decisions independently." $fontSmall $muted (New-Object System.Drawing.RectangleF 176, 2076, 820, 90)

    Draw-RoundedRect $g (New-Brush 246 170 43 255) $null 190 2410 862 96 48
    $center = New-Object System.Drawing.StringFormat
    $center.Alignment = [System.Drawing.StringAlignment]::Center
    $center.LineAlignment = [System.Drawing.StringAlignment]::Center
    $g.DrawString("The operating system for intelligent beekeeping", $fontSmall, (New-Brush 8 8 7), (New-Object System.Drawing.RectangleF 190, 2410, 862, 96), $center)

    Save-Png $bmp (Join-Path $outRoot $fileName)

    $center.Dispose(); $bg.Dispose(); $white.Dispose(); $muted.Dispose(); $gold.Dispose(); $panel.Dispose(); $panelSoft.Dispose(); $stroke.Dispose()
    $fontBrand.Dispose(); $fontHero.Dispose(); $fontSub.Dispose(); $fontTitle.Dispose(); $fontMetric.Dispose(); $fontSmall.Dispose(); $fontBadge.Dispose()
    $g.Dispose(); $bmp.Dispose()
}

function New-SubscriptionReviewScreenshot($fileName, $planName, $price, $summary, $features) {
    $w = 640
    $h = 920
    $bmp = New-Object System.Drawing.Bitmap $w, $h, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush (
        (New-Object System.Drawing.Rectangle 0,0,$w,$h),
        ([System.Drawing.Color]::FromArgb(255, 5, 5, 4)),
        ([System.Drawing.Color]::FromArgb(255, 45, 28, 8)),
        55
    )
    $g.FillRectangle($bg, 0, 0, $w, $h)
    Draw-ExoticBeeBackdrop $g $w $h ($fileName.Length * 31)
    Draw-HexPattern $g $w $h

    $white = New-Brush 255 248 228
    $muted = New-Brush 210 190 154
    $gold = New-Brush 246 170 43
    $panel = New-Brush 8 8 7 225
    $soft = New-Brush 255 255 255 18
    $stroke = New-Pen 246 170 43 105 2

    $brand = New-Object System.Drawing.Font "Segoe UI", 22, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
    $hero = New-Object System.Drawing.Font "Segoe UI", 46, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
    $priceFont = New-Object System.Drawing.Font "Segoe UI", 34, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
    $body = New-Object System.Drawing.Font "Segoe UI", 20, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
    $featureFont = New-Object System.Drawing.Font "Segoe UI", 18, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
    $small = New-Object System.Drawing.Font "Segoe UI", 13, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)

    $center = New-Object System.Drawing.StringFormat
    $center.Alignment = [System.Drawing.StringAlignment]::Center
    $center.LineAlignment = [System.Drawing.StringAlignment]::Center

    $g.DrawString("HiveOS AI", $brand, $gold, 42, 34)
    Draw-Bee $g 520 95 1.08 -18 160
    Draw-WrappedText $g $planName $hero $white (New-Object System.Drawing.RectangleF 42, 118, 556, 112)
    $g.DrawString($price, $priceFont, $gold, (New-Object System.Drawing.RectangleF 42, 236, 556, 52), $center)
    Draw-WrappedText $g $summary $body $muted (New-Object System.Drawing.RectangleF 60, 306, 520, 76)

    Draw-RoundedRect $g $panel $stroke 36 404 568 370 26
    $y = 444
    foreach ($feature in $features) {
        Draw-RoundedRect $g $soft $null 68 $y 504 52 18
        $g.DrawString($feature, $featureFont, $white, (New-Object System.Drawing.RectangleF 92, ($y + 13), 430, 28))
        $g.FillEllipse($gold, 76, ($y + 19), 10, 10)
        $y += 72
    }

    Draw-RoundedRect $g (New-Brush 246 170 43 245) $null 72 806 496 58 29
    $g.DrawString("Continue", $body, (New-Brush 8 8 7), (New-Object System.Drawing.RectangleF 72, 806, 496, 58), $center)
    $g.DrawString("Review screenshot for App Store Connect. Informational agricultural insights only.", $small, $muted, (New-Object System.Drawing.RectangleF 46, 876, 548, 34), $center)

    Save-Jpeg $bmp (Join-Path $reviewRoot $fileName) 94

    $center.Dispose(); $bg.Dispose(); $white.Dispose(); $muted.Dispose(); $gold.Dispose(); $panel.Dispose(); $soft.Dispose(); $stroke.Dispose()
    $brand.Dispose(); $hero.Dispose(); $priceFont.Dispose(); $body.Dispose(); $featureFont.Dispose(); $small.Dispose()
    $g.Dispose(); $bmp.Dispose()
}

$iconPath = Join-Path $iconRoot "HiveOSAI-AppIcon-1024.png"
New-AppIcon $iconPath
Copy-Item $iconPath (Join-Path $appIconRoot "HiveOSAI-AppIcon-1024.png") -Force

@'
{"images":[{"filename":"HiveOSAI-AppIcon-1024.png","idiom":"universal","platform":"ios","size":"1024x1024"}],"info":{"author":"xcode","version":1}}
'@ | Set-Content -Path (Join-Path $appIconRoot "Contents.json") -Encoding UTF8

$pound = [char]0x00A3
New-SubscriptionImage (Join-Path $subscriptionRoot "premium-monthly-1024.png") "Premium Monthly" "$pound 14.99 / month" "AI scans + Hive Pulse" 246 170 43
New-SubscriptionImage (Join-Path $subscriptionRoot "premium-yearly-1024.png") "Premium Yearly" "$pound 119.99 / year" "Premium intelligence annually" 255 196 84
New-SubscriptionImage (Join-Path $subscriptionRoot "apiary-pro-monthly-1024.png") "Apiary Pro" "$pound 39.99 / month" "Commercial apiary operations" 255 139 42

New-SubscriptionReviewScreenshot "premium-monthly-review.jpg" "Premium Monthly" "$pound 14.99 / month" "Monthly access for serious hive monitoring and field records." @("Unlimited hives", "AI hive scans", "Hive Pulse system", "PDF reports")
New-SubscriptionReviewScreenshot "premium-yearly-review.jpg" "Premium Yearly" "$pound 119.99 / year" "Annual premium intelligence for seasonal beekeeping operations." @("Everything in Premium", "Advanced analytics", "Weather intelligence", "Seasonal reports")
New-SubscriptionReviewScreenshot "apiary-pro-monthly-review.jpg" "Apiary Pro Monthly" "$pound 39.99 / month" "Commercial apiary tools for larger operations and teams." @("Multi-apiary management", "Commercial analytics", "Team placeholders", "Cloud backup placeholder")

New-Screenshot "01-dashboard.png" "Know your hive before trouble spreads" "Hive health, swarm risk, inspections, weather and productivity in one premium dashboard." "Hive Health Overview" @("86%|Productivity score across managed hives","2|Watchlist colonies need follow-up","Calm|AI pulse reading from mock local data") "Dashboard Intelligence" "LIVE"
New-Screenshot "02-hive-pulse.png" "Your hive speaks before it collapses" "Animated Hive Pulse turns inspections, notes and trends into cautious operational signals." "Hive Pulse System" @("Calm|Current colony activity signal","78%|Confidence from local records","Resource|Stress windows highlighted early") "Pulse meter and confidence" "PULSE"
New-Screenshot "03-ai-scan.png" "Scan brood, comb and entrances" "Photo workflows surface possible signs of brood irregularity, congestion, pest risk and comb condition." "AI Hive Scan" @("Possible|Brood pattern irregularity","May indicate|Overcrowding pressure","Recommend|Manual inspection before action") "Cautious photo insights" "SCAN"
New-Screenshot "04-inspections.png" "Inspections without the notebook chaos" "Checklist-led visits for brood, queen, pests, food stores, comb health and seasonal prep." "Inspection System" @("8|Inspection categories","Photos|Attach visual evidence","Notes|Voice placeholder ready") "Field-ready records" "CHECK"
New-Screenshot "05-analytics.png" "See trends across the season" "Charts reveal colony stability, strongest hives, weakest hives, swarm-risk history and inspection cadence." "Hive Analytics" @("92|Colony stability score","Amber Six|Needs attention","Golden Ridge|Seasonal comparison ready") "Swift Charts dashboard" "TREND"
New-Screenshot "06-swarm-network.png" "Notify local beekeepers when a swarm is spotted" "Swarm Alert Network records sightings and prepares opt-in local beekeeper notifications." "Swarm Alert Network" @("Spotted|Location and access notes","Notified|Local notification scaffold","Resolved|Track response status") "Community response layer" "ALERT"
New-Screenshot "07-apiary.png" "Run one hive or a full apiary" "Manage locations, climate regions, hive counts, notes, queen placeholders and productivity records." "Apiary Management" @("Multi-apiary|Built for scale","Queen|Age and lineage placeholders","Honey|Production estimates ready") "Apiary operations" "PRO"
New-Screenshot "08-reports.png" "Generate premium hive reports" "Create PDF summaries for inspections, swarm risk, queen status, apiary overview and seasonal performance." "Hive Reports" @("PDF|Native report generation","Share|Send records from iOS","Local|Offline-friendly data") "Professional reporting" "PDF"
New-Screenshot "09-weather.png" "Plan around forage and weather windows" "Weather intelligence placeholders support nectar flow, wind, rain, feeding reminders and swarm windows." "Weather Intelligence" @("Forage|Condition placeholder","Nectar|Flow estimate placeholder","Alerts|Swarm window planning") "Weather-aware beekeeping" "WX"
New-Screenshot "10-paywall.png" "Premium intelligence for serious beekeepers" "Unlock unlimited hives, AI scans, Hive Pulse, analytics, reports and commercial apiary tools." "HiveOS AI Plans" @("Premium|£14.99 monthly","Premium|£119.99 yearly","Apiary Pro|£39.99 monthly") "Subscription-ready" "PLUS"

New-Screenshot "01-dashboard-ipad.png" "Know your hive before trouble spreads" "Hive health, swarm risk, inspections, weather and productivity in one premium dashboard." "Hive Health Overview" @("86%|Productivity score across managed hives","2|Watchlist colonies need follow-up","Calm|AI pulse reading from mock local data") "Dashboard Intelligence" "LIVE" $iPadShotRoot 2048 2732
New-Screenshot "02-hive-pulse-ipad.png" "Your hive speaks before it collapses" "Animated Hive Pulse turns inspections, notes and trends into cautious operational signals." "Hive Pulse System" @("Calm|Current colony activity signal","78%|Confidence from local records","Resource|Stress windows highlighted early") "Pulse meter and confidence" "PULSE" $iPadShotRoot 2048 2732
New-Screenshot "03-ai-scan-ipad.png" "Scan brood, comb and entrances" "Photo workflows surface possible signs of brood irregularity, congestion, pest risk and comb condition." "AI Hive Scan" @("Possible|Brood pattern irregularity","May indicate|Overcrowding pressure","Recommend|Manual inspection before action") "Cautious photo insights" "SCAN" $iPadShotRoot 2048 2732
New-Screenshot "04-inspections-ipad.png" "Inspections without the notebook chaos" "Checklist-led visits for brood, queen, pests, food stores, comb health and seasonal prep." "Inspection System" @("8|Inspection categories","Photos|Attach visual evidence","Notes|Voice placeholder ready") "Field-ready records" "CHECK" $iPadShotRoot 2048 2732
New-Screenshot "05-analytics-ipad.png" "See trends across the season" "Charts reveal colony stability, strongest hives, weakest hives, swarm-risk history and inspection cadence." "Hive Analytics" @("92|Colony stability score","Amber Six|Needs attention","Golden Ridge|Seasonal comparison ready") "Swift Charts dashboard" "TREND" $iPadShotRoot 2048 2732
New-Screenshot "06-swarm-network-ipad.png" "Notify local beekeepers when a swarm is spotted" "Swarm Alert Network records sightings and prepares opt-in local beekeeper notifications." "Swarm Alert Network" @("Spotted|Location and access notes","Notified|Local notification scaffold","Resolved|Track response status") "Community response layer" "ALERT" $iPadShotRoot 2048 2732
New-Screenshot "07-apiary-ipad.png" "Run one hive or a full apiary" "Manage locations, climate regions, hive counts, notes, queen placeholders and productivity records." "Apiary Management" @("Multi-apiary|Built for scale","Queen|Age and lineage placeholders","Honey|Production estimates ready") "Apiary operations" "PRO" $iPadShotRoot 2048 2732
New-Screenshot "08-reports-ipad.png" "Generate premium hive reports" "Create PDF summaries for inspections, swarm risk, queen status, apiary overview and seasonal performance." "Hive Reports" @("PDF|Native report generation","Share|Send records from iOS","Local|Offline-friendly data") "Professional reporting" "PDF" $iPadShotRoot 2048 2732
New-Screenshot "09-weather-ipad.png" "Plan around forage and weather windows" "Weather intelligence placeholders support nectar flow, wind, rain, feeding reminders and swarm windows." "Weather Intelligence" @("Forage|Condition placeholder","Nectar|Flow estimate placeholder","Alerts|Swarm window planning") "Weather-aware beekeeping" "WX" $iPadShotRoot 2048 2732
New-Screenshot "10-paywall-ipad.png" "Premium intelligence for serious beekeepers" "Unlock unlimited hives, AI scans, Hive Pulse, analytics, reports and commercial apiary tools." "HiveOS AI Plans" @("Premium|£14.99 monthly","Premium|£119.99 yearly","Apiary Pro|£39.99 monthly") "Subscription-ready" "PLUS" $iPadShotRoot 2048 2732

Write-Host "Generated premium assets in $assetRoot"
