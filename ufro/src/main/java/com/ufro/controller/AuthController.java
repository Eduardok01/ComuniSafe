package com.ufro.controller;

import com.ufro.dto.RegisterRequest;
import com.ufro.model.Usuario;
import com.ufro.service.UsuarioService;
import com.google.firebase.auth.FirebaseAuthException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@CrossOrigin(origins = {
        "http://localhost:8080",
        "http://10.0.2.2:8080",
        "https://comunisafe.web.app",
        "https://comunisafe.app"
})
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UsuarioService usuarioService;

    public AuthController(UsuarioService usuarioService) {
        this.usuarioService = usuarioService;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestHeader("Authorization") String authorizationHeader) {
        try {
            Map<String, Object> response = usuarioService.loginConToken(authorizationHeader);
            System.out.println("Respuesta login: " + response);
            return ResponseEntity.ok(response);
        } catch (FirebaseAuthException e) {
            System.out.println("Error login: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token inválido o expirado.");
        }
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(
            @RequestHeader("Authorization") String authorizationHeader,
            @RequestBody RegisterRequest request) {
        try {
            Usuario usuario = usuarioService.registrarConToken(authorizationHeader, request);
            return ResponseEntity.status(HttpStatus.CREATED).body(usuario);
        } catch (FirebaseAuthException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token inválido o expirado.");
        }
    }

    // 🔥 NUEVO ENDPOINT: Obtener perfil del usuario autenticado
    @GetMapping("/perfil")
    public ResponseEntity<?> obtenerPerfil(@RequestHeader("Authorization") String authorizationHeader) {
        try {
            Usuario usuario = usuarioService.obtenerUsuarioConToken(authorizationHeader);
            if (usuario == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Usuario no encontrado.");
            }
            return ResponseEntity.ok(usuario);
        } catch (FirebaseAuthException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token inválido.");
        }
    }

    @PatchMapping("/actualizar")
    public ResponseEntity<?> actualizarUsuario(
            @RequestHeader("Authorization") String authorizationHeader,
            @RequestBody Usuario datosActualizados) {
        try {
            Usuario actualizado = usuarioService.actualizarDatosUsuario(authorizationHeader, datosActualizados);
            if (actualizado == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Usuario no encontrado.");
            }
            return ResponseEntity.ok(actualizado);
        } catch (FirebaseAuthException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token inválido.");
        }
    }

    //metodos para admins
    @PostMapping("/admin/register")
    public ResponseEntity<?> registerAdmin(
            @RequestHeader("Authorization") String authorizationHeader,
            @RequestBody RegisterRequest request) {
        try {
            Usuario usuario = usuarioService.registrarComoAdmin(authorizationHeader, request);
            return ResponseEntity.status(HttpStatus.CREATED).body(usuario);
        } catch (FirebaseAuthException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token inválido o expirado.");
        }
    }

    @GetMapping("/admin/usuarios")
    public ResponseEntity<?> obtenerTodosLosUsuarios(@RequestHeader("Authorization") String authorizationHeader) {
        try {
            if (!usuarioService.tieneRol(authorizationHeader, "admin")) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Acceso denegado. Solo administradores.");
            }

            return ResponseEntity.ok(usuarioService.obtenerTodos());
        } catch (FirebaseAuthException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token inválido.");
        }
    }

    @GetMapping("/admin/usuarios/{uid}")
    public ResponseEntity<?> obtenerUsuarioPorId(
            @RequestHeader("Authorization") String authorizationHeader,
            @PathVariable String uid) {
        try {
            if (!usuarioService.tieneRol(authorizationHeader, "admin")) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Acceso denegado. Solo administradores.");
            }

            Usuario usuario = usuarioService.obtenerUsuarioPorId(uid);
            if (usuario == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Usuario no encontrado.");
            }

            return ResponseEntity.ok(usuario);
        } catch (FirebaseAuthException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token inválido.");
        }
    }
}
