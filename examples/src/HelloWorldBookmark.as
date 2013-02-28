package
{
	import flash.events.Event;
	
	import org.purepdf.elements.*;
	import org.purepdf.pdf.fonts.*;

	public class HelloWorldBookmark extends DefaultBasicExample
	{
		public function HelloWorldBookmark(d_list:Array=null)
		{
			super(["This example will show how to create chapters","and assign bookmarks to them"]);
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
			var c: Chapter;
			
			c = new Chapter("Chapter One", 1 );
			s = c.addSection("Chapter 1.1");
			s.indentationLeft = 20;
			s.add( p );
			document.add(c);
			
			c = new Chapter("Chapter Two", 2 );
			s = c.addSection("Chapter 2.1");
			s.indentationLeft = 20;
			s.add( p );
			s = c.addSection("Chapter 2.2");
			s.indentationLeft = 20;
			s.add( p );
			
			document.add(c);
			
			document.close();
			save();
		}
	}
}