package com.ufro.controller;

import com.ufro.model.Reporte;
import com.ufro.service.ReporteService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@CrossOrigin(origins = {"http://localhost:8080", "http://192.168.0.19"})
@RestController
@RequestMapping("/api/reportes")
public class ReporteController {

    private final ReporteService reporteService;

    public ReporteController(ReporteService reporteService) {
        this.reporteService = reporteService;
    }

    @PostMapping
    public ResponseEntity<?> crearReporte(@RequestBody Reporte reporte) {
        try {
            // Validaciones simples
            if (reporte.getTipo() == null || reporte.getTipo().isEmpty()) {
                return ResponseEntity.badRequest().body("El tipo de reporte es obligatorio");
            }
            if (reporte.getLatitud() == null || reporte.getLongitud() == null) {
                return ResponseEntity.badRequest().body("La ubicación es obligatoria");
            }

            String id = reporteService.crearReporte(reporte);

            Map<String, Object> respuesta = new HashMap<>();
            respuesta.put("mensaje", "Reporte creado exitosamente");
            respuesta.put("id", id);

            return ResponseEntity.ok(respuesta);

        } catch (ExecutionException | InterruptedException e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Error al crear el reporte: " + e.getMessage());
        }
    }

    // Otros endpoints como GET, PUT, DELETE pueden ir acá
}
