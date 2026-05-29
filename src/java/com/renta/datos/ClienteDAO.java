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

    public boolean registrarCliente(Cliente cte) {
        Connection cn = Conexion.conectar();
        PreparedStatement pst = null;
        // Columna corregida de 'nombre_completo' a 'nombre' según tu script
        String sql = "INSERT INTO Clientes (nombre, dui, edad, telefono) VALUES (?, ?, ?, ?)";
        
        try {
            if (cn != null) {
                pst = cn.prepareStatement(sql);
                pst.setString(1, cte.getNombre());
                pst.setString(2, cte.getDui());
                pst.setInt(3, cte.getEdad());
                pst.setString(4, cte.getTelefono());
                
                int filasAfectadas = pst.executeUpdate();
                return filasAfectadas > 0;
            }
        } catch (SQLException e) {
            System.out.println("❌ Error al registrar cliente: " + e.getMessage());
        } finally {
            try {
                if (pst != null) pst.close();
                if (cn != null) cn.close();
            } catch (SQLException ex) {
                System.out.println(ex.getMessage());
            }
        }
        return false;
    }

    public List<Cliente> listarClientes() {
        List<Cliente> lista = new ArrayList<>();
        Connection cn = Conexion.conectar();
        PreparedStatement pst = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM Clientes";
        
        try {
            if (cn != null) {
                pst = cn.prepareStatement(sql);
                rs = pst.executeQuery();
                
                while (rs.next()) {
                    Cliente cte = new Cliente();
                    cte.setIdCliente(rs.getInt("id_cliente"));
                    cte.setNombre(rs.getString("nombre")); // Mapeo correcto de la columna
                    cte.setDui(rs.getString("dui"));
                    cte.setEdad(rs.getInt("edad"));
                    cte.setTelefono(rs.getString("telefono"));
                    
                    lista.add(cte);
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error al listar clientes: " + e.getMessage());
        } finally {
            try {
                if (rs != null) rs.close();
                if (pst != null) pst.close();
                if (cn != null) cn.close();
            } catch (SQLException ex) {
                System.out.println(ex.getMessage());
            }
        }
        return lista;
    }

    public Cliente buscarClientePorId(int id) {
        Cliente cte = null;
        Connection cn = Conexion.conectar();
        PreparedStatement pst = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM Clientes WHERE id_cliente = ?";
        
        try {
            if (cn != null) {
                pst = cn.prepareStatement(sql);
                pst.setInt(1, id);
                rs = pst.executeQuery();
                
                if (rs.next()) {
                    cte = new Cliente();
                    cte.setIdCliente(rs.getInt("id_cliente"));
                    cte.setNombre(rs.getString("nombre")); // Mapeo correcto
                    cte.setDui(rs.getString("dui"));
                    cte.setEdad(rs.getInt("edad"));
                    cte.setTelefono(rs.getString("telefono"));
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error al buscar cliente: " + e.getMessage());
        } finally {
            try {
                if (rs != null) rs.close();
                if (pst != null) pst.close();
                if (cn != null) cn.close();
            } catch (SQLException ex) {
                System.out.println(ex.getMessage());
            }
        }
        return cte;
    }

    public boolean actualizarCliente(Cliente cte) {
        Connection cn = Conexion.conectar();
        PreparedStatement pst = null;
        // Query corregida apuntando a la columna 'nombre'
        String sql = "UPDATE Clientes SET nombre = ?, dui = ?, edad = ?, telefono = ? WHERE id_cliente = ?";
        
        try {
            if (cn != null) {
                pst = cn.prepareStatement(sql);
                pst.setString(1, cte.getNombre());
                pst.setString(2, cte.getDui());
                pst.setInt(3, cte.getEdad());
                pst.setString(4, cte.getTelefono());
                pst.setInt(5, cte.getIdCliente());
                
                int filasAfectadas = pst.executeUpdate();
                return filasAfectadas > 0;
            }
        } catch (SQLException e) {
            System.out.println("❌ Error al actualizar cliente: " + e.getMessage());
        } finally {
            try {
                if (pst != null) pst.close();
                if (cn != null) cn.close();
            } catch (SQLException ex) {
                System.out.println(ex.getMessage());
            }
        }
        return false;
    }
}