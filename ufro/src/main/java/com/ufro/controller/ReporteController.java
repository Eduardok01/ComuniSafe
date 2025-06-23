package com.ufro.controller;

import com.ufro.model.Reporte;
import com.ufro.service.ReporteService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

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

  /*
    @PostMapping("/crear")
    public ResponseEntity<?> crearReporte2(@RequestBody Reporte reporte) {
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
  */
  
    @PostMapping
    public String crearReporte(@RequestBody Reporte reporte) throws ExecutionException, InterruptedException {
        return reporteService.crearReporte(reporte);
    }

    @PutMapping("/{id}/estado")
    public String actualizarEstado(@PathVariable String id) throws ExecutionException, InterruptedException {
        return reporteService.actualizarEstado(id);
    }
/* servicio borrado
    @GetMapping
    public List<Reporte> obtenerTodosLosReportes() throws ExecutionException, InterruptedException {
        return reporteService.obtenerTodosLosReportes();
    }
*/
    @DeleteMapping("/{reporteId}")
    public String eliminarReporte(@PathVariable String reporteId) throws ExecutionException, InterruptedException {
        return reporteService.eliminarReporte(reporteId);
    }

    @DeleteMapping("/{reporteId}/foto")
    public ResponseEntity<String> eliminarFotoReporte(@PathVariable String reporteId) {
        try {
            reporteService.eliminarFotoReporte(reporteId);
            return ResponseEntity.ok("Foto del reporte eliminada correctamente");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error al eliminar la foto del reporte: " + e.getMessage());
        }
    }

    @PostMapping("/{reporteId}/foto")
    public ResponseEntity<String> actualizarFotoReporte(
            @PathVariable String reporteId,
            @RequestParam("foto") MultipartFile foto) {
        try {
            String photoUrl = reporteService.actualizarFotoReporte(reporteId, foto);
            return ResponseEntity.ok(photoUrl);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error al actualizar la foto del reporte: " + e.getMessage());
        }
    }


    @PatchMapping("/{reporteId}")
    public String editarParcialmente(@PathVariable String reporteId, @RequestBody Map<String, Object> campos) throws ExecutionException, InterruptedException {
        return reporteService.editarReporte(reporteId, campos);
    }
}
