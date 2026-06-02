<%@page import="com.renta.modelos.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Usuario empMenu = (session != null) ? (Usuario) session.getAttribute("empleado") : null;
    if (empMenu == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<style>
    .navbar {
        background-color: #2c3e50;
        font-size: 21px !important;
    }
    .navbar-brand {
        color: white;
        font-weight: bold;
        text-decoration: none;
    }
    .enlace {
        color: #FFF !important;
    }
    .enlace:hover {
        color: orange !important;
    }
    .navbar-toggler {
        border-color: rgba(255, 255, 255, 0.1);
    }
    .navbar-toggler-icon {
        background-image: url("data:image/svg+xml;charset=utf8,%3Csvg viewBox='0 0 30 30' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath stroke='rgba%28255, 255, 255, 0.5%29' stroke-width='2' stroke-linecap='round' stroke-miterlimit='10' d='M4 7h22M4 15h22M4 23h22'/%3E%3C/svg%3E");
    }
    .usuario {
        color: white;
        display: flex;
        align-items: center;
    }
    .btn-logout {
        background-color: #e74c3c;
        color: white;
        text-decoration: none;
        border-radius: 4px;
        font-weight: bold;
        margin: 5px;
        height: 35px;
        box-sizing: border-box;
        display: inline-flex;
        justify-content: center;
        align-items: center;
        padding: 0 10px;
    }
    .btn-logout:hover {
        background-color: #c0392b;
        color: white;
    }
</style>
<header>
    <nav class="navbar navbar-expand-lg navbar-dark">
        <a href="principal.jsp" class="navbar-brand">🚗 Renta Autos</a>
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav"
                aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ml-auto">
                <li class="nav-item">
                    <a href="clientes.jsp" class="enlace nav-link">👥 Clientes</a>
                </li>
                <li class="nav-item">
                    <a href="vehiculos.jsp" class="enlace nav-link">🚘 Vehículos</a>
                </li>
                <li class="nav-item">
                    <a href="alquileres.jsp" class="enlace nav-link">🔑 Procesar Alquiler</a>
                </li>
                <li class="nav-item">
                    <a href="reportes.jsp" class="enlace nav-link">📊 Reportes del Día</a>
                </li>
            </ul>
            <ul class="navbar-nav ml-auto">
                <li class="nav-item usuario">
                    <strong><%= empMenu.getNombreCompleto()%></strong>
                    <a href="LogoutServlet" class="btn-logout">Cerrar Sesión</a>
                </li>
            </ul>
        </div>
    </nav>
</header>



