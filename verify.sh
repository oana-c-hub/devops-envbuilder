#!/bin/bash

echo "=========================================="
echo "  Verificare Instalare Tehnologii DevOps  "
echo "=========================================="

# Funcție pentru verificarea unei comenzi
check_tool() {
    TOOL_NAME=$1
    CMD=$2

    echo -n "Verificare $TOOL_NAME: "
    if command -v $CMD &> /dev/null;
    then
        VERSION=$($CMD --version 2>&1 | head -n 1)
        echo "✅ INSTALAT ($VERSION)"
    else
        echo "❌ NEINSTALAT (Comanda '$CMD' nu a fost găsită)"
    fi
}

# Verificăm tehnologiile din proiectul nostru
check_tool "Docker" "docker"
check_tool "Python" "python3"
check_tool "MySQL" "mysql"
check_tool "Node.js" "node"
check_tool "Java" "java"

echo "=========================================="