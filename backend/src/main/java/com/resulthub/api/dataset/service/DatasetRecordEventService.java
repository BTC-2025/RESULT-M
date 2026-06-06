package com.resulthub.api.dataset.service;

import com.resulthub.api.dataset.dto.RecordResponse;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

@Service
public class DatasetRecordEventService {

    private final ConcurrentHashMap<UUID, CopyOnWriteArrayList<SseEmitter>> emitters = new ConcurrentHashMap<>();

    public SseEmitter subscribe(UUID datasetId) {
        SseEmitter emitter = new SseEmitter(0L);
        emitters.computeIfAbsent(datasetId, ignored -> new CopyOnWriteArrayList<>()).add(emitter);

        emitter.onCompletion(() -> remove(datasetId, emitter));
        emitter.onTimeout(() -> remove(datasetId, emitter));
        emitter.onError(error -> remove(datasetId, emitter));

        try {
            emitter.send(SseEmitter.event().name("connected").data("ok"));
        } catch (IOException e) {
            remove(datasetId, emitter);
        }

        return emitter;
    }

    public void publishRecordChanged(UUID datasetId, String eventName, RecordResponse record) {
        List<SseEmitter> datasetEmitters = emitters.get(datasetId);
        if (datasetEmitters == null || datasetEmitters.isEmpty()) {
            return;
        }

        for (SseEmitter emitter : datasetEmitters) {
            try {
                emitter.send(SseEmitter.event().name(eventName).data(record));
            } catch (IOException | IllegalStateException e) {
                remove(datasetId, emitter);
            }
        }
    }

    private void remove(UUID datasetId, SseEmitter emitter) {
        List<SseEmitter> datasetEmitters = emitters.get(datasetId);
        if (datasetEmitters == null) {
            return;
        }

        datasetEmitters.remove(emitter);
        if (datasetEmitters.isEmpty()) {
            emitters.remove(datasetId);
        }
    }
}
