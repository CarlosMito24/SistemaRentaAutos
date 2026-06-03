package com.renta.controladores;

import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Document;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import com.renta.conexion.Conexion;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "ComprobanteServlet", urlPatterns = {"/ComprobanteServlet"})
public class ComprobanteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Atrapamos el ID del ticket que queremos imprimir
        int idTicket = Integer.parseInt(request.getParameter("id"));

        // Forzamos al navegador a entender que esto es un archivo descargable
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=\"Comprobante_Alquiler_#" + idTicket + ".pdf\"");

        Document documento = new Document();

        try {
            PdfWriter.getInstance(documento, response.getOutputStream());
            documento.open();

            // 1. PALETA DE FUENTES
            Font fontTitulo = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 22, BaseColor.BLACK);
            Font fontSub = FontFactory.getFont(FontFactory.HELVETICA, 12, BaseColor.DARK_GRAY);
            Font fontNegrita = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, BaseColor.BLACK);
            Font fontNormal = FontFactory.getFont(FontFactory.HELVETICA, 11, BaseColor.BLACK);
            Font fontCabeceraTabla = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11, BaseColor.WHITE);

            // 2. ENCABEZADO CORPORATIVO
            Paragraph titulo = new Paragraph("RENTA DE AUTOS ITCA", fontTitulo);
            titulo.setAlignment(Element.ALIGN_CENTER);
            documento.add(titulo);

            Paragraph subtitulo = new Paragraph("Servicios de Renta Automotriz\nSanta Tecla, El Salvador\n\n", fontSub);
            subtitulo.setAlignment(Element.ALIGN_CENTER);
            documento.add(subtitulo);

            // 3. CONSULTA A LA BASE DE DATOS
            Connection conn = Conexion.conectar();
            String sqlMaestro = "SELECT t.fecha_emision, t.total_global, c.nombre, c.dui FROM Ticket_Alquiler t INNER JOIN Clientes c ON t.id_cliente = c.id_cliente WHERE t.id_ticket = ?";
            PreparedStatement psMaestro = conn.prepareStatement(sqlMaestro);
            psMaestro.setInt(1, idTicket);
            ResultSet rsMaestro = psMaestro.executeQuery();

            if (rsMaestro.next()) {
                // Información del Cliente
                documento.add(new Paragraph("Ticket de Operación #: " + idTicket, fontNegrita));
                documento.add(new Paragraph("Fecha de Emisión: " + rsMaestro.getTimestamp("fecha_emision"), fontNormal));
                documento.add(new Paragraph("Cliente: " + rsMaestro.getString("nombre"), fontNormal));
                documento.add(new Paragraph("DUI: " + rsMaestro.getString("dui") + "\n\n", fontNormal));

                // 4. TABLA DE VEHÍCULOS (MAESTRO-DETALLE)
                PdfPTable tabla = new PdfPTable(4); 
                tabla.setWidthPercentage(100);
                tabla.setWidths(new float[]{35f, 25f, 25f, 15f});

                // Diseñando las cabeceras de la tabla
                String[] cabeceras = {"Vehículo Asignado", "Fecha Entrega", "Retorno Esperado", "Subtotal"};
                for (String cabecera : cabeceras) {
                    PdfPCell celda = new PdfPCell(new Phrase(cabecera, fontCabeceraTabla));
                    celda.setBackgroundColor(new BaseColor(30, 41, 59)); // Mismo color oscuro de tu UI web
                    celda.setPadding(8f);
                    tabla.addCell(celda);
                }

                // Llenando la tabla con la lista de autos de ese ticket
                String sqlDetalle = "SELECT v.marca, v.modelo, v.placa, d.fecha_entrega, d.fecha_devolucion_esperada, d.total_linea FROM Detalle_Alquiler d INNER JOIN Vehiculos v ON d.id_vehiculo = v.id_vehiculo WHERE d.id_ticket = ?";
                PreparedStatement psDetalle = conn.prepareStatement(sqlDetalle);
                psDetalle.setInt(1, idTicket);
                ResultSet rsDetalle = psDetalle.executeQuery();

                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");

                while (rsDetalle.next()) {
                    tabla.addCell(new Phrase(rsDetalle.getString("marca") + " " + rsDetalle.getString("modelo") + "\nPlaca: " + rsDetalle.getString("placa"), fontNormal));
                    tabla.addCell(new Phrase(sdf.format(rsDetalle.getTimestamp("fecha_entrega")), fontNormal));
                    tabla.addCell(new Phrase(sdf.format(rsDetalle.getTimestamp("fecha_devolucion_esperada")), fontNormal));
                    tabla.addCell(new Phrase("$" + String.format("%.2f", rsDetalle.getDouble("total_linea")), fontNormal));
                }
                documento.add(tabla);

                // 5. TOTAL A PAGAR
                Paragraph total = new Paragraph("\nTOTAL CANCELADO: $" + String.format("%.2f", rsMaestro.getDouble("total_global")), fontTitulo);
                total.setAlignment(Element.ALIGN_RIGHT);
                documento.add(total);
            }

            conn.close();
            documento.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}