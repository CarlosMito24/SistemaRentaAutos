package com.renta.controladores;

import com.renta.datos.ClienteDAO;
import com.renta.modelos.Cliente;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class ClienteServlet extends HttpServlet {

    // ── GET: solo para acciones simples sin formulario (eliminar, etc.)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String accion = request.getParameter("accion");
        ClienteDAO dao = new ClienteDAO();

        if ("eliminar".equals(accion)) {
            try {
                String idParam = request.getParameter("id");
                if (idParam == null || idParam.trim().isEmpty()) {
                    redirigirError(response, "ID no proporcionado");
                    return;
                }
                int id = Integer.parseInt(idParam.trim());
                if (dao.eliminarClienteLogico(id)) {
                    redirigirExito(response, "Cliente desactivado correctamente");
                } else {
                    redirigirError(response, "No se pudo desactivar el cliente");
                }
            } catch (NumberFormatException e) {
                redirigirError(response, "ID inválido");
            }
        } else {
            response.sendRedirect("clientes.jsp");
        }
    }

    // ── POST: solo para guardar / actualizar desde el formulario modal
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        ClienteDAO dao = new ClienteDAO();

        String idStr = request.getParameter("txtId");
        String nombre = request.getParameter("txtNombre");
        String dui = request.getParameter("txtDui");
        String edadStr = request.getParameter("txtEdad");
        String tel = request.getParameter("txtTelefono");

        // Validación de formato
        String error = validarDatos(nombre, dui, edadStr, tel);
        if (error != null) {
            redirigirError(response, error);
            return;
        }

        try {
            Cliente c = new Cliente();
            c.setNombre(nombre.trim());
            c.setDui(dui.trim());
            c.setEdad(Integer.parseInt(edadStr));
            c.setTelefono(tel.trim());
            c.setActivo(true);

            boolean esActualizacion = (idStr != null && !idStr.trim().isEmpty());

            if (!esActualizacion) {
                // ── REGISTRAR / REACTIVAR
                int resultado = dao.registrarCliente(c);
                switch (resultado) {
                    case 1:
                        redirigirExito(response, "Cliente registrado correctamente");
                        break;
                    case 2:
                        redirigirExito(response, "El cliente ya existía y fue reactivado");
                        break;
                    default:
                        redirigirError(response, "Ya existe un cliente activo con este DUI");
                }
            } else {
                // ── ACTUALIZAR
                int id = Integer.parseInt(idStr.trim());
                c.setIdCliente(id);

                // Validación de DUI duplicado en otro cliente activo
                Cliente existente = dao.buscarPorDui(c.getDui());
                if (existente != null && existente.getIdCliente() != id && existente.isActivo()) {
                    redirigirError(response, "El DUI ya está registrado en otro cliente activo");
                    return;
                }

                if (dao.actualizarCliente(c)) {
                    redirigirExito(response, "Cliente actualizado correctamente");
                } else {
                    redirigirError(response, "No se pudo actualizar el cliente");
                }
            }

        } catch (NumberFormatException e) {
            redirigirError(response, "Formato de datos numéricos inválido");
        }
    }

    // ── Validación de campos ──────────────────────────────────────────────────
    private String validarDatos(String nombre, String dui, String edadStr, String tel) {
        if (nombre == null || nombre.trim().length() < 3) {
            return "Nombre muy corto";
        }
        if (dui == null || !dui.matches("\\d{8}-\\d{1}")) {
            return "Formato de DUI inválido";
        }
        if (tel == null || !tel.matches("\\d{4}-\\d{4}")) {
            return "Formato de teléfono inválido";
        }
        try {
            int edad = Integer.parseInt(edadStr);
            if (edad < 18 || edad > 100) {
                return "La edad debe ser entre 18 y 100";
            }
        } catch (NumberFormatException e) {
            return "La edad debe ser un número";
        }
        return null;
    }

    // ── Helpers ───────────────────────────────────────────────────────────────
    private void redirigirExito(HttpServletResponse response, String mensaje) throws IOException {
        response.sendRedirect("clientes.jsp?msg="
                + URLEncoder.encode(mensaje, StandardCharsets.UTF_8.toString()));
    }

    private void redirigirError(HttpServletResponse response, String mensaje) throws IOException {
        response.sendRedirect("clientes.jsp?error="
                + URLEncoder.encode(mensaje, StandardCharsets.UTF_8.toString()));
    }
}
