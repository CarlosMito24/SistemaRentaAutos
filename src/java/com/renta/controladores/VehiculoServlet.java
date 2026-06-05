package com.renta.controladores;

import com.renta.datos.VehiculoDAO;
import com.renta.modelos.Vehiculo;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class VehiculoServlet extends HttpServlet {

    // ── GET: solo para acciones simples sin formulario (eliminar, reactivar, etc.)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String accion = request.getParameter("accion");
        VehiculoDAO dao = new VehiculoDAO();

        if ("eliminar".equals(accion)) {
            try {
                String idParam = request.getParameter("id");
                if (idParam == null || idParam.trim().isEmpty()) {
                    redirigirError(response, "ID no proporcionado");
                    return;
                }
                int id = Integer.parseInt(idParam.trim());
                if (dao.eliminarVehiculoLogico(id)) {
                    redirigirExito(response, "Vehículo desactivado correctamente");
                } else {
                    redirigirError(response, "No se pudo desactivar el vehículo");
                }
            } catch (NumberFormatException e) {
                redirigirError(response, "ID inválido");
            }
        } else {
            // GET sin acción reconocida → redirigir a la lista
            response.sendRedirect("vehiculos.jsp");
        }
    }

    // ── POST: solo para guardar / actualizar desde el formulario modal
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        VehiculoDAO dao = new VehiculoDAO();

        try {
            String idStr    = request.getParameter("txtId");
            String marca    = request.getParameter("txtMarca");
            String placa    = request.getParameter("txtPlaca");
            String modelo   = request.getParameter("txtModelo");
            String color    = request.getParameter("txtColor");
            String capStr   = request.getParameter("txtCapacidad");
            String anioStr  = request.getParameter("txtAnio");
            String precioRaw = request.getParameter("txtPrecio");

            // Validación básica de campos obligatorios
            if (esVacio(marca) || esVacio(placa) || esVacio(modelo)
                    || esVacio(color) || esVacio(capStr) || esVacio(anioStr) || esVacio(precioRaw)) {
                redirigirError(response, "Debe completar todos los campos obligatorios");
                return;
            }

            // Limpieza del precio (acepta coma o punto decimal)
            String precioLimpio = precioRaw.trim().replace(",", ".").replaceAll("[^0-9.]", "");
            if (precioLimpio.isEmpty()) {
                redirigirError(response, "Formato de precio inválido");
                return;
            }

            // Construir el objeto Vehiculo
            Vehiculo v = new Vehiculo();
            v.setMarca(marca.trim());
            v.setModelo(modelo.trim());
            v.setPlaca(placa.trim());
            v.setColor(color.trim());
            v.setCapacidad(Integer.parseInt(capStr.trim()));
            v.setAnio(Integer.parseInt(anioStr.trim()));
            v.setPrecioDiario(Double.parseDouble(precioLimpio));
            v.setDisponible(true);

            boolean esActualizacion = (idStr != null && !idStr.trim().isEmpty());

            if (!esActualizacion) {
                // ── REGISTRAR / REACTIVAR
                int resultado = dao.registrarVehiculo(v);
                switch (resultado) {
                    case 1:
                        redirigirExito(response, "Vehículo registrado exitosamente");
                        break;
                    case 2:
                        redirigirExito(response, "El vehículo ya existía y ha sido reactivado correctamente");
                        break;
                    default:
                        redirigirError(response, "Ya existe un vehículo activo con esta placa");
                }
            } else {
                // ── ACTUALIZAR
                int id = Integer.parseInt(idStr.trim());
                v.setIdVehiculo(id);

                // Verificar placa duplicada (lógica de negocio que quedaba suelta en el Servlet original)
                Vehiculo existente = dao.buscarPorPlaca(v.getPlaca());
                if (existente != null && existente.getIdVehiculo() != id && existente.isActivo()) {
                    redirigirError(response, "La placa ya está asignada a otro vehículo activo");
                    return;
                }

                if (dao.actualizarVehiculo(v)) {
                    redirigirExito(response, "Vehículo actualizado correctamente");
                } else {
                    redirigirError(response, "Error al actualizar el vehículo");
                }
            }

        } catch (NumberFormatException e) {
            redirigirError(response, "Formato de datos inválido (verifique números)");
        } catch (Exception e) {
            redirigirError(response, "Error inesperado en el servidor");
        }
    }

    // ── Helpers para no repetir URLEncoder en cada línea ──────────────────────

    private void redirigirExito(HttpServletResponse response, String mensaje) throws IOException {
        response.sendRedirect("vehiculos.jsp?msg=" +
                URLEncoder.encode(mensaje, StandardCharsets.UTF_8.toString()));
    }

    private void redirigirError(HttpServletResponse response, String mensaje) throws IOException {
        response.sendRedirect("vehiculos.jsp?error=" +
                URLEncoder.encode(mensaje, StandardCharsets.UTF_8.toString()));
    }

    private boolean esVacio(String valor) {
        return valor == null || valor.trim().isEmpty();
    }
}