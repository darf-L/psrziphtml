param(
    [Parameter(Mandatory=$true)]
    [string]$InputFile
)

# Konvertiere relative Pfade zu absoluten Pfaden
$InputFile = (Resolve-Path $InputFile).Path
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Prüfe ob es eine ZIP-Datei ist
$isZipFile = $InputFile -like "*.zip"
$mhtFile = $InputFile
$tempExtractPath = $null
$OutputFolder = $null

if ($isZipFile) {
    Write-Host "ZIP-Datei erkannt: $InputFile" -ForegroundColor Cyan
    
    # Output-Ordner basierend auf ZIP-Namen erstellen
    $zipBaseName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
    $OutputFolder = Join-Path $scriptDir $zipBaseName
    
    # Temp-Ordner für Entpacken
    $tempExtractPath = Join-Path $scriptDir "temp_extract_$(Get-Random)"
    New-Item -ItemType Directory -Path $tempExtractPath -Force | Out-Null
    
    Write-Host "Entpacke ZIP nach: $tempExtractPath" -ForegroundColor Cyan
    
    # ZIP entpacken
    Expand-Archive -Path $InputFile -DestinationPath $tempExtractPath -Force
    
    # Finde die .mht Datei im entpackten Ordner
    $mhtFiles = Get-ChildItem -Path $tempExtractPath -Filter "*.mht" -Recurse
    
    if ($mhtFiles.Count -eq 0) {
        Write-Host "FEHLER: Keine .mht Datei in der ZIP gefunden!" -ForegroundColor Red
        Remove-Item -Path $tempExtractPath -Recurse -Force
        exit 1
    }
    
    $mhtFile = $mhtFiles[0].FullName
    Write-Host "Gefundene MHT-Datei: $mhtFile" -ForegroundColor Green
    Write-Host ""
}
else {
    # Kein ZIP - normaler Flow
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
    $parentDir = Split-Path -Parent $InputFile
    $OutputFolder = Join-Path $parentDir $baseName
}

# Ausgabeordner erstellen
New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null

Write-Host "Starte Extraktion aus: $mhtFile" -ForegroundColor Cyan
Write-Host "Ausgabe nach: $OutputFolder" -ForegroundColor Cyan
Write-Host ""

# XML parsen um Step-Informationen zu bekommen
$content = Get-Content $mhtFile -Raw -Encoding UTF8
$xmlMatch = $content -match '(?s)<Report>.*?</Report>'
if ($xmlMatch) {
    $xmlContent = $Matches[0]
    [xml]$xml = $xmlContent
}

# Bilder extrahieren
$reader = [System.IO.StreamReader]::new($mhtFile, [System.Text.Encoding]::UTF8)
$currentFile = $null
$collecting = $false
$base64Lines = [System.Collections.ArrayList]@()
$imageCount = 0
$extractedImages = @()

while (($line = $reader.ReadLine()) -ne $null) {
    
    if ($line -like "Content-Type: image/*") {
        if ($collecting -and $currentFile -and $base64Lines.Count -gt 0) {
            $imageCount++
            $cleanBase64 = ($base64Lines -join "") -replace "\s",""
            try {
                $bytes = [Convert]::FromBase64String($cleanBase64)
                $outPath = Join-Path $OutputFolder $currentFile
                [IO.File]::WriteAllBytes($outPath, $bytes)
                $extractedImages += $currentFile
                Write-Host "[OK] [$imageCount] $currentFile gespeichert ($($bytes.Length) Bytes)"
            }
            catch {
                Write-Host "[FEHLER] bei $currentFile : $_" -ForegroundColor Red
            }
        }
        $collecting = $false
        $base64Lines.Clear()
        $currentFile = $null
        continue
    }

    if ($line -like "Content-Location:*") {
        $currentFile = ($line -replace "Content-Location:\s*", "").Trim()
        continue
    }

    if ($line -like "Content-Transfer-Encoding: base64*") {
        $collecting = $true
        continue
    }

    if ($collecting -and $line.Trim() -eq "") {
        continue
    }

    if ($collecting) {
        if ($line.StartsWith("--=")) {
            if ($currentFile -and $base64Lines.Count -gt 0) {
                $imageCount++
                $cleanBase64 = ($base64Lines -join "") -replace "\s",""
                try {
                    $bytes = [Convert]::FromBase64String($cleanBase64)
                    $outPath = Join-Path $OutputFolder $currentFile
                    [IO.File]::WriteAllBytes($outPath, $bytes)
                    $extractedImages += $currentFile
                    Write-Host "[OK] [$imageCount] $currentFile gespeichert ($($bytes.Length) Bytes)"
                }
                catch {
                    Write-Host "[FEHLER] bei $currentFile : $_" -ForegroundColor Red
                }
            }
            $collecting = $false
            $base64Lines.Clear()
            $currentFile = $null
            continue
        }
        [void]$base64Lines.Add($line.Trim())
    }
}

