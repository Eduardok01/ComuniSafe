package com.ufro.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import com.ufro.model.Reporte;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

@Service
public class ReporteService {

    private static final String COLLECTION_NAME = "reportes";

    public String crearReporte(Reporte reporte) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        DocumentReference docRef = db.collection(COLLECTION_NAME).document();
        reporte.setPendiente(true);
        reporte.setFechaHora(Date.from(Instant.now()));
        ApiFuture<WriteResult> future = docRef.set(reporte);

        return "Reporte creado en: " + reporte.getTipo();
    }

    public String actualizarEstado(String id) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        DocumentReference docRef = db.collection(COLLECTION_NAME).document(id);
        ApiFuture<WriteResult> future = docRef.update("pendiente", false);
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

    public String eliminarReporte(String reporteId) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        ApiFuture<WriteResult> writeResult = db.collection("reportes").document(reporteId).delete();
        return "Reporte eliminado con éxito: " + reporteId;
    }

    public String editarReporte(String reporteId, Map<String, Object> camposActualizados) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        DocumentReference docRef = db.collection("reportes").document(reporteId);
        ApiFuture<WriteResult> future = docRef.update(camposActualizados);
        return "Campos actualizados en: " + future.get().getUpdateTime();
    }

//    public void guardarReporte(Usuario usuario) {
//        Firestore db = FirestoreClient.getFirestore();
//        ApiFuture<WriteResult> future = db.collection(COLLECTION_NAME)
//                .document(usuario.getUid())
//                .set(usuario);
//
//        try {
//            WriteResult result = future.get(); // Espera hasta que termine la escritura
//            System.out.println("Usuario guardado en Firestore: " + usuario.getUid() + " at " + result.getUpdateTime());
//        } catch (InterruptedException | ExecutionException e) {
//            System.err.println("Error guardando usuario en Firestore: " + e.getMessage());
//            e.printStackTrace();
//        }
//    }
}
