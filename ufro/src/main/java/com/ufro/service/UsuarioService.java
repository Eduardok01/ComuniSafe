package com.ufro.service;

import com.google.firebase.auth.*;
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

    public void borrarUsuario(String uid) throws Exception {
        // Eliminar en Firestore
        Firestore db = FirestoreClient.getFirestore();
        ApiFuture<WriteResult> future = db.collection(COLLECTION_NAME).document(uid).delete();

        try {
            future.get(); // Esperar a que termine la operación
            System.out.println("Usuario eliminado de Firestore: " + uid);
        } catch (InterruptedException | ExecutionException e) {
            throw new Exception("Error eliminando usuario en Firestore: " + e.getMessage());
        }

        // Eliminar en Firebase Authentication
        try {
            FirebaseAuth.getInstance().deleteUser(uid);
            System.out.println("Usuario eliminado de Firebase Auth: " + uid);
        } catch (FirebaseAuthException e) {
            throw new Exception("Error eliminando usuario en Firebase Auth: " + e.getMessage());
        }
    }

    public Usuario editarUsuario(String uid, Map<String, Object> datosActualizados) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        DocumentReference docRef = db.collection(COLLECTION_NAME).document(uid);

        // Verifica que exista
        DocumentSnapshot snapshot = docRef.get().get();
        if (!snapshot.exists()) {
            throw new IllegalArgumentException("Usuario no encontrado");
        }

        // Si se está actualizando el rol, actualizar también los custom claims en Firebase Auth
        if (datosActualizados.containsKey("rol")) {
            String nuevoRol = (String) datosActualizados.get("rol");
            try {
                FirebaseAuth.getInstance().setCustomUserClaims(uid, Map.of("role", nuevoRol));
                System.out.println("Custom claim 'role' actualizado para UID " + uid + " con valor: " + nuevoRol);
            } catch (FirebaseAuthException e) {
                System.err.println("Error actualizando custom claims en Firebase Auth: " + e.getMessage());
                // Podrías lanzar excepción o manejar el error según tu lógica
            }
        }

        // Aplica los cambios en Firestore
        docRef.update(datosActualizados).get();

        // Devuelve el usuario actualizado
        DocumentSnapshot updatedSnapshot = docRef.get().get();
        return updatedSnapshot.toObject(Usuario.class);
    }

    // Nuevo método para crear usuario desde Map
    public Usuario crearUsuario(Map<String, Object> nuevoUsuario) throws Exception {
        // Extraer datos del mapa
        String email = (String) nuevoUsuario.get("correo");
        String password = (String) nuevoUsuario.get("password");  // O puede venir en otro campo, depende de tu frontend
        String name = (String) nuevoUsuario.get("name");
        String phone = (String) nuevoUsuario.get("phone");
        String rol = (String) nuevoUsuario.getOrDefault("rol", "user");

        if (email == null || password == null) {
            throw new IllegalArgumentException("Email y password son requeridos");
        }

        // Crear usuario en Firebase Authentication
        UserRecord.CreateRequest request = new UserRecord.CreateRequest()
                .setEmail(email)
                .setEmailVerified(false)
                .setPassword(password)
                .setDisabled(false);

        UserRecord userRecord = FirebaseAuth.getInstance().createUser(request);
        String uid = userRecord.getUid();

        // Asignar rol custom claim
        FirebaseAuth.getInstance().setCustomUserClaims(uid, Map.of("role", rol));

        // Crear objeto Usuario para Firestore
        Usuario usuario = new Usuario();
        usuario.setUid(uid);
        usuario.setCorreo(email);
        usuario.setName(name != null ? name : "Nombre no asignado");
        usuario.setPhone(phone != null ? phone : "No disponible");
        usuario.setRol(rol);

        // Guardar en Firestore
        guardarUsuario(usuario);

        return usuario;
    }
}
