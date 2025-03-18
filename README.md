# api-cp-crime-schedulingandlisting-courtallocations
Crime case scheduling and listing API for Court Allocations



## GitHub Action OpenAPI Validator

The `.github/openapi/test` directory contains a valid and invalid OpenAPI specification to assert the `.github/workflows/validate-openapi.yml`.

### Invalid OpenAPI Specification (invalid-openapi-spec.yml):

Contains several deliberate errors to test your validation action:
* Incorrect components structure (uses schema instead of schemas)
* An invalid property type (type: money instead of a valid type)
* Improperly formatted enum (comma-separated instead of an array)
* Missing required properties in schemas
* Additional invalid properties in schemas
* Referenced security scheme not properly defined

### Valid OpenAPI Specification (test-openapi-spec.yaml):
* Follows the OpenAPI 3.0.3 specification 
* Includes complete definitions for a product catalog API 
* Contains multiple endpoints, schemas, and security definitions 
* Should pass validation without any errors