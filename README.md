# PSR to HTML Converter

Convert Windows Problem Steps Recorder (PSR) `.mht` or `.zip` files into
clean, modern, responsive HTML documentation --- perfect for manuals,
internal documentation, and customer guides.

![Screenshot](https://img.shields.io/badge/PowerShell-5.1+-blue)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey)
------------------------------------------------------------------------

## ✨ Purpose

Creating manuals or technical documentation from Windows PSR recordings
can be tedious and inconsistent.
This tool automates the process and transforms PSR recordings into
structured, visually appealing HTML pages.

It significantly simplifies the creation of:

-   📘 User manuals
-   📄 Internal documentation
-   🛠 Support instructions
-   📑 Step-by-step technical guides

Instead of manually extracting screenshots and formatting documents,
everything is generated automatically.

------------------------------------------------------------------------

## ✨ Features

-   🖼️ **Automatic image extraction** from PSR `.mht` files
-   📦 **ZIP support** -- processes directly downloaded PSR archives
-   🎨 **Modern UI design** with blue/green gradient theme
-   📱 **Responsive layout** (desktop & mobile ready)
-   🔍 **Lightbox feature** for screenshot zoom
-   📄 **Separated CSS file** for easy customization
-   ✅ **Full UTF-8 support** (including special characters & emojis)
-   ⚡ **Fast, fully automated workflow**

------------------------------------------------------------------------

## 📜 Prerequisites

-   Windows Problem Steps Recorder (PSR) installed
-   Press **Windows key + R**
-   ⌨️ Type `psr`
-   ↩️ Hit **Enter**
-   🔴 Click **Start Record**
-   💾 Save the file

------------------------------------------------------------------------

## 🚀 Installation

1.  Clone the repository or download `Convert-to-HTML.ps1` and `dragFileHere.bat`

2.  Open PowerShell and navigate to the script directory

3.  If you see a security warning, run:

    `Unblock-File .\Convert-to-HTML.ps1`

------------------------------------------------------------------------

## 📖 Usage

### Drag & Drop (Recommended)

Drag your saved PSR file onto `dragFileHere.bat`.

### Via PowerShell (ZIP file)
```powershell
    .\Convert-to-HTML.ps1 -InputFile "OutputfileFromPSR.zip"
```
### Via PowerShell (MHT file)
```powershell
    .\Convert-to-HTML.ps1 -InputFile "ExtractedOutputfileFromPSR.mht"
```
------------------------------------------------------------------------

## 📂 Output Structure

The script creates a folder named after the input file:

    Recording_20260213/
    ├── Klickfolge.html
    ├── style.css
    ├── screenshot0001.JPEG
    ├── screenshot0002.JPEG
    └── ...

The generated HTML file is ready to:

-   Share with customers
-   Upload to documentation portals
-   Integrate into knowledge bases
-   Host internally
-   Print as a manual (via browser)
-   Edit and/or customize

------------------------------------------------------------------------

## 🎨 Design

The generated documentation uses a modern card-based layout featuring:

-   Gradient background (blue ![#00058](https://placehold.co/10x10/00058a/00058a)`#00058a` → green ![#3ff245](https://placehold.co/10x10/3ff245/3ff245)`#3ff245`)
-   Clean step numbering with timestamps
-   Hover animations
-   Click-to-zoom screenshots
-   Keyboard navigation (ESC to close image view)
-   Professional visual structure suitable for manuals

------------------------------------------------------------------------

## 🔧 Customization

### Change Colors

Edit the generated `style.css` file:

    background: linear-gradient(135deg, #YOUR_COLOR1 0%, #YOUR_COLOR2 100%);

------------------------------------------------------------------------

## ⚙️ Technical Details

Processing workflow:

1.  ZIP detection
2.  Temporary extraction
3.  MHT parsing (XML metadata + Base64 images)
4.  HTML generation
5.  Automatic cleanup

Encoding:

-   Script: UTF-8 with BOM
-   Output: UTF-8 without BOM

------------------------------------------------------------------------

## 📋 System Requirements

-   Windows 10 or 11
-   PowerShell 5.1+
-   .NET Framework 4.5+

------------------------------------------------------------------------

## 📝 License

MIT License

------------------------------------------------------------------------

Developed to simplify and automate PSR-based documentation workflows.

