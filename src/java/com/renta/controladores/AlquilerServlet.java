package com.renta.controladores;

import com.renta.datos.AlquilerDAO;
import com.renta.modelos.DetalleAlquiler;
import com.renta.modelos.TicketAlquiler;
import com.renta.modelos.Usuario;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "AlquilerServlet", urlPatterns = {"/AlquilerServlet"})
public class AlquilerServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");

        try {
            // 1. Validar sesión del empleado
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("empleado") == null) {
                response.sendRedirect("login.jsp?error=Sesión expirada.");
                return;
            }
            Usuario u = (Usuario) session.getAttribute("empleado");

            // 2. Crear el Ticket Maestro
            TicketAlquiler ticket = new TicketAlquiler();
            ticket.setIdUsuario(u.getIdUsuario());
            ticket.setIdCliente(Integer.parseInt(request.getParameter("txtIdCliente")));
            ticket.setFechaEmision(new Date()); 
            
            // 3. CAPTURAR MÚLTIPLES VEHÍCULOS (USANDO ARREGLOS)
            String[] vehiculos = request.getParameterValues("txtIdVehiculo[]");
            String[] fechasI = request.getParameterValues("txtFechaInicio[]");
            String[] horasI = request.getParameterValues("txtHoraInicio[]");
            String[] fechasF = request.getParameterValues("txtFechaFin[]");
            String[] horasF = request.getParameterValues("txtHoraFin[]");
            String[] totales = request.getParameterValues("txtTotalLinea[]");

            // Validar que el carrito no esté vacío
            if (vehiculos == null || vehiculos.length == 0) {
                response.sendRedirect("alquileres.jsp?error=Debe agregar al menos un vehículo al comprobante.");
                return;
            }

            double granTotal = 0.0;

            // 4. Bucle para procesar cada vehículo del carrito
            for (int i = 0; i < vehiculos.length; i++) {
                DetalleAlquiler detalle = new DetalleAlquiler();
                detalle.setIdVehiculo(Integer.parseInt(vehiculos[i]));
                
                Date fechaEntrega = sdf.parse(fechasI[i] + " " + horasI[i]);
                Date fechaDevolucion = sdf.parse(fechasF[i] + " " + horasF[i]);
                detalle.setFechaEntrega(fechaEntrega);
                detalle.setFechaDevolucionEsperada(fechaDevolucion);
                
                double totalLinea = Double.parseDouble(totales[i]);
                detalle.setPrecioAplicado(totalLinea);
                detalle.setSubtotal(totalLinea);
                detalle.setMora(0.0);
                detalle.setTotalLinea(totalLinea);

                // Inyectamos el vehículo a la lista del ticket y sumamos el dinero
                ticket.agregarDetalle(detalle);
                granTotal += totalLinea;
            }
            
            ticket.setTotalGlobal(granTotal);

            // 5. Procesar mediante el DAO y disparar el PDF
            AlquilerDAO dao = new AlquilerDAO();
            int idGenerado = dao.registrarTicket(ticket);
            
            if (idGenerado > 0) {
                response.sendRedirect("alquileres.jsp?msg=Registrado correctamente.&downloadId=" + idGenerado);
            } else {
                response.sendRedirect("alquileres.jsp?error=Error al guardar el ticket en base de datos.");
            }

        } catch (NumberFormatException | ParseException e) {
            response.sendRedirect("alquileres.jsp?error=Error en formato de datos: " + e.getMessage());
        } catch (NullPointerException e) {
            response.sendRedirect("login.jsp?error=Error de sesión.");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { processRequest(request, response); }
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { processRequest(request, response); }
}