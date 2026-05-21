package com.example.clicktracker;

import jakarta.persistence.*;

import java.time.Instant;

@Entity
@Table(name = "click_events")
public class ClickEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "pressed_at", nullable = false)
    private Instant pressedAt;

    @Column(name = "ip_address", nullable = false, length = 128)
    private String ipAddress;

    public ClickEvent() {
    }

    public ClickEvent(Instant pressedAt, String ipAddress) {
        this.pressedAt = pressedAt;
        this.ipAddress = ipAddress;
    }

    public Long getId() {
        return id;
    }

    public Instant getPressedAt() {
        return pressedAt;
    }

    public void setPressedAt(Instant pressedAt) {
        this.pressedAt = pressedAt;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }
}
