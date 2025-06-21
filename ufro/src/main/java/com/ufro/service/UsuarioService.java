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
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.*;
import java.util.concurrent.ExecutionException;

@Service
public class UsuarioService {

    private static final String COLLECTION_NAME = "usuarios";
    private final FirebaseAuthService authService;

    private final FirebaseStorageService storageService;


    public UsuarioService(FirebaseAuthService authService, FirebaseStorageService storageService
    ) {

        this.authService = authService;
        this.storageService = storageService;

    }

    public void guardarUsuario(Usuario usuario) {
        Firestore db = FirestoreClient.getFirestore();
        ApiFuture<WriteResult> future = db.collection(COLLECTION_NAME)
                .document(usuario.getUid())
                .set(usuario);

        try {
            WriteResult result = future.get();
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
        FirebaseToken decodedToken = authService.verifyIdToken(idToken);
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
        Firestore db = FirestoreClient.getFirestore();
        ApiFuture<WriteResult> future = db.collection(COLLECTION_NAME).document(uid).delete();
        future.get();
        System.out.println("Usuario eliminado de Firestore: " + uid);

        FirebaseAuth.getInstance().deleteUser(uid);
        System.out.println("Usuario eliminado de Firebase Auth: " + uid);
    }

    public Usuario editarUsuario(String uid, Map<String, Object> datosActualizados) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        DocumentReference docRef = db.collection(COLLECTION_NAME).document(uid);

        DocumentSnapshot snapshot = docRef.get().get();
        if (!snapshot.exists()) {
            throw new IllegalArgumentException("Usuario no encontrado");
        }

        // 🔒 Si se proporciona una nueva contraseña, actualizar en Firebase Auth
        if (datosActualizados.containsKey("password")) {
            String nuevaPassword = (String) datosActualizados.get("password");
            if (nuevaPassword != null && !nuevaPassword.isBlank()) {
                try {
                    UserRecord.UpdateRequest request = new UserRecord.UpdateRequest(uid)
                            .setPassword(nuevaPassword);
                    FirebaseAuth.getInstance().updateUser(request);
                    System.out.println("Contraseña actualizada para UID: " + uid);
                } catch (FirebaseAuthException e) {
                    System.err.println("Error actualizando contraseña: " + e.getMessage());
                    throw new RuntimeException("No se pudo actualizar la contraseña");
                }
            }
            datosActualizados.remove("password"); // No guardar la password en Firestore
        }

        // Rol
        if (datosActualizados.containsKey("rol")) {
            String nuevoRol = (String) datosActualizados.get("rol");
            try {
                FirebaseAuth.getInstance().setCustomUserClaims(uid, Map.of("role", nuevoRol));
                System.out.println("Custom claim 'role' actualizado para UID " + uid + " con valor: " + nuevoRol);
            } catch (FirebaseAuthException e) {
                System.err.println("Error actualizando custom claims: " + e.getMessage());
            }
        }

        docRef.update(datosActualizados).get();
        DocumentSnapshot updatedSnapshot = docRef.get().get();
        return updatedSnapshot.toObject(Usuario.class);
    }

    public Usuario crearUsuario(Map<String, Object> nuevoUsuario) throws Exception {
        String email = (String) nuevoUsuario.get("correo");
        String password = (String) nuevoUsuario.get("password");
        String name = (String) nuevoUsuario.get("name");
        String phone = (String) nuevoUsuario.get("phone");
        String rol = (String) nuevoUsuario.getOrDefault("rol", "user");

        if (email == null || password == null) {
            throw new IllegalArgumentException("Email y password son requeridos");
        }

        UserRecord.CreateRequest request = new UserRecord.CreateRequest()
                .setEmail(email)
                .setEmailVerified(false)
                .setPassword(password)
                .setDisabled(false);

        UserRecord userRecord = FirebaseAuth.getInstance().createUser(request);
        String uid = userRecord.getUid();

        FirebaseAuth.getInstance().setCustomUserClaims(uid, Map.of("role", rol));

        Usuario usuario = new Usuario();
        usuario.setUid(uid);
        usuario.setCorreo(email);
        usuario.setName(name != null ? name : "Nombre no asignado");
        usuario.setPhone(phone != null ? phone : "No disponible");
        usuario.setRol(rol);

        guardarUsuario(usuario);
        return usuario;
    }

