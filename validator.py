import json
import re
import sys
import yaml

# Lista albă (whitelist) cu tehnologiile suportate oficial de proiect
SUPPORTED_TOOLS = ["docker", "python", "mysql", "nodejs", "java"]


def is_valid_version(version: str) -> bool:
    """Verifică dacă versiunea specificată are un format valid (ex: latest, lts, 3, 8.0, 17)."""
    if not isinstance(version, str) or not version.strip():
        return False
    # Permite etichete standard (latest, lts) sau formate numerice (ex: 3, 8.0, 17.0.1)
    return bool(
        re.match(r"^(latest|lts|\d+(\.\d+)*)$", version.strip(), re.IGNORECASE)
    )


def validate_and_generate():
    """Citește fișierul de configurare, validează tehnologiile și versiunile,

    iar în caz de succes generează fișierul de variabile JSON pentru Ansible.
    """
    try:
        with open("config/env_config.yaml", "r", encoding="utf-8") as f:
            config = yaml.safe_load(f)
    except Exception as e:
        print(f"❌ Eroare la citirea fișierului de configurare: {e}")
        sys.exit(1)

    # Validare structură fișier YAML
    if not config or "tools" not in config:
        print(
            "❌ Eroare: Structură YAML invalidă sau lipsește cheia principală 'tools'."
        )
        sys.exit(1)

    requested_tools = config.get("tools", [])
    valid_tools = []

    for item in requested_tools:
        name = item.get("name")
        version = str(item.get("version", "latest"))

        # 1. Validare existență tehnologie în lista suportată
        if name not in SUPPORTED_TOOLS:
            print(
                f"❌ Eroare: Tehnologia '{name}' NU este suportată! Operare oprită."
            )
            sys.exit(1)

        # 2. Validare format versiune
        if not is_valid_version(version):
            print(
                f"❌ Eroare: Versiunea '{version}' pentru tehnologia '{name}' este invalidă! Operare oprită."
            )
            sys.exit(1)

        valid_tools.append({"name": name, "version": version})
        print(f"✔ Validat: {name} (versiune: {version})")

    # Generarea fișierului de variabile consumat ulterior de automatizarea Ansible
    output_data = {"install_tools": valid_tools}
    with open("config/vars.json", "w", encoding="utf-8") as f:
        json.dump(output_data, f, indent=4)

    print(
        "\n✅ Configurație validă! Fișierul 'config/vars.json' a fost generat pentru automatizare."
    )


if __name__ == "__main__":
    validate_and_generate()