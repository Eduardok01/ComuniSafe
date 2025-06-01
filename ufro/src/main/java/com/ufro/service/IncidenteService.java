package com.ufro.service;

import com.ufro.model.Incidente;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;

@Service
public class IncidenteService {

    private static final String COLLECTION_NAME = "incidentes";

    public void guardarIncidente(Incidente incidente) {
        Firestore db = FirestoreClient.getFirestore();
        db.collection(COLLECTION_NAME).add(incidente);
    }

    public List<Incidente> obtenerTodos() {
        List<Incidente> incidentes = new ArrayList<>();
        Firestore db = FirestoreClient.getFirestore();
        ApiFuture<QuerySnapshot> future = db.collection(COLLECTION_NAME).get();
        try {
            for (QueryDocumentSnapshot document : future.get().getDocuments()) {
                incidentes.add(document.toObject(Incidente.class));
            }
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
        }
        return incidentes;
    }
}
