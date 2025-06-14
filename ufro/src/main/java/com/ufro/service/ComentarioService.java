package com.ufro.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import com.ufro.model.Comentario;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Date;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

@Service
public class ComentarioService {
    /*
    public String agregarComentario(String reporteId, Comentario comentario) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        CollectionReference comentariosRef = db.collection("reportes").document(reporteId).collection("comentarios");

        comentario.setFechaHora(Date.from(Instant.now()));
        DocumentReference nuevoComentario = comentariosRef.document();

        ApiFuture<WriteResult> future = nuevoComentario.set(comentario);
        return "Comentario agregado en: " + reporteId;
    }
     */

    public String agregarComentario(String reporteId, Comentario comentario) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();

        // Asignar fecha actual
        comentario.setFechaHora(Date.from(Instant.now()));

        // Ruta 1: Comentarios dentro del reporte
        CollectionReference comentariosReporteRef = db.collection("reportes")
                .document(reporteId)
                .collection("comentarios");
        DocumentReference nuevoComentarioReporte = comentariosReporteRef.document();

        // Ruta 2: Comentarios dentro del usuario (usando usuarioId del comentario)
        CollectionReference comentariosUsuarioRef = db.collection("usuarios")
                .document(comentario.getUsuarioId())
                .collection("comentarios");
        DocumentReference nuevoComentarioUsuario = comentariosUsuarioRef.document(nuevoComentarioReporte.getId());

        // Guardar en ambas rutas usando el mismo ID
        ApiFuture<WriteResult> future1 = nuevoComentarioReporte.set(comentario);
        ApiFuture<WriteResult> future2 = nuevoComentarioUsuario.set(comentario);

        // Esperar ambas operaciones
        future1.get();
        future2.get();

        return "Comentario agregado en: " + reporteId + " y en usuario: " + comentario.getUsuarioId();
    }


    public List<Comentario> obtenerComentarios(String reporteId) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        ApiFuture<QuerySnapshot> future = db.collection("reportes")
                .document(reporteId)
                .collection("comentarios")
                .orderBy("fechaHora", Query.Direction.ASCENDING)
                .get();

        return future.get().getDocuments().stream()
                .map(doc -> doc.toObject(Comentario.class))
                .collect(Collectors.toList());
    }
}
