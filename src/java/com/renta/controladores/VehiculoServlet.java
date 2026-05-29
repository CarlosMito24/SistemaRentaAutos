/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.renta.controladores;

import com.renta.datos.VehiculoDAO;
import com.renta.modelos.Vehiculo;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author carlo
 */
public class VehiculoServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        VehiculoDAO dao = new VehiculoDAO();

        // =========================================================================
        // 1. INTERCEPTAR ACCIÓN DE EDICIÓN (Viaja por enlace GET)
        // =========================================================================
        if (accion != null && accion.equals("editar")) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                Vehiculo v = dao.buscarVehiculoPorId(id);
                // Enviamos el vehículo encontrado como un atributo a la vista
                request.setAttribute("vehiculoEditar", v);
            } catch (NumberFormatException e) {
                System.out.println("Error al convertir ID en vehículo: " + e.getMessage());
            }
            // Usamos forward para mantener el atributo vivo en el JSP de vehículos
            request.getRequestDispatcher("vehiculos.jsp").forward(request, response);
            return;
        }

        // =========================================================================
        // 2. LÓGICA PARA GUARDAR O ACTUALIZAR (Viaja por formulario POST)
        // =========================================================================
        // Recibir los parámetros del formulario HTML de vehiculos.jsp
        String idStr = request.getParameter("txtId"); // Campo hidden indispensable
        String marca = request.getParameter("txtMarca");
        String modelo = request.getParameter("txtModelo");
        String placa = request.getParameter("txtPlaca");
        int capacidad = Integer.parseInt(request.getParameter("txtCapacidad"));
        double precio = Double.parseDouble(request.getParameter("txtPrecio"));

        // REQUERIMIENTO 2: Validación de datos de entrada (Precios y cantidades no negativos)
        if (capacidad <= 0 || precio <= 0.0) {
            response.sendRedirect("vehiculos.jsp?error=Los valores de capacidad y precio deben ser mayores a cero.");
            return;
        }

        // Crear y estructurar el objeto Vehiculo
        Vehiculo auto = new Vehiculo();
        auto.setMarca(marca);
        auto.setModelo(modelo);
        auto.setPlaca(placa);
        auto.setCapacidad(capacidad);
        auto.setPrecioDiario(precio);

        // Al guardar o editar, determinamos su disponibilidad (por defecto true)
        // Puedes cambiar esto si agregas un checkbox o select en el formulario
        auto.setDisponible(true);

        boolean exito;

        // Evaluación del flujo: Si el ID está vacío es nuevo, de lo contrario se modifica
        if (idStr == null || idStr.trim().isEmpty()) {
            // REGISTRAR NUEVO
            exito = dao.registrarVehiculo(auto);
        } else {
            // ACTUALIZAR EXISTENTE
            try {
                auto.setIdVehiculo(Integer.parseInt(idStr.trim()));
                exito = dao.actualizarVehiculo(auto);
            } catch (NumberFormatException e) {
                exito = false;
            }
        }

        // Redireccionar de vuelta para actualizar la interfaz limpia
        if (exito) {
            response.sendRedirect("vehiculos.jsp?msg=Vehiculo procesado correctamente.");
        } else {
            response.sendRedirect("vehiculos.jsp?error=No se pudo guardar el vehiculo. Verifique que la placa no este duplicada.");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }
}
