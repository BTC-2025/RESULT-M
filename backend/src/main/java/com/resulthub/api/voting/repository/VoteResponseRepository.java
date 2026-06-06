package com.resulthub.api.voting.repository;

import com.resulthub.api.voting.entity.VoteResponse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface VoteResponseRepository extends JpaRepository<VoteResponse, UUID> {
    
    Optional<VoteResponse> findByVoteBoxIdAndUserId(UUID voteBoxId, UUID userId);
    
    boolean existsByVoteBoxIdAndUserId(UUID voteBoxId, UUID userId);
    
    boolean existsByVoteBoxIdAndIpAddressAndCreatedAtAfter(UUID voteBoxId, String ipAddress, java.time.LocalDateTime date);
    
    boolean existsByVoteBoxIdAndDeviceFingerprintAndCreatedAtAfter(UUID voteBoxId, String deviceFingerprint, java.time.LocalDateTime date);
}
