## Repo: api-cp-crime-schedulingandlisting-courtschedule

OpenAPI-first API spec library that defines the court schedule interface for the Crime Scheduling and Listing domain, returning hearing allocations by case URN.

**Pattern**: Pure spec-only
**OpenAPI spec version**: 3.0.0
**OpenAPI Generator version**: 7.19.0 (target 7.22.0 per upgrade cycle)
**Spring Boot version**: 4.0.2 (target 4.0.6+ per upgrade cycle)

## API Endpoint(s)

```
GET /case/{case_urn}/courtschedule
  → 200 CourtSchedule
  → 400 ErrorResponse
  → 401 Unauthorized
  → 403 Forbidden
  → 404 ErrorResponse
  → 500 ErrorResponse
```

## Generated Interfaces & Schema

- Schema files: schemas defined inline in `components/schemas` (no separate `.schema.json` files)
- Generated API interface: `uk.gov.hmcts.cp.openapi.api.CourtScheduleApi`
- Generated models:
  - `CourtSchedule` — top-level schedule response containing hearings
  - `Hearing` — individual hearing with date, court, and case reference
  - `CourtSitting` — court room and sitting details
  - `ErrorResponse` — machine-readable error envelope

## Domain Models

| Model | Purpose |
|---|---|
| `CourtSchedule` | Root response: allocated hearings and week-commencing hearings for a case URN |
| `Hearing` | Single hearing: court, date, session type, defendant |
| `CourtSitting` | Court room and sitting within a hearing |
| `ErrorResponse` | Structured error with traceId |

## Test Structure

| Class | What it validates |
|---|---|
| `OpenApiObjectsTest` | Reflection-based contract test verifying generated model fields and `CourtScheduleApi` interface method signatures match the spec |

## Generator Config Notes

- `@JsonInclude(NON_NULL)` is present in `additionalModelTypeAnnotations` — aligned with standard.
- `inputSpec` uses modern `.set()` syntax.
- OpenAPI spec version is 3.0.0; target 3.1.0 for future spec revisions.

## CI/CD Deviations

Standard workflow set — no deviations: `ci-draft.yml`, `ci-released.yml`, `lint-openapi.yml`, `code-analysis.yml`, `codeql.yml`, `secrets-scanner.yml`, `publish-openapi-spec.yml`.

## Repo-Specific Notes

- The spec includes example court schedule payloads for both allocated hearings and week-commencing hearings — useful for WireMock stub setup in the downstream service.
- Run `/openapi-spec-reviewer` when authoring or reviewing the OpenAPI spec.
