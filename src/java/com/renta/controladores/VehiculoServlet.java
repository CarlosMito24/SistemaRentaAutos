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
        
        // 1. Recibir los parámetros del formulario HTML de vehiculos.jsp
        String marca = request.getParameter("txtMarca");
        String modelo = request.getParameter("txtModelo");
        String placa = request.getParameter("txtPlaca");
        int capacidad = Integer.parseInt(request.getParameter("txtCapacidad"));
        double precio = Double.parseDouble(request.getParameter("txtPrecio"));
        
        // 2. REQUERIMIENTO 2: Validación de datos de entrada (Precios y cantidades no negativos)
        if (capacidad <= 0 || precio <= 0.0) {
            // Si hay datos inválidos, redirigimos con un mensaje de advertencia
            response.sendRedirect("vehiculos.jsp?error=Los valores de capacidad y precio deben ser mayores a cero.");
            return;
        }
        
        // 3. Crear el objeto Vehiculo siguiendo el paradigma POO
        Vehiculo nuevoAuto = new Vehiculo();
        nuevoAuto.setMarca(marca);
        nuevoAuto.setModelo(modelo);
        nuevoAuto.setPlaca(placa);
        nuevoAuto.setCapacidad(capacidad);
        nuevoAuto.setPrecioDiario(precio);
        nuevoAuto.setDisponible(true); // Todo auto nuevo ingresa como listo/disponible
        
        // 4. Invocar la capa DAO para persistir en SQL Server
        VehiculoDAO dao = new VehiculoDAO();
        boolean exito = dao.registrarVehiculo(nuevoAuto);
        
        // 5. Redireccionar de vuelta a la interfaz para refrescar la tabla de inventario
        if (exito) {
            response.sendRedirect("vehiculos.jsp?msg=Vehiculo registrado exitosamente.");
        } else {
            response.sendRedirect("vehiculos.jsp?error=No se pudo registrar el vehiculo. Verifique la placa.");
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
