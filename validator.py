import json
import sys
import yaml

SUPPORTED_TOOLS = ["docker", "python", "mysql", "nodejs", "java"]


def validate_and_generate():
    try:
        with open("config/env_config.yaml", "r") as f:
            config = yaml.safe_load(f)
    except Exception as e:
        print(f"❌ Eroare la citirea fișierului de configurare: {e}")
        sys.exit(1)

    requested_tools = config.get("tools", [])
    valid_tools = []

    for item in requested_tools:
        name = item.get("name")
        version = item.get("version", "latest")

        if name not in SUPPORTED_TOOLS:
            print(
                f"❌ Eroare: Tehnologia '{name}' NU este în lista suportată! Operare oprită."
            )
            sys.exit(1)

        valid_tools.append({"name": name, "version": version})
        print(f"✔ Validat: {name} (versiune: {version})")

    # Generăm fișierul de variabile pentru automatizare
    output_data = {"install_tools": valid_tools}
    with open("config/vars.json", "w") as f:
        json.dump(output_data, f, indent=4)

    print(
        "\n✅ Configurație validă! Fișierul 'config/vars.json' a fost generat pentru automatizare."
    )


if __name__ == "__main__":
    validate_and_generate()