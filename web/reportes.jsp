<%@page import="com.renta.modelos.ReporteDia"%>
<%@page import="com.renta.datos.ReporteDAO"%>
<%@page import="java.util.List"%>
<%@page import="java.time.LocalDate"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // Verificación de sesión
    com.renta.modelos.Usuario empRep = (session != null) ? (com.renta.modelos.Usuario) session.getAttribute("empleado") : null;
    if (empRep == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Fecha: prioridad al parámetro GET, si no usa hoy
    String fecha = request.getParameter("fecha");
    if (fecha == null || fecha.trim().isEmpty()) {
        fecha = LocalDate.now().toString();
    }

    ReporteDAO rDao = new ReporteDAO();
    ReporteDia resumen = null;
    List<Object[]> detalle = null;
    List<Object[]> vehiculos = null;
    List<Object[]> moras = null;
    String error = null;

    if (request.getAttribute("resumen") != null) {
        resumen = (ReporteDia) request.getAttribute("resumen");
        detalle = (List<Object[]>) request.getAttribute("detalle");
        vehiculos = (List<Object[]>) request.getAttribute("vehiculos");
        moras = (List<Object[]>) request.getAttribute("moras");
        error = (String) request.getAttribute("error");
    } else {
        try {
            resumen = rDao.obtenerResumenDia(fecha);
            detalle = rDao.obtenerDetalleAlquileresDia(fecha);
            vehiculos = rDao.obtenerVehiculosMasAlquilados(fecha);
            moras = rDao.obtenerDevolucionesConMora(fecha);
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
        .kpi-card { border-radius: 10px; padding: 20px 24px; color: white; margin-bottom: 16px; position: relative; overflow: hidden; }
        .kpi-label { font-size: 0.78rem; text-transform: uppercase; letter-spacing: 1px; opacity: 0.85; margin-bottom: 6px; }
        .kpi-value { font-size: 1.9rem; font-weight: 700; }
        .kpi-icon { position: absolute; right: 18px; top: 50%; transform: translateY(-50%); font-size: 2.8rem; opacity: 0.2; }
        .bg-kpi-blue   { background: linear-gradient(135deg, #2980b9, #3498db); }
        .bg-kpi-green  { background: linear-gradient(135deg, #1e8449, #27ae60); }
        .bg-kpi-red    { background: linear-gradient(135deg, #c0392b, #e74c3c); }
        .bg-kpi-orange { background: linear-gradient(135deg, #d35400, #e67e22); }
        .section-title { font-weight: 700; border-left: 4px solid #2c3e50; padding-left: 10px; margin: 28px 0 14px; }
    </style>
</head>
<body class="bg-light">
    <jsp:include page="menu.jsp" />
    <div class="container-fluid p-4">
        <div class="d-flex justify-content-between align-items-center my-4 flex-wrap">
            <h1 class="mb-2">📋 Reporte del Día</h1>
            <div class="d-flex align-items-center flex-wrap" style="gap:8px;">
                <form method="get" action="ReporteServlet" class="form-inline mb-0">
                    <label class="mr-2 mb-0 font-weight-bold">Fecha:</label>
                    <input type="date" name="fecha" class="form-control mr-2" value="<%= fecha %>">
                    <button type="submit" class="btn btn-primary">🔍 Buscar</button>
                </form>
                <a href="ExportarPDFServlet?fecha=<%= fecha %>" class="btn btn-danger">📄 Exportar PDF</a>
            </div>
        </div>

        <p class="text-muted mb-3">Mostrando datos del: <strong><%= fecha %></strong></p>

        <% if (error != null) { %>
            <div class="alert alert-danger">⚠️ <%= error %></div>
        <% } %>

        <div class="row">
            <div class="col-sm-6 col-xl-3"><div class="kpi-card bg-kpi-blue"><div class="kpi-label">Total Alquileres</div><div class="kpi-value"><%= resumen.getTotalAlquileres() %></div><div class="kpi-icon">📋</div></div></div>
            <div class="col-sm-6 col-xl-3"><div class="kpi-card bg-kpi-green"><div class="kpi-label">Subtotal del Día</div><div class="kpi-value">$<%= String.format("%,.2f", resumen.getTotalSubtotal()) %></div><div class="kpi-icon">💵</div></div></div>
            <div class="col-sm-6 col-xl-3"><div class="kpi-card bg-kpi-red"><div class="kpi-label">Total Moras</div><div class="kpi-value">$<%= String.format("%,.2f", resumen.getTotalMora()) %></div><div class="kpi-icon">⏰</div></div></div>
            <div class="col-sm-6 col-xl-3"><div class="kpi-card bg-kpi-orange"><div class="kpi-label">Ingresos Totales</div><div class="kpi-value">$<%= String.format("%,.2f", resumen.getTotalIngresos()) %></div><div class="kpi-icon">💰</div></div></div>
        </div>

        </div>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.24/js/jquery.dataTables.min.js"></script>
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