package com.renta.modelos;

public class ReporteDia {
    private int totalAlquileres;
    private double totalSubtotal;
    private double totalMora;
    private double totalIngresos;

    public ReporteDia() {}

    public int getTotalAlquileres() { return totalAlquileres; }
    public void setTotalAlquileres(int totalAlquileres) { this.totalAlquileres = totalAlquileres; }

    public double getTotalSubtotal() { return totalSubtotal; }
    public void setTotalSubtotal(double totalSubtotal) { this.totalSubtotal = totalSubtotal; }

    public double getTotalMora() { return totalMora; }
    public void setTotalMora(double totalMora) { this.totalMora = totalMora; }

    public double getTotalIngresos() { return totalIngresos; }
    public void setTotalIngresos(double totalIngresos) { this.totalIngresos = totalIngresos; }
}