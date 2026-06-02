package com.renta.controladores;

import com.renta.datos.AlquilerDAO;
import com.renta.modelos.Alquiler;
import com.renta.modelos.Usuario;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

//@WebServlet("/AlquilerServlet")
public class AlquilerServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        // Configuramos el formato para que atrape tanto la fecha como la hora
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");

        try {
            // 1. Captura de parámetros numéricos
            int idCliente = Integer.parseInt(request.getParameter("txtIdCliente"));
            int idVehiculo = Integer.parseInt(request.getParameter("txtIdVehiculo"));
            double totalInput = Double.parseDouble(request.getParameter("txtTotal"));

            // 2. Captura de los 4 campos de tiempo desde el JSP
            String fechaI = request.getParameter("txtFechaInicio");
            String horaI = request.getParameter("txtHoraInicio");
            String fechaF = request.getParameter("txtFechaFin");
            String horaF = request.getParameter("txtHoraFin");

            // Unimos fecha y hora con un espacio en blanco para parsearlos juntos
            Date fechaInicio = sdf.parse(fechaI + " " + horaI);
            Date fechaDevolucion = sdf.parse(fechaF + " " + horaF);

            // 3. Obtener sesión de usuario
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("empleado") == null) {
                response.sendRedirect("login.jsp?error=Sesión expirada.");
                return;
            }

            Usuario u = (Usuario) session.getAttribute("empleado");
            int idUsuario = u.getIdUsuario();

            // 4. Crear y llenar objeto Alquiler
            Alquiler alquiler = new Alquiler();
            alquiler.setIdCliente(idCliente);
            alquiler.setIdVehiculo(idVehiculo);
            alquiler.setFechaAlquiler(fechaInicio);
            alquiler.setFechaDevolucionEsperada(fechaDevolucion);
            alquiler.setIdUsuario(idUsuario);

            // Campos financieros calculados en el Frontend
            alquiler.setPrecioAplicado(totalInput); 
            alquiler.setSubtotal(totalInput);
            alquiler.setTotalPago(totalInput);
            alquiler.setMora(0.0);

            // 5. Procesar mediante el DAO
            AlquilerDAO dao = new AlquilerDAO();
            if (dao.registrarAlquiler(alquiler)) {
                response.sendRedirect("alquileres.jsp?msg=Alquiler registrado correctamente.");
            } else {
                response.sendRedirect("alquileres.jsp?error=Error al guardar en base de datos.");
            }

        } catch (NumberFormatException | ParseException e) {
            response.sendRedirect("alquileres.jsp?error=Error en formato de datos: " + e.getMessage());
        } catch (NullPointerException e) {
            response.sendRedirect("login.jsp?error=Debe iniciar sesión para realizar alquileres.");
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