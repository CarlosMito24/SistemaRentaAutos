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
import com.renta.modelos.Vehiculo;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class VehiculoDAO {
    // Método para registrar un vehículo (Soporta Req 1 y Req 2)
    public boolean registrarVehiculo(Vehiculo auto) {
        Connection cn = Conexion.conectar();
        PreparedStatement pst = null;
        String sql = "INSERT INTO Vehiculos (marca, modelo, placa, capacidad, precio_diario, disponible) VALUES (?, ?, ?, ?, ?, ?)";
        
        try {
            if (cn != null) {
                pst = cn.prepareStatement(sql);
                pst.setString(1, auto.getMarca());
                pst.setString(2, auto.getModelo());
                pst.setString(3, auto.getPlaca());
                pst.setInt(4, auto.getCapacidad());
                pst.setDouble(5, auto.getPrecioDiario());
                pst.setBoolean(6, auto.isDisponible());
                
                int filasAfectadas = pst.executeUpdate();
                return filasAfectadas > 0;
            }
        } catch (SQLException e) {
            System.out.println("❌ Error al registrar vehículo: " + e.getMessage());
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

    // Método para obtener todos los vehículos (Soporta Req 4: Control de Inventario)
    public List<Vehiculo> listarVehiculos() {
        List<Vehiculo> lista = new ArrayList<>();
        Connection cn = Conexion.conectar();
        PreparedStatement pst = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM Vehiculos";
        
        try {
            if (cn != null) {
                pst = cn.prepareStatement(sql);
                rs = pst.executeQuery();
                
                while (rs.next()) {
                    Vehiculo auto = new Vehiculo();
                    auto.setIdVehiculo(rs.getInt("id_vehiculo"));
                    auto.setMarca(rs.getString("marca"));
                    auto.setModelo(rs.getString("modelo"));
                    auto.setPlaca(rs.getString("placa"));
                    auto.setCapacidad(rs.getInt("capacidad"));
                    auto.setPrecioDiario(rs.getDouble("precio_diario"));
                    auto.setDisponible(rs.getBoolean("disponible"));
                    
                    lista.add(auto);
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error al listar vehículos: " + e.getMessage());
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
