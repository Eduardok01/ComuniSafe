package com.ufro.comuniSafe.repository;

import com.ufro.comuniSafe.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UsuarioRepository extends JpaRepository {
    Optional<Usuario> findByCorreoAndPassword(String correo, String password);
    boolean existsByCorreo(String correo);
}
