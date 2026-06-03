package com.renta.controladores;

import com.renta.datos.AlquilerDAO;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "DevolucionServlet", urlPatterns = {"/DevolucionServlet"})
public class DevolucionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Aseguramos la codificación correcta
        request.setCharacterEncoding("UTF-8");

        try {
            // 1. Capturar los parámetros enviados por el Modal
            int idDetalle = Integer.parseInt(request.getParameter("idDetalle"));
            double mora = Double.parseDouble(request.getParameter("mora"));
            double totalFinal = Double.parseDouble(request.getParameter("totalFinal"));
            String fechaRealStr = request.getParameter("fechaReal");

            // 2. Parsear la fecha del HTML (viene con una 'T' separando fecha y hora)
            SimpleDateFormat sdfInput = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            java.util.Date parsedDate = sdfInput.parse(fechaRealStr);
            
            // Convertimos la fecha de Java a un Timestamp exacto para SQL Server
            java.sql.Timestamp fechaRealSql = new java.sql.Timestamp(parsedDate.getTime());

            // 3. Ejecutar la actualización en la base de datos Maestro-Detalle
            AlquilerDAO dao = new AlquilerDAO();
            if (dao.registrarDevolucion(idDetalle, fechaRealSql, mora, totalFinal)) {
                // Redirigir mandando un parámetro especial para imprimir la devolución
                response.sendRedirect("alquileres.jsp?msg=Devolucion procesada correctamente.&downloadDevolucionId=" + idDetalle);
            } else {
                response.sendRedirect("alquileres.jsp?error=Error interno al actualizar la base de datos.");
            }

        } catch (NumberFormatException | ParseException e) {
            System.err.println("Error de parseo en Servlet: " + e.getMessage());
            response.sendRedirect("alquileres.jsp?error=Los datos enviados no tienen un formato válido.");
        }
    }
}