package com.resulthub.api.dataset.repository;

import com.resulthub.api.dataset.entity.Dataset;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface DatasetRepository extends JpaRepository<Dataset, UUID> {
    
    @Query("SELECT d FROM Dataset d WHERE d.id = :id AND d.deletedAt IS NULL")
    Optional<Dataset> findByIdAndNotDeleted(@Param("id") UUID id);

    @Query("SELECT d FROM Dataset d WHERE d.slug = :slug AND d.workspace.id = :workspaceId AND d.deletedAt IS NULL")
    Optional<Dataset> findBySlugAndWorkspaceIdAndNotDeleted(@Param("slug") String slug, @Param("workspaceId") UUID workspaceId);

    @Query("SELECT d FROM Dataset d WHERE d.workspace.id = :workspaceId AND d.deletedAt IS NULL")
    Page<Dataset> findByWorkspaceIdAndNotDeleted(@Param("workspaceId") UUID workspaceId, Pageable pageable);
}
