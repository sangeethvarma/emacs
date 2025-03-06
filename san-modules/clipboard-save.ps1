param(
  [Parameter(Mandatory)][string]$fileName
)
$filePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($fileName)
Add-Type -AssemblyName System.Windows.Forms;
if ($([System.Windows.Forms.Clipboard]::ContainsImage()))
{$image = [System.Windows.Forms.Clipboard]::GetImage();
 [System.Drawing.Bitmap]$image.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png);
 Write-Output 'clipboard content saved as file'
 exit 0}
else
{Write-Output 'clipboard does not contain image data'
 exit 1}

