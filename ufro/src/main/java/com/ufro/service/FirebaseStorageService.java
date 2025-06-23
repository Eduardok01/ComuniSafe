package com.ufro.service;

import com.google.cloud.storage.*;
import com.google.firebase.cloud.StorageClient;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.util.UUID;



@Service
public class FirebaseStorageService {
    private static final String BUCKET_NAME = "comunisafe-f8f8d.appspot.com";
    private static final String PROFILE_PHOTOS_PATH = "profile-photos/";

    public String uploadProfilePhoto(MultipartFile file, String userId) throws IOException {
        String fileName = PROFILE_PHOTOS_PATH + userId + "_" + UUID.randomUUID().toString();

        Bucket bucket = StorageClient.getInstance().bucket(BUCKET_NAME);
        BlobId blobId = BlobId.of(BUCKET_NAME, fileName);
        BlobInfo blobInfo = BlobInfo.newBuilder(blobId)
                .setContentType(file.getContentType())
                .build();

        bucket.getStorage().create(blobInfo, file.getBytes());

        return String.format("https://storage.googleapis.com/%s/%s", BUCKET_NAME, fileName);
    }

    public void deleteProfilePhoto(String photoUrl) {
        if (photoUrl != null && photoUrl.contains(BUCKET_NAME)) {
            String fileName = photoUrl.substring(photoUrl.indexOf(BUCKET_NAME) + BUCKET_NAME.length() + 1);
            Bucket bucket = StorageClient.getInstance().bucket(BUCKET_NAME);
            Blob blob = bucket.get(fileName);
            if (blob != null) {
                blob.delete();
            }
        }
    }

    public String uploadReportPhoto(MultipartFile file, String reporteId) throws IOException {
        String fileName = "report-photos/" + reporteId + "_" + UUID.randomUUID().toString();

        Bucket bucket = StorageClient.getInstance().bucket(BUCKET_NAME);
        BlobId blobId = BlobId.of(BUCKET_NAME, fileName);
        BlobInfo blobInfo = BlobInfo.newBuilder(blobId)
                .setContentType(file.getContentType())
                .build();

        bucket.getStorage().create(blobInfo, file.getBytes());

        return String.format("https://storage.googleapis.com/%s/%s", BUCKET_NAME, fileName);
    }

}
