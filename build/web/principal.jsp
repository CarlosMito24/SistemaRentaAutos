<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Panel Principal - Renta Autos</title>
        <style>
            /* Reset y estilos base del cuerpo */
            body { 
                font-family: Arial, sans-serif; 
                padding: 20px; 
                background-color: #f4f6f9; 
                margin: 0;
                box-sizing: border-box;
                min-height: 100vh;
            }
            
            /* Tarjeta contenedora principal adaptativa */
            .welcome-box { 
                background: white; 
                padding: 30px; 
                border-radius: 8px; 
                box-shadow: 0 2px 4px rgba(0,0,0,0.05);
                margin-top: 10px;
                box-sizing: border-box;
                transition: all 0.3s ease;
            }
            
            h2 { 
                color: #2c3e50; 
                margin-top: 0; 
                font-size: 28px;
            }
            
            hr { 
                border: 0; 
                border-top: 1px solid #eee; 
                margin: 20px 0; 
            }
            
            p {
                color: #555;
                font-size: 16px;
                line-height: 1.6;
            }

            /* =========================================================
               === MEDIA QUERIES PARA ADAPTACIÓN MÓVIL Y ORIENTACIÓN ===
               ========================================================= */

            /* 1. Ajuste para pantallas medianas, móviles en vertical o tablets */
            @media (max-width: 991px) {
                body {
                    padding: 15px; /* Reducimos el margen general del navegador */
                }
                .welcome-box {
                    padding: 20px; /* Caja más compacta para aprovechar espacio */
                }
                h2 {
                    font-size: 22px; /* Texto escalado para que no se desborde */
                }
            }

            /* 2. Optimización estricta para teléfonos muy pequeños */
            @media (max-width: 480px) {
                body {
                    padding: 10px;
                }
                .welcome-box {
                    padding: 15px;
                }
                h2 {
                    font-size: 18px;
                }
                p {
                    font-size: 14px;
                }
            }

            /* 3. Optimización para móviles en posición Horizontal (Landscape) */
            @media (max-height: 500px) and (orientation: landscape) {
                body {
                    padding: 10px;
                }
                .welcome-box {
                    padding: 15px 20px;
                }
                h2 {
                    font-size: 20px;
                    margin-bottom: 5px;
                }
                hr {
                    margin: 10px 0;
                }
            }
        </style>
    </head>
    <body>
        
        <jsp:include page="menu.jsp" />
        
        <div class="welcome-box">
            <h2>Sistema de Información Gerencial de Alquiler de Vehículos</h2>
            <hr>
            <p>Selecciona una opción del menú superior para empezar a gestionar las operaciones del negocio.</p>
        </div>
        
    </body>
</html>