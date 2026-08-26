#!/usr/bin/env bash
# Convert Markdown files to AsciiDoc
# Keeps SECURITY.adoc and LICENSE files as-is per requirements

set -euo pipefail

echo "📝 Converting Markdown to AsciiDoc..."

# Files to convert
MD_FILES=(
    "README.md"
    "API.md"
    "CONTRIBUTING.md"
    "CODE_OF_CONDUCT.md"
    "CLAUDE.md"
    "MAINTAINERS.md"
    "CHANGELOG.md"
    "TPCF.md"
)

# Check for pandoc
if ! command -v pandoc &> /dev/null; then
    echo "⚠️  pandoc not found - attempting manual conversion"
    echo "   Install pandoc for better results: sudo apt install pandoc"

    # Manual conversion function (basic)
    convert_manual() {
        local md_file="$1"
        local adoc_file="${md_file%.md}.adoc"

        echo "  Converting $md_file → $adoc_file (manual)"

        # Basic sed-based conversion
        sed -e 's/^# \(.*\)/= \1/' \
            -e 's/^## \(.*\)/== \1/' \
            -e 's/^### \(.*\)/=== \1/' \
            -e 's/^#### \(.*\)/==== \1/' \
            -e 's/^##### \(.*\)/===== \1/' \
            -e 's/^\*\*\(.*\)\*\*/*\1*/' \
            -e 's/^- \(.*\)/\* \1/' \
            -e 's/^`\(.*\)`/`\1`/' \
            "$md_file" > "$adoc_file"

        # Keep original as backup
        mv "$md_file" "${md_file}.bak"
    }

    for md_file in "${MD_FILES[@]}"; do
        if [ -f "$md_file" ]; then
            convert_manual "$md_file"
        fi
    done
else
    echo "✅ Using pandoc for conversion"

    for md_file in "${MD_FILES[@]}"; do
        if [ -f "$md_file" ]; then
            adoc_file="${md_file%.md}.adoc"
            echo "  Converting $md_file → $adoc_file"
            pandoc -f markdown -t asciidoc "$md_file" -o "$adoc_file"

            # Keep original as backup
            mv "$md_file" "${md_file}.bak"
        fi
    done
fi

echo ""
echo "✅ Conversion complete!"
echo ""
echo "Converted files:"
for md_file in "${MD_FILES[@]}"; do
    adoc_file="${md_file%.md}.adoc"
    if [ -f "$adoc_file" ]; then
        echo "  ✓ $adoc_file"
    fi
done

echo ""
echo "Kept as Markdown (per requirements):"
echo "  • SECURITY.adoc"
echo "  • LICENSE"
echo ""
echo "Original .md files backed up with .md.bak extension"
