<#
.SYNOPSIS
Script untuk mem-build Skripsi secara incremental (Draft 1, Draft 2, dst).

.DESCRIPTION
Konsep Incremental Draft:
  - Draft 1: Cover + BAB I + Daftar Pustaka (hanya referensi BAB I)
  - Draft 2: Cover + BAB I + BAB II + Daftar Pustaka (referensi BAB I & II)
  - ...dan seterusnya.

Daftar pustaka otomatis hanya berisi referensi yang dikutip di BAB yang disertakan.

.PARAMETER Draft
Urutan Nomor Draft (misal: 1, 2, 3, 4, 5). Default: 1.

.EXAMPLE
.\build.ps1 -Draft 5
Mem-build Draft 5 (lengkap semua bab)
#>

param(
    [ValidateRange(1, 5)]
    [int]$Draft = 1
)

$ErrorActionPreference = "Stop"

# ============================================================================
# KONFIGURASI
# ============================================================================
$jobName    = "NPM_NAMA_PRODI_Draft_$Draft"
$outDir     = "dist"
$mainTex    = "main.tex"
$draftTex   = "$outDir/draft_main.tex"  # File .tex sementara khusus draft ini

# ============================================================================
# VALIDASI: Cek apakah file BAB yang dibutuhkan ada
# ============================================================================
$missingChapters = @()
for ($i = 1; $i -le $Draft; $i++) {
    $chapFile = "chapters/BAB$i.tex"
    if (-Not (Test-Path $chapFile)) {
        $missingChapters += "BAB$i.tex"
    }
}

if ($missingChapters.Count -gt 0) {
    Write-Host "ERROR: File berikut belum tersedia:" -ForegroundColor Red
    foreach ($mc in $missingChapters) {
        Write-Host "  - chapters/$mc" -ForegroundColor Red
    }
    Write-Host "`nDraft $Draft membutuhkan BAB 1 s.d. BAB $Draft." -ForegroundColor Yellow
    exit 1
}

# ============================================================================
# PERSIAPAN DIREKTORI OUTPUT
# ============================================================================
$subDirs = @("$outDir", "$outDir/frontmatter", "$outDir/chapters")
foreach ($dir in $subDirs) {
    if (-Not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# ============================================================================
# BERSIHKAN CACHE BUILD SEBELUMNYA
# ============================================================================
$cacheExtensions = @("*.aux", "*.bbl", "*.blg", "*.toc", "*.out", "*.log", "*.lof", "*.lot", "*.fls", "*.fdb_latexmk", "*.synctex.gz")
if (Test-Path $outDir) {
    Get-ChildItem -Path $outDir -Recurse -Include $cacheExtensions -ErrorAction SilentlyContinue | Remove-Item -Force
}

# ============================================================================
# GENERATE FILE .TEX SEMENTARA UNTUK DRAFT INI
# ============================================================================

# Bangun daftar \include untuk BAB aktif
$babIncludes = ""
for ($i = 1; $i -le $Draft; $i++) {
    $babIncludes += "\include{chapters/BAB$i}`r`n"
}

# Bangun daftar \includeonly
$includeOnlyList = "frontmatter/COVER"
for ($i = 1; $i -le $Draft; $i++) {
    $includeOnlyList += ",chapters/BAB$i"
}
$includeOnlyList += ",chapters/DAFTAR_PUSTAKA"

# Baca template utama
$templateContent = Get-Content -Path $mainTex -Raw

# Hapus blok \includeonly yang sudah ada
$templateContent = $templateContent -replace '(?s)%?\s*\\includeonly\{[^}]*\}', ''

# Ganti blok BAB
$templateContent = $templateContent -replace '(?m)(\\include\{chapters/BAB\d\}\r?\n?)+', $babIncludes

# Sisipkan \includeonly tepat sebelum \begin{document}
$includeOnlyDirective = "\includeonly{$includeOnlyList}`r`n"
$templateContent = $templateContent -replace '(\\begin\{document\})', "$includeOnlyDirective`$1"

# Tulis file draft sementara
$templateContent | Out-File -FilePath $draftTex -Encoding UTF8 -NoNewline

# ============================================================================
# INFO BUILD
# ============================================================================
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "        SKRIPSI LATEX BUILDER" -ForegroundColor Cyan
Write-Host "         Incremental Draft $Draft" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# ============================================================================
# PROSES KOMPILASI
# ============================================================================
Write-Host "`n[1/4] PDFLaTeX pass 1..." -ForegroundColor Green
pdflatex -output-directory="$outDir" -interaction=nonstopmode -jobname="$jobName" "$draftTex" | Out-Null

Write-Host "[2/4] BibTeX..." -ForegroundColor Green
bibtex "$outDir/$jobName" 2>&1 | Out-Null

Write-Host "[3/4] PDFLaTeX pass 2..." -ForegroundColor Green
pdflatex -output-directory="$outDir" -interaction=nonstopmode -jobname="$jobName" "$draftTex" | Out-Null

Write-Host "[4/4] PDFLaTeX pass 3..." -ForegroundColor Green
pdflatex -output-directory="$outDir" -interaction=nonstopmode -jobname="$jobName" "$draftTex" | Out-Null

# ============================================================================
# HASIL
# ============================================================================
Write-Host ""
Write-Host "------------------------------------------" -ForegroundColor Cyan
if (Test-Path "$outDir/$jobName.pdf") {
    Write-Host "SUCCESS! Draft $Draft berhasil di-build." -ForegroundColor Green
    Write-Host "File: $outDir\$jobName.pdf" -ForegroundColor Green
} else {
    Write-Host "ERROR: Gagal mem-build PDF." -ForegroundColor Red
    exit 1
}

# Bersihkan file draft sementara
Remove-Item -Path $draftTex -Force -ErrorAction SilentlyContinue
Write-Host ""
