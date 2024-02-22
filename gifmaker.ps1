# Extension du fichier vidéo source
$extension = "mov"
# Version du gif (ajouté à la fin du nom du fichier)
$version = 4
# Taux de compression (0-200)
$lossy = 100
# Nombre d'images par seconde
$fps = 20
# Recréer le gif lors de l'exécution du script ?
$recreate = $false

# Le fichier .mov qui contient l'extrait à convertir en gif
$clipfile = (Get-Item "*.$extension")[0]
# Le nom de la vidéo
$name = [System.IO.Path]::GetFileNameWithoutExtension($clipfile)
# le nom du gif
$filename = "$name-v$version"

if ($recreate -eq $true) {
	if (Test-Path "frames") {
		Get-ChildItem -Path frames | Remove-Item -Force
	} else {
		New-Item -Path . -Name "frames" -ItemType "directory"
	}
	ffmpeg -hide_banner -loglevel error -i "$name.$extension" -vf "fps=$fps" frames/$name-%03d.png
	gifski --fps $fps --quality 100 --width 680 -o "$filename.gif" frames/$name-*.png
}
if ($lossy -gt 0) {
	gifsicle --optimize=3 --lossy=$lossy --output "$filename-lossy.gif" "$filename.gif"
	$filename += "-lossy"
}

# La taille (en Mo) du gif
$size = [string]::Format("{0:0.00}Mo", (Get-Item "$filename.gif").Length / 1MB).Replace(",", ".")
Write-Output "`n"
Write-Output $size