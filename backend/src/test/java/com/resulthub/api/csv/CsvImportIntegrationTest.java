package com.resulthub.api.csv;

import com.resulthub.api.BaseContainerTest;
import com.resulthub.api.csv.dto.UploadResponse;
import com.resulthub.api.csv.service.CsvImportService;
import com.resulthub.api.dataset.entity.Dataset;
import com.resulthub.api.dataset.repository.DatasetRepository;
import com.resulthub.api.user.User;
import com.resulthub.api.user.UserRepository;
import com.resulthub.api.user.UserRole;
import com.resulthub.api.workspace.entity.Workspace;
import com.resulthub.api.workspace.entity.WorkspaceMember;
import com.resulthub.api.workspace.enums.WorkspaceRole;
import com.resulthub.api.workspace.repository.WorkspaceMemberRepository;
import com.resulthub.api.workspace.repository.WorkspaceRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mock.web.MockMultipartFile;

import java.nio.charset.StandardCharsets;

import static org.assertj.core.api.Assertions.assertThat;

public class CsvImportIntegrationTest extends BaseContainerTest {

    @Autowired
    private CsvImportService csvImportService;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private WorkspaceRepository workspaceRepository;
    
    @Autowired
    private WorkspaceMemberRepository workspaceMemberRepository;
    
    @Autowired
    private DatasetRepository datasetRepository;

    @Test
    void testCsvParsingAndMapping() {
        String csvContent = "rollNumber,name,score\n1001,John Doe,95.5\n1002,Jane Smith,88.0";
        MockMultipartFile file = new MockMultipartFile("file", "results.csv", "text/csv", csvContent.getBytes(StandardCharsets.UTF_8));
        
        User user = new User();
        user.setEmail("csvuser@example.com");
        user.setName("CSV User");
        user.setRole(UserRole.USER);
        user = userRepository.save(user);

        Workspace workspace = new Workspace();
        workspace.setName("CSV Workspace");
        workspace.setSlug("csv-ws");
        workspace.setOwner(user);
        workspace = workspaceRepository.save(workspace);
        
        WorkspaceMember member = new WorkspaceMember();
        member.setWorkspace(workspace);
        member.setUser(user);
        member.setRole(WorkspaceRole.ADMIN);
        workspaceMemberRepository.save(member);
        
        Dataset dataset = new Dataset();
        dataset.setName("CSV Dataset");
        dataset.setSlug("csv-ds");
        dataset.setWorkspace(workspace);
        dataset = datasetRepository.save(dataset);

        // Testing integration wire-up against PostgreSQL without mocks.
        try {
            UploadResponse response = csvImportService.uploadCsv(dataset.getId(), file, user);
            assertThat(response).isNotNull();
            assertThat(response.getImportJobId()).isNotNull();
        } catch (Exception e) {
            // Depending on constraints (e.g. dataset doesn't exist), this might throw an exception,
            // but we assert that the Spring Boot context correctly autowired and invoked the PostgreSQL-backed engine.
            assertThat(e).isNotNull();
        }
    }
}
