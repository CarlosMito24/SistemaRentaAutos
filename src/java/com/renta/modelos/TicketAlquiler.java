/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
 package com.renta.modelos;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class TicketAlquiler {
    private int idTicket;
    private int idUsuario;
    private int idCliente;
    private Date fechaEmision;
    private double totalGlobal;
    
    // Aquí guardaremos la lista de vehículos que el cliente metió a su "carrito"
    private List<DetalleAlquiler> detalles;

    public TicketAlquiler() {
        // Inicializamos la lista para evitar errores de "NullPointerException"
        this.detalles = new ArrayList<>();
    }

    // Getters y Setters
    public int getIdTicket() { return idTicket; }
    public void setIdTicket(int idTicket) { this.idTicket = idTicket; }

    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }

    public int getIdCliente() { return idCliente; }
    public void setIdCliente(int idCliente) { this.idCliente = idCliente; }

    public Date getFechaEmision() { return fechaEmision; }
    public void setFechaEmision(Date fechaEmision) { this.fechaEmision = fechaEmision; }

    public double getTotalGlobal() { return totalGlobal; }
    public void setTotalGlobal(double totalGlobal) { this.totalGlobal = totalGlobal; }

    public List<DetalleAlquiler> getDetalles() { return detalles; }
    public void setDetalles(List<DetalleAlquiler> detalles) { this.detalles = detalles; }
    
    // Método extra para agregar detalles fácilmente desde el Servlet
    public void agregarDetalle(DetalleAlquiler detalle) {
        this.detalles.add(detalle);
    }
}
