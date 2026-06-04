package com.renta.controladores;

import com.renta.datos.VehiculoDAO;
import com.renta.modelos.Vehiculo;
import java.io.IOException;
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
                int id = Integer.parseInt(request.getParameter("id"));
                if (dao.eliminarVehiculoLogico(id)) {
                    response.sendRedirect("vehiculos.jsp?msg=desactivado");
                } else {
                    response.sendRedirect("vehiculos.jsp?error=error_db");
                }
            } catch (Exception e) {
                response.sendRedirect("vehiculos.jsp?error=error_id");
            }
            return;
        }

        // 2. GUARDAR / ACTUALIZAR
        String idStr = request.getParameter("txtId");
        
        try {
            Vehiculo v = new Vehiculo();
            v.setMarca(request.getParameter("txtMarca").trim());
            v.setModelo(request.getParameter("txtModelo").trim());
            v.setPlaca(request.getParameter("txtPlaca").trim());
            v.setCapacidad(Integer.parseInt(request.getParameter("txtCapacidad")));
            
            // Lógica de limpieza para evitar errores de formato en el precio
            String precioStr = request.getParameter("txtPrecio").trim().replace(",", ".");
            v.setPrecioDiario(Double.parseDouble(precioStr));
            
            v.setAnio(Integer.parseInt(request.getParameter("txtAnio")));
            v.setColor(request.getParameter("txtColor").trim());
            v.setDisponible(true);

            if (idStr == null || idStr.trim().isEmpty()) {
                // REGISTRO NUEVO
                int resultado = dao.registrarVehiculo(v);
                
                if (resultado == 1) {
                    response.sendRedirect("vehiculos.jsp?msg=registrado");
                } else if (resultado == 2) {
                    response.sendRedirect("vehiculos.jsp?msg=reactivado");
                } else {
                    response.sendRedirect("vehiculos.jsp?error=duplicado");
                }
            } else {
                // ACTUALIZACIÓN
                v.setIdVehiculo(Integer.parseInt(idStr.trim()));
                
                Vehiculo existente = dao.buscarPorPlaca(v.getPlaca());
                if (existente != null && existente.getIdVehiculo() != v.getIdVehiculo() && existente.isActivo()) {
                    response.sendRedirect("vehiculos.jsp?error=placa_existente");
                } else {
                    if (dao.actualizarVehiculo(v)) {
                        response.sendRedirect("vehiculos.jsp?msg=actualizado");
                    } else {
                        response.sendRedirect("vehiculos.jsp?error=error_db");
                    }
                }
            }
        } catch (NumberFormatException e) {
            // Este catch capturará si algún campo numérico (Año, Capacidad o Precio) falla
            response.sendRedirect("vehiculos.jsp?error=datos_invalidos");
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