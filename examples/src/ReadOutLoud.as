package
{
	import flash.events.Event;
	
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfDictionary;
	import org.purepdf.pdf.PdfName;
	import org.purepdf.pdf.PdfString;
	import org.purepdf.pdf.PdfStructureElement;
	import org.purepdf.pdf.PdfStructureTreeRoot;
	import org.purepdf.pdf.fonts.BaseFont;

	public class ReadOutLoud extends DefaultBasicExample
	{
		[Embed(source="assets/kubrick07.jpg", mimeType="application/octet-stream")] private var cls: Class;
		
		public function ReadOutLoud(d_list:Array=null)
		{
			super(d_list);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null):void
		{
			super.execute();
			createDocument();
			
			writer.tagged = true;
			document.open();

			// step 4:
			var cb: PdfContentByte = document.getDirectContent();
			var bf: BaseFont = BaseFont.createFont( BaseFont.HELVETICA, BaseFont.CP1252, BaseFont.NOT_EMBEDDED );
			
			var root: PdfStructureTreeRoot = writer.structureTreeRoot;
			var div: PdfStructureElement = PdfStructureElement.createRoot( root, new PdfName("Div") );
			var dict: PdfDictionary;
			
			cb.beginMarkedContentSequence(div);
			
			cb.beginText();
			cb.moveText(36, 788);
			cb.setFontAndSize(bf, 12);
			cb.setLeading(18);
			cb.showText("These are some famous movies by Stanley Kubrick: ");
			dict = new PdfDictionary();
			dict.put(PdfName.E, new PdfString("Doctor"));
			cb.beginMarkedContentSequence2(new PdfName("Span"), dict, true);
			cb.newlineShowText("Dr.");
			cb.endMarkedContentSequence();
			cb.showText(" Strangelove or: How I Learned to Stop Worrying and Love the Bomb.");
			dict = new PdfDictionary();
			dict.put(PdfName.E, new PdfString("Eyes Wide Shut."));
			cb.beginMarkedContentSequence2(new PdfName("Span"), dict, true);
			cb.newlineShowText("EWS");
			cb.endMarkedContentSequence();
			cb.endText();
			dict = new PdfDictionary();
			dict.put(PdfName.LANGUAGE, new PdfString("en-us"));
			dict.put(new PdfName("Alt"), new PdfString("2001: A Space Odyssey."));
			cb.beginMarkedContentSequence2(new PdfName("Span"), dict, true);
			var img: ImageElement = ImageElement.getInstance( new cls() );
			img.setAbsolutePosition(36, 734 - img.scaledHeight);
			cb.addImage(img);
			cb.endMarkedContentSequence();
			cb.endMarkedContentSequence();
			
			
			document.close();
			save();
		}
	}
}