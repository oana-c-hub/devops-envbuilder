import os
import json
import re
import sys
import yaml

# Lista albă (whitelist) cu tehnologiile suportate oficial de proiect
SUPPORTED_TOOLS = ["docker", "python", "mysql", "nodejs", "java"]

def is_valid_version(version: str) -> bool:
    """
    Verifică dacă versiunea specificată are un format valid.
    Acceptă: 'latest', 'lts', numere întregi sau formate semver (ex: '3', '8.0', '17.0.1').
    """
    if not isinstance(version, str) or not version.strip():
        return False
    return bool(re.match(r"^(latest|lts|\d+(\.\d+)*)$", version.strip(), re.IGNORECASE))

def resolve_file_paths(base_dir: str) -> tuple[str, str]:
    """
    Inspecție în cascadă pentru localizarea fișierelor de configurare și ieșire.
    Verifică pe rând: subfolderul 'config/', rădăcina proiectului și calea absolută din container.
    """
    # 1. Calea standard în subfolderul config/
    config_path = os.path.join(base_dir, "config", "env_config.yaml")
    output_path = os.path.join(base_dir, "config", "vars.json")

    # 2. Fallback local: fișierul se află direct în rădăcina proiectului
    if not os.path.exists(config_path):
        root_config = os.path.join(base_dir, "env_config.yaml")
        if os.path.exists(root_config):
            config_path = root_config
            output_path = os.path.join(base_dir, "vars.json")

    # 3. Fallback Docker: calea absolută mapată standard în container
    if not os.path.exists(config_path) and os.path.exists("/app/config/env_config.yaml"):
        config_path = "/app/config/env_config.yaml"
        output_path = "/app/config/vars.json"

    # Permite suprascrierea dinamică prin variabile de mediu (ex: folosite în CI/CD sau teste)
    final_config = os.environ.get("CONFIG_PATH", config_path)
    final_output = os.environ.get("OUTPUT_PATH", output_path)

    return final_config, final_output

def validate_and_generate():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Rezolvarea căilor de acces folosind logica de fallback
    config_path, output_path = resolve_file_paths(base_dir)

    try:
        with open(config_path, "r", encoding="utf-8") as f:
            config = yaml.safe_load(f)
    except Exception as e:
        print(f"❌ Eroare la citirea fișierului de configurare ({config_path}): {e}")
        sys.exit(1) 

    # Validare structură fișier YAML
    if not config or not isinstance(config, dict) or "tools" not in config:
        print("❌ Eroare: Structură YAML invalidă sau lipsește cheia principală 'tools'.")
        sys.exit(1)

    requested_tools = config.get("tools", [])
    if not isinstance(requested_tools, list):
        print("❌ Eroare: Cheia 'tools' trebuie să fie o listă de elemente.")
        sys.exit(1)

    valid_tools = []
    seen_tools = set()

    for item in requested_tools:
        if not isinstance(item, dict):
            print("❌ Eroare: Fiecare element din 'tools' trebuie să fie un dicționar cu 'name' și 'version'.")
            sys.exit(1)
            
        name = item.get("name")
        version = str(item.get("version", "latest"))

        if not name:
            print("❌ Eroare: S-a găsit un element fără nume specificat.")
            sys.exit(1)

        # 1. Validare existență tehnologie în lista suportată
        if name not in SUPPORTED_TOOLS:
            print(f"❌ Eroare: Tehnologia '{name}' NU este suportată! (Suportate: {SUPPORTED_TOOLS})")
            sys.exit(1)

        # 2. Validare format versiune
        if not is_valid_version(version):
            print(f"❌ Eroare: Versiunea '{version}' pentru tehnologia '{name}' este invalidă!")
            sys.exit(1)

        # 3. Tratarea duplicatelor: păstrează ultimul element procesat
        if name in seen_tools:
            print(f"⚠️ Atenție: Tehnologia '{name}' este duplicată. Se va folosi ultima instanță configurată.")
            # Eliminăm instanța anterioară din listă pentru curățenie
            valid_tools = [t for t in valid_tools if t["name"] != name]
        
        seen_tools.add(name)
        valid_tools.append({"name": name, "version": version})
        print(f"✔ Validat: {name} (versiune: {version})")

    # Asigurarea că folderul de ieșire există înainte de scriere
    output_dir = os.path.dirname(output_path)
    if output_dir and not os.path.exists(output_dir):
        os.makedirs(output_dir, exist_ok=True)

    # Generarea fișierului JSON consumat de Ansible / Terraform
    output_data = {"install_tools": valid_tools}
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(output_data, f, indent=4)

    print(f"\n✅ Configurație validă! Fișierul '{os.path.basename(output_path)}' a fost generat cu succes la calea: {output_path}")
    sys.exit(0)

if __name__ == "__main__":
    validate_and_generate()