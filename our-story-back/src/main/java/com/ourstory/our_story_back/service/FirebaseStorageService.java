package com.ourstory.our_story_back.service;

import java.io.IOException;

import org.springframework.web.multipart.MultipartFile;

public interface FirebaseStorageService {
    /**
     * Upload a file to Firebase Storage
     * 
     * @param file The file to upload
     * @param folder The folder path in Firebase Storage (e.g., "dates/123")
     * @return The public URL of the uploaded file
     * @throws IOException if upload fails
     */
    String uploadFile(MultipartFile file, String folder) throws IOException;

    /**
     * Delete a file from Firebase Storage
     * 
     * @param fileUrl The public URL of the file to delete
     * @return true if deleted successfully, false otherwise
     */
    boolean deleteFile(String fileUrl);

    /**
     * Get the file name from the URL
     * 
     * @param fileUrl The public URL
     * @return The file name
     */
    String getFileNameFromUrl(String fileUrl);
}
