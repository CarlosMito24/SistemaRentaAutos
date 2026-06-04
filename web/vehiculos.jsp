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
            vertical-align: middle;
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
            <h1 class="page-title">Gestión de <span>Vehículos</span></h1>
            <button type="button" class="btn btn-custom-accent" data-toggle="modal" data-target="#modalVehiculo" onclick="limpiarFormulario()">
                + Nuevo Vehículo
            </button>
        </div>

        <div class="panel-card">
            <div class="table-responsive">
                <table id="tablaVehiculos" class="table table-hover table-striped table-bordered">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Marca</th>
                            <th>Modelo</th>
                            <th>Año</th>
                            <th>Color</th>
                            <th>Placa</th>
                            <th>Capacidad</th>
                            <th>Precio</th>
                            <th>Estado</th>
                            <th class="text-center">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            VehiculoDAO dao = new VehiculoDAO();
                            List<Vehiculo> lista = dao.listarVehiculos();
                            for (Vehiculo v : lista) {
                        %>
                        <tr>
                            <td class="font-weight-bold text-primary">#<%= v.getIdVehiculo()%></td>
                            <td><%= v.getMarca()%></td>
                            <td><%= v.getModelo()%></td>
                            <td><%= v.getAnio()%></td>
                            <td><%= v.getColor()%></td>
                            <td style="font-family:monospace; color:var(--text-muted);"><%= v.getPlaca()%></td>
                            <td><%= v.getCapacidad()%> psj.</td>
                            <td class="font-weight-bold text-success">$<%= String.format("%.2f", v.getPrecioDiario())%></td>
                            <td>
                                <%= v.isDisponible() ? 
                                    "<span class='badge badge-success px-2 py-1'>Disponible</span>" : 
                                    "<span class='badge badge-danger px-2 py-1'>Alquilado</span>" %>
                            </td>
                            <td class="text-center">
                                <button class="btn btn-sm btn-outline-primary-custom btn-editar px-3 mr-2">✏️ EDITAR</button>
                                <button class="btn btn-sm btn-outline-danger-custom px-3" onclick="confirmarEliminar(<%= v.getIdVehiculo()%>)">🗑️ BAJA</button>
                            </td>
                        </tr>
                        <% }%>
                    </tbody>
                </table>
            </div>
        </div>

    </div>

    <div class="modal fade" id="modalVehiculo" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content">
                <form action="VehiculoServlet" method="POST">
                    <div class="modal-header">
                        <h5 class="modal-title">Registro de Vehículo</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="txtId" id="txtId">
                        
                        <div class="row">
                            <div class="form-group col-md-6">
                                <label>Marca:</label>
                                <input type="text" name="txtMarca" id="txtMarca" class="form-control" placeholder="Ej. Toyota" required>
                            </div>
                            <div class="form-group col-md-6">
                                <label>Modelo:</label>
                                <input type="text" name="txtModelo" id="txtModelo" class="form-control" placeholder="Ej. Corolla" required>
                            </div>
                        </div>

                        <div class="row">
                            <div class="form-group col-md-6">
                                <label>Año:</label>
                                <input type="number" name="txtAnio" id="txtAnio" class="form-control" placeholder="Ej. 2022" required min="2000">
                            </div>
                            <div class="form-group col-md-6">
                                <label>Color:</label>
                                <input type="text" name="txtColor" id="txtColor" class="form-control" placeholder="Ej. Blanco" required>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label>Placa (Formato PXXX-XXX):</label>
                            <input type="text" name="txtPlaca" id="txtPlaca" class="form-control" 
                                   placeholder="P123-456" maxlength="8" 
                                   pattern="P[0-9]{3}-[0-9]{3}" 
                                   title="El formato debe ser P seguido de 3 números, un guion y 3 números (ej. P123-456)" 
                                   required>
                        </div>
                        
                        <div class="row">
                            <div class="form-group col-md-6">
                                <label>Capacidad (Pasajeros):</label>
                                <input type="number" name="txtCapacidad" id="txtCapacidad" class="form-control" placeholder="Ej. 5" min="1" required>
                            </div>
                            <div class="form-group col-md-6">
                                <label>Precio Diario ($):</label>
                                <input type="text" name="txtPrecio" id="txtPrecio" class="form-control" placeholder="Ej. 45.00" required>
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
            $('#tablaVehiculos').DataTable({
                language: {
                    "sProcessing": "Procesando...",
                    "sSearch": "Buscar Vehículo:",
                    "sLengthMenu": "Mostrar _MENU_ registros",
                    "sInfo": "Mostrando _START_ al _END_ de _TOTAL_ registros",
                    "sEmptyTable": "Ningún dato disponible",
                    "oPaginate": { "sNext": "Siguiente", "sPrevious": "Anterior" }
                },
                "dom": '<"row"<"col-md-6"l><"col-md-6"f>>rtip'
            });

            // Validaciones en tiempo real
            $('#txtPrecio').on('input', function () { 
                this.value = this.value.replace(/[^0-9.]/g, ''); 
            });
            
            // Asegurar que la placa mantenga el formato en mayúsculas
            $('#txtPlaca').on('input', function () {
                this.value = this.value.toUpperCase();
            });

            // Lógica de Alertas
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.has('msg') || urlParams.has('error')) {
                Swal.fire({
                    title: urlParams.has('msg') ? '¡Éxito!' : '¡Error!',
                    text: urlParams.get('msg') || urlParams.get('error'),
                    icon: urlParams.has('msg') ? 'success' : 'error',
                    confirmButtonColor: '#3b82f6',
                    confirmButtonText: 'Aceptar'
                }).then(() => window.history.replaceState({}, document.title, window.location.pathname));
            }

            // Delegación de evento para Editar
            $('#tablaVehiculos').on('click', '.btn-editar', function () {
                var fila = $(this).closest('tr');
                $('#txtId').val(fila.find('td:eq(0)').text().replace('#','').trim());
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

        function limpiarFormulario() { 
            $('#txtId').val(''); 
            $('#modalVehiculo form')[0].reset(); 
        }

        function confirmarEliminar(id) {
            Swal.fire({ 
                title: '¿Estás seguro?', 
                text: "Esta acción desactivará el vehículo del sistema.", 
                icon: 'warning', 
                showCancelButton: true, 
                confirmButtonColor: '#dc2626', 
                cancelButtonColor: '#6c757d', 
                confirmButtonText: 'Sí, desactivar',
                cancelButtonText: 'Cancelar'
            }).then((result) => {
                if (result.isConfirmed) {
                    window.location.href = 'VehiculoServlet?accion=eliminar&id=' + id;
                }
            });
        }
    </script>
</body>
</html>