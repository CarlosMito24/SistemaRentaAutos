<%@page import="com.renta.datos.ClienteDAO"%>
<%@page import="com.renta.modelos.Cliente"%>
<%@page import="com.renta.datos.VehiculoDAO"%>
<%@page import="com.renta.modelos.Vehiculo"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.renta.datos.AlquilerDAO"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registrar Alquiler - Proyecto de POO</title>

    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
    
    <style>
        body {
            background-color: #f4f7f6;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .dashboard-header {
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
            color: white;
            padding: 20px 0;
            border-bottom: 4px solid #3b82f6; 
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .card-custom {
            border: none;
            border-radius: 12px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
            background-color: #ffffff;
        }
        .table-custom {
            border-radius: 8px;
            overflow: hidden;
        }
        .table-custom thead th {
            background-color: #1e293b;
            color: #ffffff;
            border: none;
        }
        .btn-modern {
            border-radius: 6px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .modal-header-custom {
            background-color: #1e293b;
            color: white;
            border-bottom: 3px solid #f59e0b;
        }
        .input-readonly {
            background-color: #e9ecef !important;
            font-weight: bold;
        }
    </style>
</head>
<body>

    <jsp:include page="menu.jsp" />

    <div class="container-fluid p-3">
        <h1 class="text-center my-4">Registrar Nuevo Alquiler</h1>

        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card card-custom shadow-sm mb-5">
                    <div class="card-body">
                        
                        <form action="AlquilerServlet" method="POST" onsubmit="return validarEnvioGeneral()">
                            
                            <div class="row">
                                <div class="col-md-6 form-group">
                                    <label class="font-weight-bold">Cliente:</label>
                                    <select name="txtIdCliente" id="selectCliente" class="form-control" required>
                                        <option value="">Seleccione un cliente...</option>
                                        <% for (Cliente c : new ClienteDAO().listarClientes()) {%>
                                            <option value="<%= c.getIdCliente()%>"><%= c.getNombre()%></option>
                                        <% } %>
                                    </select>
                                </div>

                                <div class="col-md-6 form-group">
                                    <label class="font-weight-bold">Vehículo a Agregar:</label>
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

                            <div class="row">
                                <div class="col-md-4 offset-md-8 form-group">
                                    <label class="font-weight-bold">Total Estimado Línea ($):</label>
                                    <input type="number" step="0.01" id="txtTotal" class="form-control input-readonly" readonly>
                                </div>
                            </div>

                            <div class="text-right mt-3">
                                <button type="button" class="btn btn-primary btn-modern" onclick="agregarAlCarrito()">
                                    <i class="fas fa-plus-circle"></i> Añadir 
                                </button>
                            </div>

                            <hr class="my-4">
                            <h5 class="text-secondary"><i class="fas fa-shopping-cart"></i> Resumen del alquiler actual</h5>
                            <div class="table-responsive">
                                <table class="table table-sm table-bordered table-custom text-center mt-2">
                                    <thead class="bg-light">
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
                                    <tfoot>
                                        <tr>
                                            <th colspan="3" class="text-right text-success" style="font-size: 1.2rem;">Total final:</th>
                                            <th class="text-success font-weight-bold" style="font-size: 1.2rem;">$<span id="lblGranTotal">0.00</span></th>
                                            <th></th>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>

                            <div id="contenedorInputsOcultos"></div>

                            <div class="text-center mt-4">
                                <button type="submit" class="btn btn-success btn-lg btn-modern btn-block shadow-sm">
                                    <i class="fas fa-print"></i> Procesar 
                                </button>
                            </div>
                        </form>

                    </div>
                </div>
            </div>
        </div>
        
        <hr class="my-5">
        <h2 class="text-center mb-4">Vehículos Pendientes de Devolución</h2>
        
        <div class="card card-custom shadow-sm mb-5">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover table-striped table-bordered text-center table-custom">
                        <thead class="thead-dark">
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
                                    <td colspan="7" class="text-muted">No hay vehículos pendientes de devolución.</td>
                                </tr>
                            <%  } else { 
                                    for (java.util.Map<String, Object> p : pendientes) {
                            %>
                                <tr>
                                    <td class="font-weight-bold"><%= p.get("id_ticket") %></td>
                                    <td><%= p.get("cliente") %></td>
                                    <td><%= p.get("vehiculo") %></td>
                                    <td><span class="badge badge-info"><%= p.get("fecha_entrega") %></span></td>
                                    <td><span class="badge badge-warning"><%= p.get("fecha_esperada") %></span></td>
                                    <td class="text-success font-weight-bold">$<%= String.format("%.2f", p.get("total_linea")) %></td>
                                    <td>
                                        <button class="btn btn-sm btn-warning btn-modern text-dark" onclick="procesarDevolucion(<%= p.get("id_detalle") %>, '<%= p.get("fecha_entrega_raw") %>', '<%= p.get("fecha_esperada_raw") %>', <%= p.get("total_linea") %>)">
                                            <i class="fas fa-undo-alt"></i> Devolución
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

    <div class="modal fade" id="modalDevolucion" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content card-custom">
                <div class="modal-header modal-header-custom">
                    <h5 class="modal-title"><i class="fas fa-car-side mr-2"></i> Procesar Devolución</h5>
                    <button type="button" class="close text-white" data-dismiss="modal" aria-label="Cerrar">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <form action="DevolucionServlet" method="POST">
                    <div class="modal-body p-4">
                        <input type="hidden" id="modalIdDetalle" name="idDetalle">

                        <div class="form-group">
                            <label class="font-weight-bold text-muted">Devolución Acordada:</label>
                            <input type="datetime-local" class="form-control input-readonly" id="modalFechaEsperada" readonly>
                        </div>

                        <div class="form-group">
                            <label class="font-weight-bold text-primary">Fecha y Hora Real de Entrega:</label>
                            <input type="datetime-local" class="form-control" id="modalFechaReal" name="fechaReal" onchange="calcularMoraModal()" required>
                            <small class="form-text text-muted">Ajuste manualmente si es necesario.</small>
                        </div>

                        <hr>
                        <input type="hidden" id="modalTotalFinal" name="totalFinal">
                        
                        <div class="row">
                            <div class="col-md-6 form-group">
                                <label class="font-weight-bold text-muted">Subtotal (Ya Cancelado):</label>
                                <input type="number" class="form-control input-readonly" id="modalSubtotal" readonly>
                            </div>
                            <div class="col-md-6 form-group">
                                <label class="font-weight-bold text-danger">Mora por Retraso ($):</label>
                                <input type="number" step="0.01" class="form-control text-danger font-weight-bold input-readonly" id="modalMora" name="mora" readonly>
                            </div>
                        </div>

                        <div class="form-group mb-0">
                            <label class="font-weight-bold text-success" style="font-size: 1.2rem;">A Cobrar HOY ($):</label>
                            <input type="number" step="0.01" class="form-control text-success font-weight-bold input-readonly" style="font-size: 1.5rem;" id="modalCobrarHoy" readonly>
                        </div>
                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary btn-modern" data-dismiss="modal">Cancelar</button>
                        <button type="submit" class="btn btn-success btn-modern"><i class="fas fa-check-circle"></i> Confirmar Entrada</button>
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
            Swal.fire('¡Éxito!', urlParams.get('msg'), 'success');
        } else if (urlParams.has('error')) {
            Swal.fire('¡Error!', urlParams.get('error'), 'error');
        }

        window.onload = function() {
            const downloadId = urlParams.get('downloadId');
            const downloadDevolucionId = urlParams.get('downloadDevolucionId');
            
            if (downloadId) {
                window.open('ComprobanteServlet?id=' + downloadId, '_blank');
            } else if (downloadDevolucionId) {
                // Abre el nuevo comprobante de devolución
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
                    Swal.fire('¡Cuidado!', 'La fecha y hora de devolución deben ser posteriores a la entrega.', 'warning');
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
                Swal.fire('Atención', 'Complete todos los campos del vehículo y espere a que se calcule el estimado.', 'warning');
                return;
            }

            contadorVehiculos++;

            const filaHtml = '<tr id="fila_' + contadorVehiculos + '">' +
                '<td>' + textoVehiculo + '</td>' +
                '<td>' + fInicio + ' ' + hInicio + '</td>' +
                '<td>' + fFin + ' ' + hFin + '</td>' +
                '<td class="font-weight-bold">$' + parseFloat(subtotal).toFixed(2) + '</td>' +
                '<td>' +
                    '<button type="button" class="btn btn-sm btn-danger" onclick="quitarDelCarrito(' + contadorVehiculos + ', ' + subtotal + ')"><i class="fas fa-trash"></i></button>' +
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
                Swal.fire('Error', 'Debe seleccionar un cliente.', 'error');
                return false; 
            }
            if (contadorVehiculos === 0 || granTotal <= 0) {
                Swal.fire('Error', 'El carrito está vacío. Añada al menos un vehículo al ticket.', 'error');
                return false; 
            }
            return true;
        }

        function procesarDevolucion(idDetalle, fechaEntregaRaw, fechaEsperadaRaw, subtotal) {
            document.getElementById('modalIdDetalle').value = idDetalle;
            document.getElementById('modalSubtotal').value = subtotal;
            document.getElementById('modalFechaEsperada').value = fechaEsperadaRaw;

            // 1. Bloqueamos para que NO se pueda elegir una fecha menor a la ACORDADA
            document.getElementById('modalFechaReal').setAttribute('min', fechaEsperadaRaw);

            // 2. Extraemos la hora exacta del sistema
            const ahora = new Date();
            ahora.setMinutes(ahora.getMinutes() - ahora.getTimezoneOffset());
            const fechaActualRaw = ahora.toISOString().slice(0,16); 
            
            // 3. Lógica de protección: Si la hora actual es antes de la fecha acordada,
            // forzamos al input a empezar desde la fecha acordada para evitar errores.
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