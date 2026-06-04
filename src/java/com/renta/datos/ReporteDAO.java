package com.renta.datos;

import com.renta.conexion.Conexion;
import com.renta.modelos.ReporteDia;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReporteDAO {

    // 1. Resumen general (KPIs)
    public ReporteDia obtenerResumenDia(String fecha) throws Exception {
        ReporteDia reporte = new ReporteDia();
        String sql = "SELECT COUNT(DISTINCT t.id_ticket) AS total_tickets, "
                   + "COALESCE(SUM(d.subtotal), 0) AS total_subtotal, "
                   + "COALESCE(SUM(d.mora), 0) AS total_mora, "
                   + "COALESCE(SUM(d.total_linea), 0) AS total_ingresos "
                   + "FROM Ticket_Alquiler t "
                   + "INNER JOIN Detalle_Alquiler d ON t.id_ticket = d.id_ticket "
                   + "WHERE CAST(t.fecha_emision AS DATE) = ?";

        try (Connection con = Conexion.conectar(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, fecha);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                reporte.setTotalAlquileres(rs.getInt("total_tickets"));
                reporte.setTotalSubtotal(rs.getDouble("total_subtotal"));
                reporte.setTotalMora(rs.getDouble("total_mora"));
                reporte.setTotalIngresos(rs.getDouble("total_ingresos"));
            }
        }
        return reporte;
    }

    // 2. Detalle de alquileres del día
    public List<Object[]> obtenerDetalleAlquileresDia(String fecha) throws Exception {
        List<Object[]> lista = new ArrayList<>();
        String sql = "SELECT c.nombre, v.marca, v.modelo, d.total_linea "
                   + "FROM Detalle_Alquiler d "
                   + "JOIN Ticket_Alquiler t ON d.id_ticket = t.id_ticket "
                   + "JOIN Clientes c ON t.id_cliente = c.id_cliente "
                   + "JOIN Vehiculos v ON d.id_vehiculo = v.id_vehiculo "
                   + "WHERE CAST(t.fecha_emision AS DATE) = ?";
        
        try (Connection con = Conexion.conectar(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, fecha);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                lista.add(new Object[]{rs.getString(1), rs.getString(2), rs.getString(3), rs.getDouble(4)});
            }
        }
        return lista;
    }

    // 3. Vehículos más alquilados
    public List<Object[]> obtenerVehiculosMasAlquilados(String fecha) throws Exception {
        List<Object[]> lista = new ArrayList<>();
        String sql = "SELECT v.marca, v.modelo, COUNT(d.id_vehiculo) as veces "
                   + "FROM Detalle_Alquiler d "
                   + "JOIN Vehiculos v ON d.id_vehiculo = v.id_vehiculo "
                   + "JOIN Ticket_Alquiler t ON d.id_ticket = t.id_ticket "
                   + "WHERE CAST(t.fecha_emision AS DATE) = ? "
                   + "GROUP BY v.marca, v.modelo ORDER BY veces DESC";
        
        try (Connection con = Conexion.conectar(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, fecha);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                lista.add(new Object[]{rs.getString(1), rs.getString(2), rs.getInt(3)});
            }
        }
        return lista;
    }

    // 4. Devoluciones con mora
    public List<Object[]> obtenerDevolucionesConMora(String fecha) throws Exception {
        List<Object[]> lista = new ArrayList<>();
        String sql = "SELECT c.nombre, v.marca + ' ' + v.modelo, d.fecha_devolucion_esperada, d.fecha_devolucion_real, d.mora "
                   + "FROM Detalle_Alquiler d "
                   + "INNER JOIN Ticket_Alquiler t ON d.id_ticket = t.id_ticket "
                   + "INNER JOIN Clientes c ON t.id_cliente = c.id_cliente "
                   + "INNER JOIN Vehiculos v ON d.id_vehiculo = v.id_vehiculo "
                   + "WHERE CAST(t.fecha_emision AS DATE) = ? AND d.mora > 0";

        try (Connection con = Conexion.conectar(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, fecha);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                lista.add(new Object[]{rs.getString(1), rs.getString(2), rs.getTimestamp(3), rs.getTimestamp(4), rs.getDouble(5)});
            }
        }
        return lista;
    }
}