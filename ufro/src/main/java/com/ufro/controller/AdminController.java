package com.ufro.controller;

import com.google.firebase.auth.FirebaseAuthException;
import com.ufro.model.Usuario;
import com.ufro.service.UsuarioService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    private final UsuarioService usuarioService;

    public AdminController(UsuarioService usuarioService) {
        this.usuarioService = usuarioService;
    }

    @PostMapping("/asignar-rol")
    public ResponseEntity<String> asignarRol(@RequestParam String uid) {
        try {
            usuarioService.asignarRolAdmin(uid);
            return ResponseEntity.ok("Rol admin asignado");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error: " + e.getMessage());
        }
    }

    @PostMapping("/usuarios")
    public ResponseEntity<?> crearUsuario(
            @RequestHeader("Authorization") String authorizationHeader,
            @RequestBody Map<String, Object> nuevoUsuario) {
        try {
            Map<String, Object> claims = usuarioService.loginConToken(authorizationHeader);
            String role = (String) claims.get("role");
            if (!"admin".equals(role)) {
                return ResponseEntity.status(403).body("No autorizado");
            }

            Usuario usuarioCreado = usuarioService.crearUsuario(nuevoUsuario);
            return ResponseEntity.status(201).body(usuarioCreado);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error al crear usuario: " + e.getMessage());
        }
    }

    @DeleteMapping("/usuarios/{uid}")
    public ResponseEntity<String> eliminarUsuario(
            @RequestHeader("Authorization") String authorizationHeader,
            @PathVariable String uid) {
        try {
            Map<String, Object> claims = usuarioService.loginConToken(authorizationHeader);
            String role = (String) claims.get("role");
            if (!"admin".equals(role)) {
                return ResponseEntity.status(403).body("No autorizado");
            }

            usuarioService.borrarUsuario(uid);
            return ResponseEntity.ok("Usuario eliminado correctamente");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error al eliminar usuario: " + e.getMessage());
        }
    }

    @PatchMapping("/usuarios/{uid}")
    public ResponseEntity<?> editarUsuario(
            @RequestHeader("Authorization") String authorizationHeader,
            @PathVariable String uid,
            @RequestBody Map<String, Object> datosActualizados) {
        try {
            Map<String, Object> claims = usuarioService.loginConToken(authorizationHeader);
            String role = (String) claims.get("role");
            if (!"admin".equals(role)) {
                return ResponseEntity.status(403).body("No autorizado");
            }

            Usuario usuarioEditado = usuarioService.editarUsuario(uid, datosActualizados);
            return ResponseEntity.ok(usuarioEditado);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error al editar usuario: " + e.getMessage());
        }
    }

    @GetMapping("/usuarios")
    public ResponseEntity<List<Usuario>> listarUsuarios(@RequestHeader("Authorization") String token) throws FirebaseAuthException {
        Map<String, Object> claims = usuarioService.loginConToken(token);
        String role = (String) claims.get("role");
        if (!"admin".equals(role)) {
            return ResponseEntity.status(403).build();
        }
        return ResponseEntity.ok(usuarioService.obtenerTodos());
    }
}
