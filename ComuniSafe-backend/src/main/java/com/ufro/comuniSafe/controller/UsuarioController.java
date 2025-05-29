package com.ufro.comuniSafe.controller;

import com.ufro.comuniSafe.model.Usuario;
import com.ufro.comuniSafe.service.UsuarioService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpSession;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {

    private final UsuarioService service;

    public UsuarioController(UsuarioService service) {
        this.service = service;
    }

    @GetMapping
    public List<Usuario> getAllUsuarios() {
        return service.findAll();
    }

    @PostMapping
    public Usuario createUsuario(@RequestBody Usuario usuario) {
        return service.save(usuario);
    }

    @PostMapping("/logout")
    public ResponseEntity<String> logout(HttpSession session) {
        session.invalidate();
        return ResponseEntity.ok("Sesión cerrada correctamente.");
    }

    @PostMapping("/register")
    public ResponseEntity<String> register(@RequestBody Usuario usuario) {
        if (usuario.getCorreo() == null || usuario.getContrañesa() == null) {
            return ResponseEntity.badRequest().body("Todos los campos son obligatorios.");
        }

        if (service.existsByEmail(usuario.getCorreo())) {
            return ResponseEntity.badRequest().body("El correo ya está registrado.");
        }

        service.register(usuario);
        return ResponseEntity.ok("Usuario registrado exitosamente.");
    }

    @PostMapping("/login")
    public ResponseEntity<String> login(@RequestBody Usuario usuario, HttpSession session) {
        Optional<Usuario> usuarioOpt = service.authenticate(usuario.getCorreo(), usuario.getContrañesa());

        if (usuarioOpt.isPresent()) {
            session.setAttribute("usuario", usuarioOpt.get());
            return ResponseEntity.ok("Inicio de sesión exitoso.");
        } else {
            return ResponseEntity.status(401).body("Correo o contraseña incorrectos.");
        }
    }
}
