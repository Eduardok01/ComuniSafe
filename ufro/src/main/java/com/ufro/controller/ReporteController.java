package com.ufro.controller;

import com.ufro.model.Reporte;
import com.ufro.service.ReporteService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.ufro.dto.ReporteConUsuarioDTO;
import java.util.HashMap;
import java.util.List;
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

    @PutMapping("/{id}")
    public ResponseEntity<?> actualizarReporte(@PathVariable String id, @RequestBody Reporte reporte) {
        boolean actualizado = reporteService.actualizarReporte(id, reporte);
        if (actualizado) {
            return ResponseEntity.ok("Reporte actualizado correctamente");
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> eliminarReporte(@PathVariable String id) {
        boolean eliminado = reporteService.eliminarReporte(id);
        if (eliminado) {
            return ResponseEntity.ok("Reporte eliminado correctamente");
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/tipo/{tipo}")
    public ResponseEntity<?> obtenerReportesPorTipo(@PathVariable String tipo) {
        try {
            List<ReporteConUsuarioDTO> reportesFiltrados = reporteService.obtenerReportesConUsuarioPorTipo(tipo.toLowerCase());
            return ResponseEntity.ok(reportesFiltrados);
        } catch (ExecutionException | InterruptedException e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Error al obtener reportes por tipo: " + e.getMessage());
        }
    }

    // Nuevo endpoint para conteo
    @GetMapping("/count/{tipo}")
    public ResponseEntity<?> contarReportesPorTipo(@PathVariable String tipo) {
        try {
            long cantidad = reporteService.contarReportesPorTipo(tipo.toLowerCase());
            Map<String, Object> respuesta = new HashMap<>();
            respuesta.put("tipo", tipo);
            respuesta.put("cantidad", cantidad);
            return ResponseEntity.ok(respuesta);
        } catch (ExecutionException | InterruptedException e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Error al contar reportes por tipo: " + e.getMessage());
        }
    }
    @GetMapping("/usuario/{usuarioId}/activos")
    public ResponseEntity<?> obtenerReportesActivosPorUsuario(@PathVariable String usuarioId) {
        try {
            List<Reporte> reportes = reporteService.obtenerReportesActivosPorUsuario(usuarioId);
            return ResponseEntity.ok(reportes);
        } catch (ExecutionException | InterruptedException e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Error al obtener reportes: " + e.getMessage());
        }
    }

    @GetMapping("/activos")
    public ResponseEntity<?> obtenerTodosLosReportesActivos() {
        try {
            List<Reporte> reportes = reporteService.obtenerTodosLosReportesActivos();
            return ResponseEntity.ok(reportes);
        } catch (ExecutionException | InterruptedException e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Error al obtener reportes activos: " + e.getMessage());
        }
    }


}
