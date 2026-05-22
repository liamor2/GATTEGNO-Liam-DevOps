package com.example.clicktracker;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/click")
public class ClickEventController {

    private final ClickEventService service;

    public ClickEventController(ClickEventService service) {
        this.service = service;
    }

    @PostMapping
    public ResponseEntity<ClickEventResponse> createClick(HttpServletRequest request) {
        String clientIp = resolveClientIp(request);
        ClickEvent event = service.recordClick(clientIp);
        return ResponseEntity.ok(ClickEventResponse.from(event));
    }

    static String resolveClientIp(HttpServletRequest request) {
        String forwardedFor = request.getHeader("X-Forwarded-For");
        if (forwardedFor != null && !forwardedFor.isBlank()) {
            return forwardedFor.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
