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
import com.renta.modelos.Usuario;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UsuarioDAO {
    // Método POO para validar el login del empleado
    public Usuario login(String user, String pass) {
        Usuario usuarioEncontrado = null;
        Connection cn = Conexion.conectar();
        PreparedStatement pst = null;
        ResultSet rs = null;
        
        // Consulta SQL parametrizada por seguridad
        String sql = "SELECT id_usuario, nombre_completo, username FROM Usuarios WHERE username = ? AND password_user = ?";
        
        try {
            if (cn != null) {
                pst = cn.prepareStatement(sql);
                pst.setString(1, user);
                pst.setString(2, pass);
                rs = pst.executeQuery();
                
                // Si la consulta devuelve una fila, las credenciales son correctas
                if (rs.next()) {
                    usuarioEncontrado = new Usuario();
                    usuarioEncontrado.setIdUsuario(rs.getInt("id_usuario"));
                    usuarioEncontrado.setNombreCompleto(rs.getString("nombre_completo"));
                    usuarioEncontrado.setUsername(rs.getString("username"));
                    // No seteamos la contraseña por seguridad en la sesión
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error en el método login de UsuarioDAO: " + e.getMessage());
        } finally {
            // Cerrar recursos para liberar memoria en el servidor
            try {
                if (rs != null) rs.close();
                if (pst != null) pst.close();
                if (cn != null) cn.close();
            } catch (SQLException ex) {
                System.out.println("Error al cerrar conexiones: " + ex.getMessage());
            }
        }
        return usuarioEncontrado; // Retorna el objeto armado o null si no se halló
    }
}
