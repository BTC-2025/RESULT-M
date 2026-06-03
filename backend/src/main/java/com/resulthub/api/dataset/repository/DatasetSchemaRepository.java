package com.resulthub.api.dataset.repository;

import com.resulthub.api.dataset.entity.DatasetSchema;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface DatasetSchemaRepository extends JpaRepository<DatasetSchema, UUID> {
    Optional<DatasetSchema> findByDatasetId(UUID datasetId);
}