if ($collecting -and $currentFile -and $base64Lines.Count -gt 0) {
    $imageCount++
    $cleanBase64 = ($base64Lines -join "") -replace "\s",""
    try {
        $bytes = [Convert]::FromBase64String($cleanBase64)
        $outPath = Join-Path $OutputFolder $currentFile
        [IO.File]::WriteAllBytes($outPath, $bytes)
        $extractedImages += $currentFile
        Write-Host "[OK] [$imageCount] $currentFile gespeichert ($($bytes.Length) Bytes)"
    }
    catch {
        Write-Host "[FEHLER] bei $currentFile : $_" -ForegroundColor Red
    }
}

$reader.Close()

# HTML generieren mit modernem Design
Write-Host ""
Write-Host "Generiere HTML-Datei..." -ForegroundColor Cyan

$steps = @()
if ($xml) {
    $actions = $xml.Report.UserActionData.RecordSession.EachAction
    foreach ($action in $actions) {
        $stepNum = $action.ActionNumber
        $time = $action.Time
        $description = $action.Description
        $screenshot = $action.ScreenshotFileName
        
        $steps += @{
            Number = $stepNum
            Time = $time
            Description = $description
            Screenshot = $screenshot
        }
    }
}

# CSS Datei erstellen
$cssContent = @'
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
    background: linear-gradient(135deg, #00058a 0%, #3ff245 100%);
    min-height: 100vh;
    padding: 40px 20px;
    color: #333;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
}

header {
    background: white;
    padding: 30px 40px;
    border-radius: 15px;
    box-shadow: 0 10px 30px rgba(0,0,0,0.2);
    margin-bottom: 30px;
}

h1 {
    color: #00058a;
    font-size: 2.5em;
    margin-bottom: 10px;
    font-weight: 700;
}

.subtitle {
    color: #666;
    font-size: 1.1em;
}

.step-card {
    background: white;
    border-radius: 15px;
    padding: 30px;
    margin-bottom: 25px;
    box-shadow: 0 5px 20px rgba(0,0,0,0.1);
    transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.step-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 30px rgba(0,0,0,0.15);
}

.step-header {
    display: flex;
    align-items: center;
    gap: 15px;
    margin-bottom: 20px;
}

.step-number {
    background: linear-gradient(135deg, #00058a 0%, #3ff245 100%);
    color: white;
    width: 50px;
    height: 50px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.5em;
    font-weight: bold;
    flex-shrink: 0;
}

.step-info {
    flex: 1;
}

.step-time {
    color: #999;
    font-size: 0.9em;
    margin-bottom: 5px;
}

.step-description {
    color: #333;
    font-size: 1.1em;
    line-height: 1.5;
}

.screenshot-container {
    margin-top: 20px;
    border-radius: 10px;
    overflow: hidden;
    border: 3px solid #f0f0f0;
    cursor: pointer;
    position: relative;
}

.screenshot-container img {
    width: 100%;
    height: auto;
    display: block;
    transition: transform 0.3s ease;
}

.screenshot-container:hover img {
    transform: scale(1.02);
}

.zoom-hint {
    position: absolute;
    bottom: 15px;
    right: 15px;
    background: rgba(0,0,0,0.7);
    color: white;
    padding: 8px 15px;
    border-radius: 20px;
    font-size: 0.85em;
    pointer-events: none;
    opacity: 0;
    transition: opacity 0.3s ease;
}

.screenshot-container:hover .zoom-hint {
    opacity: 1;
}

.lightbox {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.95);
    z-index: 1000;
    align-items: center;
    justify-content: center;
    padding: 20px;
}

.lightbox.active {
    display: flex;
}

.lightbox img {
    max-width: 95%;
    max-height: 95vh;
    border-radius: 10px;
    box-shadow: 0 10px 50px rgba(0,0,0,0.5);
}

.lightbox-close {
    position: absolute;
    top: 20px;
    right: 30px;
    color: white;
    font-size: 40px;
    cursor: pointer;
    background: rgba(255,255,255,0.1);
    width: 50px;
    height: 50px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: background 0.3s ease;
}

.lightbox-close:hover {
    background: rgba(255,255,255,0.2);
}

@media (max-width: 768px) {
    body {
        padding: 20px 10px;
    }
    
    h1 {
        font-size: 1.8em;
    }
    
    .step-card {
        padding: 20px;
    }
}
'@

$cssPath = Join-Path $OutputFolder "style.css"
Set-Content -Path $cssPath -Value $cssContent -Encoding UTF8

# HTML Datei erstellen - Beginn
$htmlBuilder = [System.Text.StringBuilder]::new()
[void]$htmlBuilder.AppendLine('<!DOCTYPE html>')
[void]$htmlBuilder.AppendLine('<html lang="de">')
[void]$htmlBuilder.AppendLine('<head>')
[void]$htmlBuilder.AppendLine('    <meta charset="UTF-8">')
[void]$htmlBuilder.AppendLine('    <meta name="viewport" content="width=device-width, initial-scale=1.0">')
[void]$htmlBuilder.AppendLine('    <title>Aufgezeichnete Schritte - Klickfolge</title>')
[void]$htmlBuilder.AppendLine('    <link rel="stylesheet" href="style.css">')
[void]$htmlBuilder.AppendLine('</head>')
[void]$htmlBuilder.AppendLine('<body>')
[void]$htmlBuilder.AppendLine('    <div class="container">')
[void]$htmlBuilder.AppendLine('        <header>')
[void]$htmlBuilder.AppendLine('            <h1>🖱️ Aufgezeichnete Schritte</h1>')
[void]$htmlBuilder.AppendLine('            <p class="subtitle">Klickfolge-Dokumentation</p>')
[void]$htmlBuilder.AppendLine('        </header>')

