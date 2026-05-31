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

        // Manejo de eliminación lógica
        if ("eliminar".equals(accion)) {
            int id = Integer.parseInt(request.getParameter("id"));
            if (dao.eliminarVehiculoLogico(id)) {
                response.sendRedirect("vehiculos.jsp?msg=Vehículo desactivado correctamente.");
            } else {
                response.sendRedirect("vehiculos.jsp?error=No se pudo desactivar el vehículo.");
            }
            return;
        }

        // Obtención de datos del formulario
        String idStr = request.getParameter("txtId");
        Vehiculo v = new Vehiculo();

        v.setMarca(request.getParameter("txtMarca"));
        v.setModelo(request.getParameter("txtModelo"));
        v.setPlaca(request.getParameter("txtPlaca"));
        v.setCapacidad(Integer.parseInt(request.getParameter("txtCapacidad")));
        v.setPrecioDiario(Double.parseDouble(request.getParameter("txtPrecio")));
        v.setAnio(Integer.parseInt(request.getParameter("txtAnio")));
        v.setColor(request.getParameter("txtColor")); // Captura del nuevo campo color
        v.setDisponible(true); // Por defecto al registrar

        boolean exito;
        if (idStr == null || idStr.trim().isEmpty()) {
            // Registro nuevo
            v.setActivo(true);
            exito = dao.registrarVehiculo(v);
        } else {
            // Actualización
            v.setIdVehiculo(Integer.parseInt(idStr.trim()));
            v.setActivo(true);
            exito = dao.actualizarVehiculo(v);
        }

        // Redirección final
        if (exito) {
            response.sendRedirect("vehiculos.jsp?msg=Operación realizada con éxito.");
        } else {
            response.sendRedirect("vehiculos.jsp?error=Error al guardar vehículo en la base de datos.");
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
