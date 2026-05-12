# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Keep replies extremely concise. No filler.

## Code Rules (non-negotiable)
- No comments unless the WHY is genuinely non-obvious (hidden constraint, workaround, surprising invariant). Never explain WHAT the code does.
- No multi-line comment blocks or docstrings.
- No error handling for scenarios that cannot happen. Trust internal code and framework guarantees. Only validate at real system boundaries (user input, external APIs).
- No features, refactoring, or abstractions beyond what the task requires. Three similar lines > premature abstraction.
- No half-finished implementations. No TODOs left in code.
- No feature flags or fallbacks for hypothetical future requirements.
- Bug fix = fix the bug only. Do not clean up surroundings.

## Overview

This is an **OpenAPI-first API specification library** for the HMCTS Common Platform — not a standalone runnable service. It defines the Court Schedule API contract and generates Spring Boot Java models and controller interfaces from an OpenAPI 3.0 spec. Consuming services implement the generated interfaces.

- **Java 25**, **Spring Boot 4.0.2**, **Gradle**
- Generated code lives in `build/generated/` (do not edit directly)
- Source of truth: `src/main/resources/openapi/openapi-spec.yml`

## Commands

### Build
```bash
./gradlew build -DAPI_SPEC_VERSION=<version>   # full build with tests
./gradlew build -x test                         # skip tests
```

`API_SPEC_VERSION` is required for full builds. In CI it is generated from git history. Locally any string works (e.g. `-DAPI_SPEC_VERSION=local`).

### Test
```bash
./gradlew test                                                                      # all tests
./gradlew test --tests 'uk.gov.hmcts.cp.config.OpenApiObjectsTest'                 # single class
./gradlew test --tests 'uk.gov.hmcts.cp.config.OpenApiObjectsTest.methodName'      # single method
./gradlew check                                                                     # tests + JaCoCo coverage
```

### Code Quality
```bash
./gradlew pmdMain                                                      # PMD static analysis
./gradlew spotlessCheck                                                # code formatting check
./gradlew spotlessApply                                                # auto-fix formatting
spectral lint "src/main/resources/openapi/*.{yml,yaml}"               # OpenAPI spec linting
./gradlew jacocoTestReport                                             # coverage report → build/reports/jacoco/
./gradlew publishToMavenLocal                                          # publish to local Maven repo
```

## Architecture

### OpenAPI-First Code Generation

The build pipeline generates Java from the OpenAPI spec via the **OpenAPI Generator** (Gradle plugin, `gradle/openapi.gradle`):

1. Input: `src/main/resources/openapi/openapi-spec.yml`
2. Schema definitions: `src/main/resources/openapi/schema/courtSchedule.schema.json`
3. Output: `build/generated/src/main/java/uk/gov/hmcts/cp/openapi/`
   - `api/CourtScheduleApi.java` — Spring `@RequestMapping` interface
   - `model/*.java` — DTOs with Lombok (`@Builder`, `@AllArgsConstructor`, `@NoArgsConstructor`) and `@JsonInclude(NON_NULL)`

Changing the data model or endpoint means editing the OpenAPI spec, then running `./gradlew openApiGenerate`.

### Single API Endpoint

```
GET /case/{case_urn}/courtschedule
  → 200 CourtScheduleResponse
  → 400 ErrorResponse
```

### Key Domain Models

| Model | Purpose |
|---|---|
| `CourtScheduleResponse` | Top-level response wrapper |
| `CourtSchedule` | Container for a list of hearings |
| `Hearing` | Hearing details (ID, type, description, listNote, optional weekCommencing) |
| `CourtSitting` | Scheduled sitting with start/end times, judge, courthouse, courtroom UUIDs |
| `HearingWeekCommencing` | Week-based scheduling alternative (AMP-203) |
| `ErrorResponse` | Machine-readable error with traceId |

### Test Structure

One test class: `src/test/java/uk/gov/hmcts/cp/config/OpenApiObjectsTest.java` — uses reflection to verify generated model fields and API interface method signatures match the spec. When adding new fields to the OpenAPI spec, update this test accordingly.

Test method names use underscores; this is intentional and permitted by the PMD ruleset.

### Gradle Configuration Modules

- `gradle/openapi.gradle` — OpenAPI code generation settings (packages, type mappings, Lombok injection)
- `gradle/java.gradle` — Java 25 (Temurin toolchain), `-Xlint:unchecked -Werror` (warnings are compiler errors)
- `gradle/test.gradle` — JUnit Platform, JaCoCo, fail-fast enabled
- `gradle/pmd.gradle` — PMD rules (see `.github/pmd-ruleset.xml`); generated code is excluded
- `gradle/repositories.gradle` — GitHub Packages + Azure Artifacts; publishes to both
- `gradle/dependency.gradle` — `dependencyUpdates` task configured to reject non-stable candidate versions

## CI/CD Workflows

| Workflow | Trigger | Purpose |
|---|---|---|
| `ci-draft.yml` | PR / push to main | Builds and publishes draft version |
| `ci-released.yml` | GitHub Release published | Publishes release version to GitHub Packages + Azure Artifacts |
| `lint-openapi.yml` | PR | Spectral + AJV validation of OpenAPI spec and JSON schemas |
| `code-analysis.yml` | PR | PMD static analysis |
| `codeql.yml` | PR + weekly | Security analysis + CycloneDX SBOM |
| `publish-openapi-spec.yml` | PR / release | Publishes spec to SwaggerHub/APIHub |

Artifact publishing requires `GITHUB_TOKEN`, `AZURE_DEVOPS_ARTIFACT_USERNAME`, and `AZURE_DEVOPS_ARTIFACT_TOKEN` environment variables.