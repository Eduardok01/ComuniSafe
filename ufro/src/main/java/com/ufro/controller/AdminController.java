package com.ufro.controller;

import com.ufro.service.UsuarioService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

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
}
