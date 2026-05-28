/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.renta.modelos;

/**
 *
 * @author carlo
 */
public class Vehiculo {
    private int idVehiculo;
    private String marca;
    private String modelo;
    private String placa;
    private int capacidad;
    private double precioDiario;
    private boolean disponible; // 1 = true (Disponible), 0 = false (Alquilado)

    // Constructor vacío
    public Vehiculo() {
    }

    // Constructor con parámetros
    public Vehiculo(int idVehiculo, String marca, String modelo, String placa, int capacidad, double precioDiario, boolean disponible) {
        this.idVehiculo = idVehiculo;
        this.marca = marca;
        this.modelo = modelo;
        this.placa = placa;
        this.capacidad = capacidad;
        this.precioDiario = precioDiario;
        this.disponible = disponible;
    }

    // Métodos Getters y Setters
    public int getIdVehiculo() { return idVehiculo; }
    public void setIdVehiculo(int idVehiculo) { this.idVehiculo = idVehiculo; }

    public String getMarca() { return marca; }
    public void setMarca(String marca) { this.marca = marca; }

    public String getModelo() { return modelo; }
    public void setModelo(String modelo) { this.modelo = modelo; }

    public String getPlaca() { return placa; }
    public void setPlaca(String placa) { this.placa = placa; }

    public int getCapacidad() { return capacidad; }
    public void setCapacidad(int capacidad) { this.capacidad = capacidad; }

    public double getPrecioDiario() { return precioDiario; }
    public void setPrecioDiario(double precioDiario) { this.precioDiario = precioDiario; }

    public boolean isDisponible() { return disponible; }
    public void setDisponible(boolean disponible) { this.disponible = disponible; }

}
