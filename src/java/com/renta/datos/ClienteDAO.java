package com.renta.datos;

import com.renta.conexion.Conexion;
import com.renta.modelos.Cliente;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ClienteDAO {

    // Devuelve: 1 = Registrado, 2 = Reactivado, 0 = Error o Ya existe
    public int registrarCliente(Cliente cte) {
        Cliente existente = buscarPorDui(cte.getDui());

        // 1. Si existe y está inactivo -> Reactivamos
        if (existente != null && !existente.isActivo()) {
            return reactivarCliente(existente.getIdCliente()) ? 2 : 0;
        }
        
        // 2. Si existe y ya está activo -> Retornamos 0 (error)
        if (existente != null && existente.isActivo()) {
            return 0;
        }

        // 3. Si NO existe, INSERT
        Connection cn = Conexion.conectar();
        PreparedStatement pst = null;
        String sql = "INSERT INTO Clientes (nombre, dui, edad, telefono, activo) VALUES (?, ?, ?, ?, ?)";
        try {
            if (cn != null) {
                pst = cn.prepareStatement(sql);
                pst.setString(1, cte.getNombre());
                pst.setString(2, cte.getDui());
                pst.setInt(3, cte.getEdad());
                pst.setString(4, cte.getTelefono());
                pst.setBoolean(5, true);
                return pst.executeUpdate() > 0 ? 1 : 0;
            }
        } catch (SQLException e) {
            System.out.println("❌ Error al registrar: " + e.getMessage());
        } finally {
            cerrarConexion(cn, pst, null);
        }
        return 0;
    }

    public boolean reactivarCliente(int id) {
        Connection cn = Conexion.conectar();
        PreparedStatement pst = null;
        String sql = "UPDATE Clientes SET activo = 1 WHERE id_cliente = ?";
        try {
            if (cn != null) {
                pst = cn.prepareStatement(sql);
                pst.setInt(1, id);
                return pst.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            System.out.println("❌ Error al reactivar: " + e.getMessage());
        } finally {
            cerrarConexion(cn, pst, null);
        }
        return false;
    }

    public boolean actualizarCliente(Cliente cte) {
        Connection cn = Conexion.conectar();
        PreparedStatement pst = null;
        String sql = "UPDATE Clientes SET nombre = ?, dui = ?, edad = ?, telefono = ?, activo = ? WHERE id_cliente = ?";
        try {
            if (cn != null) {
                pst = cn.prepareStatement(sql);
                pst.setString(1, cte.getNombre());
                pst.setString(2, cte.getDui());
                pst.setInt(3, cte.getEdad());
                pst.setString(4, cte.getTelefono());
                pst.setBoolean(5, cte.isActivo());
                pst.setInt(6, cte.getIdCliente());
                return pst.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            System.out.println("❌ Error al actualizar: " + e.getMessage());
        } finally {
            cerrarConexion(cn, pst, null);
        }
        return false;
    }

    public boolean eliminarClienteLogico(int id) {
        Connection cn = Conexion.conectar();
        PreparedStatement pst = null;
        String sql = "UPDATE Clientes SET activo = 0 WHERE id_cliente = ?";
        try {
            if (cn != null) {
                pst = cn.prepareStatement(sql);
                pst.setInt(1, id);
                return pst.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            System.out.println("❌ Error al eliminar: " + e.getMessage());
        } finally {
            cerrarConexion(cn, pst, null);
        }
        return false;
    }

    public Cliente buscarPorDui(String dui) {
        Cliente cte = null;
        Connection cn = Conexion.conectar();
        PreparedStatement pst = null;
        ResultSet rs = null;
        String sql = "SELECT id_cliente, activo FROM Clientes WHERE dui = ?";
        try {
            if (cn != null) {
                pst = cn.prepareStatement(sql);
                pst.setString(1, dui);
                rs = pst.executeQuery();
                if (rs.next()) {
                    cte = new Cliente();
                    cte.setIdCliente(rs.getInt("id_cliente"));
                    cte.setActivo(rs.getBoolean("activo"));
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error al buscar por DUI: " + e.getMessage());
        } finally {
            cerrarConexion(cn, pst, rs);
        }
        return cte;
    }

    // Método auxiliar para limpiar recursos (evita repetir código)
    private void cerrarConexion(Connection cn, PreparedStatement pst, ResultSet rs) {
        try {
            if (rs != null) rs.close();
            if (pst != null) pst.close();
            if (cn != null) cn.close();
        } catch (SQLException e) {
            System.out.println("❌ Error cerrando recursos: " + e.getMessage());
        }
    }

    // Listar y BuscarPorId se mantienen igual, solo usa el método auxiliar cerrarConexion
    public List<Cliente> listarClientes() {
        List<Cliente> lista = new ArrayList<>();
        Connection cn = Conexion.conectar();
        PreparedStatement pst = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM Clientes WHERE activo = 1";
        try {
            if (cn != null) {
                pst = cn.prepareStatement(sql);
                rs = pst.executeQuery();
                while (rs.next()) {
                    Cliente cte = new Cliente();
                    cte.setIdCliente(rs.getInt("id_cliente"));
                    cte.setNombre(rs.getString("nombre"));
                    cte.setDui(rs.getString("dui"));
                    cte.setEdad(rs.getInt("edad"));
                    cte.setTelefono(rs.getString("telefono"));
                    cte.setActivo(rs.getBoolean("activo"));
                    lista.add(cte);
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error al listar: " + e.getMessage());
        } finally {
            cerrarConexion(cn, pst, rs);
        }
        return lista;
    }
}