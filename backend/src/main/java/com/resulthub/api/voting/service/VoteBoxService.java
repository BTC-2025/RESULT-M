package com.resulthub.api.voting.service;

import com.resulthub.api.outbox.service.WriteOutboxPublisher;
import com.resulthub.api.user.User;
import com.resulthub.api.user.UserRepository;
import com.resulthub.api.workspace.entity.Workspace;
import com.resulthub.api.workspace.repository.WorkspaceRepository;
import com.resulthub.api.voting.dto.CreateVoteBoxRequest;
import com.resulthub.api.voting.dto.VoteBoxResponse;
import com.resulthub.api.voting.dto.VoteResultsResponse;
import com.resulthub.api.voting.entity.VoteBox;
import com.resulthub.api.voting.entity.VoteOption;
import com.resulthub.api.voting.entity.VoteResponse;
import com.resulthub.api.voting.repository.VoteBoxRepository;
import com.resulthub.api.voting.repository.VoteOptionRepository;
import com.resulthub.api.voting.repository.VoteResponseRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class VoteBoxService {

    private final VoteBoxRepository voteBoxRepository;
    private final VoteOptionRepository voteOptionRepository;
    private final VoteResponseRepository voteResponseRepository;
    private final WorkspaceRepository workspaceRepository;
    private final UserRepository userRepository;
    private final WriteOutboxPublisher outboxPublisher;

    @Transactional(readOnly = true)
    public Page<VoteBoxResponse> getPublicVoteBoxes(Pageable pageable) {
        return voteBoxRepository
                .findByVisibilityAndIsActiveTrue(VoteBox.VoteBoxVisibility.PUBLIC, pageable)
                .map(box -> mapToResponse(box, null));
    }

    @Transactional(readOnly = true)
    public VoteBoxResponse getVoteBoxById(UUID id, UUID currentUserId) {
        VoteBox box = voteBoxRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "VoteBox not found"));
        return mapToResponse(box, currentUserId);
    }

    public VoteBox getVoteBoxEntity(UUID id) {
        return voteBoxRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "VoteBox not found"));
    }

    @Transactional
    public VoteBoxResponse createVoteBox(CreateVoteBoxRequest request, UUID creatorId) {
        User creator = null;
        if (creatorId != null) {
            creator = userRepository.findById(creatorId).orElse(null);
        }

        Workspace linkedWorkspace = null;
        if (request.linkedWorkspaceId() != null) {
            linkedWorkspace = workspaceRepository.findById(request.linkedWorkspaceId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Workspace not found"));
        }

        VoteBox box = VoteBox.builder()
                .creator(creator)
                .title(request.title())
                .description(request.description())
                .visibility(request.visibility())
                .accessCode(request.accessCode())
                .allowAnonymous(request.allowAnonymous())
                .endsAt(request.endsAt())
                .linkedWorkspace(linkedWorkspace)
                .isActive(true)
                .build();

        final VoteBox savedBox = voteBoxRepository.save(box);

        List<VoteOption> options = new ArrayList<>();
        int order = 0;
        for (String optionText : request.options()) {
            VoteOption option = VoteOption.builder()
                    .voteBox(savedBox)
                    .optionText(optionText)
                    .displayOrder(order++)
                    .voteCount(0)
                    .build();
            options.add(option);
        }

        voteOptionRepository.saveAll(options);

        return mapToResponse(savedBox, creatorId);
    }

    @Transactional
    public void castVote(UUID voteBoxId, UUID optionId, UUID userId, String ipAddress, String deviceFingerprint) {
        VoteBox box = voteBoxRepository.findById(voteBoxId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "VoteBox not found"));

        if (box.getEndsAt() != null && box.getEndsAt().isBefore(LocalDateTime.now())) {
            throw new ResponseStatusException(HttpStatus.GONE, "This vote box has closed");
        }

        VoteOption option = voteOptionRepository.findById(optionId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "VoteOption not found"));

        if (!option.getVoteBox().getId().equals(voteBoxId)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Option does not belong to this vote box");
        }

        LocalDateTime twentyFourHoursAgo = LocalDateTime.now().minusHours(24);

        if (userId != null) {
            if (voteResponseRepository.existsByVoteBoxIdAndUserId(voteBoxId, userId)) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "User has already voted");
            }
        } else {
            if (!box.getAllowAnonymous()) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Anonymous voting is not allowed");
            }
            if (ipAddress != null && !ipAddress.isEmpty()) {
                if (voteResponseRepository.existsByVoteBoxIdAndIpAddressAndCreatedAtAfter(voteBoxId, ipAddress, twentyFourHoursAgo)) {
                    throw new ResponseStatusException(HttpStatus.TOO_MANY_REQUESTS, "IP address has already voted in the last 24 hours");
                }
            }
            if (deviceFingerprint != null && !deviceFingerprint.isEmpty()) {
                if (voteResponseRepository.existsByVoteBoxIdAndDeviceFingerprintAndCreatedAtAfter(voteBoxId, deviceFingerprint, twentyFourHoursAgo)) {
                    throw new ResponseStatusException(HttpStatus.TOO_MANY_REQUESTS, "Device has already voted in the last 24 hours");
                }
            }
        }

        User user = null;
        if (userId != null) {
            user = userRepository.findById(userId).orElse(null);
        }

        VoteResponse voteResponse = VoteResponse.builder()
                .voteBox(box)
                .option(option)
                .user(user)
                .ipAddress(ipAddress)
                .deviceFingerprint(deviceFingerprint)
                .build();

        voteResponseRepository.save(voteResponse);
        voteOptionRepository.incrementVoteCount(optionId);
        outboxPublisher.publishVoteBoxCounterEvent(voteBoxId, optionId, userId, ipAddress, deviceFingerprint);
    }

    @Transactional(readOnly = true)
    public List<VoteResultsResponse> getResults(UUID voteBoxId) {
        VoteBox box = voteBoxRepository.findById(voteBoxId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "VoteBox not found"));

        List<VoteOption> options = voteOptionRepository.findByVoteBoxIdOrderByDisplayOrderAsc(voteBoxId);
        
        long totalVotes = options.stream().mapToLong(VoteOption::getVoteCount).sum();

        List<VoteResultsResponse> results = new ArrayList<>();
        
        if (totalVotes == 0) {
            for (VoteOption option : options) {
                results.add(new VoteResultsResponse(option.getId(), option.getOptionText(), 0, 0.0));
            }
            return results;
        }

        double sumPercentages = 0.0;
        for (int i = 0; i < options.size(); i++) {
            VoteOption option = options.get(i);
            
            if (i == options.size() - 1) {
                // Last element: 100 - sum of others to ensure exactly 100%
                double percentage = Math.max(0.0, 100.0 - sumPercentages);
                percentage = Math.round(percentage * 10.0) / 10.0; // round to 1 decimal
                results.add(new VoteResultsResponse(option.getId(), option.getOptionText(), option.getVoteCount(), percentage));
            } else {
                double percentage = ((double) option.getVoteCount() / totalVotes) * 100.0;
                percentage = Math.round(percentage * 10.0) / 10.0; // round to 1 decimal
                sumPercentages += percentage;
                results.add(new VoteResultsResponse(option.getId(), option.getOptionText(), option.getVoteCount(), percentage));
            }
        }

        return results;
    }

    @Transactional
    public void deleteVoteBox(UUID id, UUID creatorId) {
        VoteBox box = voteBoxRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "VoteBox not found"));
        
        if (box.getCreator() == null || !box.getCreator().getId().equals(creatorId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the creator can delete this vote box");
        }
        
        voteBoxRepository.delete(box);
    }

    public String unlockVoteBox(UUID voteBoxId, String accessCode, com.resulthub.api.security.VoteBoxTokenService tokenService) {
        VoteBox box = voteBoxRepository.findById(voteBoxId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "VoteBox not found"));

        if (box.getVisibility() != VoteBox.VoteBoxVisibility.PASSWORD_PROTECTED) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Vote box is not password protected");
        }

        if (box.getAccessCode() == null || !box.getAccessCode().equals(accessCode)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid access code");
        }

        return tokenService.generateToken(box.getId().toString());
    }

    private VoteBoxResponse mapToResponse(VoteBox box, UUID currentUserId) {
        List<VoteOption> options = voteOptionRepository.findByVoteBoxIdOrderByDisplayOrderAsc(box.getId());
        long totalVotes = options.stream().mapToLong(VoteOption::getVoteCount).sum();

        boolean hasVoted = false;
        UUID selectedOptionId = null;

        if (currentUserId != null) {
            var responseOptional = voteResponseRepository.findByVoteBoxIdAndUserId(box.getId(), currentUserId);
            if (responseOptional.isPresent()) {
                hasVoted = true;
                selectedOptionId = responseOptional.get().getOption().getId();
            }
        }

        // Schema doesn't have hideResultsUntilEnd, so defaulting to false
        boolean hideResultsUntilEnd = false;
        
        List<VoteBoxResponse.OptionResponse> optionResponses = options.stream()
                .map(opt -> new VoteBoxResponse.OptionResponse(
                        opt.getId(),
                        opt.getOptionText(),
                        opt.getVoteCount().longValue()
                ))
                .collect(Collectors.toList());

        return new VoteBoxResponse(
                box.getId(),
                box.getTitle(),
                box.getDescription(),
                box.getVisibility(),
                box.getAllowAnonymous(),
                box.getEndsAt(),
                box.getLinkedWorkspace() != null ? box.getLinkedWorkspace().getId() : null,
                hideResultsUntilEnd,
                totalVotes,
                box.getCreatedAt(),
                optionResponses,
                hasVoted,
                selectedOptionId
        );
    }
}
