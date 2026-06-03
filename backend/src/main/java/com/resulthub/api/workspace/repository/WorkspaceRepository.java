package com.resulthub.api.workspace.repository;

import com.resulthub.api.workspace.entity.Workspace;
import com.resulthub.api.workspace.enums.VisibilityMode;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface WorkspaceRepository extends JpaRepository<Workspace, UUID> {
    
    @Query("SELECT w FROM Workspace w WHERE w.slug = :slug AND w.deletedAt IS NULL")
    Optional<Workspace> findBySlugAndNotDeleted(@Param("slug") String slug);

    @Query("SELECT w FROM Workspace w WHERE w.id = :id AND w.deletedAt IS NULL")
    Optional<Workspace> findByIdAndNotDeleted(@Param("id") UUID id);

    @Query("SELECT w FROM Workspace w WHERE w.owner.id = :ownerId AND w.deletedAt IS NULL")
    Page<Workspace> findByOwnerIdAndNotDeleted(@Param("ownerId") UUID ownerId, Pageable pageable);

    @Query("SELECT w FROM Workspace w WHERE w.visibility = :visibility AND w.deletedAt IS NULL")
    Page<Workspace> findByVisibilityAndNotDeleted(@Param("visibility") VisibilityMode visibility, Pageable pageable);
}
