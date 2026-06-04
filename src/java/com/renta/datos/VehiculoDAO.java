package com.renta.datos;

import com.renta.conexion.Conexion;
import com.renta.modelos.Vehiculo;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VehiculoDAO {

    // Retorna: 1 = Registrado, 2 = Reactivado, 0 = Error o Ya existe
    public int registrarVehiculo(Vehiculo v) {
        Vehiculo existente = buscarPorPlaca(v.getPlaca());

        // 1. Si existe y está inactivo -> Reactivamos
        if (existente != null && !existente.isActivo()) {
            return reactivarVehiculo(existente.getIdVehiculo()) ? 2 : 0;
        }

        // 2. Si existe y ya está activo -> Error (0)
        if (existente != null && existente.isActivo()) {
            return 0;
        }

        // 3. Insertar nuevo vehículo
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
            return pst.executeUpdate() > 0 ? 1 : 0;
        } catch (SQLException e) {
            System.out.println("❌ Error al registrar: " + e.getMessage());
            return 0;
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
            System.out.println("❌ Error al actualizar: " + e.getMessage());
            return false;
        }
    }

    public boolean reactivarVehiculo(int id) {
        String sql = "UPDATE Vehiculos SET activo = 1 WHERE id_vehiculo = ?";
        try (Connection cn = Conexion.conectar(); PreparedStatement pst = cn.prepareStatement(sql)) {
            pst.setInt(1, id);
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("❌ Error al reactivar: " + e.getMessage());
            return false;
        }
    }

    public boolean eliminarVehiculoLogico(int id) {
        String sql = "UPDATE Vehiculos SET activo = 0 WHERE id_vehiculo = ?";
        try (Connection cn = Conexion.conectar(); PreparedStatement pst = cn.prepareStatement(sql)) {
            pst.setInt(1, id);
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("❌ Error al eliminar: " + e.getMessage());
            return false;
        }
    }

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
            System.out.println("❌ Error buscarPorPlaca: " + e.getMessage());
        }
        return null;
    }

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
            System.out.println("❌ Error listar: " + e.getMessage());
        }
        return lista;
    }

    /**
     * Lista solo los vehículos que están marcados como disponibles (disponible
     * = 1) y que están activos en el sistema (activo = 1).
     */
    public List<Vehiculo> listarVehiculosDisponibles() {
        List<Vehiculo> lista = new ArrayList<>();
        // Filtramos por disponible = 1 y activo = 1
        String sql = "SELECT * FROM Vehiculos WHERE disponible = 1 AND activo = 1";

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
            System.out.println("❌ Error en listarVehiculosDisponibles: " + e.getMessage());
        }
        return lista;
    }
}
