package com.renta.modelos;

public class Vehiculo {

    private int idVehiculo;
    private String marca;
    private String modelo;
    private String placa;
    private int capacidad;
    private double precioDiario;
    private boolean disponible; // 1 = Disponible, 0 = Alquilado
    private boolean activo;     // 1 = Activo (Visible), 0 = Eliminado
    private int anio;
    private String color;       // Nuevo atributo

    // Constructor vacío
    public Vehiculo() {
    }

    // Constructor completo
    public Vehiculo(int idVehiculo, String marca, String modelo, String placa, int capacidad,
            double precioDiario, boolean disponible, boolean activo, int anio, String color) {
        this.idVehiculo = idVehiculo;
        this.marca = marca;
        this.modelo = modelo;
        this.placa = placa;
        this.capacidad = capacidad;
        this.precioDiario = precioDiario;
        this.disponible = disponible;
        this.activo = activo;
        this.anio = anio;
        this.color = color;
    }

    // Métodos Getters y Setters
    public int getIdVehiculo() {
        return idVehiculo;
    }

    public void setIdVehiculo(int idVehiculo) {
        this.idVehiculo = idVehiculo;
    }

    public String getMarca() {
        return marca;
    }

    public void setMarca(String marca) {
        this.marca = marca;
    }

    public String getModelo() {
        return modelo;
    }

    public void setModelo(String modelo) {
        this.modelo = modelo;
    }

    public String getPlaca() {
        return placa;
    }

    public void setPlaca(String placa) {
        this.placa = placa;
    }

    public int getCapacidad() {
        return capacidad;
    }

    public void setCapacidad(int capacidad) {
        this.capacidad = capacidad;
    }

    public double getPrecioDiario() {
        return precioDiario;
    }

    public void setPrecioDiario(double precioDiario) {
        this.precioDiario = precioDiario;
    }

    public boolean isDisponible() {
        return disponible;
    }

    public void setDisponible(boolean disponible) {
        this.disponible = disponible;
    }

    public boolean isActivo() {
        return activo;
    }

    public void setActivo(boolean activo) {
        this.activo = activo;
    }

    public int getAnio() {
        return anio;
    }

    public void setAnio(int anio) {
        this.anio = anio;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }
}
