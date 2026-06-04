<%@page import="com.renta.modelos.Vehiculo"%>
<%@page import="java.util.List"%>
<%@page import="com.renta.datos.VehiculoDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (session == null || session.getAttribute("empleado") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Control de Vehículos - Sistema Renta Autos</title>
        <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.24/css/dataTables.bootstrap4.min.css"/>
        <style>
            .dataTables_wrapper .row { display: flex; align-items: center; margin-bottom: 10px; }
            .dataTables_filter { text-align: right; }
        </style>
    </head>
    <body class="bg-light">
        <jsp:include page="menu.jsp" />
        <div class="container-fluid p-3">
            <h1 class="text-center my-4">Gestión de Vehículos</h1>

            <button type="button" class="btn btn-primary mb-3" data-toggle="modal" data-target="#modalVehiculo" onclick="limpiarFormulario()">
                + Nuevo Vehículo
            </button>

            <div class="table-responsive">
                <table id="tablaVehiculos" class="table table-hover table-striped table-bordered">
                    <thead class="thead-dark">
                        <tr>
                            <th>ID</th><th>Marca</th><th>Modelo</th><th>Año</th><th>Color</th><th>Placa</th><th>Capacidad</th><th>Precio</th><th>Estado</th><th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            VehiculoDAO dao = new VehiculoDAO();
                            List<Vehiculo> lista = dao.listarVehiculos();
                            for (Vehiculo v : lista) {
                        %>
                        <tr>
                            <td><%= v.getIdVehiculo()%></td>
                            <td><%= v.getMarca()%></td>
                            <td><%= v.getModelo()%></td>
                            <td><%= v.getAnio()%></td>
                            <td><%= v.getColor()%></td>
                            <td><%= v.getPlaca()%></td>
                            <td><%= v.getCapacidad()%> psj.</td>
                            <td>$<%= String.format("%.2f", v.getPrecioDiario())%></td>
                            <td><%= v.isDisponible() ? "<span class='badge badge-success'>Disponible</span>" : "<span class='badge badge-danger'>Alquilado</span>"%></td>
                            <td>
                                <button class="btn btn-sm btn-warning btn-editar">Editar</button>
                                <button class="btn btn-sm btn-danger" onclick="confirmarEliminar(<%= v.getIdVehiculo()%>)">Eliminar</button>
                            </td>
                        </tr>
                        <% }%>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="modal fade" id="modalVehiculo" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <form action="VehiculoServlet" method="POST">
                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title">Formulario de Vehículo</h5>
                        </div>
                        <div class="modal-body">
                            <input type="hidden" name="txtId" id="txtId">
                            <div class="form-group"><label>Marca:</label><input type="text" name="txtMarca" id="txtMarca" class="form-control" required></div>
                            <div class="form-group"><label>Modelo:</label><input type="text" name="txtModelo" id="txtModelo" class="form-control" required></div>
                            <div class="form-group"><label>Año:</label><input type="number" name="txtAnio" id="txtAnio" class="form-control" required min="2000"></div>
                            <div class="form-group"><label>Color:</label><input type="text" name="txtColor" id="txtColor" class="form-control" required></div>
                            
                            <div class="form-group">
                                <label>Placa (Formato PXXX-XXX):</label>
                                <input type="text" name="txtPlaca" id="txtPlaca" class="form-control" 
                                       placeholder="P123-456" maxlength="8" 
                                       pattern="P[0-9]{3}-[0-9]{3}" 
                                       title="El formato debe ser P seguido de 3 números, un guion y 3 números (ej. P123-456)" 
                                       required>
                            </div>
                            
                            <div class="form-group"><label>Capacidad:</label><input type="number" name="txtCapacidad" id="txtCapacidad" class="form-control" min="1" required></div>
                            <div class="form-group"><label>Precio Diario ($):</label><input type="text" name="txtPrecio" id="txtPrecio" class="form-control" required></div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                            <button type="submit" class="btn btn-success">Guardar Cambios</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.datatables.net/1.10.24/js/jquery.dataTables.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

        <script>
            $(document).ready(function () {
                $('#tablaVehiculos').DataTable({
                    language: { "sSearch": "Buscar:", "sInfo": "Mostrando _START_ al _END_ de _TOTAL_ registros", "oPaginate": {"sNext": "Siguiente", "sPrevious": "Anterior"} }
                });

                // Validaciones en tiempo real
                $('#txtPrecio').on('input', function () { this.value = this.value.replace(/[^0-9.]/g, ''); });
                
                // Asegurar que la placa mantenga el formato en mayúsculas
                $('#txtPlaca').on('input', function () {
                    this.value = this.value.toUpperCase();
                });

                // Lógica de mensajes
                const urlParams = new URLSearchParams(window.location.search);
                if (urlParams.has('msg') || urlParams.has('error')) {
                    Swal.fire({
                        title: urlParams.has('msg') ? '¡Éxito!' : '¡Error!',
                        text: urlParams.get('msg') || urlParams.get('error'),
                        icon: urlParams.has('msg') ? 'success' : 'error'
                    }).then(() => window.history.replaceState({}, document.title, window.location.pathname));
                }

                $('#tablaVehiculos').on('click', '.btn-editar', function () {
                    var fila = $(this).closest('tr');
                    $('#txtId').val(fila.find('td:eq(0)').text().trim());
                    $('#txtMarca').val(fila.find('td:eq(1)').text().trim());
                    $('#txtModelo').val(fila.find('td:eq(2)').text().trim());
                    $('#txtAnio').val(fila.find('td:eq(3)').text().trim());
                    $('#txtColor').val(fila.find('td:eq(4)').text().trim());
                    $('#txtPlaca').val(fila.find('td:eq(5)').text().trim());
                    $('#txtCapacidad').val(parseInt(fila.find('td:eq(6)').text()));
                    $('#txtPrecio').val(fila.find('td:eq(7)').text().replace('$', '').trim());
                    $('#modalVehiculo').modal('show');
                });
            });

            function limpiarFormulario() { $('#txtId').val(''); $('#modalVehiculo form')[0].reset(); }

            function confirmarEliminar(id) {
                Swal.fire({ title: '¿Estás seguro?', text: "Esta acción desactivará el vehículo.", icon: 'warning', showCancelButton: true, confirmButtonColor: '#d33', confirmButtonText: 'Sí, desactivar' }).then((result) => {
                    if (result.isConfirmed) window.location.href = 'VehiculoServlet?accion=eliminar&id=' + id;
                });
            }
        </script>
    </body>
</html>