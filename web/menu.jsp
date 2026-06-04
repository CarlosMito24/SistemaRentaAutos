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
    .navbar-custom {
        background-color: #1e293b; /* Azul corporativo oscuro */
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        padding: 12px 5%;
    }
    
    .navbar-brand-custom {
        color: #ffffff !important;
        font-weight: 800;
        font-size: 22px;
        letter-spacing: 0.5px;
        display: flex;
        align-items: center;
        gap: 12px;
    }
    
    .navbar-brand-custom span {
        color: #3b82f6; /* Azul brillante de acento */
    }
    
    .navbar-brand-custom img {
        width: 42px;
        height: 42px;
        border-radius: 50%;
        object-fit: cover;
        border: 2px solid #3b82f6;
    }

    .nav-link-custom {
        color: #e2e8f0 !important;
        font-weight: 600;
        font-size: 13.5px;
        letter-spacing: 0.5px;
        text-transform: uppercase;
        padding: 8px 16px !important;
        transition: color 0.3s, transform 0.2s;
        white-space: nowrap; 
        display: flex;
    }

    .nav-link-custom:hover {
        color: #3b82f6 !important;
        transform: translateY(-1px);
    }

    .user-info-custom {
        color: #cbd5e1;
        font-size: 14px;
        font-weight: 600;
        display: flex;
        align-items: center;
        margin-right: 20px;
    }

    .user-info-custom span {
        color: #3b82f6;
        margin-right: 8px;
        font-size: 16px;
    }

    .btn-logout-custom {
        background-color: #ef4444; /* Rojo elegante para cerrar sesión */
        color: #ffffff !important;
        padding: 8px 20px;
        border-radius: 6px;
        font-weight: 700;
        font-size: 13px;
        letter-spacing: 0.5px;
        text-transform: uppercase;
        text-decoration: none;
        transition: background-color 0.3s, transform 0.2s;
        display: inline-block;
        box-shadow: 0 2px 4px rgba(239, 68, 68, 0.2);
        white-space: nowrap; 
        display: flex;
    }

    .btn-logout-custom:hover {
        background-color: #dc2626;
        text-decoration: none;
        transform: translateY(-1px);
        box-shadow: 0 4px 8px rgba(239, 68, 68, 0.3);
    }

    .navbar-toggler {
        border-color: rgba(255,255,255,0.2);
    }
    
    .navbar-toggler-icon {
        background-image: url("data:image/svg+xml;charset=utf8,%3Csvg viewBox='0 0 30 30' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath stroke='rgba%28255, 255, 255, 0.7%29' stroke-width='2' stroke-linecap='round' stroke-miterlimit='10' d='M4 7h22M4 15h22M4 23h22'/%3E%3C/svg%3E");
    }
    
    /* Divisor vertical para separar el usuario de los links en PC */
    .nav-divider {
        width: 1px;
        height: 24px;
        background-color: rgba(255,255,255,0.15);
        margin: 0 15px;
        display: inline-block;
    }
    @media (max-width: 991px) {
        .nav-divider { display: none; }
        .user-info-custom { margin: 15px 0; }
    }
</style>

<header>
    <nav class="navbar navbar-expand-lg navbar-custom">
        <a href="principal.jsp" class="navbar-brand navbar-brand-custom">
            <!-- La misma imagen de tu login funcionando como logo circular -->
            <img src="img/xd.png" alt="Logo Renta Autos">
            Renta Autos <span>ITCA</span>
        </a>
        
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ml-auto align-items-center">
                <li class="nav-item">
                    <a href="clientes.jsp" class="nav-link nav-link-custom">👥 Clientes</a>
                </li>
                <li class="nav-item">
                    <a href="vehiculos.jsp" class="nav-link nav-link-custom">🚘 Vehículos</a>
                </li>
                <li class="nav-item">
                    <a href="alquileres.jsp" class="nav-link nav-link-custom">🔑 Procesar Alquiler</a>
                </li>
                <li class="nav-item">
                    <a href="reportes.jsp" class="nav-link nav-link-custom">📊 Reportes del Día</a>
                </li>
                
                <li class="nav-item d-none d-lg-flex align-items-center">
                    <div class="nav-divider"></div>
                </li>

                <!-- Aquí inyectamos el nombre completo sin errores -->
                <li class="nav-item user-info-custom">
                    <span>👤</span> <%= empMenu.getNombreCompleto() %>
                </li>
                <li class="nav-item">
                    <a href="LogoutServlet" class="btn-logout-custom">Cerrar Sesión</a>
                </li>
            </ul>
        </div>
    </nav>
</header>