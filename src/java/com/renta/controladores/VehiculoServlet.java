package com.renta.controladores;

import com.renta.datos.VehiculoDAO;
import com.renta.modelos.Vehiculo;
import java.io.IOException;
import javax.servlet.*;
import javax.servlet.http.*;

public class VehiculoServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        VehiculoDAO dao = new VehiculoDAO();

        // 1. Manejo de eliminación lógica
        if ("eliminar".equals(accion)) {
            int id = Integer.parseInt(request.getParameter("id"));
            if (dao.eliminarVehiculoLogico(id)) {
                response.sendRedirect("vehiculos.jsp?msg=Vehículo desactivado correctamente.");
            } else {
                response.sendRedirect("vehiculos.jsp?error=No se pudo desactivar el vehículo.");
            }
            return;
        }

        // 2. Obtención de datos del formulario
        String idStr = request.getParameter("txtId");
        String placa = request.getParameter("txtPlaca");
        
        Vehiculo v = new Vehiculo();
        v.setMarca(request.getParameter("txtMarca"));
        v.setModelo(request.getParameter("txtModelo"));
        v.setPlaca(placa);
        v.setCapacidad(Integer.parseInt(request.getParameter("txtCapacidad")));
        v.setPrecioDiario(Double.parseDouble(request.getParameter("txtPrecio")));
        v.setAnio(Integer.parseInt(request.getParameter("txtAnio")));
        v.setColor(request.getParameter("txtColor"));
        v.setDisponible(true); 

        boolean exito = false;
        Vehiculo existente = dao.buscarPorPlaca(placa);

        // 3. Lógica de registro o actualización
        if (idStr == null || idStr.trim().isEmpty()) {
            if (existente != null) {
                if (!existente.isActivo()) {
                    dao.reactivarVehiculo(existente.getIdVehiculo());
                    response.sendRedirect("vehiculos.jsp?msg=La placa existía, vehículo reactivado exitosamente.");
                } else {
                    response.sendRedirect("vehiculos.jsp?error=Ya existe un vehículo activo con esta placa.");
                }
                return;
            }
            v.setActivo(true);
            exito = dao.registrarVehiculo(v);
        } else {
            v.setIdVehiculo(Integer.parseInt(idStr.trim()));
            if (existente != null && existente.getIdVehiculo() != v.getIdVehiculo()) {
                response.sendRedirect("vehiculos.jsp?error=La placa ingresada ya pertenece a otro vehículo.");
                return;
            }
            v.setActivo(true);
            exito = dao.actualizarVehiculo(v);
        }

        // 4. Redirección final
        if (exito) {
            response.sendRedirect("vehiculos.jsp?msg=Operación realizada con éxito.");
        } else if (!response.isCommitted()) {
            response.sendRedirect("vehiculos.jsp?error=Error al procesar en la base de datos.");
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