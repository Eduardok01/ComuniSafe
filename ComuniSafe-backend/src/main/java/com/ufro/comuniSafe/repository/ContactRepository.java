package com.ufro.comuniSafe.repository;

import com.ufro.comuniSafe.model.Contact;
import org.springframework.data.jpa.repository.JpaRepository;


public interface ContactRepository extends JpaRepository<Contact, Long> {
}
