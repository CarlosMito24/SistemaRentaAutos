<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.renta.modelos.Usuario"%>
<%@page import="com.renta.conexion.Conexion"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.util.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel Principal - Renta Autos</title>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@2.9.4/dist/Chart.min.js"></script>
    <style>
        body { background-color: #f0f2f5; margin: 0; min-height: 100vh; }

        .hero {
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 40%, #0f3460 100%);
            color: white;
            padding: 40px 35px;
            margin: 18px 24px 25px 24px;
            border-radius: 16px;
            position: relative;
            overflow: hidden;
            box-shadow: 0 8px 32px rgba(15, 52, 96, 0.35);
        }
        .hero::before {
            content: '';
            position: absolute; top: -60px; right: -60px;
            width: 220px; height: 220px; border-radius: 50%;
            background: rgba(240, 165, 0, 0.08);
        }
        .hero::after {
            content: '';
            position: absolute; bottom: -40px; right: 180px;
            width: 130px; height: 130px; border-radius: 50%;
            background: rgba(99, 179, 237, 0.07);
        }
        .hero-inner { position: relative; z-index: 1; }
        .hero h2 {
            font-size: 32px; font-weight: 800; margin: 0 0 6px 0;
            letter-spacing: -0.5px;
        }
        .hero-sub {
            margin: 0; font-size: 14px;
            color: rgba(255,255,255,0.55);
            display: flex; align-items: center; gap: 8px;
        }
        .hero-sub .sep { opacity: 0.3; }
        .hero-badge {
            display: inline-flex; align-items: center; gap: 6px;
            background: rgba(255,255,255,0.08);
            border: 1px solid rgba(255,255,255,0.12);
            border-radius: 20px; padding: 4px 14px;
            font-size: 12px; color: rgba(255,255,255,0.7);
        }
        .hero-cars {
            position: absolute; right: 35px; top: 50%;
            transform: translateY(-50%);
            font-size: 72px; opacity: 0.07;
            user-select: none; pointer-events: none;
        }

        /* KPI cards */
        .card-metrica {
            border: none; border-radius: 12px; padding: 22px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.07);
            display: flex; align-items: center; gap: 18px;
            background: white; height: 100%;
            transition: transform 0.15s;
        }
        .card-metrica:hover { transform: translateY(-3px); }
        .metrica-icono {
            font-size: 36px; width: 65px; height: 65px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center; flex-shrink: 0;
        }
        .metrica-info h3 { font-size: 34px; font-weight: bold; margin: 0; line-height: 1; }
        .metrica-info p  { margin: 4px 0 0 0; color: #888; font-size: 13px; }

        .bg-azul    { background-color: #dbeafe; } .txt-azul    { color: #2563eb; }
        .bg-verde   { background-color: #dcfce7; } .txt-verde   { color: #16a34a; }
        .bg-naranja { background-color: #ffedd5; } .txt-naranja { color: #ea580c; }
        .bg-rojo    { background-color: #fee2e2; } .txt-rojo    { color: #dc2626; }
        .bg-morado  { background-color: #ede9fe; } .txt-morado  { color: #7c3aed; }
        .bg-cyan    { background-color: #cffafe; } .txt-cyan    { color: #0891b2; }

        .panel-card {
            background: white; border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.07);
            padding: 22px; height: 100%;
        }
        .panel-titulo {
            font-size: 16px; font-weight: bold; color: #2c3e50;
            margin-bottom: 15px; padding-bottom: 10px;
            border-bottom: 2px solid #f0f0f0;
        }

        /* Flota */
        .flota-label { display: flex; justify-content: space-between; font-size: 13px; color: #555; margin-bottom: 6px; }
        .progress { height: 18px; border-radius: 10px; background: #e9ecef; }
        .progress-bar { border-radius: 10px; font-size: 12px; font-weight: bold; }

        /* Meta */
        .meta-numero { text-align: center; margin: 10px 0 5px; }
        .meta-numero span { font-size: 42px; font-weight: bold; color: #2563eb; }
        .meta-numero small { font-size: 18px; color: #aaa; }
        .meta-label { text-align: center; color: #888; font-size: 13px; margin-bottom: 12px; }

        /* Badges devoluciones */
        .badge-hoy     { background: #fee2e2; color: #dc2626; padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: bold; }
        .badge-manana  { background: #fef9c3; color: #ca8a04; padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: bold; }
        .badge-vencido { background: #450a0a; color: #fca5a5; padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: bold; }

        table thead th { background: #2c3e50; color: white; font-size: 13px; }
        table td       { font-size: 13px; vertical-align: middle; }

        /* TOP ranking */
        .rank-item {
            display: flex; align-items: center; gap: 12px;
            padding: 10px 0; border-bottom: 1px solid #f3f4f6;
        }
        .rank-item:last-child { border-bottom: none; }
        .rank-num {
            width: 30px; height: 30px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-weight: bold; font-size: 13px; flex-shrink: 0;
        }
        .rank-1 { background: #fef9c3; color: #b45309; }
        .rank-2 { background: #f3f4f6; color: #6b7280; }
        .rank-3 { background: #fef3c7; color: #92400e; }
        .rank-info { flex: 1; }
        .rank-info strong { font-size: 13px; display: block; color: #2c3e50; }
        .rank-info small  { color: #888; font-size: 12px; }
        .rank-value { font-weight: bold; font-size: 14px; color: #16a34a; }




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

        int pctFlota = totalVehiculos > 0
            ? (int)(((totalVehiculos - vehiculosDisponibles)*100.0)/totalVehiculos) : 0;
        int pctMeta  = Math.min((int)((alquileresSemana*100.0)/metaSemanal), 100);
    %>

    <!-- HERO -->
    <div class="hero">
        <div class="hero-cars">🚗</div>
        <div class="container-fluid hero-inner">
            <h2>👋 Bienvenido, <%= nombre %></h2>
            <div class="hero-sub">
                <span class="hero-badge">
                    📅 <%= new SimpleDateFormat("EEEE, dd 'de' MMMM 'de' yyyy", new Locale("es","SV")).format(new Date()) %>
                </span>
                <span class="sep">·</span>
                <span class="hero-badge">📊 Panel de Control</span>
            </div>
        </div>
    </div>

    <div class="container-fluid px-4">

        <!-- ── FILA 1: 6 KPI ──────────────────────────────────────────── -->
        <div class="row mb-4">
            <div class="col-md-2 col-sm-6 mb-3">
                <div class="card-metrica">
                    <div class="metrica-icono bg-azul">👥</div>
                    <div class="metrica-info">
                        <h3 class="txt-azul"><%= totalClientes %></h3>
                        <p>Clientes</p>
                    </div>
                </div>
            </div>
            <div class="col-md-2 col-sm-6 mb-3">
                <div class="card-metrica">
                    <div class="metrica-icono bg-verde">🚘</div>
                    <div class="metrica-info">
                        <h3 class="txt-verde"><%= vehiculosDisponibles %></h3>
                        <p>Vehículos Disp.</p>
                    </div>
                </div>
            </div>
            <div class="col-md-2 col-sm-6 mb-3">
                <div class="card-metrica">
                    <div class="metrica-icono bg-naranja">🔑</div>
                    <div class="metrica-info">
                        <h3 class="txt-naranja"><%= alquileresActivos %></h3>
                        <p>Activos</p>
                    </div>
                </div>
            </div>
            <div class="col-md-2 col-sm-6 mb-3">
                <div class="card-metrica">
                    <div class="metrica-icono bg-rojo">📅</div>
                    <div class="metrica-info">
                        <h3 class="txt-rojo"><%= alquileresHoy %></h3>
                        <p>Tickets Hoy</p>
                    </div>
                </div>
            </div>
            <div class="col-md-2 col-sm-6 mb-3">
                <div class="card-metrica">
                    <div class="metrica-icono bg-morado">💵</div>
                    <div class="metrica-info">
                        <h3 class="txt-morado" style="font-size:22px;">$<%= String.format("%,.0f", ingresosHoy) %></h3>
                        <p>Ingresos Hoy</p>
                    </div>
                </div>
            </div>
            <div class="col-md-2 col-sm-6 mb-3">
                <div class="card-metrica">
                    <div class="metrica-icono bg-cyan">📈</div>
                    <div class="metrica-info">
                        <h3 class="txt-cyan" style="font-size:22px;">$<%= String.format("%,.0f", ingresosMes) %></h3>
                        <p>Ingresos del Mes</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- ── FILA 2: FLOTA + META + GRÁFICA DOBLE ───────────────────── -->
        <div class="row mb-4">
            <div class="col-md-2 mb-3">
                <div class="panel-card">
                    <div class="panel-titulo">🚗 Flota</div>
                    <div class="flota-label">
                        <span>Ocupados</span><span><%= totalVehiculos - vehiculosDisponibles %></span>
                    </div>
                    <div class="progress mb-3">
                        <div class="progress-bar bg-danger" style="width:<%= pctFlota %>%"><%= pctFlota %>%</div>
                    </div>
                    <div class="flota-label">
                        <span>Disponibles</span><span><%= vehiculosDisponibles %></span>
                    </div>
                    <div class="progress">
                        <div class="progress-bar bg-success" style="width:<%= 100-pctFlota %>%"><%= 100-pctFlota %>%</div>
                    </div>
                    <hr class="my-3">
                    <div class="text-center">
                        <small class="text-muted">Ingresos semana</small>
                        <div style="font-size:18px; font-weight:bold; color:#7c3aed;">
                            $<%= String.format("%,.2f", ingresosSemana) %>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-2 mb-3">
                <div class="panel-card text-center">
                    <div class="panel-titulo text-center">🎯 Meta Semanal</div>
                    <div class="meta-numero">
                        <span><%= alquileresSemana %></span>
                        <small>/ <%= metaSemanal %></small>
                    </div>
                    <div class="meta-label">tickets esta semana</div>
                    <div class="progress" style="height:22px;">
                        <div class="progress-bar <%= pctMeta>=100?"bg-success":pctMeta>=60?"bg-warning":"bg-danger" %>"
                             style="width:<%= pctMeta %>%; font-size:13px; font-weight:bold;">
                            <%= pctMeta %>%
                        </div>
                    </div>
                    <small class="text-muted mt-2 d-block">
                        <% if (pctMeta >= 100) { %>🎉 ¡Meta alcanzada!
                        <% } else { %><%= metaSemanal - alquileresSemana %> para la meta<% } %>
                    </small>

                </div>
            </div>

            <div class="col-md-8 mb-3">
                <div class="panel-card">
                    <div class="panel-titulo">📊 Últimos 7 Días — Alquileres e Ingresos</div>
                    <canvas id="graficaDoble" height="110"></canvas>
                </div>
            </div>
        </div>

        <!-- ── FILA 3: TOP VEHÍCULOS + TOP CLIENTES + ALERTAS VENCIDOS ── -->
        <div class="row mb-4">

            <!-- Top vehículos -->
            <div class="col-md-6 mb-3">
                <div class="panel-card">
                    <div class="panel-titulo">🏆 Top Vehículos del Mes</div>
                    <% if (topVehiculos.isEmpty()) { %>
                        <p class="text-muted text-center mt-3" style="font-size:13px;">Sin datos este mes</p>
                    <% } else {
                           String[] medals = {"🥇","🥈","🥉"};
                           String[] rankCls = {"rank-1","rank-2","rank-3"};
                           for (int i = 0; i < topVehiculos.size(); i++) {
                               Map<String,Object> v = topVehiculos.get(i); %>
                    <div class="rank-item">
                        <div class="rank-num <%= rankCls[i] %>"><%= medals[i] %></div>
                        <div class="rank-info">
                            <strong><%= v.get("nombre") %></strong>
                            <small><%= v.get("placa") %> · <%= v.get("alquileres") %> alquiler(es)</small>
                        </div>
                        <div class="rank-value">$<%= String.format("%,.0f", v.get("ingresos")) %></div>
                    </div>
                    <% } } %>
                </div>
            </div>

            <!-- Top clientes -->
            <div class="col-md-6 mb-3">
                <div class="panel-card">
                    <div class="panel-titulo">⭐ Top Clientes del Mes</div>
                    <% if (topClientes.isEmpty()) { %>
                        <p class="text-muted text-center mt-3" style="font-size:13px;">Sin datos este mes</p>
                    <% } else {
                           String[] medals2 = {"🥇","🥈","🥉"};
                           String[] rankCls2 = {"rank-1","rank-2","rank-3"};
                           for (int i = 0; i < topClientes.size(); i++) {
                               Map<String,Object> c = topClientes.get(i); %>
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

        <!-- ── FILA 4: PRÓXIMAS DEVOLUCIONES ──────────────────────────── -->
        <div class="panel-card mb-4">
            <div class="panel-titulo">⏰ Próximas Devoluciones (Hoy y Mañana)</div>
            <% if (proxDevoluciones.isEmpty()) { %>
                <p class="text-muted text-center mt-3">✅ No hay devoluciones pendientes para hoy ni mañana.</p>
            <% } else { %>
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead>
                        <tr>
                            <th>Ticket #</th><th>Cliente</th><th>Vehículo</th>
                            <th>Placa</th><th>Fecha Devolución</th><th>Alerta</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String,Object> f : proxDevoluciones) { %>
                        <tr>
                            <td><strong>#<%= f.get("id") %></strong></td>
                            <td><%= f.get("cliente") %></td>
                            <td><%= f.get("vehiculo") %></td>
                            <td><span class="badge badge-success"><%= f.get("placa") %></span></td>
                            <td><%= f.get("fecha") %></td>
                            <td>
                                <% if ((Boolean)f.get("esHoy")) { %>
                                    <span class="badge-hoy">🔴 Vence Hoy</span>
                                <% } else { %>
                                    <span class="badge-manana">🟡 Vence Mañana</span>
                                <% } %>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </div>

    </div><!-- /container -->

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        var ctx = document.getElementById('graficaDoble').getContext('2d');
        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: <%= labelsJs %>,
                datasets: [
                    {
                        label: 'Alquileres',
                        data: <%= alqJs %>,
                        backgroundColor: 'rgba(37,99,235,0.7)',
                        borderColor: 'rgba(37,99,235,1)',
                        borderWidth: 2,
                        yAxisID: 'y-alq',
                        order: 2
                    },
                    {
                        label: 'Ingresos ($)',
                        data: <%= ingresosJs %>,
                        type: 'line',
                        fill: false,
                        borderColor: 'rgba(22,163,74,1)',
                        backgroundColor: 'rgba(22,163,74,0.1)',
                        borderWidth: 2,
                        pointBackgroundColor: 'rgba(22,163,74,1)',
                        pointRadius: 4,
                        yAxisID: 'y-ing',
                        order: 1
                    }
                ]
            },
            options: {
                responsive: true,
                scales: {
                    yAxes: [
                        {
                            id: 'y-alq', position: 'left',
                            ticks: { beginAtZero: true, stepSize: 1, fontColor: '#2563eb' },
                            gridLines: { drawOnChartArea: true }
                        },
                        {
                            id: 'y-ing', position: 'right',
                            ticks: { beginAtZero: true, fontColor: '#16a34a',
                                     callback: function(v){ return '$'+v.toLocaleString(); } },
                            gridLines: { drawOnChartArea: false }
                        }
                    ]
                },
                legend: { position: 'top' },
                tooltips: {
                    callbacks: {
                        label: function(item, data) {
                            var label = data.datasets[item.datasetIndex].label;
                            var val   = item.yLabel;
                            return label === 'Ingresos ($)'
                                ? label + ': $' + val.toLocaleString()
                                : label + ': ' + val;
                        }
                    }
                }
            }
        });
    </script>
</body>
</html>
