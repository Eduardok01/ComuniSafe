package com.ufro.service;

import com.ufro.dto.RegisterRequest;
import com.ufro.model.Usuario;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.ExecutionException;

@Service
public class UsuarioService {

    private static final String COLLECTION_NAME = "usuarios";
    private final FirebaseAuthService authService;

    public UsuarioService(FirebaseAuthService authService) {
        this.authService = authService;
    }

    public void guardarUsuario(Usuario usuario) {
        Firestore db = FirestoreClient.getFirestore();
        db.collection(COLLECTION_NAME)
                .document(usuario.getUid())
                .set(usuario);
    }

    public List<Usuario> obtenerTodos() {
        List<Usuario> usuarios = new ArrayList<>();
        Firestore db = FirestoreClient.getFirestore();
        ApiFuture<QuerySnapshot> future = db.collection(COLLECTION_NAME).get();
        try {
            for (QueryDocumentSnapshot document : future.get().getDocuments()) {
                usuarios.add(document.toObject(Usuario.class));
            }
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
        }
        return usuarios;
    }

    public Map<String, Object> loginConToken(String authorizationHeader) throws FirebaseAuthException {
        String idToken = authorizationHeader.replace("Bearer ", "").trim();
        FirebaseToken decodedToken = authService.verifyIdToken(idToken);

        Map<String, Object> response = new HashMap<>();
        response.put("uid", decodedToken.getUid());
        response.put("email", decodedToken.getEmail());
        return response;
    }

    public Usuario registrarConToken(String authorizationHeader, RegisterRequest request) throws FirebaseAuthException {
        String idToken = authorizationHeader.replace("Bearer ", "").trim();
        FirebaseToken decodedToken = authService.verifyIdToken(idToken);

        Usuario usuario = new Usuario();
        usuario.setUid(decodedToken.getUid());
        usuario.setCorreo(decodedToken.getEmail());
        usuario.setName(request.getName());
        usuario.setPhone(request.getPhone());
        usuario.setRol("user");

        guardarUsuario(usuario);
        return usuario;
    }
}
