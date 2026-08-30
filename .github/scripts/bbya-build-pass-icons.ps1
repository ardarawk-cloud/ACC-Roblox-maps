param(
    [Parameter(Mandatory=$true)][string]$OutputDir
)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing

function C([string]$hex){ [System.Drawing.ColorTranslator]::FromHtml($hex) }
function RR([float]$x,[float]$y,[float]$w,[float]$h,[float]$r){
    $p=New-Object System.Drawing.Drawing2D.GraphicsPath
    $d=$r*2
    $p.AddArc($x,$y,$d,$d,180,90); $p.AddArc($x+$w-$d,$y,$d,$d,270,90)
    $p.AddArc($x+$w-$d,$y+$h-$d,$d,$d,0,90); $p.AddArc($x,$y+$h-$d,$d,$d,90,90)
    $p.CloseFigure(); return $p
}
function CenterText($g,[string]$text,$font,$brush,[float]$y,[float]$height){
    $fmt=New-Object System.Drawing.StringFormat
    $fmt.Alignment=[System.Drawing.StringAlignment]::Center
    $fmt.LineAlignment=[System.Drawing.StringAlignment]::Center
    $g.DrawString($text,$font,$brush,(New-Object System.Drawing.RectangleF(0,$y,512,$height)),$fmt)
    $fmt.Dispose()
}
function PenA([string]$color,[float]$width){
    $p=New-Object System.Drawing.Pen((C $color),$width)
    $p.StartCap=[System.Drawing.Drawing2D.LineCap]::Round
    $p.EndCap=[System.Drawing.Drawing2D.LineCap]::Round
    return $p
}
function BuildIcon([string]$name,[string]$label,[string]$kind,[string]$accent){
    $bmp=New-Object System.Drawing.Bitmap 512,512
    $g=[System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode=[System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint=[System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    $bg=New-Object System.Drawing.Drawing2D.LinearGradientBrush((New-Object System.Drawing.Point 0,0),(New-Object System.Drawing.Point 512,512),(C '#0A0C11'),(C '#171A22'))
    $g.FillRectangle($bg,0,0,512,512); $bg.Dispose()

    $accentColor=C $accent
    $halo=New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(28,$accentColor))
    $g.FillEllipse($halo,290,-90,330,330); $halo.Dispose()
    $line=New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(70,$accentColor),2)
    for($i=-160;$i -lt 650;$i+=48){ $g.DrawLine($line,$i,512,$i+380,132) }
    $line.Dispose()

    $white=New-Object System.Drawing.SolidBrush((C '#F5F7FA'))
    $muted=New-Object System.Drawing.SolidBrush((C '#AEB5C0'))
    $accentBrush=New-Object System.Drawing.SolidBrush($accentColor)
    $dimBrush=New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(42,$accentColor))
    $panel=RR 66 84 380 294 42
    $g.FillPath($dimBrush,$panel)
    $border=New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(150,$accentColor),3)
    $g.DrawPath($border,$panel)

    $fontBrand=New-Object System.Drawing.Font('Segoe UI',24,[System.Drawing.FontStyle]::Bold)
    $fontLabel=New-Object System.Drawing.Font('Segoe UI',30,[System.Drawing.FontStyle]::Bold)
    $fontBig=New-Object System.Drawing.Font('Segoe UI',76,[System.Drawing.FontStyle]::Bold)
    $brandBrush=New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(215,245,247,250))
    $g.DrawString('BBYA',$fontBrand,$brandBrush,28,24)
    $dot=New-Object System.Drawing.SolidBrush($accentColor); $g.FillEllipse($dot,104,31,12,12); $dot.Dispose()

    $p=PenA $accent 13
    switch($kind){
        'market' {
            $g.FillRectangle($accentBrush,150,172,212,40)
            for($i=0;$i -lt 5;$i++){
                $b=if($i%2 -eq 0){$white}else{$accentBrush}
                $g.FillRectangle($b,150+$i*42,172,42,40)
            }
            $g.DrawLine($p,166,216,166,314); $g.DrawLine($p,346,216,346,314); $g.DrawLine($p,166,314,346,314)
            $g.FillRectangle($accentBrush,226,250,60,64)
        }
        'mall' {
            $bag=RR 176 178 160 144 22; $g.DrawPath($p,$bag)
            $arc=New-Object System.Drawing.Pen($accentColor,13); $g.DrawArc($arc,210,142,92,88,190,160); $arc.Dispose()
            $g.DrawLine($p,220,248,292,248)
        }
        'funkot' {
            $heights=@(78,132,104,166,118,146,86); $x=143
            foreach($h in $heights){ $g.FillRectangle($accentBrush,$x,320-$h,24,$h); $x+=38 }
            $g.FillEllipse($white,238,143,36,36)
        }
        'basement' {
            $g.DrawEllipse($p,174,150,164,164)
            $g.DrawLine($p,256,184,256,274); $g.DrawLine($p,212,238,256,282); $g.DrawLine($p,300,238,256,282)
            $g.DrawLine($p,194,326,318,326)
        }
        'rooftop' {
            $g.FillRectangle($accentBrush,150,248,58,76); $g.FillRectangle($accentBrush,216,204,76,120); $g.FillRectangle($accentBrush,300,230,62,94)
            $g.DrawLine($p,136,324,376,324)
            $g.FillEllipse($white,314,142,48,48)
        }
        'skate' {
            $state=$g.Save(); $g.TranslateTransform(256,242); $g.RotateTransform(-12)
            $board=RR -132 -34 264 68 34; $g.FillPath($accentBrush,$board)
            $g.FillEllipse($white,-93,42,34,34); $g.FillEllipse($white,59,42,34,34)
            $board.Dispose(); $g.Restore($state)
        }
        'vip' {
            $pts=@((New-Object System.Drawing.PointF(256,142)),(New-Object System.Drawing.PointF(346,218)),(New-Object System.Drawing.PointF(256,324)),(New-Object System.Drawing.PointF(166,218)))
            $g.FillPolygon($accentBrush,$pts)
            CenterText $g 'VIP' (New-Object System.Drawing.Font('Segoe UI',44,[System.Drawing.FontStyle]::Bold)) $white 188 76
        }
        'sultan' {
            $pts=@((New-Object System.Drawing.PointF(154,284)),(New-Object System.Drawing.PointF(138,186)),(New-Object System.Drawing.PointF(206,232)),(New-Object System.Drawing.PointF(256,158)),(New-Object System.Drawing.PointF(306,232)),(New-Object System.Drawing.PointF(374,186)),(New-Object System.Drawing.PointF(358,284)))
            $g.FillPolygon($accentBrush,$pts); $g.FillRectangle($accentBrush,158,290,196,28)
            foreach($x in @(180,256,332)){ $g.FillEllipse($white,$x-8,260,16,16) }
        }
        'letterA' {
            $g.DrawEllipse($p,164,140,184,184); CenterText $g 'A' $fontBig $white 162 132
        }
        'letterB' {
            $g.DrawEllipse($p,164,140,184,184); CenterText $g 'B' $fontBig $white 162 132
        }
    }
    $p.Dispose()

    CenterText $g $label $fontLabel $white 398 58
    $small=New-Object System.Drawing.Font('Segoe UI',13,[System.Drawing.FontStyle]::Bold)
    CenterText $g 'ACCESS PASS' $small $muted 458 28

    $path=Join-Path $OutputDir ($name+'.png')
    $bmp.Save($path,[System.Drawing.Imaging.ImageFormat]::Png)
    Write-Host "BBYA_PASS_ICON_BUILT name=$name file=$path bytes=$((Get-Item $path).Length)"

    $small.Dispose(); $fontBrand.Dispose(); $fontLabel.Dispose(); $fontBig.Dispose(); $brandBrush.Dispose(); $white.Dispose(); $muted.Dispose(); $accentBrush.Dispose(); $dimBrush.Dispose(); $border.Dispose(); $panel.Dispose(); $g.Dispose(); $bmp.Dispose()
}

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
BuildIcon 'pasar-malam' 'PASAR MALAM' 'market' '#FFB33B'
BuildIcon 'mall' 'MALL' 'mall' '#47C7FF'
BuildIcon 'funkot' 'FUNKOT' 'funkot' '#E34BFF'
BuildIcon 'basement' 'BASEMENT' 'basement' '#FF5964'
BuildIcon 'rooftop' 'ROOFTOP' 'rooftop' '#63D5FF'
BuildIcon 'skatepark' 'SKATEPARK' 'skate' '#A7F542'
BuildIcon 'vip' 'VIP' 'vip' '#F9D65C'
BuildIcon 'sultan' 'SULTAN' 'sultan' '#FFBF38'
BuildIcon 'b-pass' 'B PASS' 'letterB' '#7C8CFF'
BuildIcon 'a-pass' 'A PASS' 'letterA' '#D9E3F0'
Write-Host 'BBYA_PASS_ICON_BUILD_PASS count=10'
