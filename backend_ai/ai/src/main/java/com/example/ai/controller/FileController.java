package com.example.ai.controller;

import com.example.ai.model.UploadedFile;
import com.example.ai.repository.UploadedFileRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.*;

@RestController
@RequestMapping("/api/v1/files")
@RequiredArgsConstructor
public class FileController {

    private final UploadedFileRepository fileRepository;
    private final String uploadDir = "C:/Flutter_AI/storage/uploads";

    @PostMapping("/upload")
    public ResponseEntity<Map<String, Object>> uploadFile(@RequestParam("file") MultipartFile file) {
        try {
            File dir = new File(uploadDir);
            if (!dir.exists()) {
                dir.mkdirs();
            }

            String fileUuid = "file-" + UUID.randomUUID().toString().substring(0, 8);
            String originalName = file.getOriginalFilename() != null ? file.getOriginalFilename() : "unnamed";
            String extension = "";
            int dotIdx = originalName.lastIndexOf('.');
            if (dotIdx > 0) {
                extension = originalName.substring(dotIdx);
            }

            String targetFilename = fileUuid + extension;
            Path targetPath = Paths.get(uploadDir, targetFilename);
            Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);

            UploadedFile savedFile = UploadedFile.builder()
                    .fileUuid(fileUuid)
                    .originalName(originalName)
                    .contentType(file.getContentType())
                    .fileSize(file.getSize())
                    .storagePath(targetPath.toString())
                    .build();

            fileRepository.save(savedFile);

            Map<String, Object> resp = new HashMap<>();
            resp.put("fileUuid", fileUuid);
            resp.put("originalName", originalName);
            resp.put("contentType", file.getContentType());
            resp.put("size", file.getSize());
            resp.put("url", "/api/v1/files/" + fileUuid);
            return ResponseEntity.ok(resp);
        } catch (Exception e) {
            Map<String, Object> err = new HashMap<>();
            err.put("error", "File upload failed: " + e.getMessage());
            return ResponseEntity.internalServerError().body(err);
        }
    }

    @GetMapping("/{uuid}")
    public ResponseEntity<UploadedFile> getFileInfo(@PathVariable String uuid) {
        return fileRepository.findByFileUuid(uuid)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
