package
{
	import flash.events.Event;
	
	import org.purepdf.Font;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Anchor;
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.pdf.PdfAnnotation;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfFileSpecification;
	import org.purepdf.pdf.PdfVersion;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.fonts.FontsResourceFactory;
	import org.purepdf.resources.BuiltinFonts;

	public class EmbeddedMovie extends DefaultBasicExample
	{
		[Embed(source="/Users/alessandro/Library/Fonts/CarolinaLTStd.otf", mimeType="application/octet-stream")] 
		private var cls1: Class;
		
		[Embed(source="assets/Encoded.mp4", mimeType="application/octet-stream")]
		private var mpeg: Class;
		
		public function EmbeddedMovie(d_list:Array=null)
		{
			super(d_list);
			registerDefaultFont();
			FontsResourceFactory.getInstance().registerFont( BaseFont.COURIER, new BuiltinFonts.COURIER() );
			FontsResourceFactory.getInstance().registerFont("CarolinaLTStd.otf", new cls1() );
		}
		
		override protected function execute(event:Event=null):void
		{
			super.execute();
			createDocument();
			
			document.setPdfVersion( PdfVersion.VERSION_1_5 );
			document.open();
			
			var rect: RectangleElement;
			var cb: PdfContentByte = document.getDirectContent();
			var bf: BaseFont = BaseFont.createFont("CarolinaLTStd.otf", BaseFont.CP1252, BaseFont.EMBEDDED );
			var font: Font = new Font( -1, 20, -1, null, bf );
			var font2: Font = new Font( -1, 12, -1, null, bf );
			var p: Paragraph = new Paragraph("I Wish I had an Angel\nNightwish", font);
			var anchor: Anchor = new Anchor("\nsee code", font2 );
			anchor.reference = "#code";
			p.add( anchor );
			document.add(p);
			
			cb.setStrokeColor( 0xBBBBBB );
			cb.setLineWidth(5);
			cb.rectangle( 36, 500, 250, 206 );
			cb.stroke();
			
			cb.resetStroke();
			cb.setFillColor( 0xBBBBBB );
			cb.moveTo( 36+115, 570 );
			cb.lineTo( 36+140, 595 );
			cb.lineTo( 36+115, 620 );
			cb.fill();
			
			// Embed mpeg video
			rect = new RectangleElement( 41, 505, 240+41, 505+196 );
			var fs: PdfFileSpecification = PdfFileSpecification.fileEmbedded( writer, "video.mpg", new mpeg(), true, null, null );
			document.addAnnotation( PdfAnnotation.createScreen( writer, rect, "Video clip", fs, "video/mpeg", true ) );
			
			
			// code
			var mono: BaseFont = BaseFont.createFont( BaseFont.COURIER, BaseFont.WINANSI );
			var font_black: Font = new Font( -1, 7, -1, RGBColor.BLACK, mono );

			document.newPage();
			p = new Paragraph( null, font_black );
			anchor = new Anchor("package\n", font_black );
			anchor.name = "code";
			p.add(anchor);
			
			p.add(
"{\n" +
"	import flash.events.Event;\n" +
"	import org.purepdf.Font;\n" +
"	import org.purepdf.colors.RGBColor;\n" +
"	import org.purepdf.elements.Chunk;\n" +
"	import org.purepdf.elements.Paragraph;\n" +
"	import org.purepdf.elements.RectangleElement;\n" +
"	import org.purepdf.pdf.PdfAnnotation;\n" +
"	import org.purepdf.pdf.PdfContentByte;\n" +
"	import org.purepdf.pdf.PdfFileSpecification;\n" +
"	import org.purepdf.pdf.PdfVersion;\n" +
"	import org.purepdf.pdf.fonts.BaseFont;\n" +
"	import org.purepdf.pdf.fonts.FontsResourceFactory;\n" +
"	import org.purepdf.resources.BuiltinFonts;\n" +
"\n" +
"	public class EmbeddedMovie extends DefaultBasicExample\n" +
"	{\n" +
"		[Embed(source=\"/Users/alessandro/Library/Fonts/CarolinaLTStd.otf\", mimeType=\"application/octet-stream\")] \n" +
"		private var cls1: Class;\n" +
"		\n" +
"		[Embed(source=\"/Users/alessandro/Desktop/Encoded.mp4\", mimeType=\"application/octet-stream\")]\n" +
"		private var mpeg: Class;\n" +
"		\n" +
"		public function Annotations(d_list:Array=null)\n" +
"		{\n" +
"			super(d_list);\n" +
"			registerDefaultFont();\n" +
"			FontsResourceFactory.getInstance().registerFont(\"CarolinaLTStd.otf\", new cls1() );\n" +
"		}\n" +
"		\n" +
"		override protected function execute(event:Event=null):void\n" +
"		{\n" +
"			super.execute();\n" +
"			createDocument();\n" +
"			\n" +
"			document.setPdfVersion( PdfVersion.VERSION_1_5 );\n" +
"			document.open();\n" +
"			\n" +
"			var rect: RectangleElement;\n" +
"			var cb: PdfContentByte = document.getDirectContent();\n" +
"			var bf: BaseFont = BaseFont.createFont(\"CarolinaLTStd.otf\", BaseFont.CP1252, BaseFont.EMBEDDED );\n" +
"			var font: Font = new Font( -1, 20, -1, null, bf );\n" +
"			\n" +
"			document.add( new Paragraph(\"I Wish I had an Angel\\nNightwish\", font) );\n" +
"			\n" +
"			cb.setStrokeColor( 0xBBBBBB );\n" +
"			cb.setLineWidth(5);\n" +
"			cb.rectangle( 36, 500, 250, 206 );\n" +
"			cb.stroke();\n" +
"			\n" +
"			cb.resetStroke();\n" +
"			cb.setFillColor( 0xBBBBBB );\n" +
"			cb.moveTo( 36+115, 570 );\n" +
"			cb.lineTo( 36+140, 595 );\n" +
"			cb.lineTo( 36+115, 620 );\n" +
"			cb.fill();\n" +
"			\n" +
"			// Embed mpeg video\n" +
"			rect = new RectangleElement( 41, 505, 240+41, 505+196 );\n" +
"			var fs: PdfFileSpecification = PdfFileSpecification.fileEmbedded( writer, \"video.mpg\", new mpeg(), true, null, null );\n" +
"			document.addAnnotation( PdfAnnotation.createScreen( writer, rect, \"Video clip\", fs, \"video/mpeg\", true ) );\n" +
"			\n" +
"			document.close();\n" +
"			save();\n" +
"		}\n" +
"	}\n" +
"}");
			
			document.add( p );
			
			document.close();
			save();
		}
	}
}