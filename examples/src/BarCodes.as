package {
	import flash.events.Event;
	
	import org.purepdf.Font;
	import org.purepdf.colors.CMYKColor;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.barcode.Barcode;
	import org.purepdf.pdf.barcode.BarcodeEAN;
	import org.purepdf.pdf.barcode.BarcodeEANSUPP;
	import org.purepdf.pdf.barcode.pdf417.BarcodePDF417;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.fonts.FontsResourceFactory;
	import org.purepdf.resources.BuiltinFonts;

	public class BarCodes extends DefaultBasicExample 
	{
		
		public function BarCodes() {
			super(["Create barcodes"]);
			registerDefaultFont();
		}

		override protected function execute(event : Event = null) : void {
			super.execute();
			
			createDocument();
			document.open();
			
			var cb : PdfContentByte = document.getDirectContent();
			var fontTitle: Font = new Font( Font.HELVETICA, 18, Font.NORMAL, new CMYKColor(0.9, 0.7, 0.4, 0.1) );
			
			// EAN 13
			document.add(new Paragraph("Barcode EAN.UCC-13", fontTitle));
			var bcode : Barcode = new BarcodeEAN();
			var p: Paragraph = new Paragraph( null );
			bcode.code = "4512345678906";
			p.add(Chunk.fromImage(bcode.createImageWithBarcode(cb, null, null), 0, -5));
			p.add(Chunk.NEWLINE);
			
			bcode.guardBars = false;
			p.add(Chunk.fromImage(bcode.createImageWithBarcode(cb, null, null), 0, -5));
			p.add(Chunk.NEWLINE);
			
			bcode.baseline = -1;
			bcode.guardBars = true;
			p.add( Chunk.fromImage( bcode.createImageWithBarcode( cb, null, null ), 0, -5 ) );
			p.add(Chunk.NEWLINE);
			p.add(Chunk.NEWLINE);
			
			p.leading = bcode.getBarcodeSize().height * 1.5;
			document.add(p);
			
			bcode.baseline = bcode.size;
			
			// UPC A
			document.add( new Paragraph("Barcode UCC-12 (UPC-A)", fontTitle ) );
			bcode.codeType = Barcode.UPCA;
			bcode.code = "785342304749";
			document.add( bcode.createImageWithBarcode( cb, null, null ) );
			document.add( Chunk.NEWLINE );
			
			// EAN 8
			document.add( new Paragraph( "Barcode EAN.UCC-8", fontTitle ) );
			bcode.codeType = Barcode.EAN8;
			bcode.barHeight = bcode.size * 1.5;
			bcode.code = "34569870";
			document.add( bcode.createImageWithBarcode(cb, null, null) );
			document.add( Chunk.NEWLINE );
			
			// UPC E
			document.add(new Paragraph("Barcode UPC-E", fontTitle ));
			bcode.codeType = Barcode.UPCE;
			bcode.code = "03456781";
			document.add( bcode.createImageWithBarcode(cb, null, null) );
			bcode.barHeight = bcode.size * 3;
			document.add( Chunk.NEWLINE );
			
			// EANSUPP
			document.add( new Paragraph( "Bookland" , fontTitle ) );
			document.add( new Paragraph( "ISBN 0-321-30474-8", fontTitle ) );
			bcode.codeType = Barcode.EAN13;
			bcode.code = "9780321304742";
			
			var codeSUPP: Barcode = new BarcodeEAN();
			codeSUPP.codeType = Barcode.SUPP5;
			codeSUPP.code = "55499";
			codeSUPP.baseline = -2;
			var eanSupp: BarcodeEANSUPP = new BarcodeEANSUPP( bcode, codeSUPP );
			document.add( eanSupp.createImageWithBarcode(cb, null, RGBColor.BLACK ) );
			document.add( Chunk.NEWLINE );
			
			// PDF417
			document.add( new Paragraph("Barcode PDF417", fontTitle ) );
			var pdf417: BarcodePDF417 = new BarcodePDF417();
			var text: String = "http://code.google.com/p/purepdf";
			pdf417.text = text;
			var image: ImageElement = pdf417.getImage();
			image.scalePercent( 150, 150 * pdf417.yHeight );
			document.add( image );
			document.close();
			save();
		}
	}
}