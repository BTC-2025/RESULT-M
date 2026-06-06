package com.resulthub.api.voting.controller;

import com.resulthub.api.security.VoteBoxAuthToken;
import com.resulthub.api.security.VoteBoxTokenService;
import com.resulthub.api.user.User;
import com.resulthub.api.voting.dto.*;
import com.resulthub.api.voting.entity.VoteBox;
import com.resulthub.api.voting.service.VoteBoxService;
import com.resulthub.api.workspace.service.WorkspaceAccessService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/votes")
@RequiredArgsConstructor
public class VoteBoxController {

    private final VoteBoxService voteBoxService;
    private final VoteBoxTokenService voteBoxTokenService;
    private final WorkspaceAccessService workspaceAccessService;

    @GetMapping
    public ResponseEntity<Page<VoteBoxResponse>> getAllPublicVoteBoxes(Pageable pageable) {
        return ResponseEntity.ok(voteBoxService.getPublicVoteBoxes(pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<VoteBoxResponse> getVoteBox(
            @PathVariable UUID id,
            @AuthenticationPrincipal User user,
            Authentication authentication
    ) {
        VoteBox box = voteBoxService.getVoteBoxEntity(id);
        
        UUID userId = user != null ? user.getId() : null;

        if (box.getVisibility() == VoteBox.VoteBoxVisibility.PRIVATE) {
            validatePrivateVoteBoxAccess(box, user);
        } else if (box.getVisibility() == VoteBox.VoteBoxVisibility.PASSWORD_PROTECTED) {
            // Require voteBoxToken for this specific box
            if (user == null && !hasVoteBoxToken(authentication, id)) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Valid vote box token required");
            }
        }

        return ResponseEntity.ok(voteBoxService.getVoteBoxById(id, userId));
    }

    @PostMapping
    public ResponseEntity<VoteBoxResponse> createVoteBox(
            @Valid @RequestBody CreateVoteBoxRequest request,
            @AuthenticationPrincipal User user
    ) {
        if (user == null && request.visibility() == VoteBox.VoteBoxVisibility.PRIVATE) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Authentication required to create private vote box");
        }
        UUID creatorId = user != null ? user.getId() : null;
        return ResponseEntity.status(HttpStatus.CREATED).body(voteBoxService.createVoteBox(request, creatorId));
    }

    @PostMapping("/{id}/cast")
    public ResponseEntity<Void> castVote(
            @PathVariable UUID id,
            @Valid @RequestBody CastVoteRequest request,
            @AuthenticationPrincipal User user,
            Authentication authentication,
            HttpServletRequest servletRequest
    ) {
        VoteBox box = voteBoxService.getVoteBoxEntity(id);

        if (box.getVisibility() == VoteBox.VoteBoxVisibility.PRIVATE) {
            validatePrivateVoteBoxAccess(box, user);
        } else if (box.getVisibility() == VoteBox.VoteBoxVisibility.PASSWORD_PROTECTED) {
            if (user == null && !hasVoteBoxToken(authentication, id)) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Valid vote box token required");
            }
        }

        UUID userId = user != null ? user.getId() : null;
        String ipAddress = getClientIpAddress(servletRequest);
        String deviceFingerprint = request.deviceFingerprint();

        voteBoxService.castVote(id, request.optionId(), userId, ipAddress, deviceFingerprint);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{id}/results")
    public ResponseEntity<List<VoteResultsResponse>> getResults(
            @PathVariable UUID id,
            @AuthenticationPrincipal User user,
            Authentication authentication
    ) {
        VoteBox box = voteBoxService.getVoteBoxEntity(id);

        if (box.getVisibility() == VoteBox.VoteBoxVisibility.PRIVATE) {
            validatePrivateVoteBoxAccess(box, user);
        } else if (box.getVisibility() == VoteBox.VoteBoxVisibility.PASSWORD_PROTECTED) {
            if (user == null && !hasVoteBoxToken(authentication, id)) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Valid vote box token required");
            }
        }

        return ResponseEntity.ok(voteBoxService.getResults(id));
    }

    @PostMapping("/{id}/unlock")
    public ResponseEntity<TokenResponse> unlockVoteBox(
            @PathVariable UUID id,
            @Valid @RequestBody UnlockVoteBoxRequest request
    ) {
        String token = voteBoxService.unlockVoteBox(id, request.accessCode(), voteBoxTokenService);
        return ResponseEntity.ok(new TokenResponse(token));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteVoteBox(
            @PathVariable UUID id,
            @AuthenticationPrincipal User user
    ) {
        if (user == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Authentication required");
        }
        voteBoxService.deleteVoteBox(id, user.getId());
        return ResponseEntity.noContent().build();
    }

    private String getClientIpAddress(HttpServletRequest request) {
        String xForwardedForHeader = request.getHeader("X-Forwarded-For");
        if (xForwardedForHeader != null && !xForwardedForHeader.isEmpty()) {
            return xForwardedForHeader.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }

    private void validatePrivateVoteBoxAccess(VoteBox box, User user) {
        if (user == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "JWT required for private vote box");
        }

        if (box.getCreator() != null && box.getCreator().getId().equals(user.getId())) {
            return;
        }

        if (box.getLinkedWorkspace() != null
                && workspaceAccessService.isMember(box.getLinkedWorkspace().getId(), user)) {
            return;
        }

        throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Workspace membership required for private vote box");
    }

    private boolean hasVoteBoxToken(Authentication authentication, UUID voteBoxId) {
        return authentication instanceof VoteBoxAuthToken
                && voteBoxId.toString().equals(authentication.getPrincipal());
    }
}
