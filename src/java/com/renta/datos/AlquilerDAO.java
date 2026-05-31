package com.renta.datos;

import com.renta.conexion.Conexion;
import com.renta.modelos.Alquiler;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class AlquilerDAO {

    public boolean registrarAlquiler(Alquiler a) {
        // SQL corregido: Incluye todos los campos obligatorios NOT NULL de la base de datos
        String sqlAlquiler = "INSERT INTO Alquileres (id_usuario, id_cliente, id_vehiculo, fecha_alquiler, fecha_devolucion_esperada, precio_aplicado, subtotal, mora, total_pago) VALUES (?, ?, ?, GETDATE(), ?, ?, ?, ?, ?)";
        String sqlUpdateAuto = "UPDATE Vehiculos SET disponible = 0 WHERE id_vehiculo = ?";

        Connection conn = null;
        try {
            conn = Conexion.conectar();

            if (conn == null) {
                System.err.println("Error: No se pudo establecer conexión a la base de datos.");
                return false;
            }

            conn.setAutoCommit(false); // Inicia transacción

            // 1. Insertar el Alquiler
            try (PreparedStatement ps = conn.prepareStatement(sqlAlquiler)) {
                ps.setInt(1, a.getIdUsuario());
                ps.setInt(2, a.getIdCliente());
                ps.setInt(3, a.getIdVehiculo());
                ps.setDate(4, new java.sql.Date(a.getFechaDevolucionEsperada().getTime()));

                // Mapeo de valores financieros (deben coincidir con los campos de tu clase Alquiler)
                ps.setDouble(5, a.getPrecioAplicado()); // precio_aplicado
                ps.setDouble(6, a.getSubtotal());       // subtotal
                ps.setDouble(7, a.getMora());           // mora
                ps.setDouble(8, a.getTotalPago());      // total_pago

                ps.executeUpdate();
            }

            // 2. Cambiar disponibilidad del vehículo
            try (PreparedStatement ps2 = conn.prepareStatement(sqlUpdateAuto)) {
                ps2.setInt(1, a.getIdVehiculo());
                ps2.executeUpdate();
            }

            conn.commit(); // Confirma cambios
            return true;

        } catch (SQLException e) {
            System.err.println("Error en transacción de alquiler: " + e.getMessage());
            try {
                if (conn != null) {
                    conn.rollback(); // Deshace si hay error
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            return false;
        } finally {
            try {
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
