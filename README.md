# api-cp-crime-schedulingandlisting-courtallocations
Crime case scheduling and listing API for Court Allocations



## GitHub Action OpenAPI Validator

The `.github/openapi/test` directory contains a valid and invalid OpenAPI specification to assert the `.github/workflows/validate-openapi.yml`.

The workflow uses the OpenAPI Validator Action uses [openapi-schema-validator](https://github.com/python-openapi/openapi-schema-validator) to validate the OpenAPI specification.

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

### Invalid OpenAPI Specification (invalid-openapi-spec.yml)

Contains several deliberate errors to test your validation action:
* Incorrect components structure (uses schema instead of schemas)
* An invalid property type (type: money instead of a valid type)
* Improperly formatted enum (comma-separated instead of an array)
* Missing required properties in schemas
* Additional invalid properties in schemas
* Referenced security scheme not properly defined

### Valid OpenAPI Specification (test-openapi-spec.yaml)
* Follows the OpenAPI 3.0.3 specification 
* Includes complete definitions for a product catalog API 
* Contains multiple endpoints, schemas, and security definitions 
* Should pass validation without any errors