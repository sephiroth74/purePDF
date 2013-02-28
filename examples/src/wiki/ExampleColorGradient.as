package wiki
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.utils.ByteArray;
	
	import org.purepdf.colors.RGBColor;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfDocument;
	import org.purepdf.pdf.PdfShading;
	import org.purepdf.pdf.PdfShadingPattern;
	import org.purepdf.pdf.PdfWriter;
	
	[SWF(frameRate="60",width="600",height="400")]
	public class ExampleColorGradient extends Sprite
	{
		public function ExampleColorGradient()
		{
			super();
			addEventListener( Event.ADDED_TO_STAGE, onAdded );
		}
		
		protected const SPRITE_W: Number = 250;
		protected const SPRITE_H: Number = 150;
		protected const STAGE_W: uint = 600;
		protected const STAGE_H: uint = 400;
		protected const GRADIENT_W: Number = SPRITE_W*2;
		protected const GRADIENT_H: Number = SPRITE_H*2;
		
		protected var sprite: Sprite;
		protected var frame: int = -1;
		protected var gradient_matrix: Matrix;
		protected var colors: Array;
		protected var alphas: Array;
		protected var ratios: Array;
		protected var gradient_rotation: Number = 0;
		protected var gradient_rect: Rectangle = new Rectangle( 0, 0, GRADIENT_W, GRADIENT_H );
		
		protected var pair_x: Number;
		protected var pair_y: Number;
		
		// pdf properties
		private var cb_colors: Vector.<RGBColor> = new Vector.<RGBColor>();
		private var cb_ratios: Vector.<Number> = new Vector.<Number>();
		
		private var test_sprite: Sprite;
		private var temp_sprite: Sprite;
		
		
		protected function onAdded( event: Event ): void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			sprite = new Sprite();
			sprite.graphics.beginFill( 0, 0.5 );
			sprite.graphics.drawRect( 0, 0, SPRITE_W, SPRITE_H );
			sprite.graphics.endFill();
			
			gradient_matrix = new Matrix();
			colors = [ 0xFF0000, 0x0000FF, 0x00FF00 ];
			alphas = [ 1, 1, 1 ];
			ratios = [ 0, 127, 255 ];
			
			sprite.buttonMode = true;
			sprite.addEventListener( MouseEvent.CLICK, onClick );
			addChild( sprite );
			
			// pdf
			for( var k: int = 0; k < colors.length; ++k )
			{
				cb_colors[k] = RGBColor.fromARGB( 0xFFFFFFFF & colors[k] );
				cb_ratios[k] = ratios[k]/255;
			}
			
			var msg_format: ElementFormat = new ElementFormat();
			msg_format.fontDescription = new FontDescription("Helvetica");
			msg_format.fontSize = 12;
			msg_format.color = 0x000000;
			
			var block: TextBlock = new TextBlock();
			block.content = new TextElement("Click the sprite to start/stop", msg_format);
			var message_line: TextLine = block.createTextLine();
			
			message_line.x = ( STAGE_W - message_line.width ) / 2;
			message_line.y = message_line.height;
			message_line.mouseChildren = false;
			message_line.mouseEnabled = false;
			addChild( message_line );
			
			test_sprite = new Sprite();
			test_sprite.mouseEnabled = false;
			addChild( test_sprite );
			
			temp_sprite = new Sprite();
			temp_sprite.mouseEnabled = false;
			addChild( temp_sprite );
			
			onEnterFrame( null );
		}
		
		protected function onEnterFrame( event: Event ): void
		{
			frame++;
			var matrix: Matrix = new Matrix();
			matrix.identity();
			matrix.translate( -SPRITE_W/2, -SPRITE_H/2 );
			matrix.b = matrix.c = Math.sin( frame/100 );
			matrix.rotate( radians( -frame/1.5 ) );
			matrix.translate( (STAGE_W/2) + ( 100 * Math.sin( frame/100 )), (STAGE_H/2) + ( 75 * Math.cos( frame/100 ))  );
			
			sprite.transform.matrix = matrix;
			
			gradient_rect.x = Math.sin( frame/100 ) * 100;
			gradient_rect.y = Math.cos( frame/100 ) * 100;
			
			var test: Matrix = new Matrix();
			test = GradientMatrix.getGradientBox( gradient_rect.width, gradient_rect.height, 0, gradient_rect.x, gradient_rect.y );
			pair_x = 1/test.a;
			pair_y = 1/test.d;
			
			
			gradient_rotation = radians( frame );
			gradient_matrix = GradientMatrix.getGradientBox( GRADIENT_W, GRADIENT_H, gradient_rotation, gradient_rect.x, gradient_rect.y );
			sprite.graphics.clear();
			sprite.graphics.beginGradientFill( GradientType.LINEAR, colors, alphas, ratios, gradient_matrix );
			sprite.graphics.drawRoundRect( 0, 0, SPRITE_W, SPRITE_H, 10, 10 );
			sprite.graphics.endFill();
			update();
		}
		
		protected function onClick( event: MouseEvent ): void
		{
			if( hasEventListener( Event.ENTER_FRAME ) )
			{
				removeEventListener( Event.ENTER_FRAME, onEnterFrame );
				save();
			} else {
				addEventListener( Event.ENTER_FRAME, onEnterFrame );
			}
		}
		
		private function save(): void
		{
			var buffer: ByteArray = new ByteArray();
			var writer: PdfWriter = PdfWriter.create( buffer, PageSize.create( STAGE_W, STAGE_H ) );
			var document: PdfDocument = writer.pdfDocument;
			document.open();
			var cb: PdfContentByte = document.getDirectContent();
			
			cb.setTransform( new Matrix( 1, 0, 0, -1, 0, STAGE_H ) );
			cb.saveState();
			cb.setTransform( sprite.transform.matrix );
			
			var matrix: Matrix = new Matrix();
			matrix.translate( -GRADIENT_W/2, -GRADIENT_H/2 );
			matrix.translate( -gradient_rect.x, -gradient_rect.y );
			matrix.scale( pair_x, pair_y );
			
			var box: Rectangle = gradient_rect.clone();
			matrix.concat( gradient_matrix );
			matrix.concat( sprite.transform.matrix );
			matrix.concat( new Matrix( 1, 0, 0, -1, 0, STAGE_H ) );
			
			var top_left: Point = box.topLeft.clone();
			var top_right: Point = new Point( box.right, box.top );
			var bottom_right: Point = box.bottomRight.clone();
			var bottom_left: Point = new Point( box.left, box.bottom );
			
			//top_left = matrix.transformPoint( top_left );
			//top_right = matrix.transformPoint( top_right );
			//bottom_right = matrix.transformPoint( bottom_right );
			//bottom_left = matrix.transformPoint( bottom_left );
			
			draw_point( top_left );
			draw_point( top_right );
			
			var shading: PdfShading = PdfShading.complexAxial( writer, top_left.x, top_left.y, top_right.x, top_right.y, cb_colors, cb_ratios, true, true );
			var pattern: PdfShadingPattern = new PdfShadingPattern( shading );
			pattern.matrix = matrix;
			
			cb.roundRectangle( 0, 0, SPRITE_W, SPRITE_H, 5 );
			cb.setShadingFill( pattern );
			cb.fill();
			cb.restoreState();
			
			document.close();
			
			var f: FileReference = new FileReference();
			f.save( buffer, "ExampleColorGradient.pdf" );			
		}
		
		private function update(): void
		{
			test_sprite.graphics.clear();
			test_sprite.graphics.beginFill( 0, 0.1 );
			test_sprite.graphics.drawRect( 0, 0, gradient_rect.width, gradient_rect.height );
			
			var matrix: Matrix = new Matrix();
			matrix.translate( -GRADIENT_W/2, -GRADIENT_H/2 );
			matrix.scale( pair_x, pair_y );
			
			var box: Rectangle = gradient_rect.clone();
			
			matrix.concat( gradient_matrix );
			matrix.concat( sprite.transform.matrix );
			
			test_sprite.transform.matrix = matrix;
			test_sprite.graphics.endFill();
		}
		
		public static function radians( degree: Number ): Number
		{
			return degree * ( Math.PI / 180 );
		}
		
		public function draw_point( pt: Point ): void
		{
			var g: Graphics = temp_sprite.graphics;
			g.beginFill( 0x000000, 1 );
			g.drawCircle( pt.x, pt.y, 2 );
		}
	}
}