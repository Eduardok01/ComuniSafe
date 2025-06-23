package com.ufro.service;

import com.google.cloud.firestore.*;
import com.ufro.model.Reporte;
import com.google.api.core.ApiFuture;
import com.google.cloud.Timestamp;
import com.google.firebase.cloud.FirestoreClient;
import com.ufro.model.Reporte;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

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



    public List<Reporte> obtenerReportesPorUsuario(String uid) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        ApiFuture<QuerySnapshot> future = db.collection(COLLECTION_NAME)
                .whereEqualTo("usuarioId", uid)
                .orderBy("fechaHora", Query.Direction.DESCENDING)
                .get();

        List<Reporte> reportes = new ArrayList<>();
        QuerySnapshot snapshots = future.get();
        for (DocumentSnapshot doc : snapshots.getDocuments()) {
            reportes.add(doc.toObject(Reporte.class));
        }
        return reportes;
    }

  /*
   public String crearReporte(Reporte reporte) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        String id = db.collection(COLLECTION_NAME).document().getId(); // Genera ID
        DocumentReference docRef = db.collection(COLLECTION_NAME).document(id);
        reporte.setId(id);
        reporte.setPendiente(true);

        // Construir un Map para enviar datos, incluyendo la conversión correcta de fechaHora
        Map<String, Object> datos = new HashMap<>();
        datos.put("id", reporte.getId());
        datos.put("tipo", reporte.getTipo());
        datos.put("descripcion", reporte.getDescripcion());
        datos.put("pendiente", reporte.getPendiente());
        datos.put("latitud", reporte.getLatitud());
        datos.put("longitud", reporte.getLongitud());
        datos.put("direccion", reporte.getDireccion());

        // Convertir LocalDateTime a Timestamp Firestore usando toEpochSecond y getNano
        datos.put("fechaHora", Timestamp.ofTimeSecondsAndNanos(
                reporte.getFechaHora().toEpochSecond(ZoneOffset.UTC),
                reporte.getFechaHora().getNano()
        ));

        datos.put("usuarioId", reporte.getUsuarioId());

        ApiFuture<WriteResult> future = docRef.set(datos);
        future.get(); // Espera a que se complete la escritura
        return id;
    }
  */
  
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
