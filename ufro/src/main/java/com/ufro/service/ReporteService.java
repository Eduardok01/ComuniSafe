package com.ufro.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import com.ufro.dto.ReporteConUsuarioDTO;
import com.ufro.model.Reporte;
import org.springframework.stereotype.Service;

import java.time.ZoneOffset;
import java.util.*;
import java.util.concurrent.ExecutionException;

@Service
public class ReporteService {

    private static final String COLLECTION_NAME = "reportes";

    public String crearReporte(Reporte reporte) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        String id = db.collection(COLLECTION_NAME).document().getId();
        DocumentReference docRef = db.collection(COLLECTION_NAME).document(id);
        reporte.setId(id);
        reporte.setPendiente(true);

        Map<String, Object> datos = construirMapaReporte(reporte);

        ApiFuture<WriteResult> future = docRef.set(datos);
        future.get();
        return id;
    }

    public boolean actualizarReporte(String id, Reporte reporte) {
        try {
            Firestore db = FirestoreClient.getFirestore();
            DocumentReference docRef = db.collection(COLLECTION_NAME).document(id);
            Map<String, Object> datos = construirMapaReporte(reporte);
            docRef.set(datos);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean eliminarReporte(String id) {
        try {
            Firestore db = FirestoreClient.getFirestore();
            db.collection(COLLECTION_NAME).document(id).delete();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Reporte> obtenerReportesPorTipo(String tipo) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        QuerySnapshot querySnapshot = db.collection(COLLECTION_NAME)
                .whereEqualTo("tipo", tipo)
                .get()
                .get();

        List<Reporte> lista = new ArrayList<>();
        for (QueryDocumentSnapshot doc : querySnapshot.getDocuments()) {
            Map<String, Object> data = doc.getData();

            Reporte reporte = new Reporte();
            reporte.setId(doc.getId());
            reporte.setTipo((String) data.get("tipo"));
            reporte.setDescripcion((String) data.get("descripcion"));
            reporte.setPendiente((Boolean) data.get("pendiente"));
            reporte.setLatitud(data.get("latitud") != null ? ((Number) data.get("latitud")).doubleValue() : null);
            reporte.setLongitud(data.get("longitud") != null ? ((Number) data.get("longitud")).doubleValue() : null);
            reporte.setDireccion((String) data.get("direccion"));

            Timestamp ts = (Timestamp) data.get("fechaHora");
            if (ts != null) {
                reporte.setFechaHora(ts.toDate().toInstant().atZone(ZoneOffset.UTC).toLocalDateTime());
            } else {
                reporte.setFechaHora(null);
            }

            reporte.setUsuarioId((String) data.get("usuarioId"));

            lista.add(reporte);
        }
        return lista;
    }

    public long contarReportesPorTipo(String tipo) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        AggregateQuery countQuery = db.collection(COLLECTION_NAME)
                .whereEqualTo("tipo", tipo)
                .count();
        AggregateQuerySnapshot snapshot = countQuery.get().get();
        return snapshot.getCount();
    }

    public List<ReporteConUsuarioDTO> obtenerReportesConUsuarioPorTipo(String tipo) throws ExecutionException, InterruptedException {
        List<Reporte> reportes = obtenerReportesPorTipo(tipo);
        List<ReporteConUsuarioDTO> listaDTO = new ArrayList<>();
        Firestore db = FirestoreClient.getFirestore();

        for (Reporte reporte : reportes) {
            String uid = reporte.getUsuarioId();
            String nombre = "Desconocido";
            String correo = "Desconocido";
            String rol = "Desconocido";

            try {
                DocumentSnapshot userDoc = db.collection("usuarios").document(uid).get().get();
                if (userDoc.exists()) {
                    nombre = userDoc.getString("name");
                    correo = userDoc.getString("correo");
                    rol = userDoc.getString("rol");
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            ReporteConUsuarioDTO dto = new ReporteConUsuarioDTO();
            dto.setId(reporte.getId()); // Aquí asignamos el ID importante para la eliminación en frontend
            dto.setTipo(reporte.getTipo());
            dto.setDescripcion(reporte.getDescripcion());
            dto.setPendiente(reporte.getPendiente());
            dto.setLatitud(reporte.getLatitud());
            dto.setLongitud(reporte.getLongitud());
            dto.setDireccion(reporte.getDireccion());
            dto.setFechaHora(Timestamp.ofTimeSecondsAndNanos(
                    reporte.getFechaHora().toEpochSecond(ZoneOffset.UTC),
                    reporte.getFechaHora().getNano()
            ));
            dto.setUsuarioId(reporte.getUsuarioId());
            dto.setNombreUsuario(nombre);
            dto.setCorreoUsuario(correo);
            dto.setRolUsuario(rol);

            listaDTO.add(dto);
        }

        return listaDTO;
    }

    private Map<String, Object> construirMapaReporte(Reporte reporte) {
        Map<String, Object> datos = new HashMap<>();
        datos.put("id", reporte.getId());
        datos.put("tipo", reporte.getTipo());
        datos.put("descripcion", reporte.getDescripcion());
        datos.put("pendiente", reporte.getPendiente());
        datos.put("latitud", reporte.getLatitud());
        datos.put("longitud", reporte.getLongitud());
        datos.put("direccion", reporte.getDireccion());

        if (reporte.getFechaHora() != null) {
            long epochSecond = reporte.getFechaHora().atZone(ZoneOffset.UTC).toInstant().getEpochSecond();
            int nano = reporte.getFechaHora().getNano();
            datos.put("fechaHora", Timestamp.ofTimeSecondsAndNanos(epochSecond, nano));
        } else {
            datos.put("fechaHora", null);
        }

        datos.put("usuarioId", reporte.getUsuarioId());
        return datos;
    }
    public List<Reporte> obtenerTodosLosReportesActivos() throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        QuerySnapshot querySnapshot = db.collection(COLLECTION_NAME)
                .whereEqualTo("pendiente", true)
                .get()
                .get();

        List<Reporte> lista = new ArrayList<>();
        for (QueryDocumentSnapshot doc : querySnapshot.getDocuments()) {
            Map<String, Object> data = doc.getData();

            Reporte reporte = new Reporte();
            reporte.setId(doc.getId());
            reporte.setTipo((String) data.get("tipo"));
            reporte.setDescripcion((String) data.get("descripcion"));
            reporte.setPendiente((Boolean) data.get("pendiente"));
            reporte.setLatitud(data.get("latitud") != null ? ((Number) data.get("latitud")).doubleValue() : null);
            reporte.setLongitud(data.get("longitud") != null ? ((Number) data.get("longitud")).doubleValue() : null);
            reporte.setDireccion((String) data.get("direccion"));

            Timestamp ts = (Timestamp) data.get("fechaHora");
            if (ts != null) {
                reporte.setFechaHora(ts.toDate().toInstant().atZone(ZoneOffset.UTC).toLocalDateTime());
            } else {
                reporte.setFechaHora(null);
            }

            reporte.setUsuarioId((String) data.get("usuarioId"));

            lista.add(reporte);
        }

        return lista;
    }


    public List<Reporte> obtenerReportesActivosPorUsuario(String usuarioId) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        QuerySnapshot querySnapshot = db.collection(COLLECTION_NAME)
                .whereEqualTo("usuarioId", usuarioId)
                .whereEqualTo("pendiente", true)
                .get()
                .get();

        List<Reporte> lista = new ArrayList<>();
        for (QueryDocumentSnapshot doc : querySnapshot.getDocuments()) {
            Map<String, Object> data = doc.getData();

            Reporte reporte = new Reporte();
            reporte.setId(doc.getId());
            reporte.setTipo((String) data.get("tipo"));
            reporte.setDescripcion((String) data.get("descripcion"));
            reporte.setPendiente((Boolean) data.get("pendiente"));
            reporte.setLatitud(data.get("latitud") != null ? ((Number) data.get("latitud")).doubleValue() : null);
            reporte.setLongitud(data.get("longitud") != null ? ((Number) data.get("longitud")).doubleValue() : null);
            reporte.setDireccion((String) data.get("direccion"));

            Timestamp ts = (Timestamp) data.get("fechaHora");
            if (ts != null) {
                reporte.setFechaHora(ts.toDate().toInstant().atZone(ZoneOffset.UTC).toLocalDateTime());
            } else {
                reporte.setFechaHora(null);
            }

            reporte.setUsuarioId((String) data.get("usuarioId"));

            lista.add(reporte);
        }
        return lista;
    }


}
