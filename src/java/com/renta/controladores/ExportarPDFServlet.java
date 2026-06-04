package com.renta.controladores;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import com.itextpdf.text.pdf.draw.LineSeparator;
import com.renta.datos.ReporteDAO;
import com.renta.modelos.ReporteDia;
import com.renta.modelos.Usuario;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "ExportarPDFServlet", urlPatterns = {"/ExportarPDFServlet"})
public class ExportarPDFServlet extends HttpServlet {

    // ── Paleta de colores ──────────────────────────────────────────────────────
    private static final BaseColor COLOR_HEADER     = new BaseColor(44, 62, 80);   // #2c3e50
    private static final BaseColor COLOR_SUBHEADER  = new BaseColor(52, 73, 94);   // #34495e
    private static final BaseColor COLOR_AZUL       = new BaseColor(41, 128, 185); // #2980b9
    private static final BaseColor COLOR_VERDE      = new BaseColor(39, 174, 96);  // #27ae60
    private static final BaseColor COLOR_ROJO       = new BaseColor(231, 76, 60);  // #e74c3c
    private static final BaseColor COLOR_NARANJA    = new BaseColor(230, 126, 34); // #e67e22
    private static final BaseColor COLOR_FILA_PAR   = new BaseColor(245, 247, 250);
    private static final BaseColor COLOR_FILA_MORA  = new BaseColor(255, 235, 235);
    private static final BaseColor COLOR_TH         = new BaseColor(44, 62, 80);
    private static final BaseColor BLANCO           = BaseColor.WHITE;

