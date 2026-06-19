Add-Type -AssemblyName System.Drawing

function Resize-Image {
    param (
        [string]$sourcePath,
        [string]$destinationPath,
        [int]$width,
        [int]$height
    )
    try {
        $srcImage = [System.Drawing.Image]::FromFile($sourcePath)
        $destImage = New-Object System.Drawing.Bitmap($width, $height)
        $graphics = [System.Drawing.Graphics]::FromImage($destImage)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.DrawImage($srcImage, 0, 0, $width, $height)
        $destImage.Save($destinationPath, [System.Drawing.Imaging.ImageFormat]::Png)
        $graphics.Dispose()
        $destImage.Dispose()
        $srcImage.Dispose()
        Write-Output "Successfully resized and saved to $destinationPath"
    } catch {
        Write-Error "Failed resizing to $destinationPath. Error: $_"
    }
}

$source = "C:\Users\shafe\.gemini\antigravity\brain\bb4067fc-8077-4152-973c-eba135bd335e\media__1781848920680.png"

Resize-Image -sourcePath $source -destinationPath "d:\PortfolioMUOP\web\favicon.png" -width 32 -height 32
Resize-Image -sourcePath $source -destinationPath "d:\PortfolioMUOP\web\icons\Icon-192.png" -width 192 -height 192
Resize-Image -sourcePath $source -destinationPath "d:\PortfolioMUOP\web\icons\Icon-512.png" -width 512 -height 512
Resize-Image -sourcePath $source -destinationPath "d:\PortfolioMUOP\web\icons\Icon-maskable-192.png" -width 192 -height 192
Resize-Image -sourcePath $source -destinationPath "d:\PortfolioMUOP\web\icons\Icon-maskable-512.png" -width 512 -height 512
