package com.resulthub.api.complaint.repository;

import com.resulthub.api.complaint.entity.ComplaintComment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ComplaintCommentRepository extends JpaRepository<ComplaintComment, UUID> {
    
    List<ComplaintComment> findByComplaintId(UUID complaintId);
}
