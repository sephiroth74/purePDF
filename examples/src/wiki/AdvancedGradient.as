package wiki
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfShading;
	import org.purepdf.pdf.PdfShadingPattern;

	public class AdvancedGradient extends DefaultBasicExample
	{
		private var alphas: Array;
		private var cb_alphas: Vector.<Number>;

		private var cb_colors: Vector.<RGBColor>;
		private var cb_ratios: Vector.<Number>;

		private var colors: Array;
		private var fill_rect: Rectangle;
		private var fill_rotation: Number;

		private var gradient_matrix: Matrix;
		private var ratios: Array;
		private var sprite: Sprite;
		private var pagesize: RectangleElement;
		private var sprite_rotation: Number;

		public function AdvancedGradient()
		{
			super( null );
			
			pagesize = PageSize.create( 500, 500 );
			sprite_rotation = radians(15);
			fill_rotation = radians(30);

			fill_rect = new Rectangle( 0, 0, 100, 100 );
			gradient_matrix = new Matrix();

			sprite = new Sprite();
			var target: Graphics = sprite.graphics;

			cb_colors = Vector.<RGBColor>( [ RGBColor.fromARGB( 0xFFFF0000 ), RGBColor.fromARGB( 0xFF0000FF ), RGBColor.fromARGB( 0xFF00FF00 ) ] );
			cb_ratios = Vector.<Number>( [ 0, 0.5, 1 ] );

			colors = [ 0xFF0000, 0x0000FF, 0x00FF00 ];
			alphas = [ 1, 1, 1 ];
			ratios = [ 0, 127, 255 ];

			gradient_matrix.createGradientBox( fill_rect.width, fill_rect.height, fill_rotation, fill_rect.left, fill_rect.top );
			
			target.beginGradientFill( GradientType.LINEAR, colors, alphas, ratios, gradient_matrix );
			target.moveTo( 0, 0 );
			target.lineTo( 100, 0 );
			target.lineTo( 100, 100 );
			target.lineTo( 0, 100 );
			target.endFill();

			var sprite_matrix: Matrix = new Matrix();
			sprite_matrix.translate( -50, -50 );
			sprite_matrix.rotate( sprite_rotation );
			sprite_matrix.translate( 300, 300 );
			sprite.transform.matrix = sprite_matrix;

			addChild( sprite );
		}

		override protected function execute( event: Event = null ): void
		{
			super.execute();

			createDocument( "", pagesize );
			document.open();

			var cb: PdfContentByte = document.getDirectContent();

			cb.setTransform( new Matrix( 1, 0, 0, -1, 0, pagesize.height ) );
			
			cb.saveState();
			cb.setTransform( sprite.transform.matrix );

			var shading: PdfShading = PdfShading.complexAxial( writer, 0, 0, fill_rect.width, 0, cb_colors, cb_ratios, true, true );
			var pattern: PdfShadingPattern = new PdfShadingPattern( shading );
			
			var sprite_matrix: Matrix = sprite.transform.matrix.clone();
			var m: Matrix = new Matrix();

			m.translate( -fill_rect.width/2, -fill_rect.height/2 );
			m.rotate( fill_rotation );
			m.translate( fill_rect.left + fill_rect.width/2, fill_rect.height/2 );
			m.concat( sprite_matrix );
			m.concat(new Matrix( 1, 0, 0, -1, 0, pagesize.height ));

			pattern.matrix = m.clone();

			cb.moveTo( 0, 0 );
			cb.lineTo( 100, 0 );
			cb.lineTo( 100, 100 );
			cb.lineTo( 0, 100 );

			cb.setShadingFill( pattern );
			cb.fill();
			cb.restoreState();

			/*
		   var axial: PdfShading = PdfShading.simpleAxial( writer, 0, 0, 50, 0, RGBColor.MAGENTA, RGBColor.YELLOW );
		   cb.paintShading(axial);

		   var m: Matrix = new Matrix( 1, 0, 0, 1, 0, 0 );
		   m.rotate( radians(30) );
		   m.translate( 10, 316 );

		   var axialPattern: PdfShadingPattern = new PdfShadingPattern( axial );
		   axialPattern.matrix = m;
		   cb.setShadingFill( axialPattern );
		   cb.rectangle( 10, 316, 50, 50 );
		   cb.fillStroke();

		   var axialColor: ShadingColor = new ShadingColor( axialPattern );
		   cb.setColorFill( axialColor );
		   cb.rectangle( 10, 200, 50, 50 );
		   cb.rectangle( 70, 200, 50, 50 );
		   cb.rectangle( 130, 200, 50, 50 );
		   cb.rectangle( 190, 200, 50, 50 );
		   cb.fillStroke();
			 */

			document.close();
			save();
		}

		public static function degrees( radians: Number ): Number
		{
			return radians * ( 180 / Math.PI );
		}

		public static function radians( degree: Number ): Number
		{
			return degree * ( Math.PI / 180 );
		}
	}
}