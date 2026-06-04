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

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        String accion = request.getParameter("accion");
        VehiculoDAO dao = new VehiculoDAO();

        // 1. ELIMINAR (Desactivación lógica)
        if ("eliminar".equals(accion)) {
            try {
                String idParam = request.getParameter("id");
                if (idParam != null) {
                    int id = Integer.parseInt(idParam);
                    if (dao.eliminarVehiculoLogico(id)) {
                        response.sendRedirect("vehiculos.jsp?msg=" + URLEncoder.encode("Vehículo desactivado correctamente", StandardCharsets.UTF_8.toString()));
                    } else {
                        response.sendRedirect("vehiculos.jsp?error=" + URLEncoder.encode("No se pudo desactivar el vehículo", StandardCharsets.UTF_8.toString()));
                    }
                }
            } catch (NumberFormatException e) {
                response.sendRedirect("vehiculos.jsp?error=" + URLEncoder.encode("ID inválido", StandardCharsets.UTF_8.toString()));
            }
            return;
        }

        // 2. GUARDAR / ACTUALIZAR
        try {
            String idStr = request.getParameter("txtId");
            String marca = request.getParameter("txtMarca");
            String placa = request.getParameter("txtPlaca");

            if (marca == null || marca.trim().isEmpty() || placa == null || placa.trim().isEmpty()) {
                response.sendRedirect("vehiculos.jsp?error=" + URLEncoder.encode("Debe completar los campos obligatorios", StandardCharsets.UTF_8.toString()));
                return;
            }

            Vehiculo v = new Vehiculo();
            v.setMarca(marca.trim());
            v.setModelo(request.getParameter("txtModelo").trim());
            v.setPlaca(placa.trim());
            v.setCapacidad(Integer.parseInt(request.getParameter("txtCapacidad")));
            v.setAnio(Integer.parseInt(request.getParameter("txtAnio")));
            v.setColor(request.getParameter("txtColor").trim());

            // Limpieza robusta del precio
            String precioRaw = request.getParameter("txtPrecio").trim().replace(",", ".");
            String precioLimpio = precioRaw.replaceAll("[^0-9.]", "");
            if (precioLimpio.isEmpty()) {
                throw new NumberFormatException();
            }
            v.setPrecioDiario(Double.parseDouble(precioLimpio));

            v.setDisponible(true);

            if (idStr == null || idStr.trim().isEmpty()) {
                // LÓGICA DE REGISTRO / REACTIVACIÓN
                int resultado = dao.registrarVehiculo(v);

                if (resultado == 1) {
                    response.sendRedirect("vehiculos.jsp?msg=" + URLEncoder.encode("Vehículo registrado exitosamente", StandardCharsets.UTF_8.toString()));
                } else if (resultado == 2) {
                    // Mensaje personalizado para reactivación (igual que en Clientes)
                    response.sendRedirect("vehiculos.jsp?msg=" + URLEncoder.encode("El vehículo ya existía y ha sido reactivado correctamente", StandardCharsets.UTF_8.toString()));
                } else {
                    response.sendRedirect("vehiculos.jsp?error=" + URLEncoder.encode("Error: Ya existe un vehículo activo con esta placa", StandardCharsets.UTF_8.toString()));
                }
            } else {
                // LÓGICA DE ACTUALIZACIÓN
                v.setIdVehiculo(Integer.parseInt(idStr.trim()));
                Vehiculo existente = dao.buscarPorPlaca(v.getPlaca());

                if (existente != null && existente.getIdVehiculo() != v.getIdVehiculo() && existente.isActivo()) {
                    response.sendRedirect("vehiculos.jsp?error=" + URLEncoder.encode("La placa ya está asignada a otro vehículo", StandardCharsets.UTF_8.toString()));
                } else if (dao.actualizarVehiculo(v)) {
                    response.sendRedirect("vehiculos.jsp?msg=" + URLEncoder.encode("Vehículo actualizado correctamente", StandardCharsets.UTF_8.toString()));
                } else {
                    response.sendRedirect("vehiculos.jsp?error=" + URLEncoder.encode("Error al actualizar el vehículo", StandardCharsets.UTF_8.toString()));
                }
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("vehiculos.jsp?error=" + URLEncoder.encode("Formato de datos inválido (verifique números)", StandardCharsets.UTF_8.toString()));
        } catch (Exception e) {
            response.sendRedirect("vehiculos.jsp?error=" + URLEncoder.encode("Error inesperado en el servidor", StandardCharsets.UTF_8.toString()));
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }
}
