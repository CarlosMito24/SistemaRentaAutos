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

@WebServlet(name = "ComprobanteDevolucionServlet", urlPatterns = {"/ComprobanteDevolucionServlet"})
public class ComprobanteDevolucionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int idDetalle = Integer.parseInt(request.getParameter("id"));

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=\"Recibo_Devolucion_#" + idDetalle + ".pdf\"");

        Document documento = new Document();

        try {
            PdfWriter.getInstance(documento, response.getOutputStream());
            documento.open();

            Font fontTitulo = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18, BaseColor.BLACK);
            Font fontSub = FontFactory.getFont(FontFactory.HELVETICA, 12, BaseColor.DARK_GRAY);
            Font fontNegrita = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, BaseColor.BLACK);
            Font fontNormal = FontFactory.getFont(FontFactory.HELVETICA, 11, BaseColor.BLACK);

            Paragraph titulo = new Paragraph("SISTEMA DE RENTA DE AUTOS", fontTitulo);
            titulo.setAlignment(Element.ALIGN_CENTER);
            documento.add(titulo);

            Paragraph subtitulo = new Paragraph("COMPROBANTE DE DEVOLUCIÓN\n\n", fontSub);
            subtitulo.setAlignment(Element.ALIGN_CENTER);
            documento.add(subtitulo);

            Connection conn = Conexion.conectar();
            String sql = "SELECT c.nombre, c.dui, v.marca, v.modelo, v.placa, d.fecha_entrega, d.fecha_devolucion_esperada, d.fecha_devolucion_real, d.precio_aplicado, d.mora, d.total_linea "
                       + "FROM Detalle_Alquiler d "
                       + "INNER JOIN Ticket_Alquiler t ON d.id_ticket = t.id_ticket "
                       + "INNER JOIN Clientes c ON t.id_cliente = c.id_cliente "
                       + "INNER JOIN Vehiculos v ON d.id_vehiculo = v.id_vehiculo "
                       + "WHERE d.id_detalle = ?";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, idDetalle);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                documento.add(new Paragraph("DATOS DEL CLIENTE", fontNegrita));
                documento.add(new Paragraph("Nombre: " + rs.getString("nombre"), fontNormal));
                documento.add(new Paragraph("DUI: " + rs.getString("dui") + "\n\n", fontNormal));

                documento.add(new Paragraph("DATOS DEL VEHÍCULO Y TIEMPOS", fontNegrita));
                documento.add(new Paragraph("Vehículo: " + rs.getString("marca") + " " + rs.getString("modelo") + " (" + rs.getString("placa") + ")", fontNormal));
                documento.add(new Paragraph("Fecha de Entrega: " + rs.getTimestamp("fecha_entrega"), fontNormal));
                documento.add(new Paragraph("Devolución Acordada: " + rs.getTimestamp("fecha_devolucion_esperada"), fontNormal));
                documento.add(new Paragraph("Devolución REAL: " + rs.getTimestamp("fecha_devolucion_real") + "\n\n", fontNormal));

                documento.add(new Paragraph("DESGLOSE FINANCIERO", fontNegrita));
                
                PdfPTable tabla = new PdfPTable(2);
                tabla.setWidthPercentage(100);
                
                tabla.addCell(new PdfPCell(new Phrase("Subtotal Cancelado al Iniciar:", fontNormal)));
                tabla.addCell(new PdfPCell(new Phrase("$" + String.format("%.2f", rs.getDouble("precio_aplicado")), fontNormal)));
                
                tabla.addCell(new PdfPCell(new Phrase("Mora Generada por Retraso:", fontNormal)));
                tabla.addCell(new PdfPCell(new Phrase("$" + String.format("%.2f", rs.getDouble("mora")), fontNegrita)));

                documento.add(tabla);
                
                Paragraph totalCobra = new Paragraph("\nTOTAL COBRADO EN DEVOLUCIÓN: $" + String.format("%.2f", rs.getDouble("mora")), fontTitulo);
                totalCobra.setAlignment(Element.ALIGN_RIGHT);
                documento.add(totalCobra);
            }

            conn.close();
            documento.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}