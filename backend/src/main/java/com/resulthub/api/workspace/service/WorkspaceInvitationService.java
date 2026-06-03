package com.resulthub.api.workspace.service;

import com.resulthub.api.user.User;
import com.resulthub.api.user.UserRepository;
import com.resulthub.api.workspace.dto.InviteMemberRequest;
import com.resulthub.api.workspace.dto.InvitationResponse;
import com.resulthub.api.workspace.entity.Workspace;
import com.resulthub.api.workspace.entity.WorkspaceInvitation;
import com.resulthub.api.workspace.entity.WorkspaceMember;
import com.resulthub.api.workspace.enums.WorkspaceRole;
import com.resulthub.api.workspace.repository.WorkspaceInvitationRepository;
import com.resulthub.api.workspace.repository.WorkspaceMemberRepository;
import com.resulthub.api.workspace.repository.WorkspaceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class WorkspaceInvitationService {

    private final WorkspaceInvitationRepository invitationRepository;
    private final WorkspaceRepository workspaceRepository;
    private final WorkspaceMemberRepository memberRepository;
    private final UserRepository userRepository;

    @Transactional
    public InvitationResponse inviteMember(UUID workspaceId, InviteMemberRequest request, User inviter) {
        Workspace workspace = workspaceRepository.findByIdAndNotDeleted(workspaceId)
                .orElseThrow(() -> new RuntimeException("Workspace not found"));

        WorkspaceMember inviterMember = memberRepository.findByWorkspaceIdAndUserId(workspaceId, inviter.getId())
                .orElseThrow(() -> new RuntimeException("Must be a member to invite"));

        if (inviterMember.getRole() != WorkspaceRole.OWNER && inviterMember.getRole() != WorkspaceRole.ADMIN) {
            throw new RuntimeException("Access denied. Only OWNER or ADMIN can invite members.");
        }

        String token = UUID.randomUUID().toString();
        WorkspaceInvitation invitation = WorkspaceInvitation.builder()
                .workspace(workspace)
                .email(request.getEmail())
                .role(request.getRole())
                .token(token)
                .expiresAt(LocalDateTime.now().plusDays(7))
                .build();
        invitation = invitationRepository.save(invitation);

        log.info("AUDIT: MEMBER_INVITED - User {} invited {} to Workspace {}", inviter.getId(), request.getEmail(), workspaceId);

        return InvitationResponse.builder()
                .id(invitation.getId())
                .email(invitation.getEmail())
                .role(invitation.getRole())
                .token(invitation.getToken())
                .expiresAt(invitation.getExpiresAt())
                .status("PENDING")
                .build();
    }

    @Transactional
    public void acceptInvitation(String token, User user) {
        WorkspaceInvitation invitation = invitationRepository.findByToken(token)
                .orElseThrow(() -> new RuntimeException("Invalid invitation token"));

        if (invitation.getAcceptedAt() != null) {
            throw new RuntimeException("Invitation already accepted");
        }
        if (invitation.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("Invitation expired");
        }

        WorkspaceMember member = WorkspaceMember.builder()
                .workspace(invitation.getWorkspace())
                .user(user)
                .role(invitation.getRole())
                .build();
        memberRepository.save(member);

        invitation.setAcceptedAt(LocalDateTime.now());
        invitationRepository.save(invitation);

        log.info("AUDIT: INVITATION_ACCEPTED - User {} joined Workspace {}", user.getId(), invitation.getWorkspace().getId());
    }
}
