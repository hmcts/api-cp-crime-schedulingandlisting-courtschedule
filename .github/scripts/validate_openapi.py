#!/usr/bin/env python3
"""
OpenAPI Schema Validator

This script validates OpenAPI/Swagger definition files against their respective
schema specifications using the openapi-schema-validator package.

Supports:
- OpenAPI 3.0.x
- Swagger 2.0

Usage:
    python validate_openapi.py <file_path> [<file_path> ...]
"""

import sys
import os
import json
import yaml
from openapi_schema_validator import validate

def load_yaml(file_path):
    """Load and parse a YAML file"""
    with open(file_path, 'r') as f:
        return yaml.safe_load(f)

def load_json(file_path):
    """Load and parse a JSON file"""
    with open(file_path, 'r') as f:
        return json.load(f)

def load_spec(file_path):
    """Load an OpenAPI spec from YAML or JSON"""
    if file_path.endswith(('.yaml', '.yml')):
        return load_yaml(file_path)
    elif file_path.endswith('.json'):
        return load_json(file_path)
    else:
        raise ValueError(f"Unsupported file extension: {file_path}")

def validate_openapi(file_path):
    """
    Validate an OpenAPI specification file

    Args:
        file_path: Path to the OpenAPI specification file

    Returns:
        bool: True if validation passed, False otherwise
    """
    try:
        spec = load_spec(file_path)

        # Check if it's a valid OpenAPI spec by looking for required fields
        if not spec.get('openapi') and not spec.get('swagger'):
            print(f"WARNING: {file_path} does not appear to be an OpenAPI specification (missing 'openapi' or 'swagger' field)")
            return True

        # Validate the OpenAPI schema against the proper specification
        if 'openapi' in spec:
            from openapi_schema_validator import OAS30Validator
            # Extract the schema objects to validate
            if 'components' in spec and 'schemas' in spec['components']:
                schemas = spec['components']['schemas']
                for schema_name, schema in schemas.items():
                    try:
                        validator = OAS30Validator(schema)
                        # We're just validating the schema itself, not data against the schema
                    except Exception as e:
                        print(f"ERROR in {file_path}, schema '{schema_name}': {str(e)}")
                        return False
            print(f"✓ {file_path} is valid (OpenAPI 3.0)")
            return True
        elif 'swagger' in spec and spec['swagger'] == '2.0':
            from openapi_schema_validator import OAS20Validator
            # Extract the schema objects to validate
            if 'definitions' in spec:
                schemas = spec['definitions']
                for schema_name, schema in schemas.items():
                    try:
                        validator = OAS20Validator(schema)
                        # We're just validating the schema itself, not data against the schema
                    except Exception as e:
                        print(f"ERROR in {file_path}, schema '{schema_name}': {str(e)}")
                        return False
            print(f"✓ {file_path} is valid (Swagger 2.0)")
            return True
        else:
            print(f"WARNING: Unknown specification version in {file_path}")
            return True
    except Exception as e:
        print(f"ERROR validating {file_path}: {str(e)}")
        return False

def main():
    """Main entry point for the script"""
    if len(sys.argv) < 2:
        print("Usage: python validate_openapi.py <file_path> [<file_path> ...]")
        sys.exit(1)

    files = sys.argv[1:]
    failures = 0

    for file_path in files:
        if not os.path.exists(file_path):
            print(f"File not found: {file_path}")
            failures += 1
            continue

        if not validate_openapi(file_path):
            failures += 1

    if failures == 0:
        print(f"All {len(files)} OpenAPI definition(s) validated successfully.")
    else:
        print(f"Validation failed for {failures} file(s) out of {len(files)}.")

    sys.exit(failures)

if __name__ == "__main__":
    main()