    public Usuario actualizarPerfilConToken(String authorizationHeader, Map<String, Object> nuevosDatos) throws FirebaseAuthException {
        String idToken = authorizationHeader.replace("Bearer ", "").trim();
        FirebaseToken decodedToken = authService.verifyIdToken(idToken);
        String uid = decodedToken.getUid();

        Firestore db = FirestoreClient.getFirestore();
        DocumentReference docRef = db.collection(COLLECTION_NAME).document(uid);

        try {
            DocumentSnapshot snapshot = docRef.get().get();
            if (!snapshot.exists()) {
                throw new IllegalArgumentException("Usuario no encontrado.");
            }

            Map<String, Object> actualizables = new HashMap<>();
            if (nuevosDatos.containsKey("name")) {
                actualizables.put("name", nuevosDatos.get("name"));
            }
            if (nuevosDatos.containsKey("correo")) {
                actualizables.put("correo", nuevosDatos.get("correo"));
            }
            if (nuevosDatos.containsKey("phone")) {
                actualizables.put("phone", nuevosDatos.get("phone"));
            }

            if (!actualizables.isEmpty()) {
                docRef.update(actualizables).get();
            }

            return docRef.get().get().toObject(Usuario.class);

        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            throw new IllegalArgumentException("Error actualizando perfil.");
        }
    }

    public String actualizarFotoPerfil(String uid, MultipartFile foto) throws IOException, ExecutionException, InterruptedException {
        // Validación de parámetros
        if (foto == null || foto.isEmpty()) {
            throw new IllegalArgumentException("La foto no puede estar vacía");
        }
        if (uid == null || uid.trim().isEmpty()) {
            throw new IllegalArgumentException("El UID del usuario es requerido");
        }

        try {
            // Subir nueva foto
            String photoUrl = storageService.uploadProfilePhoto(foto, uid);

            // Actualizar el usuario en Firestore
            Firestore db = FirestoreClient.getFirestore();
            DocumentReference docRef = db.collection(COLLECTION_NAME).document(uid);

            // Obtener la URL anterior si existe
            DocumentSnapshot doc = docRef.get().get();
            if (doc.exists()) {
                String oldPhotoUrl = doc.getString("photoUrl");
                if (oldPhotoUrl != null) {
                    // Eliminar la foto anterior
                    storageService.deleteProfilePhoto(oldPhotoUrl);
                }
            }

            // Actualizar con la nueva URL
            docRef.update("photoUrl", photoUrl).get();

            return photoUrl;
        } catch (Exception e) {
            throw new RuntimeException("Error al actualizar la foto de perfil: " + e.getMessage(), e);
        }
    }


    public void eliminarFotoPerfil(String uid) throws ExecutionException, InterruptedException {
        if (uid == null || uid.trim().isEmpty()) {
            throw new IllegalArgumentException("El UID del usuario es requerido");
        }

        try {
            Firestore db = FirestoreClient.getFirestore();
            DocumentReference docRef = db.collection(COLLECTION_NAME).document(uid);

            DocumentSnapshot doc = docRef.get().get();
            if (doc.exists()) {
                String photoUrl = doc.getString("photoUrl");
                if (photoUrl != null) {
                    // Eliminar la foto del storage
                    storageService.deleteProfilePhoto(photoUrl);

                    // Actualizar el usuario sin foto
                    docRef.update("photoUrl", null).get();
                }
            } else {
                throw new IllegalArgumentException("Usuario no encontrado");
            }
        } catch (Exception e) {
            throw new RuntimeException("Error al eliminar la foto de perfil: " + e.getMessage(), e);
        }
    }
}


