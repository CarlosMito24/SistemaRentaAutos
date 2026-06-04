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
    <title>Control de Clientes - Renta de Autos ITCA</title>
    <link rel="icon" href="img/login.jpg" type="image/jpeg">
    
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.24/css/dataTables.bootstrap4.min.css"/>
    
    <style>
        :root {
            --primary: #1e293b;
            --accent: #3b82f6;
            --bg-light: #f4f7f6;
            --text-dark: #2c3e50;
            --text-muted: #6c757d;
            --border: #e2e8f0;
            --input-bg: #f8f9fa;
            --radius: 12px;
        }

        body { 
            background-color: var(--bg-light);
            color: var(--text-dark);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0; 
            min-height: 100vh; 
        }

        /* ── ESTRUCTURA PRINCIPAL ── */
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 2px solid #e9ecef;
        }

        .page-title {
            font-size: 32px;
            font-weight: 800;
            color: var(--primary);
            margin: 0;
            letter-spacing: 0.5px;
        }
        .page-title span { color: var(--accent); }

        .panel-card {
            background: #ffffff;
            border: none;
            border-radius: var(--radius);
            box-shadow: 0 4px 6px rgba(0,0,0,0.05);
            padding: 30px; 
            margin-bottom: 40px;
        }

        /* ── BOTONES ── */
        .btn-custom-accent {
            background-color: var(--accent);
            border: none;
            color: #ffffff;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            padding: 10px 24px;
            border-radius: 6px;
            transition: all 0.3s;
            box-shadow: 0 4px 6px rgba(59, 130, 246, 0.2);
        }
        .btn-custom-accent:hover {
            background-color: #2563eb;
            color: #ffffff;
            transform: translateY(-2px);
            box-shadow: 0 6px 12px rgba(59, 130, 246, 0.3);
        }

        .btn-outline-primary-custom {
            border: 1px solid var(--accent);
            color: var(--accent);
            background: transparent;
            font-weight: 600;
            transition: all 0.3s;
        }
        .btn-outline-primary-custom:hover {
            background: var(--accent);
            color: #ffffff;
        }

        .btn-outline-danger-custom {
            border: 1px solid #dc2626;
            color: #dc2626;
            background: transparent;
            font-weight: 600;
            transition: all 0.3s;
        }
        .btn-outline-danger-custom:hover {
            background: #dc2626;
            color: white;
        }

        /* ── TABLAS Y DATATABLES (LIGHT MODE) ── */
        .table { margin-top: 15px !important; }
        .table thead th { 
            background: var(--primary) !important;
            color: #ffffff !important; 
            font-size: 13px; 
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border: none !important;
        }
        .table td { 
            font-size: 14px; 
            vertical-align: middle; 
            color: var(--text-dark);
            font-weight: 500;
        }
        .table-hover tbody tr:hover { background-color: #f1f5f9 !important; }
        
        /* Controles de DataTables */
        .dataTables_wrapper .dataTables_filter input, .dataTables_wrapper .dataTables_length select {
            background-color: #ffffff;
            border: 1px solid #ced4da;
            color: var(--text-dark);
            border-radius: 6px;
            padding: 4px 8px;
        }
        .dataTables_wrapper .dataTables_filter input:focus, .dataTables_wrapper .dataTables_length select:focus {
            outline: none;
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.15);
        }
        .dataTables_wrapper .row { display: flex; align-items: center; margin-bottom: 15px; }

        /* ── MODAL ── */
        .modal-content {
            background-color: #ffffff;
            border: none;
            border-radius: var(--radius);
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }
        .modal-header {
            background-color: var(--primary);
            color: #ffffff;
            border-bottom: none;
            border-radius: calc(var(--radius) - 1px) calc(var(--radius) - 1px) 0 0;
        }
        .modal-title {
            font-size: 20px;
            font-weight: 700;
            margin: 0;
            letter-spacing: 0.5px;
        }
        .close { color: #ffffff; opacity: 0.8; text-shadow: none; }
        .close:hover { color: #ffffff; opacity: 1; }
        
        .modal-body { padding: 30px; }
        .modal-footer { border-top: 1px solid #e9ecef; }

        /* Inputs del Modal */
        .form-group label {
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            color: var(--primary);
            margin-bottom: 8px;
        }
        .form-control {
            background: var(--input-bg);
            border: 1px solid #ced4da;
            border-radius: 8px;
            color: var(--text-dark);
            padding: 12px 15px;
            font-size: 14px;
        }
        .form-control:focus {
            background: #ffffff;
            border-color: var(--accent);
            color: var(--text-dark);
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.15);
        }
        .form-control::placeholder { color: #adb5bd; }
    </style>
</head>
<body>
    <jsp:include page="menu.jsp" />

    <div class="container-fluid px-4 py-4">
        
        <div class="page-header">
            <h1 class="page-title">Directorio de <span>Clientes</span></h1>
            <button type="button" class="btn btn-custom-accent" data-toggle="modal" data-target="#modalCliente" onclick="limpiarFormulario()">
                + Nuevo Cliente
            </button>
        </div>

        <div class="panel-card">
            <div class="table-responsive">
                <table id="tablaClientes" class="table table-hover table-bordered" style="width:100%">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Nombre Completo</th>
                            <th>DUI</th>
                            <th>Edad</th>
                            <th>Teléfono</th>
                            <th class="text-center">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            ClienteDAO daoCliente = new ClienteDAO();
                            List<Cliente> lista = daoCliente.listarClientes();
                            for (Cliente cli : lista) {
                        %>
                        <tr>
                            <td class="font-weight-bold text-primary">#<%= cli.getIdCliente()%></td>
                            <td><%= cli.getNombre()%></td>
                            <td style="font-family:monospace; color:var(--text-muted);"><%= cli.getDui()%></td>
                            <td><%= cli.getEdad()%> años</td>
                            <td style="font-family:monospace; color:var(--text-muted);"><%= cli.getTelefono()%></td>
                            <td class="text-center">
                                <button class="btn btn-sm btn-outline-primary-custom btn-editar px-3 mr-2">✏️ EDITAR</button>
                                <button class="btn btn-sm btn-outline-danger-custom px-3" onclick="confirmarEliminar(<%= cli.getIdCliente()%>)">🗑️ BAJA</button>
                            </td>
                        </tr>
                        <% }%>
                    </tbody>
                </table>
            </div>
        </div>

    </div>

    <div class="modal fade" id="modalCliente" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content">
                <form action="ClienteServlet" method="POST">
                    <div class="modal-header">
                        <h5 class="modal-title">Registro de Cliente</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="txtId" id="txtId">
                        
                        <div class="form-group">
                            <label>Nombre Completo:</label>
                            <input type="text" name="txtNombre" id="txtNombre" class="form-control" placeholder="Ej. Juan Pérez" minlength="3" required>
                        </div>
                        
                        <div class="form-group">
                            <label>DUI (Documento de Identidad):</label>
                            <input type="text" name="txtDui" id="txtDui" class="form-control" placeholder="00000000-0" pattern="\d{8}-\d{1}" title="Formato: 00000000-0" required>
                        </div>
                        
                        <div class="row">
                            <div class="form-group col-md-6">
                                <label>Edad:</label>
                                <input type="number" name="txtEdad" id="txtEdad" class="form-control" placeholder="18-100" min="18" max="100" required>
                            </div>
                            
                            <div class="form-group col-md-6">
                                <label>Teléfono:</label>
                                <input type="text" name="txtTelefono" id="txtTelefono" class="form-control" placeholder="0000-0000" pattern="\d{4}-\d{4}" title="Formato: 0000-0000" required>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer border-0 pb-4 pr-4 bg-light">
                        <button type="button" class="btn btn-secondary" style="font-weight: 600;" data-dismiss="modal">CANCELAR</button>
                        <button type="submit" class="btn btn-custom-accent">GUARDAR CAMBIOS</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.24/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.24/js/dataTables.bootstrap4.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <script>
        $(document).ready(function () {
            // Configuración local de DataTables
            $('#tablaClientes').DataTable({
                language: {
                    "sProcessing": "Procesando...",
                    "sSearch": "Buscar Cliente:",
                    "sLengthMenu": "Mostrar _MENU_ registros",
                    "sInfo": "Mostrando _START_ al _END_ de _TOTAL_ registros",
                    "sEmptyTable": "Ningún dato disponible",
                    "oPaginate": { "sNext": "Siguiente", "sPrevious": "Anterior" }
                },
                "dom": '<"row"<"col-md-6"l><"col-md-6"f>>rtip'
            });

            // Lógica de Alertas y limpieza de URL
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.has('msg') || urlParams.has('error')) {
                Swal.fire({
                    title: urlParams.has('msg') ? '¡Éxito!' : '¡Error!',
                    text: urlParams.get('msg') || urlParams.get('error'),
                    icon: urlParams.has('msg') ? 'success' : 'error',
                    confirmButtonColor: '#3b82f6',
                    confirmButtonText: 'Aceptar'
                }).then(() => {
                    window.history.replaceState({}, document.title, window.location.pathname);
                });
            }

            // Delegación de evento para Editar
            $('#tablaClientes').on('click', '.btn-editar', function () {
                var fila = $(this).closest('tr');
                // Quitamos el # del ID al leerlo de la tabla
                $('#txtId').val(fila.find('td:eq(0)').text().replace('#',''));
                $('#txtNombre').val(fila.find('td:eq(1)').text());
                $('#txtDui').val(fila.find('td:eq(2)').text());
                $('#txtEdad').val(fila.find('td:eq(3)').text().replace(' años',''));
                $('#txtTelefono').val(fila.find('td:eq(4)').text());
                $('#modalCliente').modal('show');
            });
        });

        function limpiarFormulario() {
            $('#txtId').val('');
            $('#modalCliente form')[0].reset();
        }

        function confirmarEliminar(id) {
            Swal.fire({
                title: '¿DESEA DAR DE BAJA?',
                text: "Esta acción desactivará al cliente del directorio.",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#dc2626',
                cancelButtonColor: '#6c757d',
                confirmButtonText: 'Sí, eliminar',
                cancelButtonText: 'Cancelar'
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