package com.resulthub.api.analytics;

import com.resulthub.api.BaseContainerTest;
import com.resulthub.api.analytics.entity.AnalyticsEvent;
import com.resulthub.api.analytics.enums.EventType;
import com.resulthub.api.analytics.repository.AnalyticsEventRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

public class AnalyticsIntegrationTest extends BaseContainerTest {

    @Autowired
    private AnalyticsEventRepository analyticsEventRepository;

    @Test
    void testAnalyticsEventTracking() {
        AnalyticsEvent event = new AnalyticsEvent();
        event.setDatasetId(UUID.randomUUID());
        event.setEventType(EventType.SEARCH);
        event.setMetadata(Map.of("ipAddress", "192.168.1.1"));

        AnalyticsEvent saved = analyticsEventRepository.save(event);
        assertThat(saved.getId()).isNotNull();

        long count = analyticsEventRepository.count();
        assertThat(count).isGreaterThan(0);
    }
}
