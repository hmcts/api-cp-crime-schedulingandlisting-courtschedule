import sys
import os
import json
import yaml
import jsonschema
import requests

def find_openapi_files(root_dir):
    """Recursively find OpenAPI files (.yaml, .yml) in the given directory."""
    openapi_files = []
    for root, _, files in os.walk(root_dir):
        for file in files:
            if file.endswith((".yaml", ".yml")):
                openapi_files.append(os.path.join(root, file))
    return openapi_files

def load_yaml(file_path):
    with open(file_path, "r") as f:
        return yaml.safe_load(f)

def load_json(file_path):
    with open(file_path, "r") as f:
        return json.load(f)

def load_spec(file_path):
    if file_path.endswith((".yaml", ".yml")):
        return load_yaml(file_path)
    elif file_path.endswith(".json"):
        return load_json(file_path)
    else:
        raise ValueError(f"Unsupported file extension: {file_path}")

OAPI_SCHEMA_URL = os.environ.get("OAPI_SCHEMA_URL", "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/refs/heads/main/schemas/v3.1/schema.yaml")

def fetch_openapi_schema():
    """Fetch and convert the official OpenAPI 3.1 schema from YAML to JSON."""
    try:
        response = requests.get(OAPI_SCHEMA_URL)
        response.raise_for_status()
        schema_yaml = response.text
        return yaml.safe_load(schema_yaml)  # Convert YAML to JSON-like Python dict
    except Exception as e:
        print(f"Failed to fetch OpenAPI schema: {e}")
        sys.exit(1)

def validate_openapi(file_path, oas_schema):
    """Validate an OpenAPI specification file using the official OpenAPI 3.1 schema."""
    try:
        spec = load_spec(file_path)
        errors = []

        # Validate against OpenAPI meta-schema
        try:
            jsonschema.validate(instance=spec, schema=oas_schema)
        except jsonschema.exceptions.ValidationError as e:
            errors.append(f"Schema validation failed: {e.message}")

        # Additional security scheme check
        if "security" in spec:
            for sec in spec["security"]:
                for sec_key in sec.keys():
                    if "securitySchemes" not in spec.get("components", {}) or sec_key not in spec["components"].get("securitySchemes", {}):
                        errors.append(f"Referenced security scheme '{sec_key}' is not defined.")

        if errors:
            print(f"ERROR in {file_path}:")
            for err in errors:
                print(f" - {err}")
            return False

        print(f"✓ {file_path} is valid for schema : {OAPI_SCHEMA_URL}")
        return True
    except Exception as e:
        print(f"ERROR validating {file_path}: {str(e)}")
        return False

def main():
    if len(sys.argv) < 2:
        print("Usage: python validate_openapi.py <root_directory>")
        sys.exit(1)

    root_directory = sys.argv[1]
    if not os.path.exists(root_directory):
        print(f"Error: Directory '{root_directory}' not found.")
        sys.exit(1)

    openapi_files = find_openapi_files(root_directory)
    if not openapi_files:
        print(f"No OpenAPI files found in '{root_directory}'.")
        sys.exit(0)

    print(f"Found {len(openapi_files)} OpenAPI files for validation.")

    oas_schema = fetch_openapi_schema()  # Fetch OpenAPI 3.1 schema
    failures = 0

    for file_path in openapi_files:
        if not validate_openapi(file_path, oas_schema):
            failures += 1

    if failures == 0:
        print(f"All {len(openapi_files)} OpenAPI definition(s) validated successfully.")
    else:
        print(f"Validation failed for {failures} file(s) out of {len(openapi_files)}.")

    sys.exit(failures)

if __name__ == "__main__":
    main()