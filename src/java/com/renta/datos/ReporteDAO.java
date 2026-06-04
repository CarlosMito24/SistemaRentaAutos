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

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {
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

    // 2. Detalle completo de alquileres del día (13 campos para el JSP)
    public List<Object[]> obtenerDetalleAlquileresDia(String fecha) throws Exception {
        List<Object[]> lista = new ArrayList<>();
        String sql = "SELECT "
                   + "t.id_ticket, "                          // [0]
                   + "c.nombre AS cliente, "                  // [1]
                   + "c.dui, "                                // [2]
                   + "v.marca + ' ' + v.modelo AS vehiculo, " // [3]
                   + "v.placa, "                              // [4]
                   + "t.fecha_emision, "                      // [5]
                   + "d.fecha_entrega, "                      // [6]
                   + "d.fecha_devolucion_esperada, "          // [7]
                   + "d.fecha_devolucion_real, "              // [8]
                   + "d.precio_aplicado, "                    // [9]
                   + "d.subtotal, "                           // [10]
                   + "d.mora, "                               // [11]
                   + "d.total_linea "                         // [12]
                   + "FROM Ticket_Alquiler t "
                   + "INNER JOIN Clientes c ON t.id_cliente = c.id_cliente "
                   + "INNER JOIN Detalle_Alquiler d ON t.id_ticket = d.id_ticket "
                   + "INNER JOIN Vehiculos v ON d.id_vehiculo = v.id_vehiculo "
                   + "WHERE CAST(t.fecha_emision AS DATE) = ? "
                   + "ORDER BY t.id_ticket DESC, d.id_detalle ASC";

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, fecha);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                lista.add(new Object[]{
                    rs.getInt("id_ticket"),                    // [0]
                    rs.getString("cliente"),                   // [1]
                    rs.getString("dui"),                       // [2]
                    rs.getString("vehiculo"),                  // [3]
                    rs.getString("placa"),                     // [4]
                    rs.getTimestamp("fecha_emision"),          // [5]
                    rs.getTimestamp("fecha_entrega"),          // [6]
                    rs.getDate("fecha_devolucion_esperada"),   // [7]
                    rs.getDate("fecha_devolucion_real"),       // [8]
                    rs.getDouble("precio_aplicado"),           // [9]
                    rs.getDouble("subtotal"),                  // [10]
                    rs.getDouble("mora"),                      // [11]
                    rs.getDouble("total_linea")                // [12]
                });
            }
        }
        return lista;
    }

    // 3. Vehículos actualmente alquilados (sin devolución real aún)
    public List<Object[]> obtenerVehiculosMasAlquilados(String fecha) throws Exception {
        List<Object[]> lista = new ArrayList<>();
        String sql = "SELECT "
                   + "v.marca + ' ' + v.modelo AS vehiculo, " // [0]
                   + "v.placa, "                              // [1]
                   + "c.nombre AS cliente, "                  // [2]
                   + "d.fecha_devolucion_esperada "           // [3]
                   + "FROM Detalle_Alquiler d "
                   + "INNER JOIN Ticket_Alquiler t ON d.id_ticket = t.id_ticket "
                   + "INNER JOIN Vehiculos v ON d.id_vehiculo = v.id_vehiculo "
                   + "INNER JOIN Clientes c ON t.id_cliente = c.id_cliente "
                   + "WHERE CAST(t.fecha_emision AS DATE) = ? "
                   + "AND d.fecha_devolucion_real IS NULL "
                   + "ORDER BY d.fecha_devolucion_esperada ASC";

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, fecha);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                lista.add(new Object[]{
                    rs.getString("vehiculo"),                  // [0]
                    rs.getString("placa"),                     // [1]
                    rs.getString("cliente"),                   // [2]
                    rs.getDate("fecha_devolucion_esperada")    // [3]
                });
            }
        }
        return lista;
    }

    // 4. Devoluciones con mora
    public List<Object[]> obtenerDevolucionesConMora(String fecha) throws Exception {
        List<Object[]> lista = new ArrayList<>();
        String sql = "SELECT "
                   + "c.nombre AS cliente, "                         // [0]
                   + "v.marca + ' ' + v.modelo AS vehiculo, "        // [1]
                   + "d.fecha_devolucion_esperada, "                 // [2]
                   + "d.fecha_devolucion_real, "                     // [3]
                   + "d.mora "                                       // [4]
                   + "FROM Detalle_Alquiler d "
                   + "INNER JOIN Ticket_Alquiler t ON d.id_ticket = t.id_ticket "
                   + "INNER JOIN Clientes c ON t.id_cliente = c.id_cliente "
                   + "INNER JOIN Vehiculos v ON d.id_vehiculo = v.id_vehiculo "
                   + "WHERE CAST(t.fecha_emision AS DATE) = ? "
                   + "AND d.mora > 0 "
                   + "ORDER BY d.mora DESC";

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, fecha);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                lista.add(new Object[]{
                    rs.getString("cliente"),                         // [0]
                    rs.getString("vehiculo"),                        // [1]
                    rs.getDate("fecha_devolucion_esperada"),         // [2]
                    rs.getDate("fecha_devolucion_real"),             // [3]
                    rs.getDouble("mora")                             // [4]
                });
            }
        }
        return lista;
    }
}
