# build_icons.ps1
# Turn the 1024x1536 / ~3 MB source art into TTS-ready HUD icons.
#
# Three problems with the originals:
#   1. ~3 MB each. TTS fetches every custom asset over the network on load;
#      six 3 MB PNGs is 18 MB before anyone has moved a model.
#   2. 1024x1536 portrait. The action icons need to read as squares.
#   3. Opaque dark backgrounds. A floating token HUD needs alpha, or every
#      icon sits in a visible rectangle.
#
# So: downscale, knock the background out by flood-filling from the corners,
# crop to the artwork, and letterbox onto a square transparent canvas.
#
#   out: icons/<name>.png   256x256 RGBA

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$src = "C:\Users\WH407\Downloads\CUS_TTS_v6"
$out = Join-Path $PSScriptRoot "icons"
New-Item -ItemType Directory -Force -Path $out | Out-Null

$WORK = 384      # working width; big enough to keep detail, small enough to be quick
$FINAL = 256     # final square canvas
$TOL = 26        # per-STEP tolerance now (sum of RGB delta vs the neighbour)

function Get-Resized([System.Drawing.Bitmap]$bmp, [int]$w) {
    $h = [int][Math]::Round($bmp.Height * ($w / $bmp.Width))
    $n = New-Object System.Drawing.Bitmap $w, $h, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($n)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode  = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.DrawImage($bmp, 0, 0, $w, $h)
    $g.Dispose()
    return $n
}

foreach ($file in (Get-ChildItem (Join-Path $src "*.png"))) {
    $orig = [System.Drawing.Bitmap]::FromFile($file.FullName)
    $img  = Get-Resized $orig $WORK
    $orig.Dispose()
    $W = $img.Width; $H = $img.Height

    # ---- read pixels into a flat array (per-pixel GetPixel is far too slow) --
    $rect = New-Object System.Drawing.Rectangle 0, 0, $W, $H
    $data = $img.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadWrite,
                          [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $bytes = New-Object byte[] ($data.Stride * $H)
    [System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $bytes, 0, $bytes.Length)

    function Idx([int]$x, [int]$y) { return ($y * $data.Stride) + ($x * 4) }

    # ---- flood fill from the whole border, comparing LOCALLY ----------------
    # Comparing every candidate against one global reference colour fails on
    # dark art: `activated.png` is a dark bronze triangle on black, so a fill
    # seeded from black corners walks straight through the subject.
    #
    # Instead each candidate is compared against the pixel it SPREAD FROM. A
    # smooth vignette drifts a little per step and is followed; the hard edge
    # of the badge is a large single-step jump and stops the fill dead.
    $seen  = New-Object 'bool[]' ($W * $H)
    $stack = New-Object System.Collections.Generic.Stack[int[]]

    # seed from every border pixel, each carrying its own colour
    for ($x = 0; $x -lt $W; $x++) {
        $i = Idx $x 0;        $stack.Push(@(($x), 0, $bytes[$i+2], $bytes[$i+1], $bytes[$i]))
        $i = Idx $x ($H-1);   $stack.Push(@(($x), ($H-1), $bytes[$i+2], $bytes[$i+1], $bytes[$i]))
    }
    for ($y = 0; $y -lt $H; $y++) {
        $i = Idx 0 $y;        $stack.Push(@(0, ($y), $bytes[$i+2], $bytes[$i+1], $bytes[$i]))
        $i = Idx ($W-1) $y;   $stack.Push(@(($W-1), ($y), $bytes[$i+2], $bytes[$i+1], $bytes[$i]))
    }

    while ($stack.Count -gt 0) {
        $n = $stack.Pop()
        $x = $n[0]; $y = $n[1]
        if ($x -lt 0 -or $y -lt 0 -or $x -ge $W -or $y -ge $H) { continue }
        $p = ($y * $W) + $x
        if ($seen[$p]) { continue }

        $i = Idx $x $y
        $dr = [Math]::Abs([int]$bytes[$i+2] - [int]$n[2])
        $dg = [Math]::Abs([int]$bytes[$i+1] - [int]$n[3])
        $db = [Math]::Abs([int]$bytes[$i]   - [int]$n[4])
        if (($dr + $dg + $db) -gt $TOL) { continue }   # hit an edge; stop here

        $seen[$p] = $true
        $r = $bytes[$i+2]; $g2 = $bytes[$i+1]; $b = $bytes[$i]
        $bytes[$i+3] = 0                                # transparent
        $stack.Push(@(($x-1), $y, $r, $g2, $b))
        $stack.Push(@(($x+1), $y, $r, $g2, $b))
        $stack.Push(@($x, ($y-1), $r, $g2, $b))
        $stack.Push(@($x, ($y+1), $r, $g2, $b))
    }

    # ---- opaque bounding box ------------------------------------------------
    $minX=$W; $minY=$H; $maxX=-1; $maxY=-1
    for ($y=0; $y -lt $H; $y++) {
        for ($x=0; $x -lt $W; $x++) {
            if ($bytes[(Idx $x $y) + 3] -gt 24) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
            }
        }
    }
    [System.Runtime.InteropServices.Marshal]::Copy($bytes, 0, $data.Scan0, $bytes.Length)
    $img.UnlockBits($data)

    if ($maxX -lt 0) { $minX=0; $minY=0; $maxX=$W-1; $maxY=$H-1 }
    $cw = $maxX - $minX + 1
    $ch = $maxY - $minY + 1

    # ---- letterbox onto a square transparent canvas -------------------------
    $canvas = New-Object System.Drawing.Bitmap $FINAL, $FINAL, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($canvas)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.Clear([System.Drawing.Color]::Transparent)
    $scale = [Math]::Min($FINAL / $cw, $FINAL / $ch)
    $dw = [int]($cw * $scale); $dh = [int]($ch * $scale)
    $dx = [int](($FINAL - $dw) / 2); $dy = [int](($FINAL - $dh) / 2)
    $g.DrawImage($img, (New-Object System.Drawing.Rectangle $dx, $dy, $dw, $dh),
                 $minX, $minY, $cw, $ch, [System.Drawing.GraphicsUnit]::Pixel)
    $g.Dispose()

    $dest = Join-Path $out $file.Name
    $canvas.Save($dest, [System.Drawing.Imaging.ImageFormat]::Png)
    $canvas.Dispose(); $img.Dispose()

    $before = [Math]::Round($file.Length / 1MB, 2)
    $after  = [Math]::Round((Get-Item $dest).Length / 1KB, 1)
    Write-Host ("  {0,-18} {1,6} MB -> {2,7} KB   crop {3}x{4}" -f $file.Name, $before, $after, $cw, $ch)
}

Write-Host ""
Write-Host ("Wrote {0} icons to {1}" -f (Get-ChildItem "$out\*.png").Count, $out)
