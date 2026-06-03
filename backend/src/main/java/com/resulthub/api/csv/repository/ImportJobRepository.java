package com.resulthub.api.csv.repository;

import com.resulthub.api.csv.entity.ImportJob;
import com.resulthub.api.csv.enums.ImportStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.UUID;

public interface ImportJobRepository extends JpaRepository<ImportJob, UUID> {
    
    @Query("SELECT j FROM ImportJob j WHERE j.dataset.id = :datasetId")
    Page<ImportJob> findByDatasetId(@Param("datasetId") UUID datasetId, Pageable pageable);

    @Query("SELECT j FROM ImportJob j WHERE j.dataset.id = :datasetId AND j.status = :status")
    Page<ImportJob> findByDatasetIdAndStatus(@Param("datasetId") UUID datasetId, @Param("status") ImportStatus status, Pageable pageable);
}