# Steps hinzufuegen
$zoomHintText = "🔍 Klicken zum Vergrößern"
foreach ($step in $steps) {
    [void]$htmlBuilder.AppendLine('')
    [void]$htmlBuilder.AppendLine('        <div class="step-card">')
    [void]$htmlBuilder.AppendLine('            <div class="step-header">')
    [void]$htmlBuilder.AppendLine("                <div class=`"step-number`">$($step.Number)</div>")
    [void]$htmlBuilder.AppendLine('                <div class="step-info">')
    [void]$htmlBuilder.AppendLine("                    <div class=`"step-time`">⏰ $($step.Time)</div>")
    [void]$htmlBuilder.AppendLine("                    <div class=`"step-description`">$($step.Description)</div>")
    [void]$htmlBuilder.AppendLine('                </div>')
    [void]$htmlBuilder.AppendLine('            </div>')
    [void]$htmlBuilder.AppendLine("            <div class=`"screenshot-container`" onclick=`"openLightbox('$($step.Screenshot)')`">")
    [void]$htmlBuilder.AppendLine("                <img src=`"$($step.Screenshot)`" alt=`"Screenshot Schritt $($step.Number)`">")
    [void]$htmlBuilder.AppendLine("                <div class=`"zoom-hint`">$zoomHintText</div>")
    [void]$htmlBuilder.AppendLine('            </div>')
    [void]$htmlBuilder.AppendLine('        </div>')
}

# HTML Ende
$vergroessertText = "Vergrößerte Ansicht"
[void]$htmlBuilder.AppendLine('')
[void]$htmlBuilder.AppendLine('    </div>')
[void]$htmlBuilder.AppendLine('    ')
[void]$htmlBuilder.AppendLine('    <div class="lightbox" id="lightbox" onclick="closeLightbox()">')
[void]$htmlBuilder.AppendLine('        <span class="lightbox-close">&times;</span>')
[void]$htmlBuilder.AppendLine("        <img id=`"lightbox-img`" src=`"`" alt=`"$vergroessertText`">")
[void]$htmlBuilder.AppendLine('    </div>')
[void]$htmlBuilder.AppendLine('    ')
[void]$htmlBuilder.AppendLine('    <script>')
[void]$htmlBuilder.AppendLine('        function openLightbox(imgSrc) {')
[void]$htmlBuilder.AppendLine("            document.getElementById('lightbox').classList.add('active');")
[void]$htmlBuilder.AppendLine("            document.getElementById('lightbox-img').src = imgSrc;")
[void]$htmlBuilder.AppendLine("            document.body.style.overflow = 'hidden';")
[void]$htmlBuilder.AppendLine('        }')
[void]$htmlBuilder.AppendLine('        ')
[void]$htmlBuilder.AppendLine('        function closeLightbox() {')
[void]$htmlBuilder.AppendLine("            document.getElementById('lightbox').classList.remove('active');")
[void]$htmlBuilder.AppendLine("            document.body.style.overflow = 'auto';")
[void]$htmlBuilder.AppendLine('        }')
[void]$htmlBuilder.AppendLine('        ')
[void]$htmlBuilder.AppendLine("        document.addEventListener('keydown', function(e) {")
[void]$htmlBuilder.AppendLine("            if (e.key === 'Escape') {")
[void]$htmlBuilder.AppendLine('                closeLightbox();')
[void]$htmlBuilder.AppendLine('            }')
[void]$htmlBuilder.AppendLine('        });')
[void]$htmlBuilder.AppendLine('    </script>')
[void]$htmlBuilder.AppendLine('</body>')
[void]$htmlBuilder.AppendLine('</html>')

$htmlPath = Join-Path $OutputFolder "Klickfolge.html"
Set-Content -Path $htmlPath -Value $htmlBuilder.ToString() -Encoding UTF8

Write-Host "[OK] HTML-Datei erstellt: Klickfolge.html" -ForegroundColor Green
Write-Host "[OK] CSS-Datei erstellt: style.css" -ForegroundColor Green

# Temp-Ordner aufräumen falls ZIP verwendet wurde
if ($tempExtractPath -and (Test-Path $tempExtractPath)) {
    Write-Host ""
    Write-Host "Räume temporäre Dateien auf..." -ForegroundColor Cyan
    Remove-Item -Path $tempExtractPath -Recurse -Force
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Fertig! $imageCount Bild(er) extrahiert" -ForegroundColor Green
Write-Host "Ausgabe: $OutputFolder" -ForegroundColor Green
Write-Host "HTML-Datei: Klickfolge.html" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
