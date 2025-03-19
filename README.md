# api-cp-crime-schedulingandlisting-courtallocations
Crime case scheduling and listing API for Court Allocations



## GitHub Action OpenAPI Validator

The `.github/openapi/test` directory contains a valid and invalid OpenAPI specification to assert the `.github/workflows/validate-openapi.yml`.

The `validate` action uses the OpenAPI Schema provided via the environment variable `OAPI_SCHEMA_URL` or defaults to `https://raw.githubusercontent.com/OAI/OpenAPI-Specification/refs/heads/main/schemas/v3.1/schema.yaml`

### Run validation locally

It is assumed that python is installed on your machine.

Install the required dependencies by running the following command:
```bash
  pip install -r .github/scripts/requirements.txt
```

Run the following command to validate the OpenAPI specification:
```bash
python ./.github/scripts/validate_openapi.py ./openapi
```
or to test the validation script run:
```bash
python ./.github/scripts/validate_openapi.py ./.github/examples
```