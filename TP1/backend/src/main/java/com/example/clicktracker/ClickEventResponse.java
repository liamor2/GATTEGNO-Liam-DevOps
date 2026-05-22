package com.example.clicktracker;

import java.time.Instant;

public record ClickEventResponse(Long id, Instant pressedAt, String ipAddress) {

    static ClickEventResponse from(ClickEvent event) {
        return new ClickEventResponse(event.getId(), event.getPressedAt(), event.getIpAddress());
    }
}
