package com.renta.datos;

import com.renta.conexion.Conexion;
import com.renta.modelos.Alquiler;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class AlquilerDAO {

    public boolean registrarAlquiler(Alquiler a) {
        // Se cambió el GETDATE() por '?' en la 4ta posición (fecha_alquiler) para insertar la hora exacta del usuario
        String sqlAlquiler = "INSERT INTO Alquileres (id_usuario, id_cliente, id_vehiculo, fecha_alquiler, fecha_devolucion_esperada, precio_aplicado, subtotal, mora, total_pago) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
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

                // Utilizamos Timestamp para no perder las horas y los minutos al enviarlos a SQL Server
                ps.setTimestamp(4, new java.sql.Timestamp(a.getFechaAlquiler().getTime()));
                ps.setTimestamp(5, new java.sql.Timestamp(a.getFechaDevolucionEsperada().getTime()));

                // Valores financieros
                ps.setDouble(6, a.getPrecioAplicado()); 
                ps.setDouble(7, a.getSubtotal());       
                ps.setDouble(8, a.getMora());           
                ps.setDouble(9, a.getTotalPago());      

                ps.executeUpdate();
            }

            // 2. Cambiar disponibilidad del vehículo a "Ocupado"
            try (PreparedStatement ps2 = conn.prepareStatement(sqlUpdateAuto)) {
                ps2.setInt(1, a.getIdVehiculo());
                ps2.executeUpdate();
            }

            conn.commit(); // Confirma ambos cambios
            return true;

        } catch (SQLException e) {
            System.err.println("Error en transacción de alquiler: " + e.getMessage());
            try {
                if (conn != null) {
                    conn.rollback(); // Deshace los cambios si algo explota
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            return false;
        } finally {
            // Cerramos la conexión para liberar memoria
            try {
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    // Método para listar los alquileres que aún no han sido devueltos
    public java.util.List<java.util.Map<String, Object>> listarPendientes() {
        java.util.List<java.util.Map<String, Object>> lista = new java.util.ArrayList<>();
        
        // Hacemos un JOIN para traer datos legibles y filtramos los que no tienen fecha real de devolución
        String sql = "SELECT a.id_alquiler, c.nombre AS cliente, "
                   + "v.marca + ' ' + v.modelo + ' (' + v.placa + ')' AS vehiculo, "
                   + "a.fecha_alquiler, a.fecha_devolucion_esperada, a.total_pago "
                   + "FROM Alquileres a "
                   + "INNER JOIN Clientes c ON a.id_cliente = c.id_cliente "
                   + "INNER JOIN Vehiculos v ON a.id_vehiculo = v.id_vehiculo "
                   + "WHERE a.fecha_devolucion_real IS NULL";
                   
        java.sql.Connection conn = null;
        try {
            conn = Conexion.conectar();
            java.sql.PreparedStatement ps = conn.prepareStatement(sql);
            java.sql.ResultSet rs = ps.executeQuery();
            
            // Usamos un Map para no tener que crear una clase DTO gigante
            while (rs.next()) {
                java.util.Map<String, Object> fila = new java.util.HashMap<>();
                fila.put("id_alquiler", rs.getInt("id_alquiler"));
                fila.put("cliente", rs.getString("cliente"));
                fila.put("vehiculo", rs.getString("vehiculo"));
                
                // Formateamos las fechas para que se vean elegantes en la tabla
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy hh:mm a");
                fila.put("fecha_entrega", sdf.format(rs.getTimestamp("fecha_alquiler")));
                fila.put("fecha_esperada", sdf.format(rs.getTimestamp("fecha_devolucion_esperada")));
                
                fila.put("total_pago", rs.getDouble("total_pago"));
                lista.add(fila);
            }
        } catch (java.sql.SQLException e) {
            System.err.println("Error al listar pendientes: " + e.getMessage());
        } finally {
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return lista;
    }
    // Método para procesar la entrada del vehículo y calcular mora
    public boolean registrarDevolucion(int idAlquiler) {
        String sqlSelect = "SELECT id_vehiculo, fecha_devolucion_esperada, subtotal FROM Alquileres WHERE id_alquiler = ?";
        String sqlUpdateAlquiler = "UPDATE Alquileres SET fecha_devolucion_real = ?, mora = ?, total_pago = ? WHERE id_alquiler = ?";
        String sqlUpdateVehiculo = "UPDATE Vehiculos SET disponible = 1 WHERE id_vehiculo = ?";

        java.sql.Connection conn = null;
        try {
            conn = Conexion.conectar();
            conn.setAutoCommit(false); // Iniciamos transacción segura

            int idVehiculo = 0;
            double subtotal = 0;
            java.sql.Timestamp fechaEsperada = null;

            // 1. Extraer los datos originales del alquiler
            try (java.sql.PreparedStatement psSelect = conn.prepareStatement(sqlSelect)) {
                psSelect.setInt(1, idAlquiler);
                try (java.sql.ResultSet rs = psSelect.executeQuery()) {
                    if (rs.next()) {
                        idVehiculo = rs.getInt("id_vehiculo");
                        fechaEsperada = rs.getTimestamp("fecha_devolucion_esperada");
                        subtotal = rs.getDouble("subtotal");
                    } else {
                        return false; // El alquiler no existe
                    }
                }
            }

            // 2. Calcular la mora con la fecha y hora EXACTA de este instante
            java.sql.Timestamp fechaReal = new java.sql.Timestamp(System.currentTimeMillis());
            double mora = 0.0;
            
            // Obtenemos la diferencia en milisegundos
            long diffMilis = fechaReal.getTime() - fechaEsperada.getTime();

            // Si el resultado es mayor a cero, significa que lo entregó tarde
            if (diffMilis > 0) {
                // Convertimos los milisegundos a horas, redondeando hacia arriba
                long horasTarde = (long) Math.ceil((double) diffMilis / (1000 * 60 * 60));
                mora = horasTarde * 6.25; // Tarifa de penalización
            }

            double totalFinal = subtotal + mora;

            // 3. Actualizar el registro del alquiler
            try (java.sql.PreparedStatement psUpdateA = conn.prepareStatement(sqlUpdateAlquiler)) {
                psUpdateA.setTimestamp(1, fechaReal);
                psUpdateA.setDouble(2, mora);
                psUpdateA.setDouble(3, totalFinal);
                psUpdateA.setInt(4, idAlquiler);
                psUpdateA.executeUpdate();
            }

            // 4. Liberar el vehículo para que vuelva a aparecer en el catálogo
            try (java.sql.PreparedStatement psUpdateV = conn.prepareStatement(sqlUpdateVehiculo)) {
                psUpdateV.setInt(1, idVehiculo);
                psUpdateV.executeUpdate();
            }

            conn.commit(); // Confirmar los cambios
            return true;

        } catch (java.sql.SQLException e) {
            try { if (conn != null) conn.rollback(); } catch (Exception ex) {}
            System.err.println("Error en devolución: " + e.getMessage());
            return false;
        } finally {
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
}



