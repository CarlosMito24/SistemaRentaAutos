<%@page import="com.renta.datos.ClienteDAO"%>
<%@page import="com.renta.modelos.Cliente"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Control de Clientes - Sistema Renta Autos</title>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="estilo.css" />
    <link rel="stylesheet" type="text/css" href="estilos_responsive.css" />
</head>
<body class="bg-light">

    <div class="container-fluid p-3">
        <jsp:include page="menu.jsp" />

        <%
            // Lógica gemela a vehiculos.jsp para rellenar la tabla de manera directa
            ClienteDAO daoCliente = new ClienteDAO();
            List<Cliente> lista = daoCliente.listarClientes();

            Cliente cEdit = (request.getAttribute("clienteEditar") != null) ? (Cliente) request.getAttribute("clienteEditar") : null;
            
            String msg = request.getParameter("msg");
            String error = request.getParameter("error");
        %>

        <h1 class="text-center my-4 text-dark font-weight-bold">Control de Clientes</h1>

        <% if (msg != null) { %>
            <div class="alert alert-success alert-dismissible fade show text-center font-weight-bold" role="alert">
                <%= msg %>
            </div>
        <% } %>
        <% if (error != null) { %>
            <div class="alert alert-danger alert-dismissible fade show text-center font-weight-bold" role="alert">
                <%= error %>
            </div>
        <% } %>

        <div class="row">
            <div class="col-lg-4 mb-4">
                <div class="card shadow-sm border-0">
                    <div class="card-header bg-primary text-white text-center font-weight-bold">
                        <%= (cEdit != null) ? "Modificar Datos del Cliente" : "Registrar Nuevo Cliente" %>
                    </div>
                    <div class="card-body bg-white text-dark">
                        
                        <form action="ClienteServlet" method="POST">
                            <input type="hidden" name="txtId" value="<%= (cEdit != null) ? cEdit.getIdCliente() : "" %>">

                            <div class="form-group">
                                <label class="font-weight-bold">Nombre Completo:</label>
                                <input type="text" name="txtNombre" class="form-control" required 
                                       value="<%= (cEdit != null) ? cEdit.getNombre() : "" %>" placeholder="Ej: Juan Pérez">
                            </div>
                            
                            <div class="form-group">
                                <label class="font-weight-bold">DUI:</label>
                                <input type="text" name="txtDui" class="form-control" required 
                                       placeholder="00000000-0" maxlength="10" pattern="[0-9]{8}-[0-9]{1}"
                                       title="Formato requerido: 00000000-0"
                                       value="<%= (cEdit != null) ? cEdit.getDui() : "" %>">
                            </div>
                            
                            <div class="form-group">
                                <label class="font-weight-bold">Edad:</label>
                                <input type="number" name="txtEdad" class="form-control" required min="18" max="100"
                                       placeholder="Edad mínima: 18" value="<%= (cEdit != null) ? cEdit.getEdad() : "" %>">
                            </div>
                            
                            <div class="form-group">
                                <label class="font-weight-bold">Teléfono:</label>
                                <input type="text" name="txtTelefono" class="form-control" required 
                                       placeholder="7777-7777" maxlength="9" pattern="[26789][0-9]{3}-?[0-9]{4}"
                                       title="Formato requerido: 7777-7777"
                                       value="<%= (cEdit != null) ? cEdit.getTelefono() : "" %>">
                            </div>

                            <button type="submit" class="btn btn-primary btn-block font-weight-bold shadow-sm">
                                <%= (cEdit != null) ? "Actualizar Datos" : "Guardar Cliente" %>
                            </button>
                            
                            <% if (cEdit != null) { %>
                                <a href="clientes.jsp" class="btn btn-block btn-outline-secondary mt-2">Cancelar Edición</a>
                            <% } %>
                        </form>
                    </div>
                </div>
            </div>

            <div class="col-lg-8">
                <div class="card shadow-sm border-0">
                    <div class="card-header bg-dark text-white font-weight-bold">
                        Listado de Clientes Registrados
                    </div>
                    <div class="table-responsive bg-white">
                        <table class="table table-hover table-striped text-center m-0 text-dark">
                            <thead class="thead-light">
                                <tr>
                                    <th>ID</th>
                                    <th>Nombre Completo</th>
                                    <th>DUI</th>
                                    <th>Edad</th>
                                    <th>Teléfono</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (lista != null && !lista.isEmpty()) {
                                        for (Cliente cli : lista) {
                                %>
                                <tr>
                                    <td class="align-middle font-weight-bold"><%= cli.getIdCliente() %></td>
                                    <td class="text-left align-middle pl-3"><%= cli.getNombre() %></td>
                                    <td class="align-middle"><span class="badge badge-info px-2 py-1" style="font-size: 0.9rem;"><%= cli.getDui() %></span></td>
                                    <td class="align-middle"><%= cli.getEdad() %> años</td>
                                    <td class="align-middle"><%= cli.getTelefono() %></td>
                                    <td class="align-middle">
                                        <a href="ClienteServlet?accion=editar&id=<%= cli.getIdCliente() %>" 
                                           class="btn btn-sm btn-warning font-weight-bold text-dark px-3 shadow-sm">
                                            Editar
                                        </a>
                                    </td>
                                </tr>
                                <% 
                                        }
                                    } else {
                                %>
                                <tr>
                                    <td colspan="6" class="text-muted py-4">No se encontraron registros de clientes en el sistema.</td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

</body>
</html>