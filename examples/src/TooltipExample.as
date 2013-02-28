package
{
	import flash.events.Event;
	
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.events.ChunkEvent;
	import org.purepdf.pdf.PdfAcroForm;
	import org.purepdf.pdf.PdfAction;
	import org.purepdf.pdf.PdfAnnotation;
	import org.purepdf.pdf.PdfAppearance;
	import org.purepdf.pdf.PdfArray;
	import org.purepdf.pdf.PdfDictionary;
	import org.purepdf.pdf.PdfName;
	import org.purepdf.pdf.PdfNumber;
	import org.purepdf.pdf.PdfString;
	import org.purepdf.pdf.forms.PushbuttonField;

	public class TooltipExample extends DefaultBasicExample
	{
		public function TooltipExample(d_list:Array=null)
		{
			super(["Show how to create several different tooltips","using annotations"]);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null):void
		{
			super.execute();
			createDocument();
			document.open();
			
			document.addEventListener( ChunkEvent.GENERIC_TAG, onGenericTag );
			
			var p: Paragraph = new Paragraph("Hello World ");
			var c: Chunk = new Chunk("tooltip");
			c.setGenericTag("This is my tooltip.");
			p.add( c );
			document.add( p );
			document.add( Chunk.NEWLINE );
			document.add( p );
			document.add( Chunk.NEWLINE );
			document.add( p );
			
			document.close();
			save();
		}
		
		private static var counter: int = 0;
		
		private function onGenericTag( event: ChunkEvent ): void
		{
			var annotation: PdfAnnotation;
			var red: Vector.<Number> = Vector.<Number>([ 1, 0, 0 ]);
			switch( ++counter )
			{
				case 1:
					annotation = PdfAnnotation.createSquareCircle( writer, event.rect, event.tag, true );
					annotation.put(PdfName.T, new PdfString(event.tag));
					annotation.put(PdfName.CONTENTS, null);
					annotation.put(PdfName.C, new PdfArray(red));
					break;
				
				case 2:
					annotation = PdfAnnotation.createText( writer, event.rect, "tooltip", event.tag, false, null );
					var ap: PdfAppearance = document.getDirectContent().createAppearance( event.rect.width, event.rect.height );
					annotation.setAppearance( PdfAnnotation.APPEARANCE_NORMAL, ap );
					annotation.put(PdfName.C, new PdfArray(red));
					break;
				
				case 3:
					// we create a text annotation with name mytooltip and color red
					annotation = PdfAnnotation.createText( writer, event.rect, "tooltip", event.tag, false, null );
					annotation.writer = writer;
					annotation.put( PdfName.NM, new PdfString("mytooltip") );
					annotation.put( PdfName.C, new PdfArray(red) );
					// the text must be read only, and the annotation set to NOVIEW
					annotation.put( PdfName.F, new PdfNumber(PdfAnnotation.FLAGS_READONLY | PdfAnnotation.FLAGS_NOVIEW));
					// we create a popup annotation that will define where the rectangle will appear
					var popup: PdfAnnotation = PdfAnnotation.createPopup( writer, new RectangleElement(event.rect.getLeft(), event.rect.getBottom() - 80, event.rect.getRight() + 100, event.rect.getBottom()), null, false);
					// we add a reference to the text annotation to the popup annotation
					popup.put(PdfName.PARENT, annotation.indirectReference );
					// we add a reference to the popup annotation to the text annotation
					annotation.put(PdfName.POPUP, popup.indirectReference );
					// we add both annotations to the writer
					document.addAnnotation(annotation);
					document.addAnnotation(popup);
					
					// the text annotation can't be viewed (it's invisible)
					// we create a widget annotation named mywidget (it's a button field)
					var field: PushbuttonField = new PushbuttonField(writer, event.rect, "mywidget");
					var widget: PdfAnnotation = field.getField();
					var dict: PdfDictionary = new PdfDictionary();
					// we write some javascript that makes the popup of the text annotation visible/invisible on mouse enter/exit
					var js1: String = "var t = this.getAnnot(this.pageNum, 'mytooltip'); t.popupOpen = true; var w = this.getField('mywidget'); w.setFocus();";
					var enter: PdfAction = PdfAction.javaScript(js1, writer);
					dict.put(PdfName.E, enter);
					var js2: String = "var t = this.getAnnot(this.pageNum, 'mytooltip'); t.popupOpen = false;";
					var exit: PdfAction = PdfAction.javaScript( js2, writer );
					dict.put(PdfName.X, exit);
					// we add the javascript as additional action
					widget.put(PdfName.AA, dict);
					// we add the button field
					document.addAnnotation(widget);
					break;
					
			}
			document.addAnnotation(annotation);
		}
	}
}