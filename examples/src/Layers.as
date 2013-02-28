package
{
	import flash.events.Event;
	
	import org.purepdf.colors.RGBColor;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfLayer;
	import org.purepdf.pdf.PdfVersion;
	import org.purepdf.pdf.PdfViewPreferences;

	public class Layers extends DefaultBasicExample
	{
		public function Layers()
		{
			super(["This example shows the usage of nested layers"]);
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			createDocument("Layers example");
			document.setPdfVersion( PdfVersion.VERSION_1_5 );
			document.setViewerPreferences( PdfViewPreferences.PageModeUseOC );
			document.open();
			
			var cb: PdfContentByte = document.getDirectContent();
			var nested: PdfLayer = new PdfLayer("Nested Layer", writer );
			var nested_1: PdfLayer = new PdfLayer("Nested Layer 1", writer );
			var nested_2: PdfLayer = new PdfLayer("Nested Layer 2", writer );
			
			nested.addChild( nested_1 );
			nested.addChild( nested_2 );
			cb.beginLayer( nested );
			
			cb.setColorFill( RGBColor.LIGHT_GRAY );
			cb.rectangle( 20, 522, 300, 300 );
			cb.fill();
			cb.endLayer();
			
			cb.beginLayer( nested_1 );
			cb.setColorFill( RGBColor.GRAY );
			cb.rectangle( 40, 502, 300, 300 );
			cb.fill();
			cb.endLayer();
			
			cb.beginLayer( nested_2 );
			cb.setColorFill( RGBColor.DARK_GRAY );
			cb.rectangle( 60, 482, 300, 300 );
			cb.fill();
			cb.endLayer();
			
			document.lockLayer( nested_2 );
			
			// ----------------------------
			// TITLE LAYERS
			// ----------------------------
			
			var group: PdfLayer = PdfLayer.createTitle("Title nested layer", writer );
			var group_1: PdfLayer = PdfLayer.createTitle("Title nested layer 1", writer );
			var group_2: PdfLayer = PdfLayer.createTitle("Title nested layer 2", writer );
			
			group.addChild( group_1 );
			group.addChild( group_2 );
			
			// TODO: complete text layers
			
			document.close();
			save();
		}
	}
}