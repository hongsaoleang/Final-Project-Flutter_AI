package com.example.ai.model;

import jakarta.persistence.*;
import lombok.*;

/**
 * testDB
 */
@Entity
@Table(name = "testDB")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder 
public class testDB {
    @Id 
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(name = "username",nullable = false)
    private String username;
    @Column (name = "major" , nullable = false)
    private String major;

}