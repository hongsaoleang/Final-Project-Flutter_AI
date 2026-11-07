package com.example.ai.repository;

import com.example.ai.model.testDB;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TestDbRepository extends JpaRepository<testDB, Long> {
}
