/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.renta.conexion;

/**
 *
 * @author carlo
 */

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Conexion {
    // Configuración de los parámetros de red y acceso
    private static final String DRIVER = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
    // REEMPLAZA TU_IP_DEL_SERVER por la IP real de tu Windows Server
    private static final String URL = "jdbc:sqlserver://localhost:1433;databaseName=RentaAutos;encrypt=false;trustServerCertificate=true;";
    private static final String USER = "UsuarioRentaAutos";
    private static final String PASS = "Proyecto2026*";
    
    public static Connection conectar() {
        Connection cn = null;
        try {
            // Cargar el driver JDBC en memoria
            Class.forName(DRIVER);
            // Establecer la conexión
            cn = DriverManager.getConnection(URL, USER, PASS);
            System.out.println("✅ Conexión exitosa a SQL Server de forma remota.");
        } catch (ClassNotFoundException e) {
            System.out.println("❌ Error: No se encontró el Driver JDBC. " + e.getMessage());
        } catch (SQLException e) {
            System.out.println("❌ Error de SQL al conectar: " + e.getMessage());
        }
        return cn;
    }
}
