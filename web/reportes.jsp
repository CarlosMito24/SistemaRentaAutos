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

    // Cargar datos directamente desde el DAO (funciona tanto desde el servlet como desde enlace directo)
    ReporteDAO rDao = new ReporteDAO();
    ReporteDia resumen = null;
    List<Object[]> detalle   = null;
    List<Object[]> vehiculos = null;
    List<Object[]> moras     = null;
    String error = null;

    // Si el servlet ya puso los datos en request, usarlos; si no, consultarlos aquí
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
    <title>Reporte del Día - Sistema Renta Autos</title>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.10.24/css/dataTables.bootstrap4.min.css"/>
    <style>
        .kpi-card {
            border-radius: 10px;
            padding: 20px 24px;
            color: white;
            margin-bottom: 16px;
            position: relative;
            overflow: hidden;
        }
        .kpi-card .kpi-label {
            font-size: 0.78rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            opacity: 0.85;
            margin-bottom: 6px;
        }
        .kpi-card .kpi-value {
            font-size: 1.9rem;
            font-weight: 700;
        }
        .kpi-card .kpi-icon {
            position: absolute;
            right: 18px; top: 50%;
            transform: translateY(-50%);
            font-size: 2.8rem;
            opacity: 0.2;
        }
        .bg-kpi-blue   { background: linear-gradient(135deg, #2980b9, #3498db); }
        .bg-kpi-green  { background: linear-gradient(135deg, #1e8449, #27ae60); }
        .bg-kpi-red    { background: linear-gradient(135deg, #c0392b, #e74c3c); }
        .bg-kpi-orange { background: linear-gradient(135deg, #d35400, #e67e22); }
        .section-title {
            font-weight: 700;
            border-left: 4px solid #2c3e50;
            padding-left: 10px;
            margin: 28px 0 14px;
        }

    </style>
</head>
<body class="bg-light">

    <jsp:include page="menu.jsp" />

    <div class="container-fluid p-4">

        <!-- ENCABEZADO -->
        <div class="d-flex justify-content-between align-items-center my-4 flex-wrap">
            <h1 class="mb-2">📋 Reporte del Día</h1>
            <div class="d-flex align-items-center flex-wrap" style="gap:8px;">
                <form method="get" action="ReporteServlet" class="form-inline mb-0">
                    <label class="mr-2 mb-0 font-weight-bold">Fecha:</label>
                    <input type="date" name="fecha" class="form-control mr-2"
                           value="<%= fecha %>">
                    <button type="submit" class="btn btn-primary">🔍 Buscar</button>
                </form>
                <a href="ExportarPDFServlet?fecha=<%= fecha %>" class="btn btn-danger">
                    📄 Exportar PDF
                </a>
            </div>
        </div>

        <!-- FECHA CONSULTADA -->
        <p class="text-muted mb-3">
            Mostrando datos del: <strong><%= fecha %></strong>
        </p>

        <!-- ERROR -->
        <% if (error != null) { %>
        <div class="alert alert-danger">⚠️ <%= error %></div>
        <% } %>

        <!-- KPI CARDS -->
        <div class="row">
            <div class="col-sm-6 col-xl-3">
                <div class="kpi-card bg-kpi-blue">
                    <div class="kpi-label">Total Alquileres</div>
                    <div class="kpi-value"><%= resumen.getTotalAlquileres() %></div>
                    <div class="kpi-icon">📋</div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3">
                <div class="kpi-card bg-kpi-green">
                    <div class="kpi-label">Subtotal del Día</div>
                    <div class="kpi-value">$<%= String.format("%,.2f", resumen.getTotalSubtotal()) %></div>
                    <div class="kpi-icon">💵</div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3">
                <div class="kpi-card bg-kpi-red">
                    <div class="kpi-label">Total Moras</div>
                    <div class="kpi-value">$<%= String.format("%,.2f", resumen.getTotalMora()) %></div>
                    <div class="kpi-icon">⏰</div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3">
                <div class="kpi-card bg-kpi-orange">
                    <div class="kpi-label">Ingresos Totales</div>
                    <div class="kpi-value">$<%= String.format("%,.2f", resumen.getTotalIngresos()) %></div>
                    <div class="kpi-icon">💰</div>
                </div>
            </div>
        </div>

        <!-- DETALLE DE ALQUILERES -->
        <h5 class="section-title">Detalle de Alquileres del Día</h5>
        <div class="table-responsive">
            <table id="tablaDetalle" class="table table-hover table-striped table-bordered">
                <thead class="thead-dark">
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
                        <td><span class="badge badge-secondary">#<%= f[0] %></span></td>
                        <td><strong><%= f[1] %></strong></td>
                        <td><%= f[2] %></td>
                        <td><%= f[3] %></td>
                        <td><span class="badge badge-success"><%= f[4] %></span></td>
                        <td><%= f[5] != null ? f[5].toString().substring(0,10) : "-" %></td>
                        <td><%= f[6] != null ? f[6].toString().substring(0,10) : "-" %></td>
                        <td><%= f[7] != null ? f[7] : "-" %></td>
                        <td><%= f[8] != null ? f[8].toString() : "<span class='text-muted'>Pendiente</span>" %></td>
                        <td>$<%= String.format("%,.2f", (Double) f[9]) %></td>
                        <td class="text-success font-weight-bold">$<%= String.format("%,.2f", (Double) f[10]) %></td>
                        <td class="<%= mora > 0 ? "text-danger font-weight-bold" : "text-muted" %>">
                            $<%= String.format("%,.2f", mora) %>
                        </td>
                        <td class="text-warning font-weight-bold">$<%= String.format("%,.2f", (Double) f[12]) %></td>
                    </tr>
                <% } } else { %>
                    <tr><td colspan="13" class="text-center text-muted py-4">
                        📭 No hay alquileres registrados para esta fecha.
                    </td></tr>
                <% } %>
                </tbody>
            </table>
        </div>

        <!-- FILA DOS COLUMNAS -->
        <div class="row">

            <!-- VEHÍCULOS ACTIVOS -->
            <div class="col-md-6">
                <h5 class="section-title">🚗 Vehículos Actualmente Alquilados</h5>
                <div class="table-responsive">
                    <table id="tablaVehiculos" class="table table-hover table-striped table-bordered">
                        <thead class="thead-dark">
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
                                <td><span class="badge badge-success"><%= v[1] %></span></td>
                                <td><%= v[2] %></td>
                                <td><span class="badge badge-warning text-dark"><%= v[3] != null ? v[3] : "-" %></span></td>
                            </tr>
                        <% } } else { %>
                            <tr><td colspan="4" class="text-center text-success py-3">✅ Todos los vehículos fueron devueltos</td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- MORAS -->
            <div class="col-md-6">
                <h5 class="section-title">⏰ Devoluciones con Mora</h5>
                <div class="table-responsive">
                    <table id="tablaMoras" class="table table-hover table-striped table-bordered">
                        <thead class="thead-dark">
                            <tr>
                                <th>Cliente</th>
                                <th>Vehículo</th>
                                <th>F. Estimada</th>
                                <th>F. Real</th>
                                <th>Mora</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% if (moras != null && !moras.isEmpty()) {
                               for (Object[] m : moras) { %>
                            <tr>
                                <td><%= m[0] %></td>
                                <td><%= m[1] %></td>
                                <td><%= m[2] %></td>
                                <td><%= m[3] %></td>
                                <td class="text-danger font-weight-bold">$<%= String.format("%,.2f", (Double) m[4]) %></td>
                            </tr>
                        <% } } else { %>
                            <tr><td colspan="5" class="text-center text-success py-3">✅ Sin moras registradas</td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div><!-- /row -->
    </div><!-- /container -->

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
