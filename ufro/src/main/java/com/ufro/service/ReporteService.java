package com.ufro.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import com.ufro.model.Reporte;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

@Service
public class ReporteService {

    private static final String COLLECTION_NAME = "reportes";

    public String crearReporte(Reporte reporte) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        DocumentReference docRef = db.collection(COLLECTION_NAME).document();
        ApiFuture<WriteResult> future = docRef.set(reporte);
        return "Reporte creado en: " + future.get().getUpdateTime();
    }

    public String actualizarEstado(String id, String nuevoEstado) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        DocumentReference docRef = db.collection(COLLECTION_NAME).document(id);
        ApiFuture<WriteResult> future = docRef.update("estado", nuevoEstado);
        return "Estado actualizado en: " + future.get().getUpdateTime();
    }

    public Reporte obtenerReporte(String id) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        DocumentSnapshot snapshot = db.collection(COLLECTION_NAME).document(id).get().get();
        return snapshot.exists() ? snapshot.toObject(Reporte.class) : null;
    }

    public List<Reporte> obtenerTodosLosReportes() throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        ApiFuture<QuerySnapshot> future = db.collection(COLLECTION_NAME).get();
        return future.get().getDocuments().stream()
                .map(doc -> doc.toObject(Reporte.class))
                .collect(Collectors.toList());
    }
}
