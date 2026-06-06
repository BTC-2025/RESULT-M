package com.resulthub.api.complaint.repository;

import com.resulthub.api.complaint.entity.ComplaintVote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface ComplaintVoteRepository extends JpaRepository<ComplaintVote, UUID> {
    
    Optional<ComplaintVote> findByComplaintIdAndUserId(UUID complaintId, UUID userId);
}
