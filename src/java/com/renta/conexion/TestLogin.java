/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.renta.conexion;

/**
 *
 * @author carlo
 */
import com.renta.datos.UsuarioDAO;
import com.renta.modelos.Usuario;

public class TestLogin {
    public static void main(String[] args) {
        System.out.println("=== INICIANDO PRUEBA DE CONEXIÓN Y LOGIN ===");
        
        UsuarioDAO dao = new UsuarioDAO();
        
        // Intentamos loguearnos con los datos de prueba insertados en SQL Server
        Usuario u = dao.login("carlos.mito", "admin123");
        
        if (u != null) {
            System.out.println("🎉 ¡ÉXITO TOTAL! El Login funciona perfectamente.");
            System.out.println("Empleado autenticado: " + u.getNombreCompleto() + " (ID: " + u.getIdUsuario() + ")");
        } else {
            System.out.println("⚠️ Conexión establecida pero credenciales incorrectas o el usuario no existe en la BD.");
        }
    }
}
