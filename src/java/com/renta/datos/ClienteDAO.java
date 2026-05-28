/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.renta.datos;

/**
 *
 * @author carlo
 */
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
        String sql = "INSERT INTO Clientes (nombre_completo, dui, edad, telefono) VALUES (?, ?, ?, ?)";
        
        try {
            if (cn != null) {
                pst = cn.prepareStatement(sql);
                pst.setString(1, cte.getNombreCompleto());
                pst.setString(2, cte.getDui());
                pst.setInt(3, cte.getEdad());
                pst.setString(4, cte.getTelefono());
                
                return pst.executeUpdate() > 0;
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
                    cte.setNombreCompleto(rs.getString("nombre_completo"));
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
}
