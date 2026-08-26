#!/usr/bin/env bash
# bootstrap-arch-wsl.sh --- Set up a fresh Arch-on-WSL install for this Emacs config
#
# Installs the system packages and fonts this config depends on, clones/links
# the config into place, and does a headless first-run to pre-install the
# Elisp packages. Safe to re-run.
#
# Usage: ./bootstrap-arch-wsl.sh

set -euo pipefail

CONFIG_REPO="https://github.com/sangeethvarma/emacs.git"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/emacs"

log() { printf '\n\033[1;32m==>\033[0m %s\n' "$1"; }
warn() { printf '\n\033[1;33m!!\033[0m %s\n' "$1"; }

if ! grep -qi microsoft /proc/version 2>/dev/null; then
    warn "This doesn't look like WSL (/proc/version has no 'microsoft'). Continuing anyway."
fi

# --- 1. Base system + build toolchain -------------------------------------
# base-devel: gcc/make/etc, needed to build pdf-tools' epdfinfo and jinx's
# enchant dynamic module on first `emacs -q` run.
log "Updating system and installing base packages"
sudo pacman -Syu --needed --noconfirm \
    base-devel git curl

# --- 2. Emacs itself --------------------------------------------------------
# Official Arch `emacs` package ships native-comp + tree-sitter already built in.
log "Installing Emacs"
sudo pacman -S --needed --noconfirm emacs

# --- 3. Config dependencies --------------------------------------------------
log "Installing packages this config depends on"
sudo pacman -S --needed --noconfirm \
    ripgrep \
    aspell aspell-en \
    enchant pkgconf \
    poppler automake autoconf libpng \
    imagemagick \
    fontconfig \
    texlive-basic texlive-bin texlive-binextra \
    texlive-latex texlive-latexextra texlive-latexrecommended \
    texlive-bibtexextra texlive-fontsrecommended texlive-fontsextra \
    ttf-nerd-fonts-symbols-mono

# What each is for:
#   ripgrep                 -> consult-ripgrep (san-completions.el)
#   aspell/aspell-en         -> ispell backend (san-init.el san/check-spell-checker)
#   enchant, pkgconf         -> jinx spell-checking (compiles a dynamic module)
#   poppler/automake/
#     autoconf/libpng        -> pdf-tools compiles epdfinfo against these (san-view-files.el)
#   imagemagick              -> image-dired thumbnails (whiteboard gallery, org-download)
#   texlive-*                -> latexmk + bibtex for org-latex PDF export (san-org-latex.el,
#                               san-citation.el). NOTE: the "diazessay" LaTeX class used in
#                               san-org-latex.el is NOT in these package groups -- install it
#                               manually from CTAN (https://ctan.org/pkg/diazessay) into
#                               ~/texmf/tex/latex/diazessay/ if PDF export fails with a
#                               "diazessay.cls not found" error.
#   ttf-nerd-fonts-symbols-mono -> "Symbols Nerd Font Mono" fontset (san-fonts.el,
#                               doom-modeline/nerd-icons glyphs)

# --- 4. wslu (wslpath, wslview) ---------------------------------------------
# wslpath is used by san-org-latex.el (SumatraPDF) and san-org-images.el
# (clipboard screenshot capture). It isn't in the official repos; it's an AUR
# package, which needs an AUR helper. If you don't have one, this step just
# warns instead of trying to bootstrap yay unattended.
if command -v wslpath >/dev/null 2>&1; then
    log "wslpath already present, skipping wslu"
elif command -v yay >/dev/null 2>&1; then
    log "Installing wslu (AUR) for wslpath"
    yay -S --needed --noconfirm wslu
else
    warn "wslpath not found and no AUR helper detected."
    warn "Install an AUR helper (e.g. yay) then run: yay -S wslu"
    warn "Without it, org-download screenshot capture and SumatraPDF opening won't work."
fi

# --- 5. Malayalam font (Chilanka) -------------------------------------------
# Not packaged in the official Arch repos; pulled directly from Google Fonts.
# Used by san-fonts.el for the Malayalam Unicode block fallback.
FONT_DIR="$HOME/.local/share/fonts"
if [ ! -f "$FONT_DIR/Chilanka-Regular.ttf" ]; then
    log "Downloading Chilanka font"
    mkdir -p "$FONT_DIR"
    curl -fsSL -o "$FONT_DIR/Chilanka-Regular.ttf" \
        "https://raw.githubusercontent.com/google/fonts/main/ofl/chilanka/Chilanka-Regular.ttf"
    fc-cache -f "$FONT_DIR"
else
    log "Chilanka font already installed, skipping"
fi

# --- 6. Clone/link the config -----------------------------------------------
if [ -d "$CONFIG_DIR/.git" ]; then
    log "Config already present at $CONFIG_DIR, skipping clone"
elif [ -e "$CONFIG_DIR" ]; then
    warn "$CONFIG_DIR exists but isn't a git repo -- leaving it alone. Move it aside and re-run if you want a fresh clone."
else
    log "Cloning config into $CONFIG_DIR"
    git clone "$CONFIG_REPO" "$CONFIG_DIR"
fi

# --- 7. Headless first run: pre-install all Elisp packages ------------------
# init.el's use-package :ensure t forms install everything from
# GNU ELPA/MELPA/NonGNU ELPA on first load; do that once here in batch mode
# so the first interactive launch isn't a multi-minute package-install wait.
log "Bootstrapping Elisp packages (this can take a few minutes)"
emacs --batch --eval "(progn (setq user-emacs-directory \"$CONFIG_DIR/\") (load (expand-file-name \"early-init.el\" user-emacs-directory)) (load (expand-file-name \"init.el\" user-emacs-directory)))" || \
    warn "Batch package bootstrap hit an error -- run 'emacs' interactively to see what's missing, package installs usually still succeed on the next launch."

log "Done. Remaining manual steps (see README.md):"
cat <<'EOF'
  - Mount/confirm the vault drive at /mnt/v (san-paths.el expects it).
  - Symlink your Better BibTeX .bib export to a space-free path:
      mkdir -p ~/.local/share/bib
      ln -sf "/mnt/v/Vault/2 - PhD/Resources/references.bib" ~/.local/share/bib/references.bib
  - Drop an OpenRouter API key at ~/.config/emacs/.openrouter-key (gitignored)
    if you want the OpenRouter gptel backend; without it, only the local
    Ollama backend is configured.
  - Install/run Ollama on the Windows host if you want san-llm.el's local
    models (qwen2.5-coder:3b, qwen2.5:1.5b, llama3.2).
  - Optional: SumatraPDF via scoop on Windows, for san/open-pdf-with-sumatra.
  - Optional: the Grasp web-capture backend at ~/.tools/grasp/.venv (san-notes.el)
    -- only started if that venv exists, so skip it if you don't use Grasp.
EOF
