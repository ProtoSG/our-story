package com.ourstory.our_story_back.service.impl;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.google.cloud.storage.Blob;
import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.BlobInfo;
import com.google.cloud.storage.Storage;
import com.ourstory.our_story_back.service.FirebaseStorageService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class FirebaseStorageServiceImpl implements FirebaseStorageService {

    private final Storage storage;

    @Value("${firebase.bucket-name}")
    private String bucketName;

    @Override
    public String uploadFile(MultipartFile file, String folder) throws IOException {
        // Validate file
        if (file.isEmpty()) {
            throw new IllegalArgumentException("File is empty");
        }

        // Get original filename and create unique name
        String originalFilename = file.getOriginalFilename();
        if (originalFilename == null) {
            originalFilename = "file";
        }
        
        // Extract file extension
        String extension = "";
        int lastDotIndex = originalFilename.lastIndexOf('.');
        if (lastDotIndex > 0) {
            extension = originalFilename.substring(lastDotIndex);
        }

        // Generate unique filename
        String uniqueFileName = UUID.randomUUID().toString() + extension;
        String filePath = folder + "/" + uniqueFileName;

        log.info("Uploading file to Firebase Storage: {}", filePath);

        // Create blob
        BlobId blobId = BlobId.of(bucketName, filePath);
        BlobInfo blobInfo = BlobInfo.newBuilder(blobId)
                .setContentType(file.getContentType())
                .build();

        // Upload file
        Blob blob = storage.create(blobInfo, file.getBytes());

        // Make file publicly accessible
        blob.createAcl(com.google.cloud.storage.Acl.of(
                com.google.cloud.storage.Acl.User.ofAllUsers(),
                com.google.cloud.storage.Acl.Role.READER));

        // Generate public URL
        String publicUrl = String.format(
                "https://firebasestorage.googleapis.com/v0/b/%s/o/%s?alt=media",
                bucketName,
                URLEncoder.encode(filePath, StandardCharsets.UTF_8));

        log.info("File uploaded successfully: {}", publicUrl);
        return publicUrl;
    }

    @Override
    public boolean deleteFile(String fileUrl) {
        try {
            String fileName = getFileNameFromUrl(fileUrl);
            if (fileName == null) {
                log.warn("Could not extract file name from URL: {}", fileUrl);
                return false;
            }

            BlobId blobId = BlobId.of(bucketName, fileName);
            boolean deleted = storage.delete(blobId);

            if (deleted) {
                log.info("File deleted successfully: {}", fileName);
            } else {
                log.warn("File not found: {}", fileName);
            }

            return deleted;
        } catch (Exception e) {
            log.error("Error deleting file from Firebase Storage", e);
            return false;
        }
    }

    @Override
    public String getFileNameFromUrl(String fileUrl) {
        try {
            // Extract file path from Firebase Storage URL
            // URL format: https://firebasestorage.googleapis.com/v0/b/{bucket}/o/{path}?alt=media
            if (fileUrl.contains("/o/")) {
                String[] parts = fileUrl.split("/o/");
                if (parts.length > 1) {
                    String encodedPath = parts[1].split("\\?")[0];
                    return java.net.URLDecoder.decode(encodedPath, StandardCharsets.UTF_8);
                }
            }
            return null;
        } catch (Exception e) {
            log.error("Error extracting file name from URL", e);
            return null;
        }
    }
}
