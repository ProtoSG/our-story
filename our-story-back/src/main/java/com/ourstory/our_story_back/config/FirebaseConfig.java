package com.ourstory.our_story_back.config;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.cloud.storage.Storage;
import com.google.cloud.storage.StorageOptions;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.cloud.StorageClient;

import lombok.extern.slf4j.Slf4j;

@Configuration
@Slf4j
public class FirebaseConfig {

    @Value("${firebase.project-id:#{null}}")
    private String projectId;

    @Value("${firebase.private-key:#{null}}")
    private String privateKey;

    @Value("${firebase.private-key-id:#{null}}")
    private String privateKeyId;

    @Value("${firebase.client-email:#{null}}")
    private String clientEmail;

    @Value("${firebase.client-id:#{null}}")
    private String clientId;

    @Value("${firebase.credentials-path:#{null}}")
    private String credentialsPath;

    @Value("${firebase.bucket-name}")
    private String bucketName;

    private GoogleCredentials getCredentials() throws IOException {
        // If environment variables are provided, use them
        if (projectId != null && privateKey != null && clientEmail != null && clientId != null && privateKeyId != null) {
            log.info("Initializing Firebase with environment variables");
            
            // Construct complete service account JSON with all required fields
            String jsonCredentials = String.format(
                "{" +
                "\"type\": \"service_account\"," +
                "\"project_id\": \"%s\"," +
                "\"private_key_id\": \"%s\"," +
                "\"private_key\": \"%s\"," +
                "\"client_email\": \"%s\"," +
                "\"client_id\": \"%s\"," +
                "\"auth_uri\": \"https://accounts.google.com/o/oauth2/auth\"," +
                "\"token_uri\": \"https://oauth2.googleapis.com/token\"," +
                "\"auth_provider_x509_cert_url\": \"https://www.googleapis.com/oauth2/v1/certs\"," +
                "\"client_x509_cert_url\": \"https://www.googleapis.com/robot/v1/metadata/x509/%s\"," +
                "\"universe_domain\": \"googleapis.com\"" +
                "}",
                projectId,
                privateKeyId,
                privateKey.replace("\\n", "\n"),
                clientEmail,
                clientId,
                clientEmail.replace("@", "%40")
            );
            
            return GoogleCredentials.fromStream(
                new ByteArrayInputStream(jsonCredentials.getBytes(StandardCharsets.UTF_8))
            );
        }
        
        // Fallback to credentials file if available
        if (credentialsPath != null && !credentialsPath.isEmpty()) {
            log.info("Initializing Firebase with credentials file: {}", credentialsPath);
            InputStream serviceAccount = new ClassPathResource(credentialsPath).getInputStream();
            return GoogleCredentials.fromStream(serviceAccount);
        }
        
        throw new IllegalStateException(
            "Firebase credentials not configured. Provide either:\n" +
            "1. Environment variables: FIREBASE_PROJECT_ID, FIREBASE_PRIVATE_KEY, FIREBASE_PRIVATE_KEY_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_CLIENT_ID\n" +
            "2. Credentials file path: FIREBASE_CREDENTIALS_PATH"
        );
    }

    @Bean
    public FirebaseApp initializeFirebase() throws IOException {
        if (FirebaseApp.getApps().isEmpty()) {
            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(getCredentials())
                    .setStorageBucket(bucketName)
                    .build();

            FirebaseApp app = FirebaseApp.initializeApp(options);
            log.info("Firebase initialized successfully with bucket: {}", bucketName);
            return app;
        }
        return FirebaseApp.getInstance();
    }

    @Bean
    public Storage firebaseStorage() throws IOException {
        initializeFirebase();
        return StorageOptions.newBuilder()
                .setCredentials(getCredentials())
                .setTransportOptions(
                    StorageOptions.getDefaultHttpTransportOptions().toBuilder()
                        .setConnectTimeout(60000)  // 60 seconds
                        .setReadTimeout(120000)    // 120 seconds
                        .build()
                )
                .build()
                .getService();
    }

    @Bean
    public StorageClient storageClient() throws IOException {
        initializeFirebase();
        return StorageClient.getInstance();
    }
}

