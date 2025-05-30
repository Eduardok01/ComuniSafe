package com.ufro.controller;

import com.ufro.model.Incidente;
import com.ufro.service.IncidenteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/incidentes")
@CrossOrigin(origins = "*") // Permitir peticiones desde el frontend
public class IncidenteController {

    @Autowired
    private IncidenteService incidenteService;

    @PostMapping
    public ResponseEntity<String> reportar(@RequestBody Incidente incidente) {
        incidenteService.guardarIncidente(incidente);
        return ResponseEntity.ok("Incidente reportado");
    }

    @GetMapping
    public ResponseEntity<List<Incidente>> obtenerTodos() {
        return ResponseEntity.ok(incidenteService.obtenerTodos());
    }
}
