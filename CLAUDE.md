## Repo: api-cp-crime-schedulingandlisting-courtschedule

OpenAPI-first API spec library that defines the court schedule interface for the Crime Scheduling and Listing domain, returning hearing allocations by case URN.

**Pattern**: Pure spec-only
**OpenAPI spec version**: 3.0.0
**OpenAPI Generator version**: 7.25.0
**Spring Boot version**: 4.1.1

## API Endpoint(s)

```
GET /case/{case_urn}/courtschedule
  → 200 CourtScheduleResponse
  → 400 ErrorResponse
```

Only 200 and 400 are declared in the spec today; 401, 403, 404 and 500 are not yet modelled.

## Generated Interfaces & Schema

- Schema source: `src/main/resources/openapi/openapi-spec.yml` is the single source of truth. Schemas are defined inline in `components/schemas`; there are no separate `.schema.json` / `.schema.example.json` files and no `swagger/` folder (both were removed as unused duplicates — do not reintroduce them).
- Generated API interface: `uk.gov.hmcts.cp.openapi.api.CourtScheduleApi`
- Generated models:
  - `CourtScheduleResponse` — top-level response wrapping a `courtSchedule` array
  - `CourtSchedule` — a schedule entry containing `hearings`
  - `Hearing` — individual hearing with type, description, list note, sittings and optional week-commencing details
  - `HearingWeekCommencing` — generated from the inline `Hearing.weekCommencing` object
  - `CourtSitting` — court room and sitting details
  - `ErrorResponse` — machine-readable error envelope

## Domain Models

Response shape: `CourtScheduleResponse { courtSchedule: [ CourtSchedule { hearings: [ Hearing ] } ] }`

| Model | Purpose | Required fields |
|---|---|---|
| `CourtScheduleResponse` | Root response for a case URN | `courtSchedule` |
| `CourtSchedule` | Allocated hearings and week-commencing hearings | `hearings` |
| `Hearing` | Single hearing | `hearingId`, `hearingType`, `listNote` (nullable), `courtSittings` (may be `[]`) |
| `HearingWeekCommencing` | Proposed hearing week for an unallocated hearing | `startDate`, `endDate`, `durationInWeeks`, `courtHouse` |
| `CourtSitting` | Court room and sitting within a hearing | `sittingStart`, `sittingEnd`, `courtHouse`, `courtRoom` |
| `ErrorResponse` | Structured error with traceId | — |

`hearingDescription`, `judiciaryId` and `Hearing.weekCommencing` are optional. Required fields generate `@NotNull` on the models, so adding or removing one is a contract change for consumers.

## Test Structure

| Class | What it validates |
|---|---|
| `OpenApiObjectsTest` | Reflection-based contract test verifying generated model fields and `CourtScheduleApi` interface method signatures match the spec |

## Generator Config Notes

- `@JsonInclude(NON_NULL)` is present in `additionalModelTypeAnnotations` — aligned with standard.
- `inputSpec` uses modern `.set()` syntax.
- OpenAPI spec version is 3.0.0; target 3.1.0 for future spec revisions.
- The only Swagger/OpenAPI runtime dependency needed is `io.swagger.core.v3:swagger-annotations` (the generated code imports it). Do not add `openapi-generator-core` or `swagger-parser` as `implementation` dependencies: the `org.openapi.generator` Gradle plugin brings its own, and anything in `implementation` is published in the POM (`from components.java`) and leaks onto consumers' runtime classpath.

## CI/CD Deviations

Standard workflow set: `ci-draft.yml`, `ci-released.yml`, `lint-openapi.yml`, `code-analysis.yml`, `codeql.yml`, `secrets-scanner.yml`, `publish-api-docs.yml`.

- **Example validation**: `.spectral.yml` extends `spectral:oas` with `oas3-valid-media-example` and `oas3-valid-schema-example` enabled, so the `spectral-lint` job validates every example in `openapi-spec.yml` against its schema. Keep these rules on.
- **`json-lint` / `json-validate`**: still present in `lint-openapi.yml` only because the `main` ruleset lists them as required checks. With no JSON schema files left they pass with nothing to check. Remove them once a repo admin drops them from the ruleset.

## Release & AMP Catalog

- Publishing a GitHub Release triggers `ci-released.yml` (stamps `info.version`, publishes the jar to GitHub Packages / Azure Artifacts) and `publish-api-docs.yml` (redeploys Swagger UI to https://hmcts.github.io/api-cp-crime-schedulingandlisting-courtschedule/ via `hmcts/amp-catalog`'s `publish-swagger-ui.yml@v1`). Merging to `main` alone publishes nothing.
- The repo is already registered in `amp-catalog/docs/apis.json`; a catalog PR is only needed if `info.title` or `info.description` changes.

## Repo-Specific Notes

- The spec includes example court schedule payloads for both allocated hearings (`Allocated`) and week-commencing hearings (`Week Commencing`), shaped as `courtSchedule: [ { hearings: [ … ] } ]` — useful for WireMock stub setup in the downstream service.
- `src/main/resources/logback.xml` (using `LogstashEncoder`) is packaged into the published jar; this is why `logstash-logback-encoder` is an `implementation` dependency. Moving both to test scope is an open follow-up.
- Run `/openapi-spec-reviewer` when authoring or reviewing the OpenAPI spec.