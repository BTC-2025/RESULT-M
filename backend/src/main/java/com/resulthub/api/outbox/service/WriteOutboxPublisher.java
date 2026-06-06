package com.resulthub.api.outbox.service;

import com.resulthub.api.outbox.entity.WriteOutboxEvent;
import com.resulthub.api.outbox.repository.WriteOutboxEventRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class WriteOutboxPublisher {

    private final WriteOutboxEventRepository repository;

    public void publishComplaintCounterEvent(
            UUID complaintId,
            UUID userId,
            String eventType,
            int upvoteDelta,
            int downvoteDelta,
            int flagDelta
    ) {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("complaintId", complaintId.toString());
        if (userId != null) {
            payload.put("userId", userId.toString());
        }
        payload.put("upvoteDelta", upvoteDelta);
        payload.put("downvoteDelta", downvoteDelta);
        payload.put("flagDelta", flagDelta);

        publish(
                "COMPLAINT",
                complaintId,
                eventType,
                "complaint:%s:%s:%s:%s".formatted(complaintId, userId, eventType, UUID.randomUUID()),
                payload
        );
    }

    public void publishVoteBoxCounterEvent(UUID voteBoxId, UUID optionId, UUID userId, String ipAddress, String deviceFingerprint) {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("voteBoxId", voteBoxId.toString());
        payload.put("optionId", optionId.toString());
        if (userId != null) {
            payload.put("userId", userId.toString());
        }
        if (ipAddress != null) {
            payload.put("ipAddress", ipAddress);
        }
        if (deviceFingerprint != null) {
            payload.put("deviceFingerprint", deviceFingerprint);
        }
        payload.put("voteCountDelta", 1);

        String voterKey = userId != null ? userId.toString() : ipAddress + ":" + deviceFingerprint;
        publish(
                "VOTE_BOX",
                voteBoxId,
                "VOTE_BOX_CAST",
                "vote-box:%s:%s:%s:%s".formatted(voteBoxId, optionId, voterKey, UUID.randomUUID()),
                payload
        );
    }

    private void publish(String aggregateType, UUID aggregateId, String eventType, String idempotencyKey, Map<String, Object> payload) {
        if (repository.existsByIdempotencyKey(idempotencyKey)) {
            return;
        }

        repository.save(WriteOutboxEvent.builder()
                .aggregateType(aggregateType)
                .aggregateId(aggregateId)
                .eventType(eventType)
                .idempotencyKey(idempotencyKey)
                .payload(payload)
                .build());
    }
}
