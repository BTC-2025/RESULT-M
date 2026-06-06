package com.resulthub.api.voting.repository;

import com.resulthub.api.voting.entity.VoteBox;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface VoteBoxRepository extends JpaRepository<VoteBox, UUID> {
    
    List<VoteBox> findByVisibility(VoteBox.VoteBoxVisibility visibility);

    Page<VoteBox> findByVisibilityAndIsActiveTrue(VoteBox.VoteBoxVisibility visibility, Pageable pageable);
    
    List<VoteBox> findByLinkedWorkspaceId(UUID workspaceId);
}