    // ── Fuentes ────────────────────────────────────────────────────────────────
    private static final Font F_TITULO      = new Font(Font.FontFamily.HELVETICA, 22, Font.BOLD,   BLANCO);
    private static final Font F_SUBTITULO   = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL, new BaseColor(180,180,180));
    private static final Font F_SECCION     = new Font(Font.FontFamily.HELVETICA, 11, Font.BOLD,   COLOR_HEADER);
    private static final Font F_TH          = new Font(Font.FontFamily.HELVETICA,  8, Font.BOLD,   BLANCO);
    private static final Font F_TD          = new Font(Font.FontFamily.HELVETICA,  8, Font.NORMAL, new BaseColor(50,50,50));
    private static final Font F_TD_BOLD     = new Font(Font.FontFamily.HELVETICA,  8, Font.BOLD,   new BaseColor(50,50,50));
    private static final Font F_KPI_LABEL   = new Font(Font.FontFamily.HELVETICA,  8, Font.BOLD,   new BaseColor(150,150,150));
    private static final Font F_KPI_VALUE   = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD,   COLOR_HEADER);
    private static final Font F_VERDE_BOLD  = new Font(Font.FontFamily.HELVETICA,  8, Font.BOLD,   COLOR_VERDE);
    private static final Font F_ROJO_BOLD   = new Font(Font.FontFamily.HELVETICA,  8, Font.BOLD,   COLOR_ROJO);
    private static final Font F_NARANJA_BOLD= new Font(Font.FontFamily.HELVETICA,  8, Font.BOLD,   COLOR_NARANJA);
    private static final Font F_FOOTER      = new Font(Font.FontFamily.HELVETICA,  8, Font.ITALIC, new BaseColor(150,150,150));

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("empleado") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        Usuario emp = (Usuario) session.getAttribute("empleado");

        String fecha = request.getParameter("fecha");
        if (fecha == null || fecha.trim().isEmpty()) {
            fecha = LocalDate.now().toString();
        }

        try {
            ReporteDAO dao        = new ReporteDAO();
            ReporteDia resumen    = dao.obtenerResumenDia(fecha);
            List<Object[]> detalle   = dao.obtenerDetalleAlquileresDia(fecha);
            List<Object[]> vehiculos = dao.obtenerVehiculosMasAlquilados(fecha);
            List<Object[]> moras     = dao.obtenerDevolucionesConMora(fecha);

            // ── Configurar respuesta HTTP ──────────────────────────────────────
            String nombreArchivo = "Reporte_" + fecha + ".pdf";
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + nombreArchivo + "\"");

            // ── Documento ─────────────────────────────────────────────────────
            Document doc = new Document(PageSize.A4.rotate(), 30, 30, 30, 40);
            PdfWriter writer = PdfWriter.getInstance(doc, response.getOutputStream());

            // Footer con número de página
            writer.setPageEvent(new FooterEvent(fecha, emp.getNombreCompleto()));

            doc.open();

            // ══════════════════════════════════════════════════════════════════
            // CABECERA PRINCIPAL
            // ══════════════════════════════════════════════════════════════════
            PdfPTable header = new PdfPTable(2);
            header.setWidthPercentage(100);
            header.setWidths(new float[]{3f, 1f});

            // Celda izquierda: título
            PdfPCell celdaTitulo = new PdfPCell();
            celdaTitulo.setBackgroundColor(COLOR_HEADER);
            celdaTitulo.setBorder(Rectangle.NO_BORDER);
            celdaTitulo.setPadding(16);
            Paragraph pTitulo = new Paragraph();
            pTitulo.add(new Chunk("REPORTE DEL DÍA\n", F_TITULO));
            pTitulo.add(new Chunk("Sistema de Renta de Automóviles", F_SUBTITULO));
            celdaTitulo.addElement(pTitulo);
            header.addCell(celdaTitulo);

            // Celda derecha: fecha e info
            DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");
            String fechaFormateada = LocalDate.parse(fecha).format(fmt);
            PdfPCell celdaFecha = new PdfPCell();
            celdaFecha.setBackgroundColor(COLOR_SUBHEADER);
            celdaFecha.setBorder(Rectangle.NO_BORDER);
            celdaFecha.setPadding(16);
            celdaFecha.setHorizontalAlignment(Element.ALIGN_RIGHT);
            Font fFechaLabel = new Font(Font.FontFamily.HELVETICA, 8, Font.NORMAL, new BaseColor(180,180,180));
            Font fFechaVal   = new Font(Font.FontFamily.HELVETICA, 14, Font.BOLD,  BLANCO);
            Font fEmp        = new Font(Font.FontFamily.HELVETICA,  9, Font.NORMAL, new BaseColor(200,200,200));
            Paragraph pFecha = new Paragraph();
            pFecha.setAlignment(Element.ALIGN_RIGHT);
            pFecha.add(new Chunk("FECHA\n", fFechaLabel));
            pFecha.add(new Chunk(fechaFormateada + "\n", fFechaVal));
            pFecha.add(new Chunk("\nEmitido por: " + emp.getNombreCompleto(), fEmp));
            celdaFecha.addElement(pFecha);
            header.addCell(celdaFecha);

            doc.add(header);
            doc.add(Chunk.NEWLINE);

            // ══════════════════════════════════════════════════════════════════
            // TARJETAS KPI  (4 celdas en una tabla)
            // ══════════════════════════════════════════════════════════════════
            doc.add(seccionTitulo("RESUMEN EJECUTIVO"));
            PdfPTable kpiTable = new PdfPTable(4);
            kpiTable.setWidthPercentage(100);
            kpiTable.setSpacingBefore(6);
            kpiTable.setSpacingAfter(14);

            kpiTable.addCell(kpiCell("TOTAL ALQUILERES",  String.valueOf(resumen.getTotalAlquileres()), COLOR_AZUL));
            kpiTable.addCell(kpiCell("SUBTOTAL DEL DÍA",  "$" + String.format("%,.2f", resumen.getTotalSubtotal()),  COLOR_VERDE));
            kpiTable.addCell(kpiCell("TOTAL MORAS",       "$" + String.format("%,.2f", resumen.getTotalMora()),      COLOR_ROJO));
            kpiTable.addCell(kpiCell("INGRESOS TOTALES",  "$" + String.format("%,.2f", resumen.getTotalIngresos()),  COLOR_NARANJA));
            doc.add(kpiTable);

            // ══════════════════════════════════════════════════════════════════
            // TABLA DETALLE
            // ══════════════════════════════════════════════════════════════════
            doc.add(seccionTitulo("DETALLE DE ALQUILERES"));

            PdfPTable tabDetalle = new PdfPTable(10);
            tabDetalle.setWidthPercentage(100);
            tabDetalle.setSpacingBefore(6);
            tabDetalle.setSpacingAfter(14);
            tabDetalle.setWidths(new float[]{0.6f, 2f, 1.5f, 2f, 1.2f, 1.4f, 1.4f, 1.2f, 1.2f, 1.2f});

            String[] headDetalle = {"#", "Cliente", "DUI", "Vehículo", "Placa",
                                    "F.Entrega", "F.Dev.Est.", "Precio/día", "Subtotal", "Total"};
            for (String h : headDetalle) thCell(tabDetalle, h);

            if (detalle != null) {
                int rowNum = 0;
                for (Object[] f : detalle) {
                    double mora = (Double) f[11];
                    BaseColor bg = mora > 0 ? COLOR_FILA_MORA : (rowNum % 2 == 0 ? BLANCO : COLOR_FILA_PAR);
                    rowNum++;

                    tdCell(tabDetalle, "#" + f[0],                           bg, Element.ALIGN_CENTER, F_TD_BOLD);
                    tdCell(tabDetalle, str(f[1]),                             bg, Element.ALIGN_LEFT,   F_TD_BOLD);
                    tdCell(tabDetalle, str(f[2]),                             bg, Element.ALIGN_CENTER, F_TD);
                    tdCell(tabDetalle, str(f[3]),                             bg, Element.ALIGN_LEFT,   F_TD);
                    tdCell(tabDetalle, str(f[4]),                             bg, Element.ALIGN_CENTER, F_TD_BOLD);
                    tdCell(tabDetalle, fecha10(f[6]),                         bg, Element.ALIGN_CENTER, F_TD);
                    tdCell(tabDetalle, fecha10(f[7]),                         bg, Element.ALIGN_CENTER, F_TD);
                    tdCell(tabDetalle, "$" + fmt2(f[9]),                      bg, Element.ALIGN_RIGHT,  F_TD);
                    tdCell(tabDetalle, "$" + fmt2(f[10]),                     bg, Element.ALIGN_RIGHT,  F_VERDE_BOLD);
                    tdCell(tabDetalle, "$" + fmt2(f[12]),                     bg, Element.ALIGN_RIGHT,
                           mora > 0 ? F_ROJO_BOLD : F_NARANJA_BOLD);
                }
            } else {
                PdfPCell vacio = new PdfPCell(new Phrase("Sin registros para esta fecha", F_TD));
                vacio.setColspan(10);
                vacio.setHorizontalAlignment(Element.ALIGN_CENTER);
                vacio.setPadding(10);
                tabDetalle.addCell(vacio);
            }
            doc.add(tabDetalle);

            // ══════════════════════════════════════════════════════════════════
            // DOS COLUMNAS: Vehículos | Moras
            // ══════════════════════════════════════════════════════════════════
            PdfPTable dosCol = new PdfPTable(2);
            dosCol.setWidthPercentage(100);
            dosCol.setWidths(new float[]{1f, 1f});
            dosCol.setSpacingBefore(4);

            // — Vehículos —
            PdfPCell colVeh = new PdfPCell();
            colVeh.setBorder(Rectangle.NO_BORDER);
            colVeh.setPaddingRight(8);

            PdfPTable tabVeh = new PdfPTable(4);
            tabVeh.setWidthPercentage(100);
            tabVeh.setWidths(new float[]{2.5f, 1.2f, 1f, 1.5f});
            Paragraph pVeh = new Paragraph("VEHÍCULOS ALQUILADOS", F_SECCION);
            pVeh.setSpacingAfter(6);

            String[] headVeh = {"Vehículo", "Placa", "Cliente", "Dev. antes de"};
            for (String h : headVeh) thCell(tabVeh, h);

            if (vehiculos != null && !vehiculos.isEmpty()) {
                int rv = 0;
                for (Object[] v : vehiculos) {
                    BaseColor bg = rv++ % 2 == 0 ? BLANCO : COLOR_FILA_PAR;
                    tdCell(tabVeh, str(v[0]),   bg, Element.ALIGN_LEFT,   F_TD_BOLD);
                    tdCell(tabVeh, str(v[1]),   bg, Element.ALIGN_CENTER, F_TD_BOLD);
                    tdCell(tabVeh, str(v[2]),   bg, Element.ALIGN_LEFT,   F_TD);
                    tdCell(tabVeh, str(v[3]),   bg, Element.ALIGN_CENTER, F_TD);
                }
            } else {
                PdfPCell vc = new PdfPCell(new Phrase("Sin datos", F_TD));
                vc.setColspan(4); vc.setHorizontalAlignment(Element.ALIGN_CENTER); vc.setPadding(8);
                tabVeh.addCell(vc);
            }
            colVeh.addElement(pVeh);
            colVeh.addElement(tabVeh);
            dosCol.addCell(colVeh);

            // — Moras —
            PdfPCell colMora = new PdfPCell();
            colMora.setBorder(Rectangle.NO_BORDER);
            colMora.setPaddingLeft(8);

            PdfPTable tabMora = new PdfPTable(4);
            tabMora.setWidthPercentage(100);
            tabMora.setWidths(new float[]{2f, 2f, 1.4f, 1.2f});
            Paragraph pMora = new Paragraph("DEVOLUCIONES CON MORA", F_SECCION);
            pMora.setSpacingAfter(6);

            String[] headMora = {"Cliente", "Vehículo", "F. Dev. Est.", "Mora"};
            for (String h : headMora) thCell(tabMora, h);

            if (moras != null && !moras.isEmpty()) {
                int rm = 0;
                for (Object[] m : moras) {
                    BaseColor bg = rm++ % 2 == 0 ? COLOR_FILA_MORA : new BaseColor(255, 245, 245);
                    tdCell(tabMora, str(m[0]),         bg, Element.ALIGN_LEFT,   F_TD_BOLD);
                    tdCell(tabMora, str(m[1]),         bg, Element.ALIGN_LEFT,   F_TD);
                    tdCell(tabMora, str(m[2]),         bg, Element.ALIGN_CENTER, F_TD);
                    tdCell(tabMora, "$" + fmt2(m[4]),  bg, Element.ALIGN_RIGHT,  F_ROJO_BOLD);
                }
            } else {
                PdfPCell mc = new PdfPCell(new Phrase("✓ Sin moras registradas", F_VERDE_BOLD));
                mc.setColspan(4); mc.setHorizontalAlignment(Element.ALIGN_CENTER); mc.setPadding(8);
                tabMora.addCell(mc);
            }
            colMora.addElement(pMora);
            colMora.addElement(tabMora);
            dosCol.addCell(colMora);

            doc.add(dosCol);
            doc.close();

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("reportes.jsp?fecha=" + fecha + "&error=" + e.getMessage());
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private Paragraph seccionTitulo(String texto) {
        Font f = new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD, COLOR_HEADER);
        Paragraph p = new Paragraph(texto, f);
        p.setSpacingBefore(10);
        p.setSpacingAfter(4);
        LineSeparator ls = new LineSeparator(1f, 100f, COLOR_HEADER, Element.ALIGN_CENTER, -2f);
        p.add(new Chunk(ls));
        return p;
    }

    private PdfPCell kpiCell(String label, String value, BaseColor color) {
        PdfPCell cell = new PdfPCell();
        cell.setBackgroundColor(color);
        cell.setBorder(Rectangle.NO_BORDER);
        cell.setPadding(14);
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);

        Font fLabel = new Font(Font.FontFamily.HELVETICA,  7, Font.BOLD,   new BaseColor(220,220,220));
        Font fValue = new Font(Font.FontFamily.HELVETICA, 16, Font.BOLD,   BLANCO);

        Paragraph p = new Paragraph();
        p.setAlignment(Element.ALIGN_CENTER);
        p.add(new Chunk(label + "\n", fLabel));
        p.add(new Chunk(value,         fValue));
        cell.addElement(p);
        return cell;
    }

    private void thCell(PdfPTable t, String texto) {
        PdfPCell c = new PdfPCell(new Phrase(texto, F_TH));
        c.setBackgroundColor(COLOR_TH);
        c.setBorder(Rectangle.NO_BORDER);
        c.setPadding(6);
        c.setHorizontalAlignment(Element.ALIGN_CENTER);
        t.addCell(c);
    }

    private void tdCell(PdfPTable t, String texto, BaseColor bg, int align, Font font) {
        PdfPCell c = new PdfPCell(new Phrase(texto != null ? texto : "-", font));
        c.setBackgroundColor(bg);
        c.setBorderColor(new BaseColor(220, 220, 220));
        c.setBorderWidth(0.3f);
        c.setPadding(5);
        c.setHorizontalAlignment(align);
        t.addCell(c);
    }

    private String str(Object o)  { return o != null ? o.toString() : "-"; }
    private String fmt2(Object o) { return o != null ? String.format("%,.2f", (Double) o) : "0.00"; }
    private String fecha10(Object o) {
        if (o == null) return "Pendiente";
        String s = o.toString();
        return s.length() >= 10 ? s.substring(0, 10) : s;
    }

    // ── Footer con número de página ───────────────────────────────────────────
    static class FooterEvent extends PdfPageEventHelper {
        private final String fecha;
        private final String usuario;
        FooterEvent(String fecha, String usuario) { this.fecha = fecha; this.usuario = usuario; }

        @Override
        public void onEndPage(PdfWriter writer, Document document) {
            PdfContentByte cb = writer.getDirectContent();
            Font f = new Font(Font.FontFamily.HELVETICA, 7, Font.ITALIC, new BaseColor(150,150,150));
            String left  = "Sistema Renta Autos  |  Reporte del " + fecha + "  |  Generado por: " + usuario;
            String right = "Página " + writer.getPageNumber();

            ColumnText.showTextAligned(cb, Element.ALIGN_LEFT,
                new Phrase(left, f),
                document.left(), document.bottom() - 10, 0);
            ColumnText.showTextAligned(cb, Element.ALIGN_RIGHT,
                new Phrase(right, f),
                document.right(), document.bottom() - 10, 0);
        }
    }
}

