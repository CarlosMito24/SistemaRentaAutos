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
    <title>Acceso — Renta de Autos ITCA</title>
    <link rel="icon" href="img/logo.png" type="image/jpeg">
    
    <style>
        :root {
            /* Paleta de colores original y corporativa */
            --primary: #1e293b;   /* Azul oscuro corporativo (de tu dashboard original) */
            --accent: #3b82f6;    /* Azul brillante para botones y focus */
            --bg-light: #f4f7f6;  /* Fondo principal claro */
            --text-dark: #2c3e50; /* Texto principal */
            --text-muted: #6c757d;/* Texto secundario */
            --border: #ced4da;    /* Bordes de inputs */
            --radius: 8px;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        html, body {
            height: 100%;
            /* Regresamos a la tipografía estándar y limpia */
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--bg-light);
            color: var(--text-dark);
            overflow: hidden;
        }

        /* ── LAYOUT DIVIDIDO ── */
        .stage {
            display: grid;
            grid-template-columns: 1fr 450px;
            height: 100vh;
            background: #ffffff;
        }

        /* ── LEFT PANEL (Fondo oscuro para fundir la imagen conces.jpg) ── */
        .hero {
            position: relative;
            overflow: hidden;
            background: #000000; 
            display: flex;
            flex-direction: column;
            justify-content: center;
            border-right: 1px solid var(--border);
        }

        .hero-img-wrap {
            position: relative;
            z-index: 3;
            text-align: center;
            padding: 40px;
        }

        .hero-img-wrap img {
            width: 100%;
            max-width: 850px;
            object-fit: contain;
            animation: heroReveal 1.2s cubic-bezier(0.22,1,0.36,1) both;
        }

        @keyframes heroReveal {
            from { opacity: 0; transform: scale(1.05); }
            to   { opacity: 1; transform: scale(1); }
        }

        .hero-brand {
            position: absolute;
            top: 40px;
            left: 50px;
            z-index: 5;
        }

        .hero-brand .label {
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 3px;
            text-transform: uppercase;
            color: #8ab4f8; 
            margin-bottom: 5px;
        }

        .hero-brand .title {
            font-size: 38px;
            font-weight: 800;
            line-height: 1.1;
            letter-spacing: 1px;
            color: #ffffff;
        }

        .hero-brand .title span {
            color: var(--accent);
        }

        /* ── RIGHT PANEL (Formulario Claro Corporativo) ── */
        .login-panel {
            background: #ffffff;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 40px 50px;
            box-shadow: -10px 0 30px rgba(0,0,0,0.05);
            z-index: 10;
        }

        .card {
            width: 100%;
            max-width: 350px;
        }

        .card-header {
            margin-bottom: 35px;
            text-align: left;
        }

        .card-header h1 {
            font-size: 32px;
            font-weight: 800;
            color: var(--primary);
            margin-bottom: 8px;
        }

        .card-header p {
            font-size: 14px;
            color: var(--text-muted);
        }

        /* ── FORMULARIO ── */
        .form-group {
            margin-bottom: 22px;
        }

        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 700;
            color: var(--primary);
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .input-wrap {
            position: relative;
        }

        .input-wrap .icon {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #adb5bd;
            font-size: 16px;
            transition: color 0.3s;
            pointer-events: none;
        }

        .form-group input {
            width: 100%;
            padding: 14px 15px 14px 45px;
            background: #f8f9fa;
            border: 2px solid var(--border);
            border-radius: var(--radius);
            color: var(--text-dark);
            font-size: 15px;
            font-family: inherit;
            transition: all 0.3s;
            outline: none;
        }

        .form-group input::placeholder {
            color: #adb5bd;
        }

        .form-group input:focus {
            border-color: var(--accent);
            background: #ffffff;
            box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.15);
        }

        .form-group input:focus + .icon,
        .input-wrap:focus-within .icon {
            color: var(--accent);
        }

        /* Ajuste de z-index para que el icono se vea sobre el fondo del input */
        .input-wrap input { position: relative; z-index: 1; background: transparent; }
        .input-wrap .icon { z-index: 2; }

        /* ── BOTÓN ── */
        .btn-submit {
            width: 100%;
            padding: 15px;
            margin-top: 10px;
            background: var(--primary);
            border: none;
            border-radius: var(--radius);
            color: #ffffff;
            font-size: 16px;
            font-weight: 700;
            letter-spacing: 1px;
            cursor: pointer;
            transition: background 0.3s, transform 0.2s;
        }

        .btn-submit:hover {
            background: var(--accent);
            transform: translateY(-2px);
        }

        /* ── MENSAJE DE ERROR ── */
        .error-msg {
            display: flex;
            align-items: center;
            gap: 10px;
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
            padding: 12px 15px;
            border-radius: var(--radius);
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 25px;
        }
        .error-msg::before { content: '⚠'; }

        /* ── FOOTER ── */
        .form-footer {
            margin-top: 40px;
            text-align: center;
            font-size: 13px;
            color: var(--text-muted);
        }
        .form-footer strong { color: var(--primary); }

        /* ── RESPONSIVE ── */
        @media (max-width: 860px) {
            .stage {
                grid-template-columns: 1fr;
                grid-template-rows: 250px 1fr;
                overflow-y: auto;
            }
            .hero-img-wrap { padding: 20px; }
            .hero-brand { top: 20px; left: 20px; }
            .hero-brand .title { font-size: 28px; }
            html, body { overflow: auto; }
            .login-panel { padding: 40px 30px; box-shadow: none; }
        }
    </style>
</head>
<body>

<div class="stage">
    
    <div class="hero">
        <div class="hero-brand">
            <div class="label">SISTEMA INTERNO</div>
            <div class="title">RENTA DE <span>AUTOS</span></div>
        </div>
        <div class="hero-img-wrap">
            <img src="img/conces.png" alt="Flota de Vehículos ITCA">
        </div>
    </div>

    <div class="login-panel">
        <div class="card">
            <div class="card-header">
                <h1>Bienvenido</h1>
                <p>Ingrese sus credenciales para continuar</p>
            </div>

            <% if (request.getAttribute("error") != null) { %>
            <div class="error-msg"><%= request.getAttribute("error") %></div>
            <% } %>

            <form action="LoginServlet" method="POST">
                
                <div class="form-group">
                    <label for="txtUsuario">Usuario</label>
                    <div class="input-wrap">
                        <input type="text" id="txtUsuario" name="txtUsuario" placeholder="Usuario" autocomplete="username" required>
                        <span class="icon">👤</span>
                    </div>
                </div>

                <div class="form-group">
                    <label for="txtPassword">Contraseña</label>
                    <div class="input-wrap">
                        <input type="password" id="txtPassword" name="txtPassword" placeholder="******" autocomplete="current-password" required>
                        <span class="icon">🔒</span>
                    </div>
                </div>

                <button type="submit" class="btn-submit">INICIAR SESIÓN</button>
            </form>

            <div class="form-footer">
                Sistema de gestión &nbsp;·&nbsp; <strong>ITCA-FEPADE</strong>
            </div>
            
        </div>
    </div>
</div>

</body>
</html>