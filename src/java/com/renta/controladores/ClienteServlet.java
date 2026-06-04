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
                    response.sendRedirect("clientes.jsp?error=No+se+pudo+desactivar+el+cliente");
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

            if (idStr == null || idStr.trim().isEmpty()) {
                // REGISTRO NUEVO (Usa la lógica de estados 1, 2, 0)
                int resultado = dao.registrarCliente(c);
                
                if (resultado == 1) {
                    response.sendRedirect("clientes.jsp?msg=Cliente+registrado+correctamente");
                } else if (resultado == 2) {
                    response.sendRedirect("clientes.jsp?msg=El+cliente+ya+exist%C3%ADa+y+fue+reactivado");
                } else {
                    response.sendRedirect("clientes.jsp?error=El+cliente+ya+existe+y+est%C3%A1+activo");
                }
            } else {
                // ACTUALIZACIÓN
                c.setIdCliente(Integer.parseInt(idStr));
                if (dao.actualizarCliente(c)) {
                    response.sendRedirect("clientes.jsp?msg=Cliente+actualizado+correctamente");
                } else {
                    response.sendRedirect("clientes.jsp?error=No+se+pudo+actualizar+el+cliente");
                }
            }

        } catch (NumberFormatException e) {
            response.sendRedirect("clientes.jsp?error=Formato+de+datos+num%C3%A9ricos+inv%C3%A1lido");
        }
    }

    private String validarDatos(String nombre, String dui, String edadStr, String tel) {
        if (nombre == null || nombre.trim().length() < 3) return "Nombre+muy+corto";
        if (dui == null || !dui.matches("\\d{8}-\\d{1}")) return "Formato+de+DUI+inv%C3%A1lido";
        if (tel == null || !tel.matches("\\d{4}-\\d{4}")) return "Formato+de+tel%C3%A9fono+inv%C3%A1lido";
        try {
            int edad = Integer.parseInt(edadStr);
            if (edad < 18 || edad > 100) return "La+edad+debe+ser+entre+18+y+100";
        } catch (NumberFormatException e) { return "La+edad+debe+ser+n%C3%BAmero"; }
        return null;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException { processRequest(req, res); }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException { processRequest(req, res); }
}