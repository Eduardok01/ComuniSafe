package com.ufro.controller;
import com.ufro.model.Comentario;
import com.ufro.service.ComentarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/api/reportes/{reporteId}/comentarios")
@CrossOrigin(origins = "*") // Permitir peticiones desde el frontend
public class ComentarioController {

    @Autowired
    private  ComentarioService comentarioService;


    @PostMapping
    public String agregarComentario(@PathVariable String reporteId, @RequestBody Comentario comentario) throws ExecutionException, InterruptedException {
        return comentarioService.agregarComentario(reporteId, comentario);
    }

    @GetMapping
    public List<Comentario> obtenerComentarios(@PathVariable String reporteId) throws ExecutionException, InterruptedException {
        return comentarioService.obtenerComentarios(reporteId);
    }
}
