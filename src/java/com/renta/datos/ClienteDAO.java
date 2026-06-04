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
        Cliente existente = buscarPorDui(cte.getDui());

        // Si existe y está inactivo -> Reactivamos
        if (existente != null && !existente.isActivo()) {
            return reactivarCliente(existente.getIdCliente());
        }
        // Si existe y ya está activo -> Retornamos false (para que el servlet muestre el error)
        if (existente != null && existente.isActivo()) {
            return false;
        }

        // Si NO existe, procedemos con el INSERT normal
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
                return pst.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            System.out.println("Error: " + e.getMessage());
        } finally {
            try {
                if (pst != null) {
                    pst.close();
                }
                if (cn != null) {
                    cn.close();
                }
            } catch (SQLException ex) {
            }
        }
        return false;
    }

// Agrega este método para cambiar el estado a 1 (activo)
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
            System.out.println("Error: " + e.getMessage());
        } finally {
            try {
                if (pst != null) {
                    pst.close();
                }
                if (cn != null) {
                    cn.close();
                }
            } catch (SQLException ex) {
            }
        }
        return false;
    }

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
                    cte.setActivo(rs.getBoolean("activo")); // <-- Mapeo nuevo

                    lista.add(cte);
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error al listar: " + e.getMessage());
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
                    cte.setActivo(rs.getBoolean("activo"));
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error al buscar cliente: " + e.getMessage());
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
        return cte;
    }

    public boolean actualizarCliente(Cliente cte) {
        Connection cn = Conexion.conectar();
        PreparedStatement pst = null;
        // Incluye activo en el set
        String sql = "UPDATE Clientes SET nombre = ?, dui = ?, edad = ?, telefono = ?, activo = ? WHERE id_cliente = ?";

        try {
            if (cn != null) {
                pst = cn.prepareStatement(sql);
                pst.setString(1, cte.getNombre());
                pst.setString(2, cte.getDui());
                pst.setInt(3, cte.getEdad());
                pst.setString(4, cte.getTelefono());
                pst.setBoolean(5, cte.isActivo()); // Nuevo
                pst.setInt(6, cte.getIdCliente());

                return pst.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            System.out.println("❌ Error al actualizar: " + e.getMessage());
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
            System.out.println("❌ Error al eliminar cliente: " + e.getMessage());
        } finally {
            try {
                if (pst != null) {
                    pst.close();
                }
                if (cn != null) {
                    cn.close();
                }
            } catch (SQLException ex) {
                System.out.println("❌ Error al cerrar conexión: " + ex.getMessage());
            }
        }
        return false;
    }

    public Cliente buscarPorDui(String dui) {
        Cliente cte = null;
        Connection cn = Conexion.conectar();
        PreparedStatement pst = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM Clientes WHERE dui = ?";
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
            System.out.println("Error: " + e.getMessage());
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
            }
        }
        return cte;
    }
}
