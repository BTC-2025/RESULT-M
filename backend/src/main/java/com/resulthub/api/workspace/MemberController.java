package com.resulthub.api.workspace;

import com.resulthub.api.user.User;
import com.resulthub.api.workspace.dto.InvitationResponse;
import com.resulthub.api.workspace.dto.InviteMemberRequest;
import com.resulthub.api.workspace.dto.MemberResponse;
import com.resulthub.api.workspace.enums.WorkspaceRole;
import com.resulthub.api.workspace.service.WorkspaceInvitationService;
import com.resulthub.api.workspace.service.WorkspaceMemberService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class MemberController {

    private final WorkspaceMemberService memberService;
    private final WorkspaceInvitationService invitationService;

    @PostMapping("/workspaces/{id}/invite")
    public ResponseEntity<InvitationResponse> inviteMember(
            @PathVariable UUID id,
            @Valid @RequestBody InviteMemberRequest request,
            @AuthenticationPrincipal User user
    ) {
        return ResponseEntity.ok(invitationService.inviteMember(id, request, user));
    }

    @PostMapping("/invitations/{token}/accept")
    public ResponseEntity<Void> acceptInvitation(
            @PathVariable String token,
            @AuthenticationPrincipal User user
    ) {
        invitationService.acceptInvitation(token, user);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/workspaces/{id}/members")
    public ResponseEntity<List<MemberResponse>> getMembers(
            @PathVariable UUID id,
            @AuthenticationPrincipal User user
    ) {
        return ResponseEntity.ok(memberService.getMembers(id, user));
    }

    @PatchMapping("/members/{id}/role")
    public ResponseEntity<Void> changeRole(
            @PathVariable UUID id,
            @RequestParam WorkspaceRole newRole,
            @AuthenticationPrincipal User user
    ) {
        memberService.changeMemberRole(id, newRole, user);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/members/{id}")
    public ResponseEntity<Void> removeMember(
            @PathVariable UUID id,
            @AuthenticationPrincipal User user
    ) {
        memberService.removeMember(id, user);
        return ResponseEntity.noContent().build();
    }
}
