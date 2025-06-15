package com.ufro.util;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;
import com.google.cloud.Timestamp;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.ZoneOffset;

public class FirestoreTimestampDeserializer extends JsonDeserializer<Timestamp> {

    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss[.SSS]");

    @Override
    public Timestamp deserialize(JsonParser p, DeserializationContext ctxt) throws IOException {
        String dateString = p.getText();
        LocalDateTime localDateTime = LocalDateTime.parse(dateString, FORMATTER);
        long epochSeconds = localDateTime.toEpochSecond(ZoneOffset.UTC);
        int nanos = localDateTime.getNano();
        return Timestamp.ofTimeSecondsAndNanos(epochSeconds, nanos);
    }
}
