# Convert PNG to ICO for Electron App
# Usage: .\convert_to_ico.ps1

$inputPng = ".\src\assets\logo.png"
$outputIco = ".\src\assets\logo.ico"

Write-Host "Converting PNG to ICO..." -ForegroundColor Cyan

# Load System.Drawing assembly
Add-Type -AssemblyName System.Drawing

# Load the PNG image
if (-not (Test-Path $inputPng)) {
    Write-Host "Error: $inputPng not found!" -ForegroundColor Red
    exit 1
}

$image = [System.Drawing.Image]::FromFile((Resolve-Path $inputPng))

# Create a bitmap with desired size (256x256 is standard for Windows)
$size = 256
$bitmap = New-Object System.Drawing.Bitmap $size, $size

# Draw the original image onto the bitmap (resize)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.DrawImage($image, 0, 0, $size, $size)
$graphics.Dispose()

# Save as ICO
try {
    $iconStream = New-Object System.IO.MemoryStream
    $bitmap.Save($iconStream, [System.Drawing.Imaging.ImageFormat]::Png)
    
    # Simple single-size ICO conversion
    $bitmap.Save($outputIco, [System.Drawing.Imaging.ImageFormat]::Icon)
    
    Write-Host "Success! ICO file created: $outputIco" -ForegroundColor Green
    Write-Host "Size: $((Get-Item $outputIco).Length / 1KB) KB" -ForegroundColor Yellow
}
catch {
    Write-Host "Error creating ICO: $_" -ForegroundColor Red
}
finally {
    $image.Dispose()
    $bitmap.Dispose()
}
