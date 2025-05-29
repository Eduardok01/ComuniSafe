package com.ufro.comuniSafe.service;


import com.ufro.comuniSafe.model.Usuario;
import com.ufro.comuniSafe.repository.UsuarioRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class UsuarioService {
    private final UsuarioRepository repository;

    public UsuarioService(UsuarioRepository repository) {
        this.repository = repository;
    }

    public List<Usuario> findAll() {
        return repository.findAll();
    }

    public Usuario save(Usuario usuario) {
        return (Usuario) repository.save(usuario);
    }

    public void register(Usuario usuario) {
        // Aquí podrías encriptar la contraseña si quisieras
        repository.save(usuario);
    }

    public Optional<Usuario> authenticate(String correo, String password) {
        return repository.findByCorreoAndPassword(correo, password);
    }

    public boolean existsByEmail(String correo) {
        return repository.existsByCorreo(correo);
    }
}
