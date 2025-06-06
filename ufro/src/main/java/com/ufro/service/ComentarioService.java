package com.ufro.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import com.ufro.model.Comentario;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

@Service
public class ComentarioService {
    public String agregarComentario(String reporteId, Comentario comentario) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        CollectionReference comentariosRef = db.collection("reportes").document(reporteId).collection("comentarios");

        DocumentReference nuevoComentario = comentariosRef.document();
        comentario.setId(nuevoComentario.getId());

        ApiFuture<WriteResult> future = nuevoComentario.set(comentario);
        return "Comentario agregado en: " + future.get().getUpdateTime();
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
