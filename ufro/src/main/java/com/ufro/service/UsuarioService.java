package com.ufro.service;

import com.google.firebase.auth.FirebaseAuth;
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
        ApiFuture<WriteResult> future = db.collection(COLLECTION_NAME)
                .document(usuario.getUid())
                .set(usuario);

        try {
            WriteResult result = future.get(); // Espera hasta que termine la escritura
            System.out.println("Usuario guardado en Firestore: " + usuario.getUid() + " at " + result.getUpdateTime());
        } catch (InterruptedException | ExecutionException e) {
            System.err.println("Error guardando usuario en Firestore: " + e.getMessage());
            e.printStackTrace();
        }
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
        System.out.println("Token recibido: " + idToken);

        FirebaseToken decodedToken = authService.verifyIdToken(idToken);
        System.out.println("Token verificado. UID: " + decodedToken.getUid() + ", Email: " + decodedToken.getEmail());

        String uid = decodedToken.getUid();
        String email = decodedToken.getEmail();

        Object roleClaim = decodedToken.getClaims().get("role");
        String role = roleClaim != null ? roleClaim.toString() : null;

        Map<String, Object> response = new HashMap<>();
        response.put("uid", uid);
        response.put("email", email);
        response.put("role", role);

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

    // 🔥 MÉTODO MEJORADO: Obtener perfil y crear si no existe
    public Usuario obtenerUsuarioConToken(String authorizationHeader) throws FirebaseAuthException {
        String idToken = authorizationHeader.replace("Bearer ", "").trim();
        FirebaseToken decodedToken = authService.verifyIdToken(idToken);
        String uid = decodedToken.getUid();
        String email = decodedToken.getEmail();

        Firestore db = FirestoreClient.getFirestore();
        DocumentReference docRef = db.collection(COLLECTION_NAME).document(uid);

        try {
            DocumentSnapshot snapshot = docRef.get().get();
            if (snapshot.exists()) {
                return snapshot.toObject(Usuario.class);
            } else {
                // Crear nuevo usuario con datos básicos
                Usuario nuevoUsuario = new Usuario();
                nuevoUsuario.setUid(uid);
                nuevoUsuario.setCorreo(email);
                nuevoUsuario.setName("Nombre no asignado");
                nuevoUsuario.setPhone("No disponible");
                nuevoUsuario.setRol("user");

                guardarUsuario(nuevoUsuario);

                return nuevoUsuario;
            }
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            return null;
        }
    }

    public void asignarRolAdmin(String uid) throws Exception {
        FirebaseAuth.getInstance().setCustomUserClaims(uid, Map.of("role", "admin"));
        System.out.println("Rol admin asignado al usuario con UID: " + uid);
    }
}
