package com.renta.controladores;

import com.renta.datos.ClienteDAO;
import com.renta.modelos.Cliente;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class ClienteServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        ClienteDAO dao = new ClienteDAO();

        // 1. ACCIÓN: ELIMINAR (DESACTIVAR)
        if (accion != null && accion.equals("eliminar")) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                if (dao.eliminarClienteLogico(id)) {
                    response.sendRedirect("clientes.jsp?msg=Cliente desactivado correctamente.");
                } else {
                    response.sendRedirect("clientes.jsp?error=No se pudo desactivar el cliente.");
                }
            } catch (Exception e) {
                response.sendRedirect("clientes.jsp?error=ID inválido.");
            }
            return;
        }

        // 2. ACCIÓN: GUARDAR / ACTUALIZAR
        String idStr = request.getParameter("txtId");
        String nombre = request.getParameter("txtNombre");
        String dui = request.getParameter("txtDui");
        String edadStr = request.getParameter("txtEdad");
        String telefono = request.getParameter("txtTelefono");

        // Validación básica
        if (nombre == null || dui == null || edadStr == null || telefono == null) {
            response.sendRedirect("clientes.jsp?error=Datos incompletos.");
            return;
        }

        int edad = Integer.parseInt(edadStr);
        if (edad < 18) {
            response.sendRedirect("clientes.jsp?error=El cliente debe ser mayor de 18 años.");
            return;
        }

        Cliente cliente = new Cliente();
        cliente.setNombre(nombre);
        cliente.setDui(dui);
        cliente.setEdad(edad);
        cliente.setTelefono(telefono);

        boolean exito;
        // Si no hay ID, es un registro nuevo
        if (idStr == null || idStr.trim().isEmpty()) {
            // FORZAMOS A TRUE PARA NUEVOS CLIENTES
            cliente.setActivo(true);
            exito = dao.registrarCliente(cliente);
        } else {
            // Es una actualización: se mantiene el estado que ya tenía o el que se decida
            cliente.setIdCliente(Integer.parseInt(idStr.trim()));
            cliente.setActivo(true); // Opcional: ajustar según si permites activar clientes desde el modal
            exito = dao.actualizarCliente(cliente);
        }

        if (exito) {
            response.sendRedirect("clientes.jsp?msg=Operación realizada con éxito.");
        } else {
            response.sendRedirect("clientes.jsp?error=Error al guardar en la base de datos.");
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
