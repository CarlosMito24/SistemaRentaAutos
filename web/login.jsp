<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (session != null && session.getAttribute("empleado") != null) {
        response.sendRedirect("principal.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Acceso - Renta de Autos ITCA</title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                /* Fondo degradado moderno */
                background: #2c3e50;
                display: flex;
                justify-content: center;
                align-items: center;
                min-height: 100vh;
                margin: 0;
            }

            .login-container {
                background: rgba(255, 255, 255, 0.95);
                padding: 40px;
                border-radius: 15px;
                box-shadow: 0 10px 25px rgba(0,0,0,0.3);
                width: 100%;
                max-width: 380px;
                text-align: center;
            }

            h2 {
                color: #1e3c72;
                margin-bottom: 25px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 1px;
            }

            .form-group {
                margin-bottom: 20px;
                text-align: left;
            }
            .form-group label {
                display: block;
                margin-bottom: 8px;
                color: #444;
                font-weight: 600;
            }
            .form-group input {
                width: 100%;
                padding: 14px;
                border: 2px solid #ddd;
                border-radius: 8px;
                font-size: 16px;
                transition: border 0.3s;
                box-sizing: border-box;
            }
            .form-group input:focus {
                border-color: #007bff;
                outline: none;
            }

            .btn-submit {
                width: 100%;
                padding: 14px;
                background-color: #2a5298;
                border: none;
                color: white;
                border-radius: 8px;
                cursor: pointer;
                font-size: 18px;
                font-weight: bold;
                transition: background 0.3s;
                margin-top: 10px;
            }
            .btn-submit:hover {
                background-color: #1e3c72;
            }

            .error-msg {
                background: #ffe6e6;
                color: #d00;
                padding: 10px;
                border-radius: 5px;
                margin-bottom: 20px;
                font-size: 14px;
                border: 1px solid #d00;
            }

            /* Logo o Branding superior */
            .logo-icon {
                font-size: 40px;
                margin-bottom: 10px;
                display: block;
            }
        </style>
    </head>
    <body>
        <div class="login-container">
            <span class="logo-icon">🚗</span>
            <h2>RENTA DE AUTOS ITCA</h2>

            <% if (request.getAttribute("error") != null) {%>
            <div class="error-msg"><%= request.getAttribute("error")%></div>
            <% }%>

            <form action="LoginServlet" method="POST">
                <div class="form-group">
                    <label for="txtUsuario">Usuario</label>
                    <input type="text" id="txtUsuario" name="txtUsuario" placeholder="Ingrese su usuario" required>
                </div>
                <div class="form-group">
                    <label for="txtPassword">Contraseña</label>
                    <input type="password" id="txtPassword" name="txtPassword" placeholder="••••••••" required>
                </div>
                <button type="submit" class="btn-submit">INGRESAR</button>
            </form>
        </div>
    </body>
</html>