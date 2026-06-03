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
                + "COUNT(*) AS total_alquileres, "
                + "COALESCE(SUM(subtotal), 0) AS total_subtotal, "
                + "COALESCE(SUM(mora), 0) AS total_mora, "
                + "COALESCE(SUM(total_pago), 0) AS total_ingresos "
                + "FROM dbo.Alquileres "
                + "WHERE CAST(fecha_alquiler AS DATE) = ?";

        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, fecha);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            reporte.setTotalAlquileres(rs.getInt("total_alquileres"));
            reporte.setTotalSubtotal(rs.getDouble("total_subtotal"));
            reporte.setTotalMora(rs.getDouble("total_mora"));
            reporte.setTotalIngresos(rs.getDouble("total_ingresos"));
        }

        rs.close(); ps.close(); con.close();
        return reporte;
    }

    // Detalle de alquileres del día
    public List<Object[]> obtenerDetalleAlquileresDia(String fecha) throws Exception {
        List<Object[]> lista = new ArrayList<>();
        Connection con = Conexion.conectar();

        String sql = "SELECT "
                + "a.id_alquiler, "
                + "c.nombre AS cliente, "
                + "c.dui, "
                + "v.marca + ' ' + v.modelo AS vehiculo, "
                + "v.placa, "
                + "a.fecha_alquiler, "
                + "a.fecha_devolucion_esperada, "
                + "a.fecha_devolucion_real, "
                + "a.precio_aplicado, "
                + "a.subtotal, "
                + "a.mora, "
                + "a.total_pago "
                + "FROM dbo.Alquileres a "
                + "INNER JOIN dbo.Clientes c ON a.id_cliente = c.id_cliente "
                + "INNER JOIN dbo.Vehiculos v ON a.id_vehiculo = v.id_vehiculo "
                + "WHERE CAST(a.fecha_alquiler AS DATE) = ? "
                + "ORDER BY a.id_alquiler DESC";

        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, fecha);
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            Object[] fila = {
                rs.getInt("id_alquiler"),
                rs.getString("cliente"),
                rs.getString("dui"),
                rs.getString("vehiculo"),
                rs.getString("placa"),
                rs.getTimestamp("fecha_alquiler"),
                rs.getDate("fecha_devolucion_esperada"),
                rs.getDate("fecha_devolucion_real"),
                rs.getDouble("precio_aplicado"),
                rs.getDouble("subtotal"),
                rs.getDouble("mora"),
                rs.getDouble("total_pago")
            };
            lista.add(fila);
        }

        rs.close(); ps.close(); con.close();
        return lista;
    }

    // Vehículos más alquilados en el día
    public List<Object[]> obtenerVehiculosMasAlquilados(String fecha) throws Exception {
        List<Object[]> lista = new ArrayList<>();
        Connection con = Conexion.conectar();

        String sql = "SELECT "
                + "v.marca + ' ' + v.modelo AS vehiculo, "
                + "v.placa, "
                + "COUNT(*) AS veces_alquilado, "
                + "SUM(a.total_pago) AS ingresos "
                + "FROM dbo.Alquileres a "
                + "INNER JOIN dbo.Vehiculos v ON a.id_vehiculo = v.id_vehiculo "
                + "WHERE CAST(a.fecha_alquiler AS DATE) = ? "
                + "GROUP BY v.marca, v.modelo, v.placa "
                + "ORDER BY veces_alquilado DESC";

        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, fecha);
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            Object[] fila = {
                rs.getString("vehiculo"),
                rs.getString("placa"),
                rs.getInt("veces_alquilado"),
                rs.getDouble("ingresos")
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
                + "a.fecha_devolucion_esperada, "
                + "a.fecha_devolucion_real, "
                + "a.mora "
                + "FROM dbo.Alquileres a "
                + "INNER JOIN dbo.Clientes c ON a.id_cliente = c.id_cliente "
                + "INNER JOIN dbo.Vehiculos v ON a.id_vehiculo = v.id_vehiculo "
                + "WHERE CAST(a.fecha_alquiler AS DATE) = ? "
                + "AND a.mora > 0 "
                + "ORDER BY a.mora DESC";

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
