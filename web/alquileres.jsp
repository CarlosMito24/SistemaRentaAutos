<%@page import="com.renta.datos.ClienteDAO"%>
<%@page import="com.renta.modelos.Cliente"%>
<%@page import="com.renta.datos.VehiculoDAO"%>
<%@page import="com.renta.modelos.Vehiculo"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Registrar Alquiler</title>

        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
    </head>
    <body class="bg-light">

        <jsp:include page="menu.jsp" />

        <div class="container-fluid p-3">
            <h1 class="text-center my-4">Registrar Nuevo Alquiler</h1>

            <div class="row justify-content-center">
                <div class="col-md-8">
                    <div class="card shadow-sm">
                        <div class="card-body">
                            <form action="AlquilerServlet" method="POST">
                                <div class="row">
                                    <div class="col-md-6 form-group">
                                        <label>Cliente:</label>
                                        <select name="txtIdCliente" class="form-control" required>
                                            <option value="">Seleccione un cliente...</option>
                                            <% for (Cliente c : new ClienteDAO().listarClientes()) {%>
                                            <option value="<%= c.getIdCliente()%>"><%= c.getNombre()%></option>
                                            <% } %>
                                        </select>
                                    </div>

                                    <div class="col-md-6 form-group">
                                        <label>Vehículo:</label>
                                        <select name="txtIdVehiculo" id="selectVehiculo" class="form-control" onchange="calcularTotal()" required>
                                            <%
                                                VehiculoDAO vdao = new VehiculoDAO();
                                                java.util.List<Vehiculo> lista = vdao.listarVehiculosDisponibles();
                                                if (lista.isEmpty()) { %>
                                            <option value="">No hay vehículos disponibles</option>
                                            <% } else { %>
                                            <option value="">Seleccione un vehículo...</option>
                                            <% for (Vehiculo v : lista) {%>
                                            <option value="<%= v.getIdVehiculo()%>" data-precio="<%= v.getPrecioDiario()%>">
                                                <%= v.getMarca() + " " + v.getModelo() + " (" + v.getPlaca() + ") - $" + v.getPrecioDiario() + "/día"%>
                                            </option>
                                            <% } %>
                                            <% }%>
                                        </select>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-4 form-group">
                                        <label>Fecha de Entrega:</label>
                                        <input type="date" name="txtFechaInicio" id="txtFechaInicio" class="form-control" onchange="calcularTotal()" required>
                                    </div>
                                    <div class="col-md-4 form-group">
                                        <label>Fecha de Devolución:</label>
                                        <input type="date" name="txtFechaFin" id="txtFechaFin" class="form-control" onchange="calcularTotal()" required>
                                    </div>
                                    <div class="col-md-4 form-group">
                                        <label>Total Estimado ($):</label>
                                        <input type="number" step="0.01" name="txtTotal" id="txtTotal" class="form-control" readonly required>
                                    </div>
                                </div>

                                <div class="text-right mt-3">
                                    <a href="principal.jsp" class="btn btn-secondary">Cancelar</a>
                                    <button type="submit" class="btn btn-primary">Confirmar Alquiler</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

        <script>
                                            function calcularTotal() {
                                                const select = document.getElementById('selectVehiculo');
                                                const fechaInicio = new Date(document.getElementById('txtFechaInicio').value);
                                                const fechaFin = new Date(document.getElementById('txtFechaFin').value);
                                                const inputTotal = document.getElementById('txtTotal');

                                                const precioDiario = parseFloat(select.options[select.selectedIndex].getAttribute('data-precio') || 0);

                                                if (fechaInicio && fechaFin && fechaFin > fechaInicio && precioDiario > 0) {
                                                    const diffTime = Math.abs(fechaFin - fechaInicio);
                                                    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                                                    inputTotal.value = (diffDays * precioDiario).toFixed(2);
                                                }
                                            }

                                            // Lógica de Alertas
                                            const urlParams = new URLSearchParams(window.location.search);
                                            if (urlParams.has('msg')) {
                                                Swal.fire('¡Éxito!', urlParams.get('msg'), 'success');
                                            } else if (urlParams.has('error')) {
                                                Swal.fire('¡Error!', urlParams.get('error'), 'error');
                                            }
        </script>
    </body>
</html>