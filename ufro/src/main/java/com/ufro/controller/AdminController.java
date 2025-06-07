package com.ufro.controller;

import com.ufro.service.UsuarioService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
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
    @DeleteMapping("/usuarios/{uid}")
    public ResponseEntity<String> eliminarUsuario(
            //esta parte se encarga de proteger el endpoint, solo un admin puede borrar usuario
            //en caso de no estar seguro, se puede quitar
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
}
