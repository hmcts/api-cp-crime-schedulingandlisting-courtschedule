package uk.gov.hmcts.cp.config;

import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import uk.gov.hmcts.cp.openapi.api.CourtScheduleApi;
import uk.gov.hmcts.cp.openapi.model.*;

import java.lang.reflect.Field;
import java.time.Instant;

import static org.assertj.core.api.Assertions.assertThat;

@Slf4j
class OpenApiObjectsTest {
    @Test
    void generated_error_response_should_have_expected_fields() {
        assertThat(ErrorResponse.class).hasDeclaredMethods("error", "message", "details", "traceId");
    }

    @Test
    void generated_court_schedule_should_have_expected_fields() {
        assertThat(CourtSchedule.class).hasDeclaredFields("hearings");
    }

    @Test
    void generated_court_schedule_response_should_have_expected_fields() {
        assertThat(CourtScheduleResponse.class).hasDeclaredFields("courtSchedule");
    }

    @Test
    void generated_court_sitting_should_have_expected_fields() {
        assertThat(CourtSitting.class).hasDeclaredFields("sittingStart", "sittingEnd", "judiciaryId", "courtHouse", "courtRoom");
    }

    @Test
    void generated_hearing_should_have_expected_fields() {
        assertThat(Hearing.class).hasDeclaredFields("hearingId", "hearingType", "hearingDescription", "listNote", "weekCommencing", "courtSittings");
    }

    @Test
    void generated_week_commencing_should_have_expected_fields() {
        assertThat(HearingWeekCommencing.class).hasDeclaredFields("startDate", "endDate", "durationInWeeks", "courtHouse");
    }

    @Test
    void generated_api_should_have_expected_methods() {
        assertThat(CourtScheduleApi.class).hasDeclaredMethods("getCourtScheduleByCaseUrn");
    }
    @Test
    void generated_error_response_timestamp_should_be_instant() throws Exception {
        Field timestampField = ErrorResponse.class.getDeclaredField("timestamp");

        assertThat(timestampField.getType())
                .as("timestamp field type")
                .isEqualTo(Instant.class);
    }
}