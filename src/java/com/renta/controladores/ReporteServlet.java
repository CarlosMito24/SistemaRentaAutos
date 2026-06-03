package com.renta.controladores;

import com.renta.datos.ReporteDAO;
import com.renta.modelos.ReporteDia;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "ReporteServlet", urlPatterns = {"/ReporteServlet"})
public class ReporteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Usa el mismo atributo de sesión que LoginServlet: "empleado"
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("empleado") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String fecha = request.getParameter("fecha");
        if (fecha == null || fecha.isEmpty()) {
            fecha = LocalDate.now().toString();
        }

        ReporteDAO dao = new ReporteDAO();
        try {
            ReporteDia resumen  = dao.obtenerResumenDia(fecha);
            List<Object[]> detalle   = dao.obtenerDetalleAlquileresDia(fecha);
            List<Object[]> vehiculos = dao.obtenerVehiculosMasAlquilados(fecha);
            List<Object[]> moras     = dao.obtenerDevolucionesConMora(fecha);

            request.setAttribute("resumen",   resumen);
            request.setAttribute("detalle",   detalle);
            request.setAttribute("vehiculos", vehiculos);
            request.setAttribute("moras",     moras);
            request.setAttribute("fecha",     fecha);

            request.getRequestDispatcher("reportes.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al generar el reporte: " + e.getMessage());
            request.setAttribute("fecha", fecha);
            request.getRequestDispatcher("reportes.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}


