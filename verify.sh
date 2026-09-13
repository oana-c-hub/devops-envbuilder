#!/bin/bash

echo "=========================================="
echo "  Verificare Instalare Tehnologii DevOps  "
echo "=========================================="

VARS_FILE="config/vars.json"

# Verificăm dacă fișierul de variabile generat la validare există
if [ ! -f "$VARS_FILE" ]; then
    echo "❌ Eroare: Fișierul '$VARS_FILE' nu a fost găsit!"
    exit 1
fi

ERRORS=0

# Harta comenzilor specifice fiecărei tehnologii pentru verificare
get_tool_cmd() {
    case "$1" in
        docker) echo "docker" ;;
        python) echo "python3" ;;
        mysql)  echo "mysql" ;;
        nodejs) echo "node" ;;
        java)   echo "java" ;;
        *)      echo "$1" ;;
    esac
}

# Extragere nume tehnologii din vars.json (fără dependență de jq, folosind grep/sed)
TOOLS=$(grep -o '"name": "[^"]*"' "$VARS_FILE" | cut -d'"' -f4)

for TOOL in $TOOLS; do
    CMD=$(get_tool_cmd "$TOOL")
    echo -n "Verificare $TOOL ($CMD): "
    
    # Verificăm dacă executabilul există pe server
    if command -v "$CMD" &> /dev/null; then
        VERSION=$("$CMD" --version 2>&1 | head -n 1)
        echo "✅ INSTALAT ($VERSION)"
    else
        echo "❌ NEINSTALAT (Comanda '$CMD' nu a fost găsită)"
        ERRORS=$((ERRORS + 1))
    fi
done

echo "=========================================="

# Returnăm cod de ieșire corespunzător pentru pipeline-ul Jenkins
if [ "$ERRORS" -gt 0 ]; then
    echo "❌ Verificare eșuată! $ERRORS tehnologie/tehnologii din configurare lipsesc."
    exit 1
else
    echo "✅ Toate tehnologiile solicitate au fost verificate cu succes!"
    exit 0
fi