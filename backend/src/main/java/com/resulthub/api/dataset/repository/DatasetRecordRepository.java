package com.resulthub.api.dataset.repository;

import com.resulthub.api.dataset.entity.DatasetRecord;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface DatasetRecordRepository extends JpaRepository<DatasetRecord, UUID> {

    @Query("SELECT r FROM DatasetRecord r WHERE r.id = :id AND r.deletedAt IS NULL")
    Optional<DatasetRecord> findByIdAndNotDeleted(@Param("id") UUID id);

    @Query("SELECT r FROM DatasetRecord r WHERE r.dataset.id = :datasetId AND r.deletedAt IS NULL")
    Page<DatasetRecord> findByDatasetIdAndNotDeleted(@Param("datasetId") UUID datasetId, Pageable pageable);

    @Query("SELECT r FROM DatasetRecord r WHERE r.dataset.id = :datasetId AND r.recordKey = :recordKey AND r.deletedAt IS NULL")
    Optional<DatasetRecord> findByDatasetIdAndRecordKeyAndNotDeleted(@Param("datasetId") UUID datasetId, @Param("recordKey") String recordKey);
}
