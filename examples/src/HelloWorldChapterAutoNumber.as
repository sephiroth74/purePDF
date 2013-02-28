package
{
	import flash.events.Event;
	
	import org.purepdf.elements.*;
	import org.purepdf.pdf.fonts.*;

	public class HelloWorldChapterAutoNumber extends DefaultBasicExample
	{
		public function HelloWorldChapterAutoNumber(d_list:Array=null)
		{
			super(["Create chapters with automatic numbers"]);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			createDocument("Hello World Bookmars");
			document.open();
			
			var p: Paragraph = new Paragraph("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent vel lectus lorem. Phasellus convallis, tortor a venenatis mattis, erat mi euismod tellus, in fermentum sapien nibh sit amet urna. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Praesent tellus libero, lacinia ac egestas eget, interdum quis purus. Donec ut nisl metus, sit amet viverra turpis. Mauris ultrices dapibus lacus non ultrices. Cras elementum luctus mauris, vitae eleifend diam accumsan ut. Aliquam erat volutpat. Suspendisse placerat nibh in libero tincidunt a elementum mi vehicula. Donec lobortis magna vel nibh mollis tempor. Maecenas et elit nunc. Nam non auctor orci. Aliquam vel velit vel mi adipiscing semper in ac orci. Vestibulum commodo sem eget tortor lobortis semper. Ut sit amet sapien non velit rutrum egestas sollicitudin in elit. Fusce laoreet leo a sem mattis iaculis");
			p.indentationLeft = 20;
			p.setAlignment( ElementTags.ALIGN_RIGHT );
			
			var s: Section;
			var c: ChapterAutoNumber;
			
			c = new ChapterAutoNumber("Chapter One");
			c.bookmarkTitle = "First one";
			c.bookmarkOpen = false;
			
			s = c.addSection("Chapter");
			s.indentationLeft = 20;
			s.add( p );
			document.add(c);
			
			c = new ChapterAutoNumber("Chapter Two");
			s = c.addSection("Nested Chapter");
			s.indentationLeft = 20;
			s.add( p );
			s = c.addSection("Nested Chapter");
			s.indentationLeft = 20;
			s.add( p );
			
			document.add(c);
			
			document.close();
			save();
		}
	}
}