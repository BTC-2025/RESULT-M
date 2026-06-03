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

    @Query(value = "SELECT * FROM dataset_records WHERE dataset_id = :datasetId AND deleted_at IS NULL AND " +
            "((:rollNumber IS NOT NULL AND LOWER(data->>'rollNumber') = LOWER(:rollNumber)) OR " +
            "(:dateOfBirth IS NOT NULL AND data->>'dateOfBirth' = :dateOfBirth)) LIMIT 1", nativeQuery = true)
    Optional<DatasetRecord> lookupRecord(@Param("datasetId") UUID datasetId, @Param("rollNumber") String rollNumber, @Param("dateOfBirth") String dateOfBirth);
}
