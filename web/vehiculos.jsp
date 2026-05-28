<%@page import="com.renta.modelos.Vehiculo"%>
<%@page import="java.util.List"%>
<%@page import="com.renta.datos.VehiculoDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Control de Vehículos - Renta Autos</title>
        <style>
            /* Contenedor flexible principal */
            .container { display: flex; gap: 30px; margin-top: 20px; }
            .form-box { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); width: 35%; height: max-content; }
            .table-box { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); width: 65%; }
            
            .form-group { margin-bottom: 12px; }
            .form-group label { display: block; margin-bottom: 5px; font-weight: bold; color: #333; }
            .form-group input, .form-group select { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; font-size: 16px; } /* Ajuste de 16px para evitar zoom automático en iOS/Android */
            
            .btn-save { background-color: #2ecc71; color: white; border: none; padding: 12px; width: 100%; border-radius: 4px; font-size: 16px; cursor: pointer; font-weight: bold; }
            .btn-save:hover { background-color: #27ae60; }
            
            /* Contenedor para hacer la tabla deslizable en celulares */
            .table-responsive { width: 100%; overflow-x: auto; -webkit-overflow-scrolling: touch; }
            
            table { width: 100%; border-collapse: collapse; margin-top: 15px; min-width: 500px; } /* min-width evita que las columnas se aplasten en pantallas diminutas */
            table, th, td { border: 1px solid #ddd; }
            th, td { padding: 10px; text-align: left; }
            th { background-color: #34495e; color: white; }
            
            .badge-success { background-color: #2ecc71; color: white; padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; }
            .badge-danger { background-color: #e74c3c; color: white; padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; }
            .alert-inventario { background-color: #fff3cd; color: #856404; padding: 10px; border-radius: 5px; margin-bottom: 15px; border: 1px solid #ffeeba; }

            /* === RESPONSIVE MODAL CON @MEDIA === */
            @media (max-width: 991px) {
                .container {
                    flex-direction: column; /* Cambia de lado-a-lado a una sola columna vertical */
                    gap: 20px;
                }
                .form-box, .table-box {
                    width: 100%; /* Ocupan todo el ancho de la pantalla del móvil */
                    box-sizing: border-box;
                }
            }
        </style>
    </head>
    <body style="font-family: Arial, sans-serif; padding: 15px; background-color: #f4f6f9; margin: 0;">
        
        <jsp:include page="menu.jsp" />
        
        <h2>🚗 Gestión del Inventario de Vehículos</h2>
        <hr>
        
        <div class="container">
            <div class="form-box">
                <h3>Registrar Nuevo Auto</h3>
                <form action="VehiculoServlet" method="POST">
                    <div class="form-group">
                        <label>Marca:</label>
                        <input type="text" name="txtMarca" required placeholder="Ej: Toyota">
                    </div>
                    <div class="form-group">
                        <label>Modelo:</label>
                        <input type="text" name="txtModelo" required placeholder="Ej: Corolla">
                    </div>
                    <div class="form-group">
                        <label>Placa:</label>
                        <input type="text" name="txtPlaca" required placeholder="Ej: P123-456">
                    </div>
                    <div class="form-group">
                        <label>Capacidad:</label>
                        <input type="number" name="txtCapacidad" min="1" required placeholder="Ej: 5">
                    </div>
                    <div class="form-group">
                        <label>Precio Diario ($):</label>
                        <input type="number" step="0.01" name="txtPrecio" min="0.01" required placeholder="Ej: 35.00">
                    </div>
                    <button type="submit" class="btn-save">Guardar Vehículo</button>
                </form>
            </div>
            
            <div class="table-box">
                <h3>Autos en Existencia</h3>
                
                <%
                    VehiculoDAO dao = new VehiculoDAO();
                    List<Vehiculo> lista = dao.listarVehiculos();
                    
                    int disponibles = 0;
                    for(Vehiculo v : lista) {
                        if(v.isDisponible()) disponibles++;
                    }
                    
                    if (disponibles < 2) {
                %>
                    <div class="alert-inventario">
                        ⚠️ <strong>¡Alerta Gerencial!</strong> La disponibilidad de vehículos es críticamente baja (<%= disponibles %> autos disponibles).
                    </div>
                <% } %>
                
                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Vehículo</th>
                                <th>Placa</th>
                                <th>Capacidad</th>
                                <th>Precio/Día</th>
                                <th>Estado</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for(Vehiculo v : lista) { %>
                            <tr>
                                <td><%= v.getIdVehiculo() %></td>
                                <td><strong><%= v.getMarca() %></strong> <%= v.getModelo() %></td>
                                <td><%= v.getPlaca() %></td>
                                <td><%= v.getCapacidad() %> psj.</td>
                                <td>$<%= String.format("%.2f", v.getPrecioDiario()) %></td>
                                <td>
                                    <% if(v.isDisponible()) { %>
                                        <span class="badge-success">Disponible</span>
                                    <% } else { %>
                                        <span class="badge-danger">Alquilado</span>
                                    <% } %>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </body>
</html>