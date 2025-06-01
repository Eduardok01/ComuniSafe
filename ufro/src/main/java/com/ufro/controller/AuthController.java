package com.ufro.controller;

import com.ufro.service.FirebaseAuthService;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.ufro.dto.RegisterRequest;

import java.util.HashMap;
import java.util.Map;

@CrossOrigin(origins = "http://localhost:60393")
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final FirebaseAuthService authService;

    public AuthController(FirebaseAuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestHeader("Authorization") String authorizationHeader) {
        try {
            // Extrae el token del header
            String idToken = authorizationHeader.replace("Bearer ", "").trim();

            // Verifica el token con Firebase Admin SDK
            FirebaseToken decodedToken = authService.verifyIdToken(idToken);

            // Puedes devolver datos del usuario si lo necesitas
            Map<String, Object> response = new HashMap<>();
            response.put("uid", decodedToken.getUid());
            response.put("email", decodedToken.getEmail());

            return ResponseEntity.ok(response);
        } catch (FirebaseAuthException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token inválido o expirado.");
        }
    }
    @PostMapping("/register")
    public ResponseEntity<?> register(
            @RequestHeader("Authorization") String authorizationHeader,
            @RequestBody RegisterRequest request) {

        try {
            String idToken = authorizationHeader.replace("Bearer ", "").trim();

            // Verifica el token con Firebase Admin SDK
            FirebaseToken decodedToken = authService.verifyIdToken(idToken);

            // Aquí puedes guardar el usuario en tu base de datos si lo deseas
            String uid = decodedToken.getUid();
            String email = decodedToken.getEmail();
            String name = request.getName();
            String phone = request.getPhone();

            System.out.println("Registrando usuario:");
            System.out.println("UID: " + uid);
            System.out.println("Email: " + email);
            System.out.println("Nombre: " + name);
            System.out.println("Teléfono: " + phone);

            // Aquí puedes almacenar esto en tu base de datos si tienes una.

            Map<String, Object> response = new HashMap<>();
            response.put("uid", uid);
            response.put("email", email);
            response.put("name", name);
            response.put("phone", phone);

            return ResponseEntity.status(HttpStatus.CREATED).body(response);

        } catch (FirebaseAuthException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token inválido o expirado.");
        }
    }
}
