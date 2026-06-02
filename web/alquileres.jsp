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
        <title>Registrar Alquiler</title>

        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
    </head>
    <body class="bg-light">

        <jsp:include page="menu.jsp" />

        <div class="container-fluid p-3">
            <h1 class="text-center my-4">Registrar Nuevo Alquiler</h1>

            <div class="row justify-content-center">
                <div class="col-md-8">
                    <div class="card shadow-sm">
                        <div class="card-body">
                            
                            <form action="AlquilerServlet" method="POST" onsubmit="return validarFormulario()">
                                <div class="row">
                                    <div class="col-md-6 form-group">
                                        <label>Cliente:</label>
                                        <select name="txtIdCliente" class="form-control" required>
                                            <option value="">Seleccione un cliente...</option>
                                            <% for (Cliente c : new ClienteDAO().listarClientes()) {%>
                                            <option value="<%= c.getIdCliente()%>"><%= c.getNombre()%></option>
                                            <% } %>
                                        </select>
                                    </div>

                                    <div class="col-md-6 form-group">
                                        <label>Vehículo:</label>
                                        <select name="txtIdVehiculo" id="selectVehiculo" class="form-control" onchange="calcularTotal()" required>
                                            <%
                                                VehiculoDAO vdao = new VehiculoDAO();
                                                java.util.List<Vehiculo> lista = vdao.listarVehiculosDisponibles();
                                                if (lista.isEmpty()) { %>
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
                                        <input type="date" name="txtFechaInicio" id="txtFechaInicio" class="form-control" onchange="calcularTotal()" required>
                                    </div>
                                    <div class="col-md-3 form-group">
                                        <label>Hora de Entrega:</label>
                                        <input type="time" name="txtHoraInicio" id="txtHoraInicio" class="form-control" onchange="calcularTotal()" required>
                                    </div>

                                    <div class="col-md-3 form-group">
                                        <label>Fecha Devolución:</label>
                                        <input type="date" name="txtFechaFin" id="txtFechaFin" class="form-control" onchange="calcularTotal()" required>
                                    </div>
                                    <div class="col-md-3 form-group">
                                        <label>Hora Devolución:</label>
                                        <input type="time" name="txtHoraFin" id="txtHoraFin" class="form-control" onchange="calcularTotal()" required>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-4 offset-md-8 form-group">
                                        <label>Total Estimado ($):</label>
                                        <input type="number" step="0.01" name="txtTotal" id="txtTotal" class="form-control" readonly required>
                                    </div>
                                </div>

                                <div class="text-right mt-3">
                                    <a href="principal.jsp" class="btn btn-secondary">Cancelar</a>
                                    <button type="submit" class="btn btn-primary">Confirmar Alquiler</button>
                                </div>
                            </form>

                        </div>
                    </div>
                </div>
            </div>
        </div>
        <hr class="my-5">
            <h2 class="text-center mb-4">Vehículos Pendientes de Devolución</h2>
            
            <div class="card shadow-sm mb-5">
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-hover table-striped table-bordered text-center">
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
                                        <td colspan="7" class="text-muted">No hay vehículos pendientes de devolución en este momento.</td>
                                    </tr>
                                <%  } else { 
                                        for (java.util.Map<String, Object> p : pendientes) {
                                %>
                                    <tr>
                                        <td class="font-weight-bold"><%= p.get("id_alquiler") %></td>
                                        <td><%= p.get("cliente") %></td>
                                        <td><%= p.get("vehiculo") %></td>
                                        <td><span class="badge badge-info"><%= p.get("fecha_entrega") %></span></td>
                                        <td><span class="badge badge-warning"><%= p.get("fecha_esperada") %></span></td>
                                        <td class="text-success font-weight-bold">$<%= String.format("%.2f", p.get("total_pago")) %></td>
                                        <td>
                                            <button class="btn btn-sm btn-success font-weight-bold" onclick="procesarDevolucion(<%= p.get("id_alquiler") %>, '<%= p.get("fecha_esperada") %>')">
                                                ✅ Recibir
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

        <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

        <script>
                    // 1. BLOQUEAR FECHAS DEL PASADO
                    document.addEventListener("DOMContentLoaded", function() {
                        let hoy = new Date().toISOString().split('T')[0];
                        document.getElementById("txtFechaInicio").setAttribute('min', hoy);
                        document.getElementById("txtFechaFin").setAttribute('min', hoy);
                    });

                    // 2. FUNCIÓN DE CÁLCULO FUSIONANDO CAMPOS SEPARADOS

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

                     // Solo operamos si los 4 campos tienen datos
                     if (fechaInicio && horaInicio && fechaFin && horaFin) {

                         // MÉTODO A PRUEBA DE FALLOS: Desarmamos los textos y armamos la fecha matemáticamente
                         const [yearI, monthI, dayI] = fechaInicio.split('-');
                         const [hourI, minI] = horaInicio.split(':');
                         const dateInicio = new Date(yearI, monthI - 1, dayI, hourI, minI);

                         const [yearF, monthF, dayF] = fechaFin.split('-');
                         const [hourF, minF] = horaFin.split(':');
                         const dateFin = new Date(yearF, monthF - 1, dayF, hourF, minF);

                         // Validar viaje en el tiempo
                         if (dateFin <= dateInicio) {
                             Swal.fire('¡Cuidado!', 'La fecha y hora de devolución deben ser posteriores a la entrega.', 'warning');
                             document.getElementById('txtHoraFin').value = ''; 
                             inputTotal.value = ''; 
                             return; 
                         }

                         // EXTRACCIÓN SEGURA DEL PRECIO: Prevenimos el error NaN
                         let precioAttr = select.options[select.selectedIndex].getAttribute('data-precio');
                         let precioDiario = parseFloat(precioAttr);

                         // Si el precio atrapado es NaN (ej: opción "Seleccione..."), lo forzamos a 0
                         if (isNaN(precioDiario)) {
                             precioDiario = 0;
                         }

                         if (precioDiario > 0) {
                             const diffTime = Math.abs(dateFin - dateInicio);
                             const diffHours = Math.ceil(diffTime / (1000 * 60 * 60)); 

                             const diasCompletos = Math.floor(diffHours / 24);
                             const horasSueltas = diffHours % 24;

                             const tarifaPorHora = 5.00;
                             let costoHoras = horasSueltas * tarifaPorHora;

                             if(costoHoras > precioDiario) {
                                 costoHoras = precioDiario;
                             }

                             const totalEstimado = (diasCompletos * precioDiario) + costoHoras;

                             // Asignación limpia y segura
                             inputTotal.value = totalEstimado.toFixed(2);
                         } else {
                             inputTotal.value = "";
                         }
                     }
                 }

                    // 3. VALIDACIÓN ANTES DE ENVIAR
                    function validarFormulario() {
                        const total = document.getElementById('txtTotal').value;
                        const cliente = document.getElementsByName('txtIdCliente')[0].value;
                        const vehiculo = document.getElementById('selectVehiculo').value;

                        // Verificamos que los nuevos campos de hora no estén vacíos
                        const horaI = document.getElementById('txtHoraInicio').value;
                        const horaF = document.getElementById('txtHoraFin').value;

                        if (cliente === "" || vehiculo === "") {
                            Swal.fire('Error', 'Debe seleccionar un cliente y un vehículo válidos.', 'error');
                            return false; 
                        }

                        if (horaI === "" || horaF === "") {
                            Swal.fire('Error', 'Debe especificar las horas exactas de entrega y devolucion.', 'error');
                            return false; 
                        }

                        if (total === "" || parseFloat(total) <= 0) {
                            Swal.fire('Error', 'Revise las fechas y horas para calcular el total antes de procesar.', 'error');
                            return false; 
                        }

                        return true; 
                    }

                    // Alertas
                    const urlParams = new URLSearchParams(window.location.search);
                    if (urlParams.has('msg')) {
                        Swal.fire('¡Éxito!', urlParams.get('msg'), 'success');
                    } else if (urlParams.has('error')) {
                        Swal.fire('¡Error!', urlParams.get('error'), 'error');
                    }

                    // 4. LÓGICA PARA RECIBIR VEHÍCULO
                        function procesarDevolucion(idAlquiler, fechaEsperada) {
                            Swal.fire({
                                title: 'Procesar Devolución',
                                text: `¿Desea registrar la entrada del ticket #${idAlquiler}? El sistema evaluará la hora prometida (${fechaEsperada}) y calculará si hay mora.`,
                                icon: 'question',
                                showCancelButton: true,
                                confirmButtonColor: '#28a745',
                                cancelButtonColor: '#6c757d',
                                confirmButtonText: 'Sí, recibir vehículo',
                                cancelButtonText: 'Cancelar'
                            }).then((result) => {
                                if (result.isConfirmed) {
                                    // Redirigimos al Servlet enviando el ID por la URL (Método GET)
                                    window.location.href = 'DevolucionServlet?id=' + idAlquiler;
                                }
                            });
                        }
        </script>   
    </body>
</html>