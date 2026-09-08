#!/bin/bash

set -e

PDF_DIR="./pdfs"
mkdir -p "$PDF_DIR"

PDF_DIR_ABS="$(cd "$PDF_DIR" && pwd)"

echo "========================================"
echo "Typora Markdown → PDF"
echo "Output: $PDF_DIR"
echo "========================================"

for file in *.md; do

    name="${file%.md}"
    output="$PDF_DIR/$name.pdf"

    echo
    echo "Exporting: $file"

    # Open Markdown file in Typora
    open -a "Typora" "$PWD/$file"

    # Give Typora time to load
    sleep 2

    # File → Export → PDF
    osascript <<APPLESCRIPT

tell application "Typora"
    activate
end tell

tell application "System Events"
    tell process "Typora"

        click menu bar item "File" of menu bar 1

        delay 0.5

        click menu item "Export" of menu 1 of menu bar item "File" of menu bar 1

        delay 0.5

        click menu item "PDF" of menu 1 of menu item "Export" of menu 1 of menu bar item "File" of menu bar 1

    end tell
end tell

APPLESCRIPT

    # Wait for Export/Save dialog
    sleep 2

    osascript <<APPLESCRIPT

tell application "System Events"
    tell process "Typora"

        -- Go to ./pdfs
        keystroke "g" using {command down, shift down}

        delay 1

        keystroke "$PDF_DIR_ABS"

        delay 0.5

        keystroke return

        delay 1

        -- IMPORTANT:
        -- Do NOT type the filename.
        -- Typora has already supplied "filename.pdf".

        keystroke return

    end tell
end tell

APPLESCRIPT

    # Wait for PDF
    echo "Waiting for PDF..."

    for i in {1..30}; do
        if [ -f "$output" ]; then
            echo "✓ Created: $output"
            break
        fi
        sleep 1
    done

    if [ ! -f "$output" ]; then
        echo "✗ Failed: $file"
        exit 1
    fi

    # Close the document
    osascript <<'APPLESCRIPT'
tell application "Typora"
    activate
end tell

tell application "System Events"
    tell process "Typora"
        keystroke "w" using command down
    end tell
end tell
APPLESCRIPT

    sleep 1

done

echo
echo "========================================"
echo "✓ ALL PDFs CREATED"
echo "========================================"