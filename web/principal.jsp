<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.renta.modelos.Usuario"%>
<%@page import="com.renta.conexion.Conexion"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.LinkedHashMap"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Locale"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
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
                background: linear-gradient(135deg, #2c3e50 0%, #3d5a80 100%);
                color: white;
                padding: 35px 30px;
                margin-bottom: 25px;
            }
            .hero h2 { font-size: 30px; font-weight: bold; margin: 0 0 5px 0; }
            .hero p  { margin: 0; opacity: 0.7; font-size: 14px; }

            .card-metrica {
                border: none;
                border-radius: 12px;
                padding: 22px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.07);
                display: flex;
                align-items: center;
                gap: 18px;
                background: white;
                height: 100%;
            }
            .metrica-icono {
                font-size: 36px;
                width: 65px; height: 65px;
                border-radius: 50%;
                display: flex; align-items: center; justify-content: center;
                flex-shrink: 0;
            }
            .metrica-info h3 { font-size: 34px; font-weight: bold; margin: 0; line-height: 1; }
            .metrica-info p  { margin: 4px 0 0 0; color: #888; font-size: 13px; }

            .bg-azul    { background-color: #dbeafe; } .txt-azul    { color: #2563eb; }
            .bg-verde   { background-color: #dcfce7; } .txt-verde   { color: #16a34a; }
            .bg-naranja { background-color: #ffedd5; } .txt-naranja { color: #ea580c; }
            .bg-rojo    { background-color: #fee2e2; } .txt-rojo    { color: #dc2626; }

            .panel-card {
                background: white;
                border-radius: 12px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.07);
                padding: 22px;
                height: 100%;
            }
            .panel-titulo {
                font-size: 16px; font-weight: bold; color: #2c3e50;
                margin-bottom: 15px; padding-bottom: 10px;
                border-bottom: 2px solid #f0f0f0;
            }

            /* Barra de flota */
            .flota-label { display: flex; justify-content: space-between; font-size: 13px; color: #555; margin-bottom: 6px; }
            .progress { height: 18px; border-radius: 10px; background: #e9ecef; }
            .progress-bar { border-radius: 10px; font-size: 12px; font-weight: bold; }

            /* Meta semanal */
            .meta-numero { text-align: center; margin: 10px 0 5px; }
            .meta-numero span { font-size: 42px; font-weight: bold; color: #2563eb; }
            .meta-numero small { font-size: 18px; color: #aaa; }
            .meta-label { text-align: center; color: #888; font-size: 13px; margin-bottom: 12px; }

            /* Tabla devoluciones */
            .badge-hoy     { background: #fee2e2; color: #dc2626; padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: bold; }
            .badge-manana  { background: #fef9c3; color: #ca8a04; padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: bold; }
            table thead th { background: #2c3e50; color: white; font-size: 13px; }
            table td       { font-size: 13px; vertical-align: middle; }
        </style>
    </head>
    <body>
        <jsp:include page="menu.jsp" />

        <%
            Usuario emp = (Usuario) session.getAttribute("empleado");
            String nombre = (emp != null) ? emp.getNombreCompleto() : "Usuario";

            int totalClientes = 0, totalVehiculos = 0, alquileresActivos = 0, alquileresHoy = 0;
            int vehiculosDisponibles = 0, metaSemanal = 25, alquileresSemana = 0;

            // Datos gráfica (últimos 7 días)
            String[] diasLabels = new String[7];
            int[]    diasValores = new int[7];

            // Próximas devoluciones
            List<Map<String, Object>> proxDevoluciones = new ArrayList<>();

            Connection conn = null;
            try {
                conn = Conexion.conectar();

                // Métricas generales
                ResultSet r;
                r = conn.createStatement().executeQuery("SELECT COUNT(*) FROM Clientes");
                if (r.next()) totalClientes = r.getInt(1);

                r = conn.createStatement().executeQuery("SELECT COUNT(*) FROM Vehiculos");
                if (r.next()) totalVehiculos = r.getInt(1);

                r = conn.createStatement().executeQuery("SELECT COUNT(*) FROM Vehiculos WHERE disponible = 1");
                if (r.next()) vehiculosDisponibles = r.getInt(1);

                r = conn.createStatement().executeQuery("SELECT COUNT(*) FROM Alquileres WHERE fecha_devolucion_real IS NULL");
                if (r.next()) alquileresActivos = r.getInt(1);

                r = conn.createStatement().executeQuery("SELECT COUNT(*) FROM Alquileres WHERE CAST(fecha_alquiler AS DATE) = CAST(GETDATE() AS DATE)");
                if (r.next()) alquileresHoy = r.getInt(1);

                // Meta semanal (lunes a hoy)
                r = conn.createStatement().executeQuery(
                    "SELECT COUNT(*) FROM Alquileres WHERE fecha_alquiler >= DATEADD(DAY, 1-DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS DATE))");
                if (r.next()) alquileresSemana = r.getInt(1);

                // Gráfica últimos 7 días
                SimpleDateFormat sdfLabel = new SimpleDateFormat("dd/MM");
                Calendar cal = Calendar.getInstance();
                for (int i = 6; i >= 0; i--) {
                    Calendar dia = (Calendar) cal.clone();
                    dia.add(Calendar.DAY_OF_YEAR, -i);
                    diasLabels[6 - i] = sdfLabel.format(dia.getTime());
                }
                PreparedStatement psGraf = conn.prepareStatement(
                    "SELECT CAST(fecha_alquiler AS DATE) AS dia, COUNT(*) AS total " +
                    "FROM Alquileres " +
                    "WHERE fecha_alquiler >= DATEADD(DAY, -6, CAST(GETDATE() AS DATE)) " +
                    "GROUP BY CAST(fecha_alquiler AS DATE) ORDER BY dia");
                ResultSet rsGraf = psGraf.executeQuery();
                Map<String, Integer> grafMap = new LinkedHashMap<>();
                while (rsGraf.next()) {
                    grafMap.put(rsGraf.getString("dia"), rsGraf.getInt("total"));
                }
                SimpleDateFormat sdfDb = new SimpleDateFormat("yyyy-MM-dd");
                for (int i = 0; i < 7; i++) {
                    Calendar dia = (Calendar) cal.clone();
                    dia.add(Calendar.DAY_OF_YEAR, -(6 - i));
                    String key = sdfDb.format(dia.getTime());
                    diasValores[i] = grafMap.containsKey(key) ? grafMap.get(key) : 0;
                }

                // Próximas devoluciones (hoy y mañana)
                PreparedStatement psDev = conn.prepareStatement(
                    "SELECT a.id_alquiler, c.nombre AS cliente, " +
                    "v.marca + ' ' + v.modelo AS vehiculo, v.placa, " +
                    "a.fecha_devolucion_esperada " +
                    "FROM Alquileres a " +
                    "INNER JOIN Clientes c ON a.id_cliente = c.id_cliente " +
                    "INNER JOIN Vehiculos v ON a.id_vehiculo = v.id_vehiculo " +
                    "WHERE a.fecha_devolucion_real IS NULL " +
                    "AND CAST(a.fecha_devolucion_esperada AS DATE) <= DATEADD(DAY, 1, CAST(GETDATE() AS DATE)) " +
                    "ORDER BY a.fecha_devolucion_esperada ASC");
                ResultSet rsDev = psDev.executeQuery();
                SimpleDateFormat sdfTabla = new SimpleDateFormat("dd/MM/yyyy");
                SimpleDateFormat sdfCompare = new SimpleDateFormat("yyyyMMdd");
                String hoy = sdfCompare.format(new Date());
                while (rsDev.next()) {
                    Map<String, Object> fila = new HashMap<>();
                    fila.put("id", rsDev.getInt("id_alquiler"));
                    fila.put("cliente", rsDev.getString("cliente"));
                    fila.put("vehiculo", rsDev.getString("vehiculo"));
                    fila.put("placa", rsDev.getString("placa"));
                    java.sql.Timestamp fechaDev = rsDev.getTimestamp("fecha_devolucion_esperada");
                    fila.put("fecha", sdfTabla.format(fechaDev));
                    String diaFecha = sdfCompare.format(new Date(fechaDev.getTime()));
                    fila.put("esHoy", diaFecha.equals(hoy));
                    proxDevoluciones.add(fila);
                }

            } catch (Exception e) {
                System.err.println("Error dashboard: " + e.getMessage());
            } finally {
                try { if (conn != null) conn.close(); } catch (Exception e) {}
            }

            // Preparar datos para Chart.js
            StringBuilder labelsJs = new StringBuilder("[");
            StringBuilder valoresJs = new StringBuilder("[");
            for (int i = 0; i < 7; i++) {
                labelsJs.append("'").append(diasLabels[i]).append("'");
                valoresJs.append(diasValores[i]);
                if (i < 6) { labelsJs.append(","); valoresJs.append(","); }
            }
            labelsJs.append("]");
            valoresJs.append("]");

            int pctFlota = totalVehiculos > 0 ? (int)(((totalVehiculos - vehiculosDisponibles) * 100.0) / totalVehiculos) : 0;
            int pctMeta  = (int)((alquileresSemana * 100.0) / metaSemanal);
            if (pctMeta > 100) pctMeta = 100;
        %>

        <!-- HERO -->
        <div class="hero">
            <div class="container-fluid">
                <h2>👋 Bienvenido, <%= nombre %>!</h2>
                <p>Panel de Control &nbsp;·&nbsp; <%= new SimpleDateFormat("EEEE, dd 'de' MMMM 'de' yyyy", new Locale("es","SV")).format(new Date()) %></p>
            </div>
        </div>

        <div class="container-fluid px-4">

            <!-- MÉTRICAS -->
            <div class="row mb-4">
                <div class="col-md-3 col-sm-6 mb-3">
                    <div class="card-metrica">
                        <div class="metrica-icono bg-azul">👥</div>
                        <div class="metrica-info">
                            <h3 class="txt-azul"><%= totalClientes %></h3>
                            <p>Total Clientes</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6 mb-3">
                    <div class="card-metrica">
                        <div class="metrica-icono bg-verde">🚘</div>
                        <div class="metrica-info">
                            <h3 class="txt-verde"><%= vehiculosDisponibles %></h3>
                            <p>Vehículos Disponibles</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6 mb-3">
                    <div class="card-metrica">
                        <div class="metrica-icono bg-naranja">🔑</div>
                        <div class="metrica-info">
                            <h3 class="txt-naranja"><%= alquileresActivos %></h3>
                            <p>Alquileres Activos</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6 mb-3">
                    <div class="card-metrica">
                        <div class="metrica-icono bg-rojo">📅</div>
                        <div class="metrica-info">
                            <h3 class="txt-rojo"><%= alquileresHoy %></h3>
                            <p>Alquileres de Hoy</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- FILA 2: FLOTA + META + GRÁFICA -->
            <div class="row mb-4">

                <!-- Barra de flota -->
                <div class="col-md-3 mb-3">
                    <div class="panel-card">
                        <div class="panel-titulo">🚗 Estado de Flota</div>
                        <div class="flota-label">
                            <span>Ocupados: <%= totalVehiculos - vehiculosDisponibles %></span>
                            <span>Total: <%= totalVehiculos %></span>
                        </div>
                        <div class="progress mb-3">
                            <div class="progress-bar bg-danger" style="width: <%= pctFlota %>%"><%= pctFlota %>%</div>
                        </div>
                        <div class="flota-label">
                            <span>Disponibles: <%= vehiculosDisponibles %></span>
                            <span><%= pctFlota %>% ocupado</span>
                        </div>
                        <div class="progress">
                            <div class="progress-bar bg-success" style="width: <%= 100 - pctFlota %>%"><%= 100 - pctFlota %>%</div>
                        </div>
                    </div>
                </div>

                <!-- Meta semanal -->
                <div class="col-md-3 mb-3">
                    <div class="panel-card text-center">
                        <div class="panel-titulo text-center">🎯 Meta Semanal</div>
                        <div class="meta-numero">
                            <span><%= alquileresSemana %></span>
                            <small>/ <%= metaSemanal %></small>
                        </div>
                        <div class="meta-label">alquileres esta semana</div>
                        <div class="progress" style="height:22px;">
                            <div class="progress-bar <%= pctMeta >= 100 ? "bg-success" : pctMeta >= 60 ? "bg-warning" : "bg-danger" %>"
                                 style="width: <%= pctMeta %>%; font-size:13px; font-weight:bold;">
                                <%= pctMeta %>%
                            </div>
                        </div>
                        <small class="text-muted mt-2 d-block">
                            <% if (pctMeta >= 100) { %>🎉 ¡Meta alcanzada!
                            <% } else { %><%= metaSemanal - alquileresSemana %> alquileres para la meta<% } %>
                        </small>
                    </div>
                </div>

                <!-- Gráfica -->
                <div class="col-md-6 mb-3">
                    <div class="panel-card">
                        <div class="panel-titulo">📊 Alquileres — Últimos 7 Días</div>
                        <canvas id="graficaAlquileres" height="130"></canvas>
                    </div>
                </div>

            </div>

            <!-- FILA 3: PRÓXIMAS DEVOLUCIONES -->
            <div class="panel-card mb-4">
                <div class="panel-titulo">⏰ Próximas Devoluciones (Hoy y Mañana)</div>
                <% if (proxDevoluciones.isEmpty()) { %>
                    <p class="text-muted text-center mt-3">✅ No hay devoluciones pendientes para hoy ni mañana.</p>
                <% } else { %>
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Cliente</th>
                                <th>Vehículo</th>
                                <th>Placa</th>
                                <th>Fecha Devolución</th>
                                <th>Alerta</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Map<String, Object> fila : proxDevoluciones) { %>
                            <tr>
                                <td><%= fila.get("id") %></td>
                                <td><%= fila.get("cliente") %></td>
                                <td><%= fila.get("vehiculo") %></td>
                                <td><%= fila.get("placa") %></td>
                                <td><%= fila.get("fecha") %></td>
                                <td>
                                    <% if ((Boolean) fila.get("esHoy")) { %>
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

        </div>

        <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            var ctx = document.getElementById('graficaAlquileres').getContext('2d');
            new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: <%= labelsJs %>,
                    datasets: [{
                        label: 'Alquileres',
                        data: <%= valoresJs %>,
                        backgroundColor: 'rgba(37, 99, 235, 0.7)',
                        borderColor: 'rgba(37, 99, 235, 1)',
                        borderWidth: 2,
                        borderRadius: 6
                    }]
                },
                options: {
                    responsive: true,
                    legend: { display: false },
                    scales: {
                        yAxes: [{ ticks: { beginAtZero: true, stepSize: 1 } }]
                    }
                }
            });
        </script>
    </body>
</html>