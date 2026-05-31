package com.renta.modelos;

/**
 *
 * @author carlo
 */
public class Cliente {

    private int idCliente;
    private String nombre;
    private String dui;
    private int edad;
    private String telefono;
    private boolean activo; // Agregado para coincidir con la columna 'activo' (BIT)

    public Cliente() {
    }

    // Actualizado el constructor para incluir 'activo'
    public Cliente(int idCliente, String nombre, String dui, int edad, String telefono, boolean activo) {
        this.idCliente = idCliente;
        this.nombre = nombre;
        this.dui = dui;
        this.edad = edad;
        this.telefono = telefono;
        this.activo = activo;
    }

    // Getters y Setters agregados
    public boolean isActivo() {
        return activo;
    }

    public void setActivo(boolean activo) {
        this.activo = activo;
    }

    public int getIdCliente() {
        return idCliente;
    }

    public void setIdCliente(int idCliente) {
        this.idCliente = idCliente;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getDui() {
        return dui;
    }

    public void setDui(String dui) {
        this.dui = dui;
    }

    public int getEdad() {
        return edad;
    }

    public void setEdad(int edad) {
        this.edad = edad;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }
}
