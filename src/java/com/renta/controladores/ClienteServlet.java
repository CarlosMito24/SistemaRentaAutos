package com.renta.controladores;

import com.renta.datos.ClienteDAO;
import com.renta.modelos.Cliente;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author carlo
 */
public class ClienteServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        ClienteDAO dao = new ClienteDAO();

        // Si la acción es editar, viaja por RequestDispatcher.forward
        if (accion != null && accion.equals("editar")) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                Cliente cte = dao.buscarClientePorId(id);
                request.setAttribute("clienteEditar", cte);
            } catch (NumberFormatException e) {
                System.out.println("Error en conversión de ID: " + e.getMessage());
            }
            request.getRequestDispatcher("clientes.jsp").forward(request, response);
            return;
        }

        // LÓGICA DE GUARDAR (Igual a VehiculoServlet)
        // 1. Recibir los parámetros desde clientes.jsp
        String idStr = request.getParameter("txtId");
        String nombre = request.getParameter("txtNombre");
        String dui = request.getParameter("txtDui");
        int edad = Integer.parseInt(request.getParameter("txtEdad"));
        String telefono = request.getParameter("txtTelefono");

        // 2. Validación de regla de negocio
        if (edad < 18) {
            response.sendRedirect("clientes.jsp?error=Los valores de edad deben ser mayores o iguales a 18.");
            return;
        }

        // 3. Crear el objeto con el paradigma POO
        Cliente nuevoCliente = new Cliente();
        nuevoCliente.setNombre(nombre);
        nuevoCliente.setDui(dui);
        nuevoCliente.setEdad(edad);
        nuevoCliente.setTelefono(telefono);

        // 4. Invocar la capa DAO
        boolean exito;
        if (idStr == null || idStr.trim().isEmpty()) {
            exito = dao.registrarCliente(nuevoCliente);
        } else {
            nuevoCliente.setIdCliente(Integer.parseInt(idStr.trim()));
            exito = dao.actualizarCliente(nuevoCliente);
        }

        // 5. Redireccionar de vuelta a la vista (Refresca nativamente el inventario/tabla)
        if (exito) {
            response.sendRedirect("clientes.jsp?msg=Cliente registrado exitosamente.");
        } else {
            response.sendRedirect("clientes.jsp?error=No se pudo registrar el cliente. Verifique el DUI.");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }
}