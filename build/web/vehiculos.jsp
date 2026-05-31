<%@page import="com.renta.modelos.Vehiculo"%>
<%@page import="java.util.List"%>
<%@page import="com.renta.datos.VehiculoDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Control de Vehículos - Sistema Renta Autos</title>
        <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.24/css/dataTables.bootstrap4.min.css"/>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    </head>
    <body class="bg-light">

        <div class="container-fluid p-3">
            <jsp:include page="menu.jsp" />

            <%
                VehiculoDAO dao = new VehiculoDAO();
                List<Vehiculo> lista = dao.listarVehiculos();
            %>

            <h1 class="text-center my-4">Gestión de Vehículos</h1>

            <button type="button" class="btn btn-primary mb-3" data-toggle="modal" data-target="#modalVehiculo" onclick="limpiarFormulario()">
                + Nuevo Vehículo
            </button>

            <table id="tablaVehiculos" class="table table-hover table-striped table-bordered">
                <thead class="thead-dark">
                    <tr>
                        <th>ID</th><th>Marca</th><th>Modelo</th><th>Año</th><th>Color</th><th>Placa</th><th>Capacidad</th><th>Precio</th><th>Estado</th><th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Vehiculo v : lista) {%>
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
                            <button class="btn btn-sm btn-warning" onclick="editarVehiculo(this)">Editar</button>
                            <button class="btn btn-sm btn-danger" onclick="confirmarEliminar(<%= v.getIdVehiculo()%>)">Eliminar</button>
                        </td>
                    </tr>
                    <% }%>
                </tbody>
            </table>
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
                            <div class="form-group"><label>Año:</label><input type="number" name="txtAnio" id="txtAnio" class="form-control" required min="1900"></div>
                            <div class="form-group"><label>Color:</label><input type="text" name="txtColor" id="txtColor" class="form-control" required></div>
                            <div class="form-group"><label>Placa:</label><input type="text" name="txtPlaca" id="txtPlaca" class="form-control" required></div>
                            <div class="form-group"><label>Capacidad:</label><input type="number" name="txtCapacidad" id="txtCapacidad" class="form-control" min="1" required></div>
                            <div class="form-group"><label>Precio Diario ($):</label><input type="number" step="0.01" name="txtPrecio" id="txtPrecio" class="form-control" min="0.01" required></div>
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
        <script src="https://cdn.datatables.net/1.10.24/js/dataTables.bootstrap4.min.js"></script>

        <script>
                                $(document).ready(function () {
                                    $('#tablaVehiculos').DataTable({"language": {"url": "//cdn.datatables.net/plug-ins/1.10.24/i18n/Spanish.json"}});

                                    const urlParams = new URLSearchParams(window.location.search);
                                    if (urlParams.has('msg'))
                                        Swal.fire('¡Éxito!', urlParams.get('msg'), 'success');
                                    else if (urlParams.has('error'))
                                        Swal.fire('¡Error!', urlParams.get('error'), 'error');
                                });

                                function limpiarFormulario() {
                                    $('#txtId').val('');
                                    $('#modalVehiculo form')[0].reset();
                                }

                                function editarVehiculo(btn) {
                                    var fila = $(btn).closest('tr');
                                    $('#txtId').val(fila.find('td:eq(0)').text());
                                    $('#txtMarca').val(fila.find('td:eq(1)').text());
                                    $('#txtModelo').val(fila.find('td:eq(2)').text());
                                    $('#txtAnio').val(fila.find('td:eq(3)').text());
                                    $('#txtColor').val(fila.find('td:eq(4)').text()); // Nuevo campo
                                    $('#txtPlaca').val(fila.find('td:eq(5)').text());
                                    $('#txtCapacidad').val(parseInt(fila.find('td:eq(6)').text()));
                                    var precio = fila.find('td:eq(7)').text().replace('$', '');
                                    $('#txtPrecio').val(precio);
                                    $('#modalVehiculo').modal('show');
                                }

                                function confirmarEliminar(id) {
                                    Swal.fire({
                                        title: '¿Estás seguro?',
                                        text: "Esta acción desactivará el vehículo.",
                                        icon: 'warning',
                                        showCancelButton: true,
                                        confirmButtonColor: '#d33',
                                        cancelButtonColor: '#3085d6',
                                        confirmButtonText: 'Sí, desactivar'
                                    }).then((result) => {
                                        if (result.isConfirmed)
                                            window.location.href = 'VehiculoServlet?accion=eliminar&id=' + id;
                                    });
                                }
        </script>
    </body>
</html>