<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.renta.modelos.Usuario"%>
<%@page import="com.renta.conexion.Conexion"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.util.*"%>
<%@page import="java.text.SimpleDateFormat"%>

<%
    // Verificación de seguridad forzada
    if (session == null || session.getAttribute("empleado") == null) {
        response.sendRedirect("login.jsp");
        return; 
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel Principal - Renta Autos ITCA</title>
    <link rel="icon" href="img/login.jpg" type="image/jpeg">
    
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@2.9.4/dist/Chart.min.js"></script>
    
    <style>
        :root {
            --primary: #1e293b;
            --accent: #3b82f6;
            --bg-light: #f4f7f6;
            --text-dark: #2c3e50;
            --text-muted: #6c757d;
            --border: #e2e8f0;
            --radius: 12px;
        }

        body { 
            background-color: var(--bg-light);
            color: var(--text-dark);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0; 
            min-height: 100vh; 
        }

        /* ── HERO SECTION ── */
        .hero {
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
            color: white;
            padding: 40px 35px;
            margin: 18px 24px 25px 24px;
            border-radius: var(--radius);
            position: relative;
            overflow: hidden;
            box-shadow: 0 8px 20px rgba(0,0,0,0.15);
        }
        .hero::before {
            content: '';
            position: absolute; top: -60px; right: -60px;
            width: 250px; height: 250px; border-radius: 50%;
            background: rgba(59, 130, 246, 0.15);
        }
        .hero-inner { position: relative; z-index: 1; }
        
        .hero h2 {
            font-size: 32px;
            font-weight: 800;
            margin: 0 0 8px 0;
            letter-spacing: 0.5px;
        }
        .hero h2 span { color: #60a5fa; }
        
        .hero-sub {
            margin: 0;
            font-size: 14px;
            color: #cbd5e1;
            display: flex; align-items: center; gap: 10px;
        }
        .hero-sub .sep { opacity: 0.5; }
        .hero-badge {
            display: inline-flex;
            align-items: center; gap: 6px;
            background: rgba(255,255,255,0.1);
            border: 1px solid rgba(255,255,255,0.2);
            border-radius: 20px; padding: 4px 15px;
            font-weight: 600;
            color: #f8fafc;
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
        
        /* Colores de íconos */
        .bg-azul    { background-color: #dbeafe; color: #2563eb; }
        .bg-verde   { background-color: #dcfce7; color: #16a34a; }
        .bg-naranja { background-color: #ffedd5; color: #ea580c; }
        .bg-rojo    { background-color: #fee2e2; color: #dc2626; }
        .bg-morado  { background-color: #ede9fe; color: #7c3aed; }
        .bg-cyan    { background-color: #cffafe; color: #0891b2; }

        .metrica-info h3 { 
            font-size: 32px; 
            font-weight: 800;
            color: var(--text-dark);
            margin: 0; line-height: 1;
        }
        .metrica-info p { 
            margin: 6px 0 0 0; 
            color: var(--text-muted);
            font-size: 13px; 
            font-weight: 600;
            text-transform: uppercase;
        }

        /* ── PANELS ── */
        .panel-card {
            background: #ffffff;
            border: none;
            border-radius: var(--radius);
            box-shadow: 0 4px 6px rgba(0,0,0,0.05);
            padding: 24px; 
            height: 100%;
        }
        .panel-titulo {
            font-size: 18px;
            font-weight: 700;
            color: var(--primary);
            margin-bottom: 20px; padding-bottom: 12px;
            border-bottom: 2px solid var(--bg-light);
        }

        /* ── CONTENEDOR DE GRÁFICA ── */
        .chart-container {
            position: relative;
            height: 250px; 
            width: 100%;
        }

        /* ── FLOTA & META ── */
        .flota-label { display: flex; justify-content: space-between; font-size: 14px; font-weight: 600; color: var(--text-dark); margin-bottom: 8px; }
        .progress { 
            height: 20px; 
            border-radius: 10px; 
            background: var(--bg-light); 
            box-shadow: inset 0 1px 2px rgba(0,0,0,0.1);
        }
        .progress-bar { 
            font-size: 12px; font-weight: bold; line-height: 20px;
        }

        .meta-numero { text-align: center; margin: 10px 0 5px; }
        .meta-numero span { font-size: 42px; font-weight: 800; color: var(--accent); }
        .meta-numero small { font-size: 18px; color: var(--text-muted); font-weight: 600; }
        .meta-label { text-align: center; color: var(--text-muted); font-size: 12px; font-weight: 600; text-transform: uppercase; margin-bottom: 15px; }

        /* ── TABLAS Y RANKINGS ── */
        .table thead th { 
            background: var(--primary);
            color: #ffffff; 
            font-size: 13px; 
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border: none;
        }
        .table td { 
            font-size: 14px; vertical-align: middle; 
            font-weight: 500;
        }

        .badge-hoy { background: #fee2e2; color: #dc2626; padding: 5px 12px; border-radius: 6px; font-size: 11px; font-weight: bold; text-transform: uppercase;}
        .badge-manana { background: #fef9c3; color: #ca8a04; padding: 5px 12px; border-radius: 6px; font-size: 11px; font-weight: bold; text-transform: uppercase;}

        .rank-item {
            display: flex; align-items: center; gap: 15px;
            padding: 12px 0; border-bottom: 1px solid var(--bg-light);
        }
        .rank-item:last-child { border-bottom: none; }
        .rank-num {
            width: 35px; height: 35px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 14px; font-weight: 800; flex-shrink: 0;
            background: var(--bg-light); color: var(--text-muted);
        }
        .rank-1 { background: #fef9c3; color: #b45309; }
        .rank-2 { background: #f1f5f9; color: #475569; }
        .rank-3 { background: #ffedd5; color: #c2410c; }
        
        .rank-info { flex: 1; }
        .rank-info strong { font-size: 15px; display: block; color: var(--text-dark); font-weight: 700;}
        .rank-info small  { color: var(--text-muted); font-size: 13px; }
        .rank-value { font-size: 18px; font-weight: 800; color: #10b981; }
    </style>
</head>
<body>
    <jsp:include page="menu.jsp" />

    <%
        Usuario emp = (Usuario) session.getAttribute("empleado");
        String nombre = (emp != null) ? emp.getNombreCompleto() : "Usuario";

        // ── Variables ──────────────────────────────────────────────────────
        int totalClientes = 0, totalVehiculos = 0, alquileresActivos = 0, alquileresHoy = 0;
        int vehiculosDisponibles = 0, metaSemanal = 25, alquileresSemana = 0;
        double ingresosHoy = 0, ingresosSemana = 0, ingresosMes = 0;
        String[] diasLabels   = new String[7];
        int[]    diasAlq      = new int[7];
        double[] diasIngresos = new double[7];

        List<Map<String,Object>> proxDevoluciones = new ArrayList<>();
        List<Map<String,Object>> topVehiculos     = new ArrayList<>();
        List<Map<String,Object>> topClientes      = new ArrayList<>();

        boolean dbOk = false;
        Connection conn = null;
        try {
            conn   = Conexion.conectar();
            dbOk   = (conn != null && !conn.isClosed());
            ResultSet r;

            // Clientes activos
            r = conn.createStatement().executeQuery("SELECT COUNT(*) FROM Clientes WHERE activo = 1");
            if (r.next()) totalClientes = r.getInt(1);

            // Vehículos
            r = conn.createStatement().executeQuery("SELECT COUNT(*) FROM Vehiculos WHERE activo = 1");
            if (r.next()) totalVehiculos = r.getInt(1);

            r = conn.createStatement().executeQuery("SELECT COUNT(*) FROM Vehiculos WHERE disponible = 1 AND activo = 1");
            if (r.next()) vehiculosDisponibles = r.getInt(1);

            // Alquileres activos (sin devolución real)
            r = conn.createStatement().executeQuery(
                "SELECT COUNT(*) FROM Detalle_Alquiler WHERE fecha_devolucion_real IS NULL");
            if (r.next()) alquileresActivos = r.getInt(1);

            // Tickets de hoy
            r = conn.createStatement().executeQuery(
                "SELECT COUNT(*) FROM Ticket_Alquiler WHERE CAST(fecha_emision AS DATE) = CAST(GETDATE() AS DATE)");
            if (r.next()) alquileresHoy = r.getInt(1);

            // Meta semanal
            r = conn.createStatement().executeQuery(
                "SELECT COUNT(*) FROM Ticket_Alquiler " +
                "WHERE fecha_emision >= DATEADD(DAY, 1-DATEPART(WEEKDAY,GETDATE()), CAST(GETDATE() AS DATE))");
            if (r.next()) alquileresSemana = r.getInt(1);

            // Ingresos hoy
            r = conn.createStatement().executeQuery(
                "SELECT COALESCE(SUM(d.total_linea),0) FROM Detalle_Alquiler d " +
                "INNER JOIN Ticket_Alquiler t ON d.id_ticket = t.id_ticket " +
                "WHERE CAST(t.fecha_emision AS DATE) = CAST(GETDATE() AS DATE)");
            if (r.next()) ingresosHoy = r.getDouble(1);

            // Ingresos semana
            r = conn.createStatement().executeQuery(
                "SELECT COALESCE(SUM(d.total_linea),0) FROM Detalle_Alquiler d " +
                "INNER JOIN Ticket_Alquiler t ON d.id_ticket = t.id_ticket " +
                "WHERE t.fecha_emision >= DATEADD(DAY, 1-DATEPART(WEEKDAY,GETDATE()), CAST(GETDATE() AS DATE))");
            if (r.next()) ingresosSemana = r.getDouble(1);

            // Ingresos mes
            r = conn.createStatement().executeQuery(
                "SELECT COALESCE(SUM(d.total_linea),0) FROM Detalle_Alquiler d " +
                "INNER JOIN Ticket_Alquiler t ON d.id_ticket = t.id_ticket " +
                "WHERE YEAR(t.fecha_emision) = YEAR(GETDATE()) AND MONTH(t.fecha_emision) = MONTH(GETDATE())");
            if (r.next()) ingresosMes = r.getDouble(1);

            // Gráfica: alquileres e ingresos últimos 7 días
            SimpleDateFormat sdfLabel = new SimpleDateFormat("dd/MM");
            SimpleDateFormat sdfDb    = new SimpleDateFormat("yyyy-MM-dd");
            Calendar cal = Calendar.getInstance();
            for (int i = 6; i >= 0; i--) {
                Calendar d = (Calendar) cal.clone();
                d.add(Calendar.DAY_OF_YEAR, -i);
                diasLabels[6-i] = sdfLabel.format(d.getTime());
            }
            PreparedStatement psG = conn.prepareStatement(
                "SELECT CAST(t.fecha_emision AS DATE) AS dia, COUNT(DISTINCT t.id_ticket) AS total, " +
                "COALESCE(SUM(total_global),0) AS ingresos " +
                "FROM Ticket_Alquiler t " +
                "LEFT JOIN Detalle_Alquiler d ON t.id_ticket = d.id_ticket " +
                "WHERE t.fecha_emision >= DATEADD(DAY,-6,CAST(GETDATE() AS DATE)) " +
                "GROUP BY CAST(t.fecha_emision AS DATE) ORDER BY dia");
            ResultSet rsG = psG.executeQuery();
            Map<String,int[]> grafMap = new LinkedHashMap<>();
            while (rsG.next()) {
                grafMap.put(rsG.getString("dia"),
                    new int[]{ rsG.getInt("total"), (int) rsG.getDouble("ingresos") });
            }
            for (int i = 0; i < 7; i++) {
                Calendar d = (Calendar) cal.clone();
                d.add(Calendar.DAY_OF_YEAR, -(6-i));
                String key = sdfDb.format(d.getTime());
                if (grafMap.containsKey(key)) {
                    diasAlq[i]      = grafMap.get(key)[0];
                    diasIngresos[i] = grafMap.get(key)[1];
                }
            }

            // Próximas devoluciones (hoy y mañana)
            PreparedStatement psDev = conn.prepareStatement(
                "SELECT t.id_ticket, c.nombre AS cliente, " +
                "v.marca+' '+v.modelo AS vehiculo, v.placa, d.fecha_devolucion_esperada " +
                "FROM Detalle_Alquiler d " +
                "INNER JOIN Ticket_Alquiler t ON d.id_ticket   = t.id_ticket " +
                "INNER JOIN Clientes c        ON t.id_cliente  = c.id_cliente " +
                "INNER JOIN Vehiculos v       ON d.id_vehiculo = v.id_vehiculo " +
                "WHERE d.fecha_devolucion_real IS NULL " +
                "AND CAST(d.fecha_devolucion_esperada AS DATE) " +
                "BETWEEN CAST(GETDATE() AS DATE) AND DATEADD(DAY,1,CAST(GETDATE() AS DATE)) " +
                "ORDER BY d.fecha_devolucion_esperada ASC");
            ResultSet rsDev = psDev.executeQuery();
            SimpleDateFormat sdfT = new SimpleDateFormat("dd/MM/yyyy");
            SimpleDateFormat sdfC = new SimpleDateFormat("yyyyMMdd");
            String hoy = sdfC.format(new Date());
            while (rsDev.next()) {
                Map<String,Object> f = new HashMap<>();
                f.put("id",       rsDev.getInt("id_ticket"));
                f.put("cliente",  rsDev.getString("cliente"));
                f.put("vehiculo", rsDev.getString("vehiculo"));
                f.put("placa",    rsDev.getString("placa"));
                java.sql.Timestamp fd = rsDev.getTimestamp("fecha_devolucion_esperada");
                f.put("fecha", sdfT.format(fd));
                f.put("esHoy", sdfC.format(new Date(fd.getTime())).equals(hoy));
                proxDevoluciones.add(f);
            }

            // Top 3 vehículos del mes
            PreparedStatement psTopV = conn.prepareStatement(
                "SELECT TOP 3 v.marca+' '+v.modelo AS vehiculo, v.placa, " +
                "COUNT(*) AS alquileres, COALESCE(SUM(d.total_linea),0) AS ingresos " +
                "FROM Detalle_Alquiler d " +
                "INNER JOIN Ticket_Alquiler t ON d.id_ticket   = t.id_ticket " +
                "INNER JOIN Vehiculos v       ON d.id_vehiculo = v.id_vehiculo " +
                "WHERE YEAR(t.fecha_emision)=YEAR(GETDATE()) AND MONTH(t.fecha_emision)=MONTH(GETDATE()) " +
                "GROUP BY v.marca, v.modelo, v.placa ORDER BY ingresos DESC");
            ResultSet rsTopV = psTopV.executeQuery();
            while (rsTopV.next()) {
                Map<String,Object> f = new HashMap<>();
                f.put("nombre",     rsTopV.getString("vehiculo"));
                f.put("placa",      rsTopV.getString("placa"));
                f.put("alquileres", rsTopV.getInt("alquileres"));
                f.put("ingresos",   rsTopV.getDouble("ingresos"));
                topVehiculos.add(f);
            }

            // Top 3 clientes del mes
            PreparedStatement psTopC = conn.prepareStatement(
                "SELECT TOP 3 c.nombre AS cliente, COUNT(DISTINCT t.id_ticket) AS tickets, " +
                "COALESCE(SUM(d.total_linea),0) AS gastado " +
                "FROM Ticket_Alquiler t " +
                "INNER JOIN Clientes c        ON t.id_cliente  = c.id_cliente " +
                "INNER JOIN Detalle_Alquiler d ON t.id_ticket  = d.id_ticket " +
                "WHERE YEAR(t.fecha_emision)=YEAR(GETDATE()) AND MONTH(t.fecha_emision)=MONTH(GETDATE()) " +
                "GROUP BY c.nombre ORDER BY gastado DESC");
            ResultSet rsTopC = psTopC.executeQuery();
            while (rsTopC.next()) {
                Map<String,Object> f = new HashMap<>();
                f.put("nombre",  rsTopC.getString("cliente"));
                f.put("tickets", rsTopC.getInt("tickets"));
                f.put("gastado", rsTopC.getDouble("gastado"));
                topClientes.add(f);
            }

        } catch (Exception e) {
            System.err.println("Error dashboard: " + e.getMessage());
        } finally {
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }

        // Chart.js arrays
        StringBuilder labelsJs    = new StringBuilder("[");
        StringBuilder alqJs       = new StringBuilder("[");
        StringBuilder ingresosJs  = new StringBuilder("[");
        for (int i = 0; i < 7; i++) {
            labelsJs.append("'").append(diasLabels[i]).append("'");
            alqJs.append(diasAlq[i]);
            ingresosJs.append((int)diasIngresos[i]);
            if (i < 6) { labelsJs.append(","); alqJs.append(","); ingresosJs.append(","); }
        }
        labelsJs.append("]"); alqJs.append("]"); ingresosJs.append("]");
        int pctFlota = totalVehiculos > 0 ? (int)(((totalVehiculos - vehiculosDisponibles)*100.0)/totalVehiculos) : 0;
        int pctMeta  = Math.min((int)((alquileresSemana*100.0)/metaSemanal), 100);
    %>

    <div class="hero">
        <div class="container-fluid hero-inner">
            <h2>👋 Hola, <span><%= nombre %></span></h2>
            <div class="hero-sub">
                <span class="hero-badge">📅 <%= new SimpleDateFormat("EEEE, dd 'de' MMMM 'de' yyyy", new Locale("es","SV")).format(new Date()) %></span>
                <span class="sep">|</span>
                <span>Panel de Control de Rentas</span>
            </div>
        </div>
    </div>

    <div class="container-fluid px-4">

        <div class="row mb-4">
            <div class="col-md-2 col-sm-6 mb-3">
                <div class="card-metrica">
                    <div class="metrica-icono bg-azul">👥</div>
                    <div class="metrica-info">
                        <h3 class="text-primary"><%= totalClientes %></h3>
                        <p>Clientes</p>
                    </div>
                </div>
            </div>
            <div class="col-md-2 col-sm-6 mb-3">
                <div class="card-metrica">
                    <div class="metrica-icono bg-verde">🚘</div>
                    <div class="metrica-info">
                        <h3 class="text-success"><%= vehiculosDisponibles %></h3>
                        <p>Autos Disp.</p>
                    </div>
                </div>
            </div>
            <div class="col-md-2 col-sm-6 mb-3">
                <div class="card-metrica">
                    <div class="metrica-icono bg-naranja">🔑</div>
                    <div class="metrica-info">
                        <h3 class="text-warning"><%= alquileresActivos %></h3>
                        <p>En Ruta</p>
                    </div>
                </div>
            </div>
            <div class="col-md-2 col-sm-6 mb-3">
                <div class="card-metrica">
                    <div class="metrica-icono bg-rojo">📝</div>
                    <div class="metrica-info">
                        <h3 class="text-danger"><%= alquileresHoy %></h3>
                        <p>Tickets Hoy</p>
                    </div>
                </div>
            </div>
            <div class="col-md-2 col-sm-6 mb-3">
                <div class="card-metrica">
                    <div class="metrica-icono bg-morado">💵</div>
                    <div class="metrica-info">
                        <h3 class="text-purple" style="font-size:24px; color: #7c3aed;">$<%= String.format("%,.0f", ingresosHoy) %></h3>
                        <p>Ingresos Hoy</p>
                    </div>
                </div>
            </div>
            <div class="col-md-2 col-sm-6 mb-3">
                <div class="card-metrica">
                    <div class="metrica-icono bg-cyan">💎</div>
                    <div class="metrica-info">
                        <h3 class="text-info" style="font-size:24px;">$<%= String.format("%,.0f", ingresosMes) %></h3>
                        <p>Corte del Mes</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mb-4">
            <div class="col-md-2 mb-3">
                <div class="panel-card">
                    <div class="panel-titulo">Estado de Flota</div>
                    <div class="flota-label">
                        <span>Ocupados</span><span class="text-danger"><%= totalVehiculos - vehiculosDisponibles %></span>
                    </div>
                    <div class="progress mb-3">
                        <div class="progress-bar bg-danger" style="width:<%= pctFlota %>%"><%= pctFlota %>%</div>
                    </div>
                    <div class="flota-label">
                        <span>Disponibles</span><span class="text-success"><%= vehiculosDisponibles %></span>
                    </div>
                    <div class="progress">
                        <div class="progress-bar bg-success" style="width:<%= 100-pctFlota %>%"><%= 100-pctFlota %>%</div>
                    </div>
                    <hr class="my-4">
                    <div class="text-center">
                        <small class="text-muted" style="font-weight: 700; text-transform: uppercase;">Ingresos de la Semana</small>
                        <div style="font-size:24px; font-weight:800; color:var(--accent); margin-top: 5px;">
                            $<%= String.format("%,.2f", ingresosSemana) %>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-2 mb-3">
                <div class="panel-card text-center">
                    <div class="panel-titulo text-center">Meta Semanal</div>
                    <div class="meta-numero">
                        <span><%= alquileresSemana %></span>
                        <small>/ <%= metaSemanal %></small>
                    </div>
                    <div class="meta-label">TICKETS ESTA SEMANA</div>
                    <div class="progress mb-3">
                        <div class="progress-bar <%= pctMeta>=100?"bg-success":"bg-primary" %>"
                             style="width:<%= pctMeta %>%;">
                            <%= pctMeta %>%
                        </div>
                    </div>
                    <small class="text-muted mt-3 d-block font-weight-bold">
                        <% if (pctMeta >= 100) { %><span class="text-success">🎉 ¡META ALCANZADA!</span>
                        <% } else { %><%= metaSemanal - alquileresSemana %> rentas para la meta<% } %>
                    </small>
                </div>
            </div>

            <div class="col-md-8 mb-3">
                <div class="panel-card">
                    <div class="panel-titulo">Rendimiento (Últimos 7 Días)</div>
                    <div class="chart-container">
                        <canvas id="graficaDoble"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mb-4">
            <div class="col-md-6 mb-3">
                <div class="panel-card">
                    <div class="panel-titulo">🏆 Top Vehículos del Mes</div>
                    <% if (topVehiculos.isEmpty()) { %>
                        <p class="text-muted text-center mt-3" style="font-size:14px;">Sin datos este mes</p>
                    <% } else {
                           String[] rankCls = {"rank-1","rank-2","rank-3"};
                           String[] medals = {"1","2","3"};
                           for (int i = 0; i < topVehiculos.size(); i++) {
                               Map<String,Object> v = topVehiculos.get(i);
                    %>
                    <div class="rank-item">
                        <div class="rank-num <%= rankCls[i] %>"><%= medals[i] %></div>
                        <div class="rank-info">
                            <strong><%= v.get("nombre") %></strong>
                            <small><%= v.get("placa") %> &nbsp;|&nbsp; <%= v.get("alquileres") %> alquiler(es)</small>
                        </div>
                        <div class="rank-value">$<%= String.format("%,.0f", v.get("ingresos")) %></div>
                    </div>
                    <% } } %>
                </div>
            </div>

            <div class="col-md-6 mb-3">
                <div class="panel-card">
                    <div class="panel-titulo">⭐ Clientes VIP del Mes</div>
                    <% if (topClientes.isEmpty()) { %>
                        <p class="text-muted text-center mt-3" style="font-size:14px;">Sin datos este mes</p>
                    <% } else {
                           String[] rankCls2 = {"rank-1","rank-2","rank-3"};
                           String[] medals2 = {"1","2","3"};
                           for (int i = 0; i < topClientes.size(); i++) {
                               Map<String,Object> c = topClientes.get(i);
                    %>
                    <div class="rank-item">
                        <div class="rank-num <%= rankCls2[i] %>"><%= medals2[i] %></div>
                        <div class="rank-info">
                            <strong><%= c.get("nombre") %></strong>
                            <small><%= c.get("tickets") %> ticket(s) este mes</small>
                        </div>
                        <div class="rank-value">$<%= String.format("%,.0f", c.get("gastado")) %></div>
                    </div>
                    <% } } %>
                </div>
            </div>
        </div>

        <div class="panel-card mb-4">
            <div class="panel-titulo">⏰ Próximas Devoluciones (Hoy y Mañana)</div>
            <% if (proxDevoluciones.isEmpty()) { %>
                <p class="text-muted text-center mt-4 mb-4" style="font-size: 15px;">✅ No hay devoluciones pendientes a corto plazo.</p>
            <% } else { %>
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead>
                        <tr>
                            <th>TICKET</th>
                            <th>CLIENTE</th>
                            <th>VEHÍCULO</th>
                            <th>PLACA</th>
                            <th>RETORNO ESPERADO</th>
                            <th>ESTADO</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String,Object> f : proxDevoluciones) { %>
                        <tr>
                            <td class="font-weight-bold text-primary">#<%= f.get("id") %></td>
                            <td><%= f.get("cliente") %></td>
                            <td><%= f.get("vehiculo") %></td>
                            <td style="font-family:monospace; color:var(--text-muted);"><%= f.get("placa") %></td>
                            <td><%= f.get("fecha") %></td>
                            <td>
                                <% if ((Boolean)f.get("esHoy")) { %>
                                    <span class="badge-hoy">Vence Hoy</span>
                                <% } else { %>
                                    <span class="badge-manana">Vence Mañana</span>
                                <% } %>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </div>

    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Adaptación de Chart.js al concepto Claro / Corporativo
        var ctx = document.getElementById('graficaDoble').getContext('2d');
        Chart.defaults.global.defaultFontFamily = "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif";
        Chart.defaults.global.defaultFontColor = '#6c757d';
        
        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: <%= labelsJs %>,
                datasets: [
                    {
                        label: 'Alquileres',
                        data: <%= alqJs %>,
                        backgroundColor: 'rgba(59, 130, 246, 0.85)',
                        borderColor: '#2563eb',
                        borderWidth: 1,
                        yAxisID: 'y-alq',
                        order: 2,
                        barPercentage: 0.5,
                        borderRadius: 4
                    },
                    {
                        label: 'Ingresos ($)',
                        data: <%= ingresosJs %>,
                        type: 'line',
                        fill: true,
                        backgroundColor: 'rgba(16, 185, 129, 0.1)',
                        borderColor: '#10b981',
                        borderWidth: 3,
                        pointBackgroundColor: '#ffffff',
                        pointBorderColor: '#10b981',
                        pointBorderWidth: 2,
                        pointRadius: 4,
                        pointHoverRadius: 6,
                        yAxisID: 'y-ing',
                        order: 1
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    xAxes: [{
                        gridLines: { display: false }
                    }],
                    yAxes: [
                        {
                            id: 'y-alq', position: 'left',
                            ticks: { beginAtZero: true, stepSize: 1, fontColor: '#3b82f6' },
                            gridLines: { drawOnChartArea: true, color: 'rgba(0,0,0,0.05)', zeroLineColor: 'rgba(0,0,0,0.1)' }
                        },
                        {
                            id: 'y-ing', position: 'right',
                            ticks: { beginAtZero: true, fontColor: '#10b981',
                                     callback: function(v){ return '$'+v.toLocaleString(); } },
                            gridLines: { drawOnChartArea: false }
                        }
                    ]
                },
                legend: { 
                    position: 'top',
                    labels: { boxWidth: 12, fontColor: '#2c3e50', fontSize: 13, fontStyle: 'bold' }
                },
                tooltips: {
                    backgroundColor: '#ffffff',
                    titleFontFamily: "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif",
                    titleFontSize: 14,
                    titleFontColor: '#2c3e50',
                    bodyFontFamily: "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif",
                    bodyFontSize: 13,
                    bodyFontColor: '#6c757d',
                    borderColor: '#e2e8f0',
                    borderWidth: 1,
                    cornerRadius: 8,
                    displayColors: true,
                    callbacks: {
                        labelColor: function(tooltipItem, chart) {
                            var color = tooltipItem.datasetIndex === 0 ? '#3b82f6' : '#10b981';
                            return { borderColor: color, backgroundColor: color };
                        },
                        label: function(item, data) {
                            var label = data.datasets[item.datasetIndex].label;
                            var val   = item.yLabel;
                            return label === 'Ingresos ($)'
                                ? ' Ingresos: $' + val.toLocaleString()
                                : ' ' + label + ': ' + val;
                        }
                    }
                }
            }
        });
    </script>
</body>
</html>