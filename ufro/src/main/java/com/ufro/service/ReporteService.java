package com.ufro.service;

import com.ufro.model.Reporte;
import com.google.api.core.ApiFuture;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.WriteResult;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.stereotype.Service;

import java.time.ZoneOffset;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@Service
public class ReporteService {

    private static final String COLLECTION_NAME = "reportes";

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

    // Aquí podrías agregar métodos para obtener, actualizar, borrar reportes...
}
