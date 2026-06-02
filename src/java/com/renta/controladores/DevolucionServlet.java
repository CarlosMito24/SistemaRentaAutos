package com.renta.controladores;

import com.renta.datos.AlquilerDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "DevolucionServlet", urlPatterns = {"/DevolucionServlet"})
public class DevolucionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Atrapamos el ID del ticket que viene en la URL
            int idAlquiler = Integer.parseInt(request.getParameter("id"));
            AlquilerDAO dao = new AlquilerDAO();

            // Ejecutamos la matemática y actualizamos la BD
            if (dao.registrarDevolucion(idAlquiler)) {
                response.sendRedirect("alquileres.jsp?msg=Vehículo recibido con éxito. Mora y totales actualizados.");
            } else {
                response.sendRedirect("alquileres.jsp?error=No se pudo procesar la devolución.");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect("alquileres.jsp?error=Error de sistema: ID inválido.");
        }
    }
}