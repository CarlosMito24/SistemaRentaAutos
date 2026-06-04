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

        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        String accion = request.getParameter("accion");
        ClienteDAO dao = new ClienteDAO();

        // 1. ELIMINAR
        if ("eliminar".equals(accion)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                if (dao.eliminarClienteLogico(id)) {
                    response.sendRedirect("clientes.jsp?msg=Cliente+desactivado+correctamente");
                } else {
                    response.sendRedirect("clientes.jsp?error=No+se+pudo+realizar+la+operaci%C3%B3n");
                }
            } catch (Exception e) {
                response.sendRedirect("clientes.jsp?error=ID+inv%C3%A1lido");
            }
            return;
        }

        // 2. GUARDAR / ACTUALIZAR
        String idStr = request.getParameter("txtId");
        String nombre = request.getParameter("txtNombre");
        String dui = request.getParameter("txtDui");
        String edadStr = request.getParameter("txtEdad");
        String tel = request.getParameter("txtTelefono");

        // Ejecutar validación de backend
        String error = validarDatos(nombre, dui, edadStr, tel);
        if (error != null) {
            response.sendRedirect("clientes.jsp?error=" + error);
            return;
        }

        try {
            Cliente c = new Cliente();
            c.setNombre(nombre.trim());
            c.setDui(dui.trim());
            c.setEdad(Integer.parseInt(edadStr));
            c.setTelefono(tel.trim());
            c.setActivo(true);

            boolean exito;
            if (idStr == null || idStr.trim().isEmpty()) {
                // El DAO ahora maneja la lógica de inserción o reactivación
                exito = dao.registrarCliente(c);
            } else {
                c.setIdCliente(Integer.parseInt(idStr));
                exito = dao.actualizarCliente(c);
            }

            if (exito) {
                // Si exito es true, el cliente se guardó o se reactivó con éxito
                response.sendRedirect("clientes.jsp?msg=Operaci%C3%B3n+exitosa");
            } else {
                // Si exito es false, es porque el cliente ya existe y está activo (duplicado)
                response.sendRedirect("clientes.jsp?error=El+cliente+con+ese+DUI+ya+existe+y+est%C3%A1+activo");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("clientes.jsp?error=Datos+num%C3%A9ricos+inv%C3%A1lidos");
        }
    }

    // Método auxiliar de validación
    private String validarDatos(String nombre, String dui, String edadStr, String tel) {
        if (nombre == null || nombre.trim().length() < 3) {
            return "El+nombre+debe+tener+al+menos+3+caracteres";
        }
        if (dui == null || !dui.matches("\\d{8}-\\d{1}")) {
            return "Formato+de+DUI+inv%C3%A1lido+(00000000-0)";
        }
        if (tel == null || !tel.matches("\\d{4}-\\d{4}")) {
            return "Formato+de+tel%C3%A9fono+inv%C3%A1lido+(0000-0000)";
        }
        try {
            int edad = Integer.parseInt(edadStr);
            if (edad < 18 || edad > 100) {
                return "La+edad+debe+ser+entre+18+y+100+a%C3%B1os";
            }
        } catch (NumberFormatException e) {
            return "La+edad+debe+ser+un+n%C3%BAmero";
        }
        return null;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        processRequest(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        processRequest(req, res);
    }
}
