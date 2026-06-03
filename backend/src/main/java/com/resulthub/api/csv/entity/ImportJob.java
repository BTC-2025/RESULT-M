package com.resulthub.api.csv.entity;

import com.resulthub.api.csv.enums.ImportStatus;
import com.resulthub.api.dataset.entity.Dataset;
import com.resulthub.api.user.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "import_jobs")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ImportJob {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dataset_id", nullable = false)
    private Dataset dataset;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "uploaded_by")
    private User uploadedBy;

    @Column(nullable = false)
    private String filename;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    private ImportStatus status = ImportStatus.PENDING;

    private Integer totalRows = 0;
    private Integer successfulRows = 0;
    private Integer failedRows = 0;

    private String errorFilePath;

    private LocalDateTime startedAt;
    private LocalDateTime completedAt;
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        if (status == null) status = ImportStatus.PENDING;
        if (totalRows == null) totalRows = 0;
        if (successfulRows == null) successfulRows = 0;
        if (failedRows == null) failedRows = 0;
    }
}
