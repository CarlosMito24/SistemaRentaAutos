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
                if (pst != null) {
                    pst.close();
                }
                if (cn != null) {
                    cn.close();
                }
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
                if (rs != null) {
                    rs.close();
                }
                if (pst != null) {
                    pst.close();
                }
                if (cn != null) {
                    cn.close();
                }
            } catch (SQLException ex) {
                System.out.println(ex.getMessage());
            }
        }
        return lista;
    }

    // Método para buscar un vehículo por su ID para cargar el formulario de edición
    public Vehiculo buscarVehiculoPorId(int id) {
        Vehiculo v = null;
        Connection cn = Conexion.conectar();
        PreparedStatement pst = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM Vehiculos WHERE id_vehiculo = ?";

        try {
            if (cn != null) {
                pst = cn.prepareStatement(sql);
                pst.setInt(1, id);
                rs = pst.executeQuery();

                if (rs.next()) {
                    v = new Vehiculo();
                    v.setIdVehiculo(rs.getInt("id_vehiculo"));
                    v.setMarca(rs.getString("marca"));
                    v.setModelo(rs.getString("modelo"));
                    v.setPlaca(rs.getString("placa"));
                    v.setCapacidad(rs.getInt("capacidad"));
                    v.setPrecioDiario(rs.getDouble("precio_diario"));
                    v.setDisponible(rs.getBoolean("disponible"));
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error al buscar vehículo por ID: " + e.getMessage());
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (pst != null) {
                    pst.close();
                }
                if (cn != null) {
                    cn.close();
                }
            } catch (SQLException ex) {
                System.out.println(ex.getMessage());
            }
        }
        return v;
    }

    // ¡NUEVO MÉTODO AGREGADO! Permite aplicar los cambios modificados en la base de datos
    public boolean actualizarVehiculo(Vehiculo auto) {
        Connection cn = Conexion.conectar();
        PreparedStatement pst = null;
        String sql = "UPDATE Vehiculos SET marca = ?, modelo = ?, placa = ?, capacidad = ?, precio_diario = ?, disponible = ? WHERE id_vehiculo = ?";

        try {
            if (cn != null) {
                pst = cn.prepareStatement(sql);
                pst.setString(1, auto.getMarca());
                pst.setString(2, auto.getModelo());
                pst.setString(3, auto.getPlaca());
                pst.setInt(4, auto.getCapacidad());
                pst.setDouble(5, auto.getPrecioDiario());
                pst.setBoolean(6, auto.isDisponible());
                pst.setInt(7, auto.getIdVehiculo()); // El ID va al final para cumplir con el WHERE

                int filasAfectadas = pst.executeUpdate();
                return filasAfectadas > 0;
            }
        } catch (SQLException e) {
            System.out.println("❌ Error al actualizar vehículo: " + e.getMessage());
        } finally {
            try {
                if (pst != null) {
                    pst.close();
                }
                if (cn != null) {
                    cn.close();
                }
            } catch (SQLException ex) {
                System.out.println(ex.getMessage());
            }
        }
        return false;
    }

    public List<Vehiculo> buscarVehiculos(String filtro) {
        List<Vehiculo> lista = new ArrayList<>();
        Connection cn = Conexion.conectar();
        PreparedStatement pst = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM Vehiculos WHERE marca LIKE ? OR modelo LIKE ? OR placa LIKE ?";

        try {
            if (cn != null) {
                pst = cn.prepareStatement(sql);
                String parametro = "%" + filtro + "%";
                pst.setString(1, parametro);
                pst.setString(2, parametro);
                pst.setString(3, parametro);
                rs = pst.executeQuery();

                while (rs.next()) {
                    Vehiculo v = new Vehiculo();
                    v.setIdVehiculo(rs.getInt("id_vehiculo"));
                    v.setMarca(rs.getString("marca"));
                    v.setModelo(rs.getString("modelo"));
                    v.setPlaca(rs.getString("placa"));
                    v.setCapacidad(rs.getInt("capacidad"));
                    v.setPrecioDiario(rs.getDouble("precio_diario"));
                    v.setDisponible(rs.getBoolean("disponible"));
                    lista.add(v);
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error en búsqueda: " + e.getMessage());
        } finally {
            // CORRECCIÓN: Agregamos el cierre de recursos para evitar fugas de memoria
            try {
                if (rs != null) {
                    rs.close();
                }
                if (pst != null) {
                    pst.close();
                }
                if (cn != null) {
                    cn.close();
                }
            } catch (SQLException ex) {
                System.out.println("Error al cerrar recursos: " + ex.getMessage());
            }
        }
        return lista;
    }
}
