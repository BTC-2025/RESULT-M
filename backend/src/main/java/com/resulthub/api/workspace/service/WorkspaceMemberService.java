package com.resulthub.api.workspace.service;

import com.resulthub.api.user.User;
import com.resulthub.api.workspace.dto.MemberResponse;
import com.resulthub.api.workspace.entity.WorkspaceMember;
import com.resulthub.api.workspace.enums.WorkspaceRole;
import com.resulthub.api.workspace.repository.WorkspaceMemberRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class WorkspaceMemberService {

    private final WorkspaceMemberRepository memberRepository;

    public List<MemberResponse> getMembers(UUID workspaceId, User user) {
        if (!memberRepository.existsByWorkspaceIdAndUserId(workspaceId, user.getId())) {
            throw new RuntimeException("Access denied. Must be a member to view other members.");
        }
        return memberRepository.findByWorkspaceId(workspaceId).stream()
                .map(member -> MemberResponse.builder()
                        .id(member.getId())
                        .userId(member.getUser().getId())
                        .name(member.getUser().getName())
                        .email(member.getUser().getEmail())
                        .role(member.getRole())
                        .joinedAt(member.getJoinedAt())
                        .build())
                .collect(Collectors.toList());
    }

    @Transactional
    public void changeMemberRole(UUID memberId, WorkspaceRole newRole, User executor) {
        WorkspaceMember targetMember = memberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("Member not found"));

        WorkspaceMember executorMember = memberRepository.findByWorkspaceIdAndUserId(targetMember.getWorkspace().getId(), executor.getId())
                .orElseThrow(() -> new RuntimeException("Access denied"));

        if (executorMember.getRole() != WorkspaceRole.OWNER) {
            throw new RuntimeException("Only OWNER can change member roles");
        }

        if (targetMember.getRole() == WorkspaceRole.OWNER) {
            throw new RuntimeException("Cannot change OWNER role");
        }

        targetMember.setRole(newRole);
        memberRepository.save(targetMember);
        log.info("AUDIT: MEMBER_ROLE_CHANGED - User {} changed role of {} to {} in Workspace {}", executor.getId(), targetMember.getUser().getId(), newRole, targetMember.getWorkspace().getId());
    }

    @Transactional
    public void removeMember(UUID memberId, User executor) {
        WorkspaceMember targetMember = memberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("Member not found"));

        WorkspaceMember executorMember = memberRepository.findByWorkspaceIdAndUserId(targetMember.getWorkspace().getId(), executor.getId())
                .orElseThrow(() -> new RuntimeException("Access denied"));

        if (executorMember.getRole() != WorkspaceRole.OWNER && executorMember.getRole() != WorkspaceRole.ADMIN) {
            throw new RuntimeException("Only OWNER or ADMIN can remove members");
        }

        if (targetMember.getRole() == WorkspaceRole.OWNER) {
            throw new RuntimeException("Cannot remove the OWNER");
        }

        memberRepository.delete(targetMember);
        log.info("AUDIT: MEMBER_REMOVED - User {} removed {} from Workspace {}", executor.getId(), targetMember.getUser().getId(), targetMember.getWorkspace().getId());
    }
}
