package com.renta.datos;

import com.renta.conexion.Conexion;
import com.renta.modelos.TicketAlquiler;
import com.renta.modelos.DetalleAlquiler;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AlquilerDAO {

    // 1. REGISTRAR TICKET (MAESTRO - DETALLE)
        public int registrarTicket(TicketAlquiler ticket) {
        String sqlTicket = "INSERT INTO Ticket_Alquiler (id_usuario, id_cliente, fecha_emision, total_global) VALUES (?, ?, ?, ?)";
        String sqlDetalle = "INSERT INTO Detalle_Alquiler (id_ticket, id_vehiculo, fecha_entrega, fecha_devolucion_esperada, precio_aplicado, subtotal, mora, total_linea) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        String sqlUpdateAuto = "UPDATE Vehiculos SET disponible = 0 WHERE id_vehiculo = ?";

        Connection conn = null;
        try {
            conn = Conexion.conectar();
            conn.setAutoCommit(false); // Iniciamos transacción blindada

            int idTicketGenerado = 0;

            // A) Insertar el Ticket Maestro y atrapar la llave generada
            try (PreparedStatement psTicket = conn.prepareStatement(sqlTicket, Statement.RETURN_GENERATED_KEYS)) {
                psTicket.setInt(1, ticket.getIdUsuario());
                psTicket.setInt(2, ticket.getIdCliente());
                psTicket.setTimestamp(3, new java.sql.Timestamp(ticket.getFechaEmision().getTime()));
                psTicket.setDouble(4, ticket.getTotalGlobal());
                psTicket.executeUpdate();

                try (ResultSet rs = psTicket.getGeneratedKeys()) {
                    if (rs.next()) {
                        idTicketGenerado = rs.getInt(1); // Atrapamos el ID que SQL Server acaba de crear
                    } else {
                        throw new SQLException("No se pudo obtener el ID del Ticket Maestro.");
                    }
                }
            }

            // B) Insertar todos los vehículos (Detalles) vinculados a ese Ticket
            try (PreparedStatement psDetalle = conn.prepareStatement(sqlDetalle);
                 PreparedStatement psUpdate = conn.prepareStatement(sqlUpdateAuto)) {

                // Recorremos la lista de vehículos del cliente
                for (DetalleAlquiler detalle : ticket.getDetalles()) {
                    psDetalle.setInt(1, idTicketGenerado);
                    psDetalle.setInt(2, detalle.getIdVehiculo());
                    psDetalle.setTimestamp(3, new java.sql.Timestamp(detalle.getFechaEntrega().getTime()));
                    psDetalle.setTimestamp(4, new java.sql.Timestamp(detalle.getFechaDevolucionEsperada().getTime()));
                    psDetalle.setDouble(5, detalle.getPrecioAplicado());
                    psDetalle.setDouble(6, detalle.getSubtotal());
                    psDetalle.setDouble(7, detalle.getMora());
                    psDetalle.setDouble(8, detalle.getTotalLinea());
                    psDetalle.executeUpdate();

                    // C) Ocultamos el vehículo del catálogo
                    psUpdate.setInt(1, detalle.getIdVehiculo());
                    psUpdate.executeUpdate();
                }
            }

            conn.commit(); // Confirmamos todo
               return idTicketGenerado; // <--- DEVOLVEMOS EL NÚMERO CREADO

        } catch (SQLException e) {
            System.err.println("Error en transacción Maestro-Detalle: " + e.getMessage());
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) {}
            return -1; // <--- SI FALLA, DEVOLVEMOS -1
        } finally {
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }

    // 2. LISTAR VEHÍCULOS PENDIENTES DE DEVOLUCIÓN
    public List<Map<String, Object>> listarPendientes() {
        List<Map<String, Object>> lista = new ArrayList<>();
        // El JOIN ahora cruza el Detalle con el Ticket para saber de quién es el auto
        String sql = "SELECT d.id_detalle, t.id_ticket, c.nombre AS cliente, "
                   + "v.marca + ' ' + v.modelo + ' (' + v.placa + ')' AS vehiculo, "
                   + "d.fecha_entrega, d.fecha_devolucion_esperada, d.total_linea "
                   + "FROM Detalle_Alquiler d "
                   + "INNER JOIN Ticket_Alquiler t ON d.id_ticket = t.id_ticket "
                   + "INNER JOIN Clientes c ON t.id_cliente = c.id_cliente "
                   + "INNER JOIN Vehiculos v ON d.id_vehiculo = v.id_vehiculo "
                   + "WHERE d.fecha_devolucion_real IS NULL";

        Connection conn = null;
        try {
            conn = Conexion.conectar();
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, Object> fila = new HashMap<>();
                fila.put("id_detalle", rs.getInt("id_detalle"));
                fila.put("id_ticket", rs.getInt("id_ticket"));
                fila.put("cliente", rs.getString("cliente"));
                fila.put("vehiculo", rs.getString("vehiculo"));

                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy hh:mm a");
                fila.put("fecha_entrega", sdf.format(rs.getTimestamp("fecha_entrega")));
                fila.put("fecha_esperada", sdf.format(rs.getTimestamp("fecha_devolucion_esperada")));
                
                // Formato ISO estricto para inyectarlo en el <input type="datetime-local"> del futuro Modal
                java.text.SimpleDateFormat sdfInput = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
                fila.put("fecha_esperada_raw", sdfInput.format(rs.getTimestamp("fecha_devolucion_esperada")));

                fila.put("total_linea", rs.getDouble("total_linea"));
                lista.add(fila);
            }
        } catch (SQLException e) {
            System.err.println("Error al listar pendientes: " + e.getMessage());
        } finally {
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return lista;
    }

    // 3. PROCESAR DEVOLUCIÓN (VÍA MODAL)
    public boolean registrarDevolucion(int idDetalle, java.sql.Timestamp fechaReal, double moraCalculada, double totalFinal) {
        String sqlSelect = "SELECT id_vehiculo, id_ticket FROM Detalle_Alquiler WHERE id_detalle = ?";
        String sqlUpdateDetalle = "UPDATE Detalle_Alquiler SET fecha_devolucion_real = ?, mora = ?, total_linea = ? WHERE id_detalle = ?";
        String sqlUpdateVehiculo = "UPDATE Vehiculos SET disponible = 1 WHERE id_vehiculo = ?";
        // Magia SQL: Sumamos todos los detalles para actualizar el Ticket Maestro
        String sqlUpdateTicket = "UPDATE Ticket_Alquiler SET total_global = (SELECT SUM(total_linea) FROM Detalle_Alquiler WHERE id_ticket = ?) WHERE id_ticket = ?";

        Connection conn = null;
        try {
            conn = Conexion.conectar();
            conn.setAutoCommit(false);

            int idVehiculo = 0;
            int idTicket = 0;

            // A) Buscar a qué Ticket y a qué Vehículo pertenece este detalle
            try (PreparedStatement psSelect = conn.prepareStatement(sqlSelect)) {
                psSelect.setInt(1, idDetalle);
                try (ResultSet rs = psSelect.executeQuery()) {
                    if (rs.next()) {
                        idVehiculo = rs.getInt("id_vehiculo");
                        idTicket = rs.getInt("id_ticket");
                    } else {
                        return false;
                    }
                }
            }

            // B) Actualizar el Detalle (mora y tiempo real de entrega)
            try (PreparedStatement psUpdateD = conn.prepareStatement(sqlUpdateDetalle)) {
                psUpdateD.setTimestamp(1, fechaReal);
                psUpdateD.setDouble(2, moraCalculada);
                psUpdateD.setDouble(3, totalFinal);
                psUpdateD.setInt(4, idDetalle);
                psUpdateD.executeUpdate();
            }

            // C) Liberar el vehículo
            try (PreparedStatement psUpdateV = conn.prepareStatement(sqlUpdateVehiculo)) {
                psUpdateV.setInt(1, idVehiculo);
                psUpdateV.executeUpdate();
            }
            
            // D) Actualizar la factura general
            try (PreparedStatement psUpdateT = conn.prepareStatement(sqlUpdateTicket)) {
                psUpdateT.setInt(1, idTicket);
                psUpdateT.setInt(2, idTicket);
                psUpdateT.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            try { if (conn != null) conn.rollback(); } catch (Exception ex) {}
            System.err.println("Error en devolución manual: " + e.getMessage());
            return false;
        } finally {
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
}