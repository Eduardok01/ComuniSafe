package com.ufro.controller;

import com.ufro.model.Usuario;
import com.ufro.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/usuarios")
@CrossOrigin(origins = "*") // Permitir peticiones desde el frontend
public class UsuarioController {

    @Autowired
    private UsuarioService usuarioService;

    // Obtener todos los usuarios
    @GetMapping
    public ResponseEntity<List<Usuario>> getAllUsuarios() {
        List<Usuario> usuarios = usuarioService.obtenerTodos();
        return ResponseEntity.ok(usuarios);
    }

    @PostMapping("/guardar")
    public ResponseEntity<String> guardarUsuario2(@RequestBody Usuario usuario) {
        try {
            usuarioService.guardarUsuario(usuario);
            return ResponseEntity.ok("Usuario guardado exitosamente.");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error al guardar el usuario: " + e.getMessage());
        }
    }
    @PostMapping
    public ResponseEntity<String> guardarUsuario(@RequestBody Usuario usuario) {

        usuarioService.guardarUsuario(usuario);
        return ResponseEntity.ok("Usuario guardado exitosamente.");

    }
}


