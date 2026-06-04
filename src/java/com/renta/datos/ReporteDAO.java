package com.renta.datos;

import com.renta.conexion.Conexion;
import com.renta.modelos.ReporteDia;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReporteDAO {

    // Resumen general del día
    public ReporteDia obtenerResumenDia(String fecha) throws Exception {
        ReporteDia reporte = new ReporteDia();
        Connection con = Conexion.conectar();

        String sql = "SELECT "
                + "COUNT(DISTINCT t.id_ticket)       AS total_tickets, "
                + "COALESCE(SUM(d.subtotal), 0)      AS total_subtotal, "
                + "COALESCE(SUM(d.mora), 0)          AS total_mora, "
                + "COALESCE(SUM(d.total_linea), 0)   AS total_ingresos "
                + "FROM Ticket_Alquiler t "
                + "INNER JOIN Detalle_Alquiler d ON t.id_ticket = d.id_ticket "
                + "WHERE CAST(t.fecha_emision AS DATE) = ?";

        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, fecha);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            reporte.setTotalAlquileres(rs.getInt("total_tickets"));
            reporte.setTotalSubtotal(rs.getDouble("total_subtotal"));
            reporte.setTotalMora(rs.getDouble("total_mora"));
            reporte.setTotalIngresos(rs.getDouble("total_ingresos"));
        }

        rs.close(); ps.close(); con.close();
        return reporte;
    }

    // Detalle de alquileres del día (un registro por vehículo/detalle)
    public List<Object[]> obtenerDetalleAlquileresDia(String fecha) throws Exception {
        List<Object[]> lista = new ArrayList<>();
        Connection con = Conexion.conectar();

        String sql = "SELECT "
                + "t.id_ticket, "
                + "c.nombre                          AS cliente, "
                + "c.dui, "
                + "v.marca + ' ' + v.modelo          AS vehiculo, "
                + "v.placa, "
                + "t.fecha_emision, "
                + "d.fecha_entrega, "
                + "d.fecha_devolucion_esperada, "
                + "d.fecha_devolucion_real, "
                + "d.precio_aplicado, "
                + "d.subtotal, "
                + "d.mora, "
                + "d.total_linea "
                + "FROM Ticket_Alquiler t "
                + "INNER JOIN Clientes c    ON t.id_cliente  = c.id_cliente "
                + "INNER JOIN Detalle_Alquiler d ON t.id_ticket = d.id_ticket "
                + "INNER JOIN Vehiculos v   ON d.id_vehiculo = v.id_vehiculo "
                + "WHERE CAST(t.fecha_emision AS DATE) = ? "
                + "ORDER BY t.id_ticket DESC, d.id_detalle ASC";

        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, fecha);
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            Object[] fila = {
                rs.getInt("id_ticket"),           // 0
                rs.getString("cliente"),           // 1
                rs.getString("dui"),               // 2
                rs.getString("vehiculo"),          // 3
                rs.getString("placa"),             // 4
                rs.getTimestamp("fecha_emision"),  // 5
                rs.getTimestamp("fecha_entrega"),  // 6
                rs.getDate("fecha_devolucion_esperada"), // 7
                rs.getDate("fecha_devolucion_real"),     // 8
                rs.getDouble("precio_aplicado"),   // 9
                rs.getDouble("subtotal"),          // 10
                rs.getDouble("mora"),              // 11
                rs.getDouble("total_linea")        // 12
            };
            lista.add(fila);
        }

        rs.close(); ps.close(); con.close();
        return lista;
    }

    // Vehículos activos (sin devolución real aún)
    public List<Object[]> obtenerVehiculosMasAlquilados(String fecha) throws Exception {
        List<Object[]> lista = new ArrayList<>();
        Connection con = Conexion.conectar();

        String sql = "SELECT "
                + "v.marca + ' ' + v.modelo AS vehiculo, "
                + "v.placa, "
                + "c.nombre AS cliente, "
                + "d.fecha_devolucion_esperada "
                + "FROM Detalle_Alquiler d "
                + "INNER JOIN Vehiculos v         ON d.id_vehiculo = v.id_vehiculo "
                + "INNER JOIN Ticket_Alquiler t   ON d.id_ticket   = t.id_ticket "
                + "INNER JOIN Clientes c          ON t.id_cliente  = c.id_cliente "
                + "WHERE CAST(t.fecha_emision AS DATE) = ? "
                + "AND d.fecha_devolucion_real IS NULL "
                + "ORDER BY d.fecha_devolucion_esperada ASC";

        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, fecha);
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            Object[] fila = {
                rs.getString("vehiculo"),
                rs.getString("placa"),
                rs.getString("cliente"),
                rs.getDate("fecha_devolucion_esperada")
            };
            lista.add(fila);
        }

        rs.close(); ps.close(); con.close();
        return lista;
    }

    // Devoluciones con mora del día
    public List<Object[]> obtenerDevolucionesConMora(String fecha) throws Exception {
        List<Object[]> lista = new ArrayList<>();
        Connection con = Conexion.conectar();

        String sql = "SELECT "
                + "c.nombre AS cliente, "
                + "v.marca + ' ' + v.modelo AS vehiculo, "
                + "d.fecha_devolucion_esperada, "
                + "d.fecha_devolucion_real, "
                + "d.mora "
                + "FROM Detalle_Alquiler d "
                + "INNER JOIN Ticket_Alquiler t ON d.id_ticket   = t.id_ticket "
                + "INNER JOIN Clientes c        ON t.id_cliente  = c.id_cliente "
                + "INNER JOIN Vehiculos v       ON d.id_vehiculo = v.id_vehiculo "
                + "WHERE CAST(t.fecha_emision AS DATE) = ? "
                + "AND d.mora > 0 "
                + "ORDER BY d.mora DESC";

        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, fecha);
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            Object[] fila = {
                rs.getString("cliente"),
                rs.getString("vehiculo"),
                rs.getDate("fecha_devolucion_esperada"),
                rs.getDate("fecha_devolucion_real"),
                rs.getDouble("mora")
            };
            lista.add(fila);
        }

        rs.close(); ps.close(); con.close();
        return lista;
    }
}

