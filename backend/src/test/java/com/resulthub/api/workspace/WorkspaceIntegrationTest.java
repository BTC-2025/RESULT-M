package com.resulthub.api.workspace;

import com.resulthub.api.BaseContainerTest;
import com.resulthub.api.user.User;
import com.resulthub.api.user.UserRepository;
import com.resulthub.api.user.UserRole;
import com.resulthub.api.workspace.entity.Workspace;
import com.resulthub.api.workspace.repository.WorkspaceRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

public class WorkspaceIntegrationTest extends BaseContainerTest {

    @Autowired
    private WorkspaceRepository workspaceRepository;
    
    @Autowired
    private UserRepository userRepository;

    @Test
    void testWorkspaceCreationAndRetrieval() {
        User user = new User();
        user.setEmail("owner1@example.com");
        user.setName("Owner");
        user.setRole(UserRole.USER);
        user = userRepository.save(user);

        Workspace workspace = new Workspace();
        workspace.setName("Test University");
        workspace.setSlug("test-univ");
        workspace.setOwner(user);

        Workspace saved = workspaceRepository.save(workspace);

        assertThat(saved.getId()).isNotNull();

        Optional<Workspace> retrieved = workspaceRepository.findById(saved.getId());
        assertThat(retrieved).isPresent();
        assertThat(retrieved.get().getName()).isEqualTo("Test University");
    }
}
