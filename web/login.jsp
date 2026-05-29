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
            /* Cambiamos height: 100vh por min-height para que si el contenido es más alto (ej: horizontal), permita hacer scroll */
            body { 
                font-family: Arial, sans-serif; 
                background-color: #f4f4f9; 
                display: flex; 
                justify-content: center; 
                align-items: center; 
                min-height: 100vh; 
                margin: 0; 
                padding: 20px; /* Más padding para que la caja no pegue en los bordes en pantallas pequeñas */
                box-sizing: border-box; 
            }
            
            .login-container { 
                background: white; 
                padding: 30px; 
                border-radius: 8px; 
                box-shadow: 0 4px 8px rgba(0,0,0,0.1); 
                width: 100%; 
                max-width: 350px; 
                box-sizing: border-box; 
                transition: all 0.3s ease; /* Transición suave si se gira la pantalla */
            }
            
            h2 { text-align: center; color: #333; margin-top: 0; }
            .form-group { margin-bottom: 15px; }
            .form-group label { display: block; margin-bottom: 5px; color: #666; font-weight: bold; }
            .form-group input { width: 100%; padding: 12px; box-sizing: border-box; border: 1px solid #ccc; border-radius: 4px; font-size: 16px; } 
            
            .btn-submit { 
                width: 100%; 
                padding: 12px; 
                background-color: #007bff; 
                border: none; 
                color: white; 
                border-radius: 4px; 
                cursor: pointer; 
                font-size: 16px; 
                font-weight: bold; 
            }
            .btn-submit:hover { background-color: #0056b3; }
            .error-msg { color: red; text-align: center; font-size: 14px; margin-bottom: 10px; }

            /* =========================================================
               === MEDIA QUERIES MULTIPANTALLA (VERTICAL Y HORIZONTAL) ===
               ========================================================= */

            /* 1. Ajuste para tablets y pantallas medianas */
            @media (max-width: 991px) {
                .login-container {
                    padding: 25px;
                }
            }

            /* 2. Optimización estricta para teléfonos móviles pequeños (Vertical) */
            @media (max-width: 480px) {
                body {
                    padding: 10px;
                }
                .login-container {
                    padding: 20px 15px;
                    border-radius: 6px;
                }
                h2 { font-size: 24px; }
            }

            /* 3. CONTROL DE GIRO HORIZONTAL (LANDSCAPE)
               Detecta cuando la pantalla del móvil es más ancha que alta */
            @media (max-height: 500px) and (orientation: landscape) {
                body {
                    align-items: flex-start; /* Evita que la caja se quede atrapada al centro si es muy alta */
                    padding: 15px;
                }
                .login-container {
                    padding: 15px 25px;
                    max-width: 450px; /* Ensanchamos un poco la caja en horizontal para aprovechar el espacio */
                }
                h2 { margin-bottom: 10px; }
                .form-group { margin-bottom: 10px; } /* Compactamos márgenes para que quepa todo sin hacer mucho scroll */
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