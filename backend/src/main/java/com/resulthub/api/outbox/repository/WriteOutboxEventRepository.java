package com.resulthub.api.outbox.repository;

import com.resulthub.api.outbox.entity.WriteOutboxEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface WriteOutboxEventRepository extends JpaRepository<WriteOutboxEvent, UUID> {
    boolean existsByIdempotencyKey(String idempotencyKey);
}
