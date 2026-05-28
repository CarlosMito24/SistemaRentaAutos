/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.renta.controladores;

import com.renta.datos.UsuarioDAO;
import com.renta.modelos.Usuario;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 *
 * @author carlo
 */
public class LoginServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Capturar los datos enviados desde el formulario login.jsp
        String txtUsuario = request.getParameter("txtUsuario");
        String txtPassword = request.getParameter("txtPassword");
        
        UsuarioDAO dao = new UsuarioDAO();
        // Validar en la base de datos
        Usuario empleadoLogueado = dao.login(txtUsuario, txtPassword);
        
        if (empleadoLogueado != null) {
            // ¡Credenciales correctas! Creamos o recuperamos la sesión de Tomcat
            HttpSession session = request.getSession(true);
            // Guardamos el objeto entero del usuario en la sesión para usarlo en otras páginas
            session.setAttribute("empleado", empleadoLogueado);
            
            // Redireccionar al menú o panel principal del negocio (lo crearemos después)
            response.sendRedirect("principal.jsp");
        } else {
            // Credenciales incorrectas: Regresamos al login enviando un mensaje de error
            request.setAttribute("error", "Usuario o contraseña inválidos.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
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
