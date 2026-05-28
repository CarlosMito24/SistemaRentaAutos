/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.renta.modelos;

/**
 *
 * @author carlo
 */
public class Usuario {
    private int idUsuario;
    private String nombreCompleto;
    private String username;
    private String passwordUser;

    // Constructor vacío (Requerido para instanciar objetos limpios)
    public Usuario() {
    }

    // Constructor con parámetros
    public Usuario(int idUsuario, String nombreCompleto, String username, String passwordUser) {
        this.idUsuario = idUsuario;
        this.nombreCompleto = nombreCompleto;
        this.username = username;
        this.passwordUser = passwordUser;
    }

    // Métodos Getters y Setters (Encapsulamiento)
    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }

    public String getNombreCompleto() { return nombreCompleto; }
    public void setNombreCompleto(String nombreCompleto) { this.nombreCompleto = nombreCompleto; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPasswordUser() { return passwordUser; }
    public void setPasswordUser(String passwordUser) { this.passwordUser = passwordUser; }
}
