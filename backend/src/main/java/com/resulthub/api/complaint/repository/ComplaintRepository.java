package com.resulthub.api.complaint.repository;

import com.resulthub.api.complaint.entity.Complaint;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ComplaintRepository extends JpaRepository<Complaint, UUID> {

    @Query(
            value = """
                    SELECT *
                    FROM complaints
                    ORDER BY (COALESCE(net_score, 0)::float / POWER((EXTRACT(EPOCH FROM (NOW() - created_at)) / 3600) + 2, 1.5)) DESC
                    """,
            countQuery = "SELECT COUNT(*) FROM complaints",
            nativeQuery = true
    )
    Page<Complaint> findTrending(Pageable pageable);

    List<Complaint> findAllByOrderByNetScoreDesc();

    Page<Complaint> findAllByOrderByNetScoreDesc(Pageable pageable);
    
    List<Complaint> findAllByOrderByCreatedAtDesc();

    Page<Complaint> findAllByOrderByCreatedAtDesc(Pageable pageable);
    
    List<Complaint> findByCategory(String category);

    Page<Complaint> findByCategory(String category, Pageable pageable);
    
    List<Complaint> findByStatus(Complaint.ComplaintStatus status);

    Page<Complaint> findByStatus(Complaint.ComplaintStatus status, Pageable pageable);

    List<Complaint> findByCategoryAndStatus(String category, Complaint.ComplaintStatus status);

    Page<Complaint> findByCategoryAndStatus(String category, Complaint.ComplaintStatus status, Pageable pageable);

    @Modifying
    @Query("UPDATE Complaint c SET c.upvotes = c.upvotes + :delta WHERE c.id = :id")
    void incrementUpvotes(@Param("id") UUID id, @Param("delta") int delta);

    @Modifying
    @Query("UPDATE Complaint c SET c.downvotes = c.downvotes + :delta WHERE c.id = :id")
    void incrementDownvotes(@Param("id") UUID id, @Param("delta") int delta);

    @Modifying
    @Query("UPDATE Complaint c SET c.flagCount = c.flagCount + 1 WHERE c.id = :id")
    void incrementFlagCount(@Param("id") UUID id);

    @Modifying
    @Query("""
            UPDATE Complaint c
            SET c.status = :reviewStatus
            WHERE c.id = :id
              AND c.status = :openStatus
              AND c.flagCount >= :threshold
            """)
    void moveToReviewWhenFlagThresholdReached(
            @Param("id") UUID id,
            @Param("openStatus") Complaint.ComplaintStatus openStatus,
            @Param("reviewStatus") Complaint.ComplaintStatus reviewStatus,
            @Param("threshold") int threshold
    );
}
