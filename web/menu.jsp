<%-- 
    Document   : menu
    Created on : 26 may 2026, 19:38:28
    Author     : carlo
--%>

<%@page import="com.renta.modelos.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Verificación centralizada de sesión para cualquier página que incluya el menú
    Usuario empMenu = (session != null) ? (Usuario) session.getAttribute("empleado") : null;
    if (empMenu == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<style>
    .navbar {
        background-color: #2c3e50;
        padding: 15px 20px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-radius: 5px;
        margin-bottom: 20px;
        flex-wrap: wrap; /* Permite que los elementos bajen si no caben */
    }
    .navbar-brand {
        color: white;
        font-size: 20px;
        font-weight: bold;
        text-decoration: none;
    }
    .navbar-menu {
        display: flex;
        gap: 20px;
    }
    .navbar-item {
        color: #ecf0f1;
        text-decoration: none;
        font-size: 16px;
        padding: 5px 10px;
        border-radius: 4px;
        transition: background 0.3s;
    }
    .navbar-item:hover {
        background-color: #34495e;
        color: #3498db;
    }
    .user-info {
        color: white;
        display: flex;
        align-items: center;
        gap: 15px;
    }
    .btn-logout {
        background-color: #e74c3c;
        color: white;
        padding: 6px 12px;
        text-decoration: none;
        border-radius: 4px;
        font-weight: bold;
        font-size: 14px;
    }
    .btn-logout:hover {
        background-color: #c0392b;
    }

    /* === RESPONSIVE: DISEÑO PARA MÓVILES Y TABLETAS === */
    @media (max-width: 991px) {
        .navbar {
            flex-direction: column;
            align-items: flex-start;
            gap: 15px;
        }
        .navbar-menu {
            flex-direction: column;
            width: 100%;
            gap: 10px;
        }
        .navbar-item {
            display: block;
            padding: 8px 10px;
            background-color: #34495e;
        }
        .user-info {
            width: 100%;
            justify-content: space-between;
            border-top: 1px solid #4f5d73;
            padding-top: 10px;
        }
    }
</style>

<div class="navbar">
    <a href="principal.jsp" class="navbar-brand">🚗 Renta Autos</a>
    
    <div class="navbar-menu">
        <a href="clientes.jsp" class="navbar-item">👥 Clientes</a>
        <a href="vehiculos.jsp" class="navbar-item">🚘 Vehículos</a>
        <a href="#" class="navbar-item">🔑 Procesar Alquiler</a>
        <a href="#" class="navbar-item">📊 Reportes del Día</a>
    </div>
    
    <div class="user-info">
        <span>👤 <strong><%= empMenu.getNombreCompleto() %></strong></span>
        <a href="LogoutServlet" class="btn-logout">Cerrar Sesión</a>
    </div>
</div>
