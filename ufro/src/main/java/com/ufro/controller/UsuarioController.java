package com.ufro.controller;

import com.ufro.service.UsuarioService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {
    private final UsuarioService usuarioService;

    public UsuarioController(UsuarioService usuarioService) {
        this.usuarioService = usuarioService;
    }

    @PostMapping("/{uid}/foto")
    public ResponseEntity<String> actualizarFotoPerfil(
            @PathVariable String uid,
            @RequestParam("foto") MultipartFile foto) {
        try {
            String photoUrl = usuarioService.actualizarFotoPerfil(uid, foto);
            return ResponseEntity.ok(photoUrl);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error al actualizar la foto: " + e.getMessage());
        }
    }

    @DeleteMapping("/{uid}/foto")
    public ResponseEntity<String> eliminarFotoPerfil(
            @PathVariable String uid) {
        try {
            usuarioService.eliminarFotoPerfil(uid);
            return ResponseEntity.ok("Foto de perfil eliminada exitosamente");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error al eliminar la foto: " + e.getMessage());
        }
    }
}
