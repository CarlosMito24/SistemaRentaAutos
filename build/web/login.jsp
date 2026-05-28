<%-- 
    Document   : login
    Created on : 26 may 2026, 19:16:35
    Author     : carlo
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Acceso al Sistema - Renta Autos</title>
        <style>
            body { font-family: Arial, sans-serif; background-color: #f4f4f9; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; padding: 10px; box-sizing: border-box; }
            .login-container { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); width: 100%; max-width: 350px; box-sizing: border-box; }
            h2 { text-align: center; color: #333; margin-top: 0; }
            .form-group { margin-bottom: 15px; }
            .form-group label { display: block; margin-bottom: 5px; color: #666; font-weight: bold; }
            .form-group input { width: 100%; padding: 12px; box-sizing: border-box; border: 1px solid #ccc; border-radius: 4px; font-size: 16px; } /* 16px evita el zoom automático en celulares */
            .btn-submit { width: 100%; padding: 12px; background-color: #007bff; border: none; color: white; border-radius: 4px; cursor: pointer; font-size: 16px; font-weight: bold; }
            .btn-submit:hover { background-color: #0056b3; }
            .error-msg { color: red; text-align: center; font-size: 14px; margin-bottom: 10px; }

            /* === RESPONSIVE PARA EL LOGIN === */
            @media (max-width: 991px) {
                .login-container {
                    padding: 20px;
                }
            }
        </style>
    </head>
    <body>
        <div class="login-container">
            <h2>Renta Autos</h2>
            
            <% if (request.getAttribute("error") != null) { %>
                <div class="error-msg"><%= request.getAttribute("error") %></div>
            <% } %>

            <form action="LoginServlet" method="POST">
                <div class="form-group">
                    <label for="txtUsuario">Usuario Empleado:</label>
                    <input type="text" id="txtUsuario" name="txtUsuario" required>
                </div>
                <div class="form-group">
                    <label for="txtPassword">Contraseña:</label>
                    <input type="password" id="txtPassword" name="txtPassword" required>
                </div>
                <button type="submit" class="btn-submit">Ingresar al Sistema</button>
            </form>
        </div>
    </body>
</html>