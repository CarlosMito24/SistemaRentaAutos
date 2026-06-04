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
    <title>Gestión de Vehículos</title>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.24/css/dataTables.bootstrap4.min.css"/>
</head>
<body class="bg-light">
    <jsp:include page="menu.jsp" />
    <div class="container-fluid p-3">
        <% VehiculoDAO dao = new VehiculoDAO(); List<Vehiculo> lista = dao.listarVehiculos(); %>
        <h1 class="text-center my-4">Gestión de Vehículos</h1>
        <button type="button" class="btn btn-primary mb-3" data-toggle="modal" data-target="#modalVehiculo" onclick="limpiarFormulario()">+ Nuevo Vehículo</button>
        <table id="tablaVehiculos" class="table table-hover table-striped table-bordered">
            <thead class="thead-dark">
                <tr><th>ID</th><th>Marca</th><th>Modelo</th><th>Año</th><th>Color</th><th>Placa</th><th>Capacidad</th><th>Precio</th><th>Estado</th><th>Acciones</th></tr>
            </thead>
            <tbody>
                <% for (Vehiculo v : lista) {%>
                <tr>
                    <td><%= v.getIdVehiculo()%></td><td><%= v.getMarca()%></td><td><%= v.getModelo()%></td>
                    <td><%= v.getAnio()%></td><td><%= v.getColor()%></td><td><%= v.getPlaca()%></td>
                    <td><%= v.getCapacidad()%></td><td>$<%= String.format("%.2f", v.getPrecioDiario())%></td>
                    <td><%= v.isDisponible() ? "<span class='badge badge-success'>Disponible</span>" : "<span class='badge badge-danger'>Alquilado</span>"%></td>
                    <td><button class="btn btn-sm btn-warning">Editar</button> <button class="btn btn-sm btn-danger" onclick="confirmarEliminar(<%= v.getIdVehiculo()%>)">Eliminar</button></td>
                </tr>
                <% }%>
            </tbody>
        </table>
    </div>

    <div class="modal fade" id="modalVehiculo" tabindex="-1" role="dialog"><div class="modal-dialog"><div class="modal-content">
        <form action="VehiculoServlet" method="POST">
            <div class="modal-header bg-primary text-white"><h5 class="modal-title">Formulario de Vehículo</h5></div>
            <div class="modal-body">
                <input type="hidden" name="txtId" id="txtId">
                <div class="form-group"><label>Marca:</label><input type="text" name="txtMarca" id="txtMarca" class="form-control" required></div>
                <div class="form-group"><label>Modelo:</label><input type="text" name="txtModelo" id="txtModelo" class="form-control" required></div>
                <div class="form-group"><label>Año:</label><input type="number" name="txtAnio" id="txtAnio" class="form-control" required></div>
                <div class="form-group"><label>Color:</label><input type="text" name="txtColor" id="txtColor" class="form-control" required></div>
                <div class="form-group"><label>Placa:</label><input type="text" name="txtPlaca" id="txtPlaca" class="form-control" required></div>
                <div class="form-group"><label>Capacidad:</label><input type="number" name="txtCapacidad" id="txtCapacidad" class="form-control" required></div>
                <div class="form-group"><label>Precio Diario ($):</label><input type="text" name="txtPrecio" id="txtPrecio" class="form-control" required></div>
            </div>
            <div class="modal-footer"><button type="button" class="btn btn-secondary" data-dismiss="modal">Cerrar</button><button type="submit" class="btn btn-success">Guardar</button></div>
        </form>
    </div></div></div>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.24/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.24/js/dataTables.bootstrap4.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <script>
        $(document).ready(function () {
            $('#tablaVehiculos').DataTable({"language": {"processing": "Procesando...", "lengthMenu": "Mostrar _MENU_ registros", "zeroRecords": "No se encontraron resultados", "emptyTable": "Ningún dato disponible", "info": "Mostrando _START_ al _END_ de _TOTAL_ registros", "search": "Buscar:", "paginate": {"first": "Primero", "last": "Último", "next": "Siguiente", "previous": "Anterior"}}});

            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.has('msg')) Swal.fire('¡Éxito!', urlParams.get('msg'), 'success').then(() => window.history.replaceState({}, document.title, window.location.pathname));
            else if (urlParams.has('error')) Swal.fire('¡Error!', urlParams.get('error'), 'error').then(() => window.history.replaceState({}, document.title, window.location.pathname));
        });

        function limpiarFormulario() { $('#txtId').val(''); $('#modalVehiculo form')[0].reset(); }

        $(document).on('click', '.btn-warning', function() {
            var f = $(this).closest('tr');
            $('#txtId').val(f.find('td:eq(0)').text());
            $('#txtMarca').val(f.find('td:eq(1)').text());
            $('#txtModelo').val(f.find('td:eq(2)').text());
            $('#txtAnio').val(f.find('td:eq(3)').text());
            $('#txtColor').val(f.find('td:eq(4)').text());
            $('#txtPlaca').val(f.find('td:eq(5)').text());
            $('#txtCapacidad').val(f.find('td:eq(6)').text());
            
            // Capturamos el precio y limpiamos el símbolo '$'
            var precio = f.find('td:eq(7)').text().replace('$', '').trim();
            $('#txtPrecio').val(precio);
            
            $('#modalVehiculo').modal('show');
        });

        function confirmarEliminar(id) {
            Swal.fire({title: '¿Estás seguro?', text: "Esta acción desactivará el vehículo.", icon: 'warning', showCancelButton: true, confirmButtonColor: '#d33', confirmButtonText: 'Sí, desactivar'}).then((result) => { if (result.isConfirmed) window.location.href = 'VehiculoServlet?accion=eliminar&id=' + id; });
        }
    </script>
</body>
</html>