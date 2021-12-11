#This is an imported script I pulled from the internet.
$setwallpapersrc = @"
using System.Runtime.InteropServices;

public class Wallpaper
{
  public const int SetDesktopWallpaper = 20;
  public const int UpdateIniFile = 0x01;
  public const int SendWinIniChange = 0x02;
  [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
  private static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
  public static void SetWallpaper(string path)
  {
    SystemParametersInfo(SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange);
  }
}
"@
Add-Type -TypeDefinition $setwallpapersrc

Write-Output "Getting latest images"
#You can change the Sector here to change to a different region. Go to the NOAA website to find the sectors
$sector = "se"
#You can change the map type to get different tpyes of maps. Go to the NOAA website to find the types
$mapType = "GEOCOLOR"

$url = "https://www.star.nesdis.noaa.gov/GOES/sector.php?sat=G16&sector=" + $sector
$searchUrl = "https://cdn.star.nesdis.noaa.gov/GOES16/ABI/SECTOR/" + $sector + "/" + $mapType

#Get the image page from NOAA
$response = Invoke-WebRequest -Uri $url
#Grab all links on the screen
$links = $response.links
$imageLinks = @()

#Need to find the right image links based on what we want
foreach ($item in $links)
{
    $href = $item.href
   
    #If we match the search URL, add it to the list
    if (($href -ne $Null) -and $href.startswith($searchUrl))
        {
            $imageLinks += $item.href
        }
}

$image = ""
#I'm pulling the 2400x2400 image which is the fifth in the list
if ($imageLinks.count -gt 5)
{
    $image = $imageLinks[4]
}

if ($image -ne "")
{
    #Find the current location, and get ready to create a file of the image
    $location = Get-Location
    $localImage = $location.Path + "\image.jpg"
    Write-Output "Getting Image"
    $x =Invoke-WebRequest -Uri $image -OutFile $localImage
    Write-Output "Setting Image"
    [Wallpaper]::SetWallpaper($localImage)
}