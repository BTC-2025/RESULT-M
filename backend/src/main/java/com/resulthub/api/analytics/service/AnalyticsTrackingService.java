package com.resulthub.api.analytics.service;

import com.resulthub.api.analytics.entity.AnalyticsEvent;
import com.resulthub.api.analytics.enums.EventType;
import com.resulthub.api.analytics.repository.AnalyticsEventRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class AnalyticsTrackingService {

    private final AnalyticsEventRepository eventRepository;

    @Async
    public void trackEvent(EventType type, UUID workspaceId, UUID datasetId, UUID recordId, UUID userId, String sessionId, Map<String, Object> metadata) {
        try {
            AnalyticsEvent event = AnalyticsEvent.builder()
                    .eventType(type)
                    .workspaceId(workspaceId)
                    .datasetId(datasetId)
                    .recordId(recordId)
                    .userId(userId)
                    .anonymousSessionId(sessionId)
                    .metadata(metadata)
                    .build();
            eventRepository.save(event);
        } catch (Exception e) {
            log.error("Failed to track analytics event: {}", type, e);
            // Non-blocking, so we just log and swallow the error to not interrupt the main transaction
        }
    }
}
