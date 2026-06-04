<%@page import="com.renta.modelos.ReporteDia"%>
<%@page import="com.renta.datos.ReporteDAO"%>
<%@page import="java.util.List"%>
<%@page import="java.time.LocalDate"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Verificar sesión igual que los otros JSP
    com.renta.modelos.Usuario empRep = (session != null)
        ? (com.renta.modelos.Usuario) session.getAttribute("empleado") : null;
    if (empRep == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Fecha: prioridad al parámetro GET, si no usa hoy
    String fecha = request.getParameter("fecha");
    if (fecha == null || fecha.trim().isEmpty()) {
        fecha = LocalDate.now().toString();
    }

    // Cargar datos directamente desde el DAO
    ReporteDAO rDao = new ReporteDAO();
    ReporteDia resumen = null;
    List<Object[]> detalle   = null;
    List<Object[]> vehiculos = null;
    List<Object[]> moras     = null;
    String error = null;

    if (request.getAttribute("resumen") != null) {
        resumen  = (ReporteDia)    request.getAttribute("resumen");
        detalle  = (List<Object[]>) request.getAttribute("detalle");
        vehiculos= (List<Object[]>) request.getAttribute("vehiculos");
        moras    = (List<Object[]>) request.getAttribute("moras");
        error    = (String)         request.getAttribute("error");
    } else {
        try {
            resumen   = rDao.obtenerResumenDia(fecha);
            detalle   = rDao.obtenerDetalleAlquileresDia(fecha);
            vehiculos = rDao.obtenerVehiculosMasAlquilados(fecha);
            moras     = rDao.obtenerDevolucionesConMora(fecha);
        } catch (Exception ex) {
            error = "Error al cargar datos: " + ex.getMessage();
            resumen = new ReporteDia();
        }
    }
    if (resumen == null) resumen = new ReporteDia();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reporte del Día - Sistema Renta Autos ITCA</title>
    <link rel="icon" href="img/login.jpg" type="image/jpeg">
    
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.10.24/css/dataTables.bootstrap4.min.css"/>
    
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
            align-items: flex-end;
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 2px solid #e9ecef;
            flex-wrap: wrap;
            gap: 15px;
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
        .panel-titulo {
            font-size: 20px;
            font-weight: 700;
            color: var(--primary);
            margin-bottom: 20px;
        }

        /* ── KPI CARDS ── */
        .card-metrica {
            background: #ffffff;
            border: none;
            border-radius: var(--radius); 
            padding: 22px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.05);
            display: flex; align-items: center; gap: 18px;
            height: 100%;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .card-metrica:hover { 
            transform: translateY(-3px);
            box-shadow: 0 8px 15px rgba(0,0,0,0.1);
        }
        .metrica-icono {
            font-size: 28px;
            width: 60px; height: 60px; 
            border-radius: 12px;
            display: flex; align-items: center; justify-content: center; flex-shrink: 0;
        }
        
        .bg-azul    { background-color: #dbeafe; color: #2563eb; }
        .bg-verde   { background-color: #dcfce7; color: #16a34a; }
        .bg-rojo    { background-color: #fee2e2; color: #dc2626; }
        .bg-cyan    { background-color: #cffafe; color: #0891b2; }

        .metrica-info h3 { 
            font-size: 30px; 
            font-weight: 800;
            margin: 0; line-height: 1;
        }
        .metrica-info p { 
            margin: 6px 0 0 0; 
            color: var(--text-muted);
            font-size: 12px; 
            font-weight: 700;
            text-transform: uppercase;
        }

        /* ── BOTONES Y FORMULARIOS ── */
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

        .btn-outline-danger-custom {
            border: 1px solid #dc2626;
            color: #dc2626;
            background: transparent;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            padding: 10px 24px;
            border-radius: 6px;
            transition: all 0.3s;
        }
        .btn-outline-danger-custom:hover {
            background: #dc2626;
            color: white;
            box-shadow: 0 4px 6px rgba(220, 38, 38, 0.2);
        }

        .form-control {
            background: var(--input-bg);
            border: 1px solid #ced4da;
            border-radius: 8px;
            color: var(--text-dark);
            padding: 10px 15px;
            font-size: 14px;
            height: auto; /* Corrección de altura solicitada */
        }
        .form-control:focus {
            background: #ffffff;
            border-color: var(--accent);
            color: var(--text-dark);
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.15);
        }

        /* ── TABLAS Y DATATABLES ── */
        .table { margin-top: 15px !important; }
        .table thead th { 
            background: var(--primary) !important;
            color: #ffffff !important; 
            font-size: 12px; 
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
    </style>
</head>
<body>

    <jsp:include page="menu.jsp" />

    <div class="container-fluid px-4 py-4">

        <div class="page-header">
            <div>
                <h1 class="page-title">Reportes <span>del Día</span></h1>
                <p class="text-muted mt-2 mb-0 font-weight-bold">
                    Mostrando datos del: <span class="text-primary"><%= fecha %></span>
                </p>
            </div>
            
            <div class="d-flex align-items-center flex-wrap" style="gap:15px;">
                <form method="get" action="ReporteServlet" class="form-inline mb-0">
                    <label class="mr-2 mb-0 font-weight-bold text-primary" style="font-size: 13px; text-transform: uppercase;">Seleccionar Fecha:</label>
                    <input type="date" name="fecha" class="form-control mr-2" value="<%= fecha %>">
                    <button type="submit" class="btn btn-custom-accent py-2 px-3"><i class="fas fa-search mr-1"></i> Buscar</button>
                </form>
                <a href="ExportarPDFServlet?fecha=<%= fecha %>" class="btn btn-outline-danger-custom py-2">
                    📄 Exportar PDF
                </a>
            </div>
        </div>

        <% if (error != null) { %>
        <div class="alert alert-danger" style="border-radius: 8px; font-weight: bold;">⚠️ <%= error %></div>
        <% } %>

        <div class="row mb-4">
            <div class="col-md-3 col-sm-6 mb-3">
                <div class="card-metrica">
                    <div class="metrica-icono bg-azul">📋</div>
                    <div class="metrica-info">
                        <h3 class="text-primary"><%= resumen.getTotalAlquileres() %></h3>
                        <p>Total Alquileres</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3 col-sm-6 mb-3">
                <div class="card-metrica">
                    <div class="metrica-icono bg-verde">💵</div>
                    <div class="metrica-info">
                        <h3 class="text-success">$<%= String.format("%,.2f", resumen.getTotalSubtotal()) %></h3>
                        <p>Subtotal Base</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3 col-sm-6 mb-3">
                <div class="card-metrica">
                    <div class="metrica-icono bg-rojo">⏰</div>
                    <div class="metrica-info">
                        <h3 class="text-danger">$<%= String.format("%,.2f", resumen.getTotalMora()) %></h3>
                        <p>Total Moras</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3 col-sm-6 mb-3">
                <div class="card-metrica">
                    <div class="metrica-icono bg-cyan">💰</div>
                    <div class="metrica-info">
                        <h3 class="text-info">$<%= String.format("%,.2f", resumen.getTotalIngresos()) %></h3>
                        <p>Ingresos Totales</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="panel-card mb-4">
            <h3 class="panel-titulo">Detalle de Alquileres Registrados</h3>
            <div class="table-responsive">
                <table id="tablaDetalle" class="table table-hover table-bordered">
                    <thead>
                        <tr>
                            <th>Ticket</th>
                            <th>Cliente</th>
                            <th>DUI</th>
                            <th>Vehículo</th>
                            <th>Placa</th>
                            <th>F. Emisión</th>
                            <th>F. Entrega</th>
                            <th>F. Dev. Est.</th>
                            <th>F. Dev. Real</th>
                            <th>Precio/día</th>
                            <th>Subtotal</th>
                            <th>Mora</th>
                            <th>Total Línea</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if (detalle != null && !detalle.isEmpty()) {
                           for (Object[] f : detalle) {
                               double mora = (Double) f[11];
                               String rowClass = mora > 0 ? "table-danger" : "";
                    %>
                        <tr class="<%= rowClass %>">
                            <td class="font-weight-bold text-primary">#<%= f[0] %></td>
                            <td><strong><%= f[1] %></strong></td>
                            <td class="text-muted" style="font-family:monospace;"><%= f[2] %></td>
                            <td><%= f[3] %></td>
                            <td><span class="badge badge-success px-2 py-1"><%= f[4] %></span></td>
                            <td><%= f[5] != null ? f[5].toString().substring(0,10) : "-" %></td>
                            <td><%= f[6] != null ? f[6].toString().substring(0,10) : "-" %></td>
                            <td><%= f[7] != null ? f[7] : "-" %></td>
                            <td><%= f[8] != null ? f[8].toString() : "<span class='badge badge-warning'>Pendiente</span>" %></td>
                            <td>$<%= String.format("%,.2f", (Double) f[9]) %></td>
                            <td class="text-success font-weight-bold">$<%= String.format("%,.2f", (Double) f[10]) %></td>
                            <td class="<%= mora > 0 ? "text-danger font-weight-bold" : "text-muted" %>">
                                $<%= String.format("%,.2f", mora) %>
                            </td>
                            <td class="text-primary font-weight-bold" style="font-size: 15px;">$<%= String.format("%,.2f", (Double) f[12]) %></td>
                        </tr>
                    <% } } else { %>
                        <tr><td colspan="13" class="text-center text-muted py-4">📭 No hay alquileres registrados para esta fecha.</td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="row">

            <div class="col-md-6 mb-3">
                <div class="panel-card h-100">
                    <h3 class="panel-titulo">🚗 Vehículos Actualmente Alquilados</h3>
                    <div class="table-responsive">
                        <table id="tablaVehiculos" class="table table-hover table-bordered">
                            <thead>
                                <tr>
                                    <th>Vehículo</th>
                                    <th>Placa</th>
                                    <th>Cliente</th>
                                    <th>Devolver antes de</th>
                                </tr>
                            </thead>
                            <tbody>
                            <% if (vehiculos != null && !vehiculos.isEmpty()) {
                                   for (Object[] v : vehiculos) { %>
                                <tr>
                                    <td><strong><%= v[0] %></strong></td>
                                    <td class="text-muted" style="font-family:monospace;"><%= v[1] %></td>
                                    <td><%= v[2] %></td>
                                    <td><span class="badge badge-warning text-dark px-2 py-1"><%= v[3] != null ? v[3] : "-" %></span></td>
                                </tr>
                            <% } } else { %>
                                <tr><td colspan="4" class="text-center text-success py-4 font-weight-bold">✅ Todos los vehículos fueron devueltos</td></tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div class="col-md-6 mb-3">
                <div class="panel-card h-100">
                    <h3 class="panel-titulo">⏰ Devoluciones con Mora Registrada</h3>
                    <div class="table-responsive">
                        <table id="tablaMoras" class="table table-hover table-bordered">
                            <thead>
                                <tr>
                                    <th>Cliente</th>
                                    <th>Vehículo</th>
                                    <th>F. Estimada</th>
                                    <th>F. Real</th>
                                    <th>Mora Aplicada</th>
                                </tr>
                            </thead>
                            <tbody>
                            <% if (moras != null && !moras.isEmpty()) {
                                   for (Object[] m : moras) { %>
                                <tr>
                                    <td><strong><%= m[0] %></strong></td>
                                    <td><%= m[1] %></td>
                                    <td><%= m[2] %></td>
                                    <td><%= m[3] %></td>
                                    <td class="text-danger font-weight-bold" style="font-size: 15px;">$<%= String.format("%,.2f", (Double) m[4]) %></td>
                                </tr>
                            <% } } else { %>
                                <tr><td colspan="5" class="text-center text-success py-4 font-weight-bold">✅ Sin moras registradas</td></tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

        </div></div><link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.24/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.24/js/dataTables.bootstrap4.min.js"></script>
    <script>
        $(document).ready(function () {
            var lang = {"url": "//cdn.datatables.net/plug-ins/1.10.24/i18n/Spanish.json"};
            $('#tablaDetalle').DataTable({language: lang});
            $('#tablaVehiculos').DataTable({language: lang, paging: false, searching: false, info: false});
            $('#tablaMoras').DataTable({language: lang, paging: false, searching: false, info: false});
        });
    </script>
</body>
</html>