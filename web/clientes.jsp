<%@page import="com.renta.datos.ClienteDAO"%>
<%@page import="com.renta.modelos.Cliente"%>
<%@page import="java.util.List"%>
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
        <title>Control de Clientes - Renta de Autos</title>
        <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.24/css/dataTables.bootstrap4.min.css"/>
        <style>
            /* Alineación profesional para los controles de DataTables */
            .dataTables_wrapper .row {
                display: flex;
                align-items: center;
                margin-bottom: 10px;
            }
            .dataTables_filter { text-align: right; }
        </style>
    </head>
    <body class="bg-light">
        <jsp:include page="menu.jsp" />

        <div class="container-fluid p-3">
            <h1 class="text-center my-4">Gestión de Clientes</h1>
            
            <button type="button" class="btn btn-primary mb-3" data-toggle="modal" data-target="#modalCliente" onclick="limpiarFormulario()">
                + Nuevo Cliente
            </button>

            <div class="table-responsive">
                <table id="tablaClientes" class="table table-hover table-striped table-bordered">
                    <thead class="thead-dark">
                        <tr>
                            <th>ID</th><th>Nombre</th><th>DUI</th><th>Edad</th><th>Teléfono</th><th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            ClienteDAO daoCliente = new ClienteDAO();
                            List<Cliente> lista = daoCliente.listarClientes();
                            for (Cliente cli : lista) {
                        %>
                        <tr>
                            <td><%= cli.getIdCliente()%></td>
                            <td><%= cli.getNombre()%></td>
                            <td><%= cli.getDui()%></td>
                            <td><%= cli.getEdad()%></td>
                            <td><%= cli.getTelefono()%></td>
                            <td>
                                <button class="btn btn-sm btn-warning" onclick="editarCliente(this)">Editar</button>
                                <button class="btn btn-sm btn-danger" onclick="confirmarEliminar(<%= cli.getIdCliente()%>)">Eliminar</button>
                            </td>
                        </tr>
                        <% }%>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="modal fade" id="modalCliente" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <form action="ClienteServlet" method="POST">
                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title">Formulario de Cliente</h5>
                        </div>
                        <div class="modal-body">
                            <input type="hidden" name="txtId" id="txtId">
                            <div class="form-group">
                                <label>Nombre:</label>
                                <input type="text" name="txtNombre" id="txtNombre" class="form-control" placeholder="Ej. Juan Pérez" required>
                            </div>
                            <div class="form-group">
                                <label>DUI:</label>
                                <input type="text" name="txtDui" id="txtDui" class="form-control" placeholder="00000000-0" pattern="\d{8}-\d{1}" title="Formato: 00000000-0" required>
                            </div>
                            <div class="form-group">
                                <label>Edad:</label>
                                <input type="number" name="txtEdad" id="txtEdad" class="form-control" placeholder="Ingrese edad (18-100)" min="18" max="100" required>
                            </div>
                            <div class="form-group">
                                <label>Teléfono:</label>
                                <input type="text" name="txtTelefono" id="txtTelefono" class="form-control" placeholder="0000-0000" pattern="\d{4}-\d{4}" title="Formato: 0000-0000" required>
                            </div>
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
                // Inicializar DataTables con la configuración de columnas (l=length, f=filter)
                $('#tablaClientes').DataTable({
                    "language": {
                        "url": "//cdn.datatables.net/plug-ins/1.10.24/i18n/Spanish.json",
                        "search": "Buscar:"
                    },
                    "dom": '<"row"<"col-md-6"l><"col-md-6"f>>rtip'
                });

                // Lógica de mensajes SweetAlert
                const urlParams = new URLSearchParams(window.location.search);
                if (urlParams.has('msg') || urlParams.has('error')) {
                    let tipo = urlParams.has('msg') ? 'success' : 'error';
                    let titulo = urlParams.has('msg') ? '¡Éxito!' : '¡Error!';
                    let mensaje = decodeURIComponent((urlParams.get('msg') || urlParams.get('error')).replace(/\+/g, ' '));
                    Swal.fire(titulo, mensaje, tipo).then(() => {
                        window.history.replaceState({}, document.title, window.location.pathname);
                    });
                }
            });

            function limpiarFormulario() {
                $('#txtId').val('');
                $('#modalCliente form')[0].reset();
            }

            function editarCliente(btn) {
                var fila = $(btn).closest('tr');
                $('#txtId').val(fila.find('td:eq(0)').text());
                $('#txtNombre').val(fila.find('td:eq(1)').text());
                $('#txtDui').val(fila.find('td:eq(2)').text());
                $('#txtEdad').val(fila.find('td:eq(3)').text());
                $('#txtTelefono').val(fila.find('td:eq(4)').text());
                $('#modalCliente').modal('show');
            }

            function confirmarEliminar(id) {
                Swal.fire({
                    title: '¿Estás seguro?',
                    text: "Esta acción desactivará al cliente.",
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#d33',
                    confirmButtonText: 'Sí, eliminar'
                }).then((result) => {
                    if (result.isConfirmed) {
                        window.location.href = 'ClienteServlet?accion=eliminar&id=' + id;
                    }
                });
            }

            // Formateadores de entrada
            document.getElementById('txtDui').addEventListener('input', function (e) {
                let value = e.target.value.replace(/\D/g, '');
                if (value.length > 8) value = value.substring(0, 8) + '-' + value.substring(8, 9);
                e.target.value = value;
            });

            document.getElementById('txtTelefono').addEventListener('input', function (e) {
                let value = e.target.value.replace(/\D/g, '');
                if (value.length > 4) value = value.substring(0, 4) + '-' + value.substring(4, 8);
                e.target.value = value;
            });
        </script>
    </body>
</html>