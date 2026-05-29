<%@page import="com.renta.modelos.Vehiculo"%>
<%@page import="java.util.List"%>
<%@page import="com.renta.datos.VehiculoDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Control de Vehículos - Sistema Renta Autos</title>
        <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
        <style>
            body {
                background-color: #f8f9fa;
                color: #212529;
            }
            .card {
                border: none;
            }
            .card-header {
                font-size: 1.1rem;
            }
            .table th {
                background-color: #343a40;
                color: white;
            }
            .table-responsive {
                width: 100%;
                overflow-x: auto;
                -webkit-overflow-scrolling: touch;
            }
        </style>
    </head>
    <body class="bg-light">
        <div class="container-fluid p-3">
            <jsp:include page="menu.jsp" />

            <%
                VehiculoDAO dao = new VehiculoDAO();

                // Lógica de Búsqueda (Req 3)
                String filtro = request.getParameter("txtBuscar");
                List<Vehiculo> lista;
                if (filtro != null && !filtro.trim().isEmpty()) {
                    lista = dao.buscarVehiculos(filtro);
                } else {
                    lista = dao.listarVehiculos();
                }

                // Carga de objeto para edición
                Vehiculo vEdit = (request.getAttribute("vehiculoEditar") != null) ? (Vehiculo) request.getAttribute("vehiculoEditar") : null;

                // Mensajes de sistema
                String msg = request.getParameter("msg");
                String error = request.getParameter("error");

                // Cálculo de disponibles para alerta (Req 4)
                int disponibles = 0;
                if (lista != null) {
                    for (Vehiculo v : lista) {
                        if (v.isDisponible()) {
                            disponibles++;
                        }
                    }
                }
            %>

            <h1 class="text-center my-4 text-dark font-weight-bold">Control de Vehículos</h1>

            <% if (msg != null) {%> <div class="alert alert-success text-center font-weight-bold"><%= msg%></div> <% } %>
            <% if (error != null) {%> <div class="alert alert-danger text-center font-weight-bold"><%= error%></div> <% } %>

            <% if (disponibles < 2) {%>
            <div class="alert alert-warning text-center font-weight-bold border border-warning shadow-sm mb-4">
                ⚠️ <strong>¡Alerta Gerencial!</strong> Disponibilidad crítica: <%= disponibles%> autos disponibles.
            </div>
            <% }%>

            <form action="vehiculos.jsp" method="GET" class="mb-4">
                <div class="input-group">
                    <input type="text" name="txtBuscar" class="form-control" placeholder="Buscar por marca, modelo o placa..." 
                           value="<%= (filtro != null) ? filtro : ""%>">
                    <div class="input-group-append">
                        <button class="btn btn-primary" type="submit">Buscar</button>
                        <a href="vehiculos.jsp" class="btn btn-outline-secondary">Limpiar</a>
                    </div>
                </div>
            </form>

            <div class="row">
                <div class="col-lg-4 mb-4">
                    <div class="card shadow-sm border-0">
                        <div class="card-header bg-primary text-white text-center font-weight-bold">
                            <%= (vEdit != null) ? "Modificar Características" : "Registrar Nuevo Vehículo"%>
                        </div>
                        <div class="card-body bg-white">
                            <form action="VehiculoServlet" method="POST">
                                <input type="hidden" name="txtId" value="<%= (vEdit != null) ? vEdit.getIdVehiculo() : ""%>">
                                <div class="form-group"><label>Marca:</label><input type="text" name="txtMarca" class="form-control" required value="<%= (vEdit != null) ? vEdit.getMarca() : ""%>"></div>
                                <div class="form-group"><label>Modelo:</label><input type="text" name="txtModelo" class="form-control" required value="<%= (vEdit != null) ? vEdit.getModelo() : ""%>"></div>
                                <div class="form-group"><label>Placa:</label><input type="text" name="txtPlaca" class="form-control" required value="<%= (vEdit != null) ? vEdit.getPlaca() : ""%>"></div>
                                <div class="form-group"><label>Capacidad:</label><input type="number" name="txtCapacidad" class="form-control" min="1" required value="<%= (vEdit != null) ? vEdit.getCapacidad() : ""%>"></div>
                                <div class="form-group"><label>Precio Diario ($):</label><input type="number" step="0.01" name="txtPrecio" class="form-control" min="0.01" required value="<%= (vEdit != null) ? vEdit.getPrecioDiario() : ""%>"></div>
                                <button type="submit" class="btn btn-primary btn-block"><%= (vEdit != null) ? "Actualizar" : "Guardar"%></button>
                                <% if (vEdit != null) { %><a href="vehiculos.jsp" class="btn btn-block btn-outline-secondary mt-2">Cancelar</a><% } %>
                            </form>
                        </div>
                    </div>
                </div>

                <div class="col-lg-8">
                    <div class="card shadow-sm border-0">
                        <div class="table-responsive bg-white">
                            <table class="table table-hover text-center">
                                <thead><tr><th>ID</th><th>Vehículo</th><th>Placa</th><th>Capacidad</th><th>Precio</th><th>Estado</th><th>Acciones</th></tr></thead>
                                <tbody>
                                    <% if (lista != null && !lista.isEmpty()) {
                                            for (Vehiculo v : lista) {%>
                                    <tr>
                                        <td><%= v.getIdVehiculo()%></td>
                                        <td class="text-left"><strong><%= v.getMarca()%></strong> <%= v.getModelo()%></td>
                                        <td><span class="badge badge-secondary"><%= v.getPlaca()%></span></td>
                                        <td><%= v.getCapacidad()%> psj.</td>
                                        <td class="text-success font-weight-bold">$<%= String.format("%.2f", v.getPrecioDiario())%></td>
                                        <td><%= v.isDisponible() ? "<span class='badge badge-success'>Disponible</span>" : "<span class='badge badge-danger'>Alquilado</span>"%></td>
                                        <td><a href="VehiculoServlet?accion=editar&id=<%= v.getIdVehiculo()%>" class="btn btn-sm btn-warning">Editar</a></td>
                                    </tr>
                                    <% }
                                    } else { %>
                                    <tr><td colspan="7">No se encontraron vehículos.</td></tr>
                                    <% }%>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>