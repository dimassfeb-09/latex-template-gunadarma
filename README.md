# Template Skripsi Universitas Gunadarma (LaTeX)

Template ini dirancang untuk memudahkan mahasiswa Universitas Gunadarma dalam menyusun dokumen skripsi menggunakan LaTeX sesuai dengan pedoman penulisan terbaru.

## Persiapan & Instalasi

Untuk dapat menggunakan template ini, Anda perlu menginstal distribusi LaTeX dan editor teks yang mendukung.

### 1. Instalasi Distribusi LaTeX

Pilih salah satu sesuai sistem operasi Anda:

- **Windows:** [MiKTeX](https://miktex.org/download) atau [TeX Live](https://www.tug.org/texlive/).
- **macOS:** [MacTeX](https://www.tug.org/mactex/).
- **Linux:** Gunakan package manager (contoh: `sudo apt install texlive-full`).

### 2. Instalasi Editor (IDE)

Gunakan **VS Code** dengan ekstensi **LaTeX Workshop** (Sangat Direkomendasikan) untuk mendapatkan fitur terbaik seperti linting, autocomplete, dan preview otomatis.

### 3. Instalasi Perl (Direkomendasikan)

Perl diperlukan agar fitur otomatisasi seperti `latexmk` atau pembuatan indeks/glossary dapat berjalan dengan lancar di Windows.

- Download installer di: [strawberryperl.com](https://strawberryperl.com/).
- Pilih versi **Recommended (64-bit MSI)**.
- Jalankan installer dan ikuti instruksi hingga selesai.
- Verifikasi dengan menjalankan perintah `perl -v` di Terminal atau PowerShell.

---

## Cara Penggunaan

1. **Buka File Utama:** Selalu edit dan lakukan build dari file `main.tex`.
2. **Struktur Folder:**
   - `frontmatter/`: Berisi Cover, Abstrak, Pengesahan, dll.
   - `chapters/`: Berisi isi skripsi (Bab 1 - Bab 5).
   - `assets/`: Tempat menyimpan gambar dan logo.
   - `resources/`: Berisi file `.bib` untuk daftar pustaka.

---

## Cara Build (Compile)

### Menggunakan VS Code (LaTeX Workshop)

1. Buka folder template di VS Code.
2. Buka file `main.tex`.
3. Tekan `Ctrl + Alt + B` untuk melakukan build.
4. Tekan `Ctrl + Alt + V` untuk melihat PDF hasil build.

### Menggunakan Command Line (Manual)

Jika Anda menggunakan MiKTeX/TeX Live secara manual, jalankan urutan berikut di terminal:

```bash
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```

_Catatan: Menjalankan `pdflatex` beberapa kali diperlukan agar daftar isi dan sitasi terupdate dengan benar._

### Menggunakan Latexmk (Otomatis)

Jika `latexmk` terinstal, cukup jalankan:

```bash
latexmk -pdf main.tex
```

### Menggunakan PowerShell (Incremental Build)

Template ini menyertakan script `build.ps1` untuk melakukan build per bab (incremental):

```powershell
# Build Draft 1 (Hanya Bab 1)
.\build.ps1 -Draft 1

# Build Lengkap (Sampai Bab 5)
.\build.ps1 -Draft 5
```

Script ini akan otomatis memfilter daftar pustaka hanya untuk bab yang sedang di-build dan menyimpan hasilnya di folder `dist/`.

---

## Tips Pengeditan

- **Tahun Otomatis:** Tahun di cover dan abstrak sudah diatur menggunakan `\the\year`, sehingga akan selalu mengikuti tahun saat ini.
- **Identitas:** Ubah placeholder `[NAMA ANDA]`, `[NPM ANDA]`, dll. di dalam folder `frontmatter/`.
- **Gambar:** Gunakan format `\begin{figure} ... \end{figure}` dan letakkan file gambar di folder `assets/`.
- **Daftar Pustaka:** Tambahkan referensi Anda di `resources/DAFTAR_PUSTAKA.bib`.

---

_Dibuat untuk mempermudah pejuang skripsi Gunadarma! Selamat mengerjakan._
