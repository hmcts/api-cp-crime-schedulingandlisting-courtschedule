package uk.gov.hmcts.cp.config;

import io.swagger.v3.oas.models.responses.ApiResponse;
import io.swagger.v3.oas.models.responses.ApiResponses;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.ExternalDocumentation;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class OpenAPIConfigurationLoaderTest {

    private static final Logger log = LoggerFactory.getLogger(OpenAPIConfigurationLoaderTest.class);

    @Test
    void openAPI_bean_should_have_expected_properties() {
        OpenAPIConfigurationLoader config = new OpenAPIConfigurationLoader();
        OpenAPI openAPI = config.openAPI();
        assertNotNull(openAPI);

        Info info = openAPI.getInfo();
        assertNotNull(info);
        assertEquals("Common Platform API Scheduling and Listing Court Schedule", info.getTitle());
        assertEquals("Scheduling and Listing API providing the court schedule", info.getDescription());

        String apiGitHubRepository = "api-cp-crime-schedulingandlisting-courtschedule";
        String expectedVersion = System.getProperty("API_SPEC_VERSION", "0.0.0");
        log.info("API version set to: {}", expectedVersion);

        assertEquals(expectedVersion, info.getVersion());

        License license = info.getLicense();
        assertNotNull(license);
        assertEquals("MIT", license.getName());
        assertEquals("https://opensource.org/licenses/MIT", license.getUrl());

        assertNotNull(info.getContact());
        assertEquals("no-reply@hmcts.com", info.getContact().getEmail());

        assertNotNull(openAPI.getServers());
        assertFalse(openAPI.getServers().isEmpty());
        assertEquals("https://virtserver.swaggerhub.com/HMCTS-DTS/" + apiGitHubRepository + "/" + expectedVersion,
                openAPI.getServers().get(0).getUrl());
    }

    @Test
    void loadOpenApiFromClasspath_should_throw_for_missing_resource() {
        Exception exception = assertThrows(IllegalArgumentException.class, () ->
                OpenAPIConfigurationLoader.loadOpenApiFromClasspath("nonexistent-file.yaml")
        );
        assertTrue(exception.getMessage().contains("Missing resource"));
    }

    @Test
    void loadOpenApiFromClasspath_should_throw_for_blank_path() {
        try {
            OpenAPIConfigurationLoader.loadOpenApiFromClasspath(" ");
            assert false;
        } catch (IllegalArgumentException e) {
            assert true;
        }
    }

    @Test
    void loadOpenApiFromClasspath_should_throw_for_null_path() {
        try {
            OpenAPIConfigurationLoader.loadOpenApiFromClasspath(null);
            assert false;
        } catch (IllegalArgumentException e) {
            assert true;
        }
    }

    @Test
    void openAPI_should_define_200_response_for_getCourtScheduleByCaseUrn() {
        OpenAPIConfigurationLoader config = new OpenAPIConfigurationLoader();
        OpenAPI openAPI = config.openAPI();

        assertNotNull(openAPI.getPaths());
        assertTrue(openAPI.getPaths().containsKey("/case/{case_urn}/courtschedule"));

        ApiResponses responses = openAPI.getPaths()
                .get("/case/{case_urn}/courtschedule")
                .getGet()
                .getResponses();

        assertNotNull(responses);
        ApiResponse okResponse = responses.get("200");
        assertNotNull(okResponse, "200 response should be defined");
        assertEquals("Case found", okResponse.getDescription());
        assertNotNull(okResponse.getContent().get("application/json"));
    }

    @Test
    void openAPI_should_define_400_response_for_getCourtScheduleByCaseUrn() {
        OpenAPIConfigurationLoader config = new OpenAPIConfigurationLoader();
        OpenAPI openAPI = config.openAPI();

        assertNotNull(openAPI.getPaths());
        assertTrue(openAPI.getPaths().containsKey("/case/{case_urn}/courtschedule"));

        ApiResponses responses = openAPI.getPaths()
                .get("/case/{case_urn}/courtschedule")
                .getGet()
                .getResponses();

        assertNotNull(responses);
        ApiResponse badRequest = responses.get("400");
        assertNotNull(badRequest, "400 response should be defined");
        assertEquals("Bad input parameter", badRequest.getDescription());
        assertNotNull(badRequest.getContent().get("application/json"));
    }
}