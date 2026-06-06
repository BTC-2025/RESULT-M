package com.resulthub.api.voting.repository;

import com.resulthub.api.voting.entity.VoteOption;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface VoteOptionRepository extends JpaRepository<VoteOption, UUID> {
    
    List<VoteOption> findByVoteBoxIdOrderByDisplayOrderAsc(UUID voteBoxId);

    @Modifying
    @org.springframework.data.jpa.repository.Query("UPDATE VoteOption v SET v.voteCount = v.voteCount + 1 WHERE v.id = :optionId")
    void incrementVoteCount(UUID optionId);
}
