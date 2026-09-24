#!/bin/bash

echo "=========================================="
echo "  Verificare Instalare Tehnologii DevOps  "
echo "=========================================="

# Căutare flexibilă a fișierului vars.json (în config/ sau în rădăcină)
VARS_FILE="config/vars.json"
if [ ! -f "$VARS_FILE" ]; then
    if [ -f "vars.json" ]; then
        VARS_FILE="vars.json"
    elif [ -f "/app/config/vars.json" ]; then
        VARS_FILE="/app/config/vars.json"
    else
        echo "❌ Eroare: Fișierul de variabile 'vars.json' nu a fost găsit!"
        exit 1
    fi
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

# Extragere nume tehnologii din vars.json folosind grep/cut
TOOLS=$(grep -o '"name": "[^"]*"' "$VARS_FILE" | cut -d'"' -f4)

if [ -z "$TOOLS" ]; then
    echo "❌ Eroare: Nu s-a putut extrage nicio tehnologie din $VARS_FILE sau fișierul este gol."
    exit 1
fi

for TOOL in $TOOLS; do
    CMD=$(get_tool_cmd "$TOOL")
    echo -n "Verificare $TOOL ($CMD): "
    
    # Verificăm dacă executabilul există pe server în PATH
    if command -v "$CMD" &> /dev/null; then
        VERSION=$("$CMD" --version 2>&1 | head -n 1)
        echo "✅ INSTALAT ($VERSION)"
    else
        echo "❌ NEINSTALAT (Comanda '$CMD' nu a fost găsită)"
        ERRORS=$((ERRORS + 1))
    fi
done

echo "=========================================="

# Returnăm codul de ieșire pentru pipeline-ul CI/CD (Jenkins)
if [ "$ERRORS" -gt 0 ]; then
    echo "❌ Verificare eșuată! $ERRORS tehnologie/tehnologii din configurare lipsesc."
    exit 1
else
    echo "✅ Toate tehnologiile solicitate au fost verificate cu succes!"
    exit 0
fi
