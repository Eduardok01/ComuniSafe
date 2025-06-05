package com.ufro.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import com.google.firebase.cloud.FirestoreClient;
import com.ufro.model.Contact;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;

@Service
public class ContactService {

    private static final String COLLECTION_NAME = "contactos";

    public void guardarContactos(Contact contact) {
        Firestore db = FirestoreClient.getFirestore();
        db.collection(COLLECTION_NAME).add(contact);
    }

    public List<Contact> obtenerTodos() {
        List<Contact> contactos = new ArrayList<>();
        Firestore db = FirestoreClient.getFirestore();
        ApiFuture<QuerySnapshot> future = db.collection(COLLECTION_NAME).get();
        try {
            for (QueryDocumentSnapshot document : future.get().getDocuments()) {
                contactos.add(document.toObject(Contact.class));
            }
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
        }
        return contactos;
    }
}
