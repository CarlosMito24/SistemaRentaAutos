<%@page import="com.renta.datos.ClienteDAO"%>
<%@page import="com.renta.modelos.Cliente"%>
<%@page import="com.renta.datos.VehiculoDAO"%>
<%@page import="com.renta.modelos.Vehiculo"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.renta.datos.AlquilerDAO"%>

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
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registrar Alquiler - Renta de Autos ITCA</title>
    <link rel="icon" href="img/login.jpg" type="image/jpeg">

    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">

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
        .panel-titulo {
            font-size: 20px;
            font-weight: 700;
            color: var(--primary);
            margin-bottom: 20px;
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

        /* ── FORMULARIOS ── */
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
            height: auto;
        }
        .form-control:focus {
            background: #ffffff;
            border-color: var(--accent);
            color: var(--text-dark);
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.15);
        }
        .form-control.input-readonly {
            background-color: #e9ecef !important;
            font-weight: bold;
            color: var(--primary);
        }

        /* ── TABLAS ── */
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
    </style>
</head>
<body>

    <jsp:include page="menu.jsp" />

    <div class="container-fluid px-4 py-4">
        
        <div class="page-header">
            <h1 class="page-title">Procesar <span>Alquileres</span></h1>
        </div>

        <div class="row justify-content-center">
            <div class="col-md-12">
                
                <div class="panel-card">
                    <h3 class="panel-titulo"><i class="fas fa-file-signature mr-2"></i> Registrar un nuevo alquiler</h3>
                    <hr class="mb-4">

                    <form action="AlquilerServlet" method="POST" onsubmit="return validarEnvioGeneral()">
                        
                        <div class="row">
                            <div class="col-md-6 form-group">
                                <label>Cliente:</label>
                                <select name="txtIdCliente" id="selectCliente" class="form-control" required>
                                    <option value="">Seleccione un cliente...</option>
                                    <% for (Cliente c : new ClienteDAO().listarClientes()) {%>
                                        <option value="<%= c.getIdCliente()%>"><%= c.getNombre()%></option>
                                    <% } %>
                                </select>
                            </div>

                            <div class="col-md-6 form-group">
                                <label>Vehículo a Agregar:</label>
                                <select id="selectVehiculo" class="form-control" onchange="calcularTotal()">
                                    <%
                                        VehiculoDAO vdao = new VehiculoDAO();
                                        java.util.List<Vehiculo> lista = vdao.listarVehiculosDisponibles();
                                        if (lista.isEmpty()) { 
                                    %>
                                        <option value="">No hay vehículos disponibles</option>
                                    <% } else { %>
                                        <option value="">Seleccione un vehículo...</option>
                                        <% for (Vehiculo v : lista) {%>
                                            <option value="<%= v.getIdVehiculo()%>" data-precio="<%= v.getPrecioDiario()%>">
                                                <%= v.getMarca() + " " + v.getModelo() + " (" + v.getPlaca() + ") - $" + v.getPrecioDiario() + "/día"%>
                                            </option>
                                        <% } %>
                                    <% }%>
                                </select>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-3 form-group">
                                <label>Fecha de Entrega:</label>
                                <input type="date" id="txtFechaInicio" class="form-control" onchange="calcularTotal()">
                            </div>
                            <div class="col-md-3 form-group">
                                <label>Hora de Entrega:</label>
                                <input type="time" id="txtHoraInicio" class="form-control" onchange="calcularTotal()">
                            </div>
                            <div class="col-md-3 form-group">
                                <label>Fecha Devolución:</label>
                                <input type="date" id="txtFechaFin" class="form-control" onchange="calcularTotal()">
                            </div>
                            <div class="col-md-3 form-group">
                                <label>Hora Devolución:</label>
                                <input type="time" id="txtHoraFin" class="form-control" onchange="calcularTotal()">
                            </div>
                        </div>

                        <div class="row align-items-end mt-2">
                            <div class="col-md-4 offset-md-8 form-group">
                                <label>Total Estimado ($):</label>
                                <input type="number" step="0.01" id="txtTotal" class="form-control input-readonly" readonly>
                            </div>
                        </div>

                        <div class="text-right mb-4">
                            <button type="button" class="btn btn-outline-primary-custom" onclick="agregarAlCarrito()">
                                <i class="fas fa-plus-circle mr-1"></i> Añadir 
                            </button>
                        </div>

                        <h5 class="font-weight-bold text-primary mt-4 mb-3"><i class="fas fa-shopping-cart mr-2"></i> Resumen del Alquiler</h5>
                        
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover text-center">
                                <thead>
                                    <tr>
                                        <th>Vehículo</th>
                                        <th>Entrega</th>
                                        <th>Devolución</th>
                                        <th>Subtotal</th>
                                        <th>Acción</th>
                                    </tr>
                                </thead>
                                <tbody id="carritoBody">
                                    </tbody>
                                <tfoot class="bg-light">
                                    <tr>
                                        <th colspan="3" class="text-right text-dark" style="font-size: 1.1rem; vertical-align: middle;">TOTAL FINAL:</th>
                                        <th class="text-success font-weight-bold" style="font-size: 1.3rem;">$<span id="lblGranTotal">0.00</span></th>
                                        <th></th>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>

                        <div id="contenedorInputsOcultos"></div>

                        <div class="text-center mt-5">
                            <button type="submit" class="btn btn-custom-accent btn-lg px-5 py-3">
                                <i class="fas fa-print mr-2"></i> Procesar 
                            </button>
                        </div>
                    </form>
                </div>
                
                <div class="panel-card">
                    <h3 class="panel-titulo"><i class="fas fa-undo-alt mr-2"></i> Vehículos Pendientes de Devolución</h3>
                    <hr class="mb-4">
                    
                    <div class="table-responsive">
                        <table class="table table-hover table-bordered text-center">
                            <thead>
                                <tr>
                                    <th># Ticket</th>
                                    <th>Cliente</th>
                                    <th>Vehículo</th>
                                    <th>Fecha de Salida</th>
                                    <th>Retorno Esperado</th>
                                    <th>Total Abonado</th>
                                    <th>Acción</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    AlquilerDAO adao = new AlquilerDAO();
                                    java.util.List<java.util.Map<String, Object>> pendientes = adao.listarPendientes();
                                    
                                    if(pendientes.isEmpty()) {
                                %>
                                    <tr>
                                        <td colspan="7" class="text-muted py-4">No hay vehículos pendientes de devolución.</td>
                                    </tr>
                                <%  } else { 
                                        for (java.util.Map<String, Object> p : pendientes) {
                                %>
                                    <tr>
                                        <td class="font-weight-bold text-primary">#<%= p.get("id_ticket") %></td>
                                        <td><%= p.get("cliente") %></td>
                                        <td><%= p.get("vehiculo") %></td>
                                        <td><span class="badge badge-info px-2 py-1"><%= p.get("fecha_entrega") %></span></td>
                                        <td><span class="badge badge-warning px-2 py-1"><%= p.get("fecha_esperada") %></span></td>
                                        <td class="text-success font-weight-bold">$<%= String.format("%.2f", p.get("total_linea")) %></td>
                                        <td>
                                            <button class="btn btn-sm btn-outline-primary-custom" onclick="procesarDevolucion(<%= p.get("id_detalle") %>, '<%= p.get("fecha_entrega_raw") %>', '<%= p.get("fecha_esperada_raw") %>', <%= p.get("total_linea") %>)">
                                                <i class="fas fa-check-circle mr-1"></i> Devolver
                                            </button>
                                        </td>
                                    </tr>
                                <%      } 
                                    } 
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <div class="modal fade" id="modalDevolucion" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fas fa-car-side mr-2"></i> Procesar Devolución</h5>
                    <button type="button" class="close text-white" data-dismiss="modal" aria-label="Cerrar">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <form action="DevolucionServlet" method="POST">
                    <div class="modal-body">
                        <input type="hidden" id="modalIdDetalle" name="idDetalle">

                        <div class="form-group">
                            <label>Devolución Acordada:</label>
                            <input type="datetime-local" class="form-control input-readonly" id="modalFechaEsperada" readonly>
                        </div>

                        <div class="form-group">
                            <label class="text-primary">Fecha y Hora Real de Entrega:</label>
                            <input type="datetime-local" class="form-control" id="modalFechaReal" name="fechaReal" onchange="calcularMoraModal()" required>
                            <small class="form-text text-muted mt-2">Ajuste manualmente si es necesario.</small>
                        </div>

                        <hr class="my-4">
                        <input type="hidden" id="modalTotalFinal" name="totalFinal">
                        
                        <div class="row">
                            <div class="col-md-6 form-group">
                                <label>Subtotal (Ya Cancelado):</label>
                                <input type="number" class="form-control input-readonly" id="modalSubtotal" readonly>
                            </div>
                            <div class="col-md-6 form-group">
                                <label class="text-danger">Mora por Retraso ($):</label>
                                <input type="number" step="0.01" class="form-control text-danger font-weight-bold input-readonly" id="modalMora" name="mora" readonly>
                            </div>
                        </div>

                        <div class="form-group mb-0 mt-3 p-3 bg-light rounded text-center border">
                            <label class="text-success mb-1" style="font-size: 1.1rem;">A COBRAR HOY ($):</label>
                            <input type="number" step="0.01" class="form-control text-success font-weight-bold text-center border-0 bg-transparent" style="font-size: 2rem; padding: 0;" id="modalCobrarHoy" readonly>
                        </div>
                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary" style="font-weight: 600;" data-dismiss="modal">CANCELAR</button>
                        <button type="submit" class="btn btn-custom-accent">CONFIRMAR ENTRADA</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            let hoy = new Date().toISOString().split('T')[0];
            document.getElementById("txtFechaInicio").setAttribute('min', hoy);
            document.getElementById("txtFechaFin").setAttribute('min', hoy);
        });

        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.has('msg')) {
            Swal.fire({
                title: '¡Éxito!',
                text: urlParams.get('msg'),
                icon: 'success',
                confirmButtonColor: '#3b82f6',
                confirmButtonText: 'Aceptar'
            });
        } else if (urlParams.has('error')) {
            Swal.fire({
                title: '¡Error!',
                text: urlParams.get('error'),
                icon: 'error',
                confirmButtonColor: '#3b82f6',
                confirmButtonText: 'Aceptar'
            });
        }

        window.onload = function() {
            const downloadId = urlParams.get('downloadId');
            const downloadDevolucionId = urlParams.get('downloadDevolucionId');
            
            if (downloadId) {
                window.open('ComprobanteServlet?id=' + downloadId, '_blank');
            } else if (downloadDevolucionId) {
                window.open('ComprobanteDevolucionServlet?id=' + downloadDevolucionId, '_blank');
            }
        };

        function calcularTotal() {
            const select = document.getElementById('selectVehiculo');
            const fechaInicio = document.getElementById('txtFechaInicio').value;
            const horaInicio = document.getElementById('txtHoraInicio').value;
            const fechaFin = document.getElementById('txtFechaFin').value;
            const horaFin = document.getElementById('txtHoraFin').value;
            const inputTotal = document.getElementById('txtTotal');

            if(fechaInicio) {
                document.getElementById("txtFechaFin").setAttribute('min', fechaInicio);
            }

            if (fechaInicio && horaInicio && fechaFin && horaFin) {
                const arrFI = fechaInicio.split('-');
                const arrHI = horaInicio.split(':');
                const dateInicio = new Date(arrFI[0], arrFI[1] - 1, arrFI[2], arrHI[0], arrHI[1]);

                const arrFF = fechaFin.split('-');
                const arrHF = horaFin.split(':');
                const dateFin = new Date(arrFF[0], arrFF[1] - 1, arrFF[2], arrHF[0], arrHF[1]);

                if (dateFin <= dateInicio) {
                    Swal.fire({
                        title: '¡Cuidado!',
                        text: 'La fecha y hora de devolución deben ser posteriores a la entrega.',
                        icon: 'warning',
                        confirmButtonColor: '#3b82f6'
                    });
                    document.getElementById('txtHoraFin').value = ''; 
                    inputTotal.value = ''; 
                    return; 
                }

                let precioAttr = select.options[select.selectedIndex].getAttribute('data-precio');
                let precioDiario = parseFloat(precioAttr);

                if (isNaN(precioDiario)) precioDiario = 0;

                if (precioDiario > 0) {
                    const diffTime = Math.abs(dateFin - dateInicio);
                    const diffHours = Math.ceil(diffTime / (1000 * 60 * 60)); 
                    const diasCompletos = Math.floor(diffHours / 24);
                    const horasSueltas = diffHours % 24;

                    const tarifaPorHora = 5.00;
                    let costoHoras = horasSueltas * tarifaPorHora;
                    if(costoHoras > precioDiario) costoHoras = precioDiario;

                    const totalEstimado = (diasCompletos * precioDiario) + costoHoras;
                    inputTotal.value = totalEstimado.toFixed(2);
                } else {
                    inputTotal.value = "";
                }
            }
        }

        let granTotal = 0.0;
        let contadorVehiculos = 0;

        function agregarAlCarrito() {
            const select = document.getElementById('selectVehiculo');
            const idVehiculo = select.value;
            const textoVehiculo = select.options[select.selectedIndex].text;
            
            const fInicio = document.getElementById('txtFechaInicio').value;
            const hInicio = document.getElementById('txtHoraInicio').value;
            const fFin = document.getElementById('txtFechaFin').value;
            const hFin = document.getElementById('txtHoraFin').value;
            const subtotal = document.getElementById('txtTotal').value;

            if (!idVehiculo || !fInicio || !hInicio || !fFin || !hFin || !subtotal) {
                Swal.fire({
                    title: 'Atención',
                    text: 'Complete todos los campos del vehículo y espere a que se calcule el estimado.',
                    icon: 'warning',
                    confirmButtonColor: '#3b82f6'
                });
                return;
            }

            contadorVehiculos++;

            const filaHtml = '<tr id="fila_' + contadorVehiculos + '">' +
                '<td>' + textoVehiculo + '</td>' +
                '<td>' + fInicio + ' ' + hInicio + '</td>' +
                '<td>' + fFin + ' ' + hFin + '</td>' +
                '<td class="font-weight-bold text-dark">$' + parseFloat(subtotal).toFixed(2) + '</td>' +
                '<td>' +
                    '<button type="button" class="btn btn-sm btn-outline-danger-custom" onclick="quitarDelCarrito(' + contadorVehiculos + ', ' + subtotal + ')"><i class="fas fa-trash"></i></button>' +
                '</td>' +
            '</tr>';
            
            document.getElementById('carritoBody').insertAdjacentHTML('beforeend', filaHtml);

            const inputsOcultosHtml = '<div id="ocultos_' + contadorVehiculos + '">' +
                '<input type="hidden" name="txtIdVehiculo[]" value="' + idVehiculo + '">' +
                '<input type="hidden" name="txtFechaInicio[]" value="' + fInicio + '">' +
                '<input type="hidden" name="txtHoraInicio[]" value="' + hInicio + '">' +
                '<input type="hidden" name="txtFechaFin[]" value="' + fFin + '">' +
                '<input type="hidden" name="txtHoraFin[]" value="' + hFin + '">' +
                '<input type="hidden" name="txtTotalLinea[]" value="' + subtotal + '">' +
            '</div>';
            
            document.getElementById('contenedorInputsOcultos').insertAdjacentHTML('beforeend', inputsOcultosHtml);

            granTotal += parseFloat(subtotal);
            document.getElementById('lblGranTotal').innerText = granTotal.toFixed(2);
            
            document.getElementById('txtFechaInicio').value = '';
            document.getElementById('txtHoraInicio').value = '';
            document.getElementById('txtFechaFin').value = '';
            document.getElementById('txtHoraFin').value = '';
            document.getElementById('txtTotal').value = '';
            select.selectedIndex = 0;
        }

        function quitarDelCarrito(idFila, monto) {
            document.getElementById('fila_' + idFila).remove();
            document.getElementById('ocultos_' + idFila).remove();
            granTotal -= parseFloat(monto);
            document.getElementById('lblGranTotal').innerText = Math.max(0, granTotal).toFixed(2);
        }

        function validarEnvioGeneral() {
            const cliente = document.getElementById('selectCliente').value;
            if (cliente === "") {
                Swal.fire({
                    title: 'Error',
                    text: 'Debe seleccionar un cliente.',
                    icon: 'error',
                    confirmButtonColor: '#3b82f6'
                });
                return false; 
            }
            if (contadorVehiculos === 0 || granTotal <= 0) {
                Swal.fire({
                    title: 'Error',
                    text: 'El carrito está vacío. Añada al menos un vehículo al ticket.',
                    icon: 'error',
                    confirmButtonColor: '#3b82f6'
                });
                return false; 
            }
            return true;
        }

        function procesarDevolucion(idDetalle, fechaEntregaRaw, fechaEsperadaRaw, subtotal) {
            document.getElementById('modalIdDetalle').value = idDetalle;
            document.getElementById('modalSubtotal').value = subtotal;
            document.getElementById('modalFechaEsperada').value = fechaEsperadaRaw;

            document.getElementById('modalFechaReal').setAttribute('min', fechaEsperadaRaw);

            const ahora = new Date();
            ahora.setMinutes(ahora.getMinutes() - ahora.getTimezoneOffset());
            const fechaActualRaw = ahora.toISOString().slice(0,16); 
            
            if (fechaActualRaw < fechaEsperadaRaw) {
                document.getElementById('modalFechaReal').value = fechaEsperadaRaw;
            } else {
                document.getElementById('modalFechaReal').value = fechaActualRaw;
            }

            calcularMoraModal();
            $('#modalDevolucion').modal('show');
        }

        function calcularMoraModal() {
            const esperadaStr = document.getElementById('modalFechaEsperada').value;
            const realStr = document.getElementById('modalFechaReal').value;
            const subtotal = parseFloat(document.getElementById('modalSubtotal').value);

            if(!esperadaStr || !realStr) return;

            const dateEsperada = new Date(esperadaStr);
            const dateReal = new Date(realStr);

            let mora = 0.0;
            const diffMilis = dateReal - dateEsperada;

            if (diffMilis > 0) {
                const horasTarde = Math.ceil(diffMilis / (1000 * 60 * 60));
                mora = horasTarde * 6.25;
            }

            const totalFinalDB = subtotal + mora; 

            document.getElementById('modalMora').value = mora.toFixed(2);
            document.getElementById('modalCobrarHoy').value = mora.toFixed(2); 
            document.getElementById('modalTotalFinal').value = totalFinalDB.toFixed(2); 
        }
    </script>
</body>
</html>