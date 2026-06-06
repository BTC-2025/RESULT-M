package com.resulthub.api.voting.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "vote_options")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VoteOption {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vote_box_id", nullable = false)
    private VoteBox voteBox;

    @Column(name = "option_text", nullable = false, length = 255)
    private String optionText;

    @Column(name = "vote_count")
    @Builder.Default
    private Integer voteCount = 0;

    @Column(name = "display_order")
    @Builder.Default
    private Integer displayOrder = 0;
}
