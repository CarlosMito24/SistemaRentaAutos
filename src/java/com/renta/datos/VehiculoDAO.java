package com.renta.datos;

import com.renta.conexion.Conexion;
import com.renta.modelos.Vehiculo;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VehiculoDAO {

    // Lista todos los vehículos activos
    public List<Vehiculo> listarVehiculos() {
        List<Vehiculo> lista = new ArrayList<>();
        String sql = "SELECT * FROM Vehiculos WHERE activo = 1";
        try (Connection cn = Conexion.conectar(); PreparedStatement pst = cn.prepareStatement(sql); ResultSet rs = pst.executeQuery()) {
            while (rs.next()) {
                Vehiculo v = new Vehiculo();
                v.setIdVehiculo(rs.getInt("id_vehiculo"));
                v.setMarca(rs.getString("marca"));
                v.setModelo(rs.getString("modelo"));
                v.setPlaca(rs.getString("placa"));
                v.setCapacidad(rs.getInt("capacidad"));
                v.setPrecioDiario(rs.getDouble("precio_diario"));
                v.setDisponible(rs.getBoolean("disponible"));
                v.setActivo(rs.getBoolean("activo"));
                v.setAnio(rs.getInt("anio"));
                v.setColor(rs.getString("color"));
                lista.add(v);
            }
        } catch (SQLException e) {
            System.out.println("Error listar: " + e.getMessage());
        }
        return lista;
    }

    /**
     * BUSCA UN VEHÍCULO POR PLACA (Nuevo)
     * Útil para validar si el vehículo ya existe, esté activo o no.
     */
    public Vehiculo buscarPorPlaca(String placa) {
        String sql = "SELECT id_vehiculo, activo FROM Vehiculos WHERE placa = ?";
        try (Connection cn = Conexion.conectar(); PreparedStatement pst = cn.prepareStatement(sql)) {
            pst.setString(1, placa);
            ResultSet rs = pst.executeQuery();
            if (rs.next()) {
                Vehiculo v = new Vehiculo();
                v.setIdVehiculo(rs.getInt("id_vehiculo"));
                v.setActivo(rs.getBoolean("activo"));
                return v;
            }
        } catch (SQLException e) {
            System.out.println("Error buscarPorPlaca: " + e.getMessage());
        }
        return null;
    }

    /**
     * REACTIVA UN VEHÍCULO (Nuevo)
     * Cambia activo de 0 a 1 para no duplicar registros.
     */
    public boolean reactivarVehiculo(int id) {
        String sql = "UPDATE Vehiculos SET activo = 1 WHERE id_vehiculo = ?";
        try (Connection cn = Conexion.conectar(); PreparedStatement pst = cn.prepareStatement(sql)) {
            pst.setInt(1, id);
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            return false;
        }
    }

    public List<Vehiculo> listarVehiculosDisponibles() {
        List<Vehiculo> lista = new ArrayList<>();
        String sql = "SELECT * FROM Vehiculos WHERE activo = 1 AND disponible = 1";
        try (Connection cn = Conexion.conectar(); PreparedStatement pst = cn.prepareStatement(sql); ResultSet rs = pst.executeQuery()) {
            while (rs.next()) {
                Vehiculo v = new Vehiculo();
                v.setIdVehiculo(rs.getInt("id_vehiculo"));
                v.setMarca(rs.getString("marca"));
                v.setModelo(rs.getString("modelo"));
                v.setPlaca(rs.getString("placa"));
                v.setPrecioDiario(rs.getDouble("precio_diario"));
                v.setAnio(rs.getInt("anio"));
                v.setColor(rs.getString("color"));
                lista.add(v);
            }
        } catch (SQLException e) {
            System.out.println("Error al listar disponibles: " + e.getMessage());
        }
        return lista;
    }

    public boolean registrarVehiculo(Vehiculo v) {
        String sql = "INSERT INTO Vehiculos (marca, modelo, placa, capacidad, precio_diario, disponible, activo, anio, color) VALUES (?,?,?,?,?,?,1,?,?)";
        try (Connection cn = Conexion.conectar(); PreparedStatement pst = cn.prepareStatement(sql)) {
            pst.setString(1, v.getMarca());
            pst.setString(2, v.getModelo());
            pst.setString(3, v.getPlaca());
            pst.setInt(4, v.getCapacidad());
            pst.setDouble(5, v.getPrecioDiario());
            pst.setBoolean(6, v.isDisponible());
            pst.setInt(7, v.getAnio());
            pst.setString(8, v.getColor());
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            return false;
        }
    }

    public boolean actualizarVehiculo(Vehiculo v) {
        String sql = "UPDATE Vehiculos SET marca=?, modelo=?, placa=?, capacidad=?, precio_diario=?, disponible=?, anio=?, color=? WHERE id_vehiculo=?";
        try (Connection cn = Conexion.conectar(); PreparedStatement pst = cn.prepareStatement(sql)) {
            pst.setString(1, v.getMarca());
            pst.setString(2, v.getModelo());
            pst.setString(3, v.getPlaca());
            pst.setInt(4, v.getCapacidad());
            pst.setDouble(5, v.getPrecioDiario());
            pst.setBoolean(6, v.isDisponible());
            pst.setInt(7, v.getAnio());
            pst.setString(8, v.getColor());
            pst.setInt(9, v.getIdVehiculo());
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            return false;
        }
    }

    public boolean eliminarVehiculoLogico(int id) {
        String sql = "UPDATE Vehiculos SET activo = 0 WHERE id_vehiculo = ?";
        try (Connection cn = Conexion.conectar(); PreparedStatement pst = cn.prepareStatement(sql)) {
            pst.setInt(1, id);
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            return false;
        }
    }
}