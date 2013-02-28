/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: BidiOrder.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/BidiOrder.as $
*
* The contents of this file are subject to  LGPL license
* (the "GNU LIBRARY GENERAL PUBLIC LICENSE"), in which case the
* provisions of LGPL are applicable instead of those above.  If you wish to
* allow use of your version of this file only under the terms of the LGPL
* License and not to allow others to use your version of this file under
* the MPL, indicate your decision by deleting the provisions above and
* replace them with the notice and other provisions required by the LGPL.
* If you do not delete the provisions above, a recipient may use your version
* of this file under either the MPL or the GNU LIBRARY GENERAL PUBLIC LICENSE
*
* Software distributed under the License is distributed on an "AS IS" basis,
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
* for the specific language governing rights and limitations under the License.
*
* The Original Code is 'iText, a free JAVA-PDF library' ( version 4.2 ) by Bruno Lowagie.
* All the Actionscript ported code and all the modifications to the
* original java library are written by Alessandro Crugnola (alessandro@sephiroth.it)
*
* This library is free software; you can redistribute it and/or modify it
* under the terms of the MPL as stated above or under the terms of the GNU
* Library General Public License as published by the Free Software Foundation;
* either version 2 of the License, or any later version.
*
* This library is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE. See the GNU LIBRARY GENERAL PUBLIC LICENSE for more
* details
*
* If you didn't download this code from the following link, you should check if
* you aren't using an obsolete version:
* http://code.google.com/p/purepdf
*
*/
package org.purepdf.pdf
{

	public final class BidiOrder
	{
		public static const AL: int = 4;
		public static const AN: int = 11;
		public static const B: int = 15;
		public static const BN: int = 14;
		public static const CS: int = 12;
		public static const EN: int = 8;
		public static const ES: int = 9;
		public static const ET: int = 10;
		// The bidi types
		public static const L: int = 0;
		public static const LRE: int = 1;
		public static const LRO: int = 2;
		public static const NSM: int = 13;
		public static const ON: int = 18;
		public static const PDF: int = 7;
		public static const R: int = 3;
		public static const RLE: int = 5;
		public static const RLO: int = 6;
		public static const S: int = 16;
		public static const TYPE_MAX: int = 18;
		public static const TYPE_MIN: int = 0;
		public static const WS: int = 17;
		private var embeddings: Vector.<int>;
		private var initialTypes: Vector.<int>;
		private var paragraphEmbeddingLevel: int = -1; // undefined
		private var resultLevels: Vector.<int>; // for paragraph, not lines
		private var resultTypes: Vector.<int>; // for paragraph, not lines
		private var textLength: int; // for convenience

		public function BidiOrder()
		{
			trace('BidiOrder::ctor');
			BidiOrderTypes.init();
		}

		/**
		 *
		 * @throw ArgumentError
		 */
		public function create( text: Vector.<int>, offset: int, length: int, pemb: int ): void
		{
			initialTypes = new Vector.<int>( length, true );

			for ( var k: int = 0; k < length; ++k )
			{
				initialTypes[k] = BidiOrderTypes.rTypes[text[offset + k]];
			}
			validateParagraphEmbeddingLevel( pemb );
			paragraphEmbeddingLevel = pemb;
			runAlgorithm();
		}

		public function getLevel(): Vector.<int>
		{
			return getLevels( Vector.<int>( [textLength] ) );
		}

		public function getLevels( linebreaks: Vector.<int> ): Vector.<int>
		{
			validateLineBreaks( linebreaks, textLength );
			var result: Vector.<int> = resultLevels.concat(); // convert to bytes?
			var i: int;
			var t: int;
			var j: int;

			for ( i = 0; i < result.length; ++i )
			{
				t = initialTypes[i];

				if ( t == B || t == S )
				{
					result[i] = paragraphEmbeddingLevel;

					for ( j = i - 1; j >= 0; --j )
					{
						if ( isWhitespace( initialTypes[j] ) )
						{ // including format codes
							result[j] = paragraphEmbeddingLevel;
						} else
						{
							break;
						}
					}
				}
			}
			var start: int = 0;
			var limit: int;

			for ( i = 0; i < linebreaks.length; ++i )
			{
				limit = linebreaks[i];

				for ( j = limit - 1; j >= start; --j )
				{
					if ( isWhitespace( initialTypes[j] ) )
					{ // including format codes
						result[j] = paragraphEmbeddingLevel;
					} else
					{
						break;
					}
				}
				start = limit;
			}
			return result;
		}

		private function determineExplicitEmbeddingLevels(): void
		{
			embeddings = processEmbeddings( resultTypes, paragraphEmbeddingLevel );

			for ( var i: int = 0; i < textLength; ++i )
			{
				var level: int = embeddings[i];

				if ( ( level & 0x80 ) != 0 )
				{
					level &= 0x7f;
					resultTypes[i] = typeForLevel( level );
				}
				resultLevels[i] = level;
			}
		}

		private function determineParagraphEmbeddingLevel(): void
		{
			var strongType: int = -1; // unknown

			for ( var i: int = 0; i < textLength; ++i )
			{
				var t: int = resultTypes[i];

				if ( t == L || t == AL || t == R )
				{
					strongType = t;
					break;
				}
			}

			if ( strongType == -1 )
			{
				paragraphEmbeddingLevel = 0;
			} else if ( strongType == L )
			{
				paragraphEmbeddingLevel = 0;
			} else
			{
				paragraphEmbeddingLevel = 1;
			}
		}

		private function findRunLimit( index: int, limit: int, validSet: Vector.<int> ): int
		{
			--index;
			var t: int;
			var i: int;
			var loop: Boolean;

			while ( ++index < limit )
			{
				loop = true;
				t = resultTypes[index];

				for ( i = 0; i < validSet.length; ++i )
				{
					if ( t == validSet[i] )
					{
						loop = false;
						break;
					}
				}

				if ( loop )
					return index;
				else
					continue;
			}
			return limit;
		}

		private function reinsertExplicitCodes( textLength: int ): int
		{
			var i: int;
			var t: int;

			for ( i = initialTypes.length; --i >= 0;  )
			{
				t = initialTypes[i];

				if ( t == LRE || t == RLE || t == LRO || t == RLO || t == PDF || t == BN )
				{
					embeddings[i] = 0;
					resultTypes[i] = t;
					resultLevels[i] = -1;
				} else
				{
					--textLength;
					embeddings[i] = embeddings[textLength];
					resultTypes[i] = resultTypes[textLength];
					resultLevels[i] = resultLevels[textLength];
				}
			}

			if ( resultLevels[0] == -1 )
			{
				resultLevels[0] = paragraphEmbeddingLevel;
			}

			for ( i = 1; i < initialTypes.length; ++i )
			{
				if ( resultLevels[i] == -1 )
				{
					resultLevels[i] = resultLevels[i - 1];
				}
			}
			return initialTypes.length;
		}

		private function removeExplicitCodes(): int
		{
			var w: int = 0;
			var i: int;
			var t: int;

			for ( i = 0; i < textLength; ++i )
			{
				t = initialTypes[i];

				if ( !( t == LRE || t == RLE || t == LRO || t == RLO || t == PDF || t == BN ) )
				{
					embeddings[w] = embeddings[i];
					resultTypes[w] = resultTypes[i];
					resultLevels[w] = resultLevels[i];
					w++;
				}
			}
			return w;
		}

		private function resolveImplicitLevels( start: int, limit: int, level: int, sor: int, eor: int ): void
		{
			var i: int;
			var t: int;

			if ( ( level & 1 ) == 0 )
			{ // even level
				for ( i = start; i < limit; ++i )
				{
					t = resultTypes[i];

					if ( t == L )
					{
					} else if ( t == R )
					{
						resultLevels[i] += 1;
					} else
					{
						resultLevels[i] += 2;
					}
				}
			} else
			{
				for ( i = start; i < limit; ++i )
				{
					t = resultTypes[i];

					if ( t == R )
					{
					} else
					{
						resultLevels[i] += 1;
					}
				}
			}
		}

		private function resolveNeutralTypes( start: int, limit: int, level: int, sor: int, eor: int ): void
		{
			var i: int;
			var t: int;
			var runstart: int;
			var runlimit: int;
			var leadingType: int;
			var trailingType: int;
			var resolvedType: int;

			for ( i = start; i < limit; ++i )
			{
				t = resultTypes[i];

				if ( t == WS || t == ON || t == B || t == S )
				{
					runstart = i;
					runlimit = findRunLimit( runstart, limit, Vector.<int>( [B, S, WS, ON] ) );

					if ( runstart == start )
					{
						leadingType = sor;
					} else
					{
						leadingType = resultTypes[runstart - 1];

						if ( leadingType == L || leadingType == R )
						{
						} else if ( leadingType == AN )
						{
							leadingType = R;
						} else if ( leadingType == EN )
						{
							leadingType = R;
						}
					}

					if ( runlimit == limit )
					{
						trailingType = eor;
					} else
					{
						trailingType = resultTypes[runlimit];

						if ( trailingType == L || trailingType == R )
						{
						} else if ( trailingType == AN )
						{
							trailingType = R;
						} else if ( trailingType == EN )
						{
							trailingType = R;
						}
					}

					if ( leadingType == trailingType )
					{
						resolvedType = leadingType;
					} else
					{
						resolvedType = typeForLevel( level );
					}
					setTypes( runstart, runlimit, resolvedType );
					i = runlimit;
				}
			}
		}

		private function resolveWeakTypes( start: int, limit: int, level: int, sor: int, eor: int ): void
		{
			var preceedingCharacterType: int = sor;
			var i: int;
			var t: int;
			var j: int;

			for ( i = start; i < limit; ++i )
			{
				t = resultTypes[i];

				if ( t == NSM )
				{
					resultTypes[i] = preceedingCharacterType;
				} else
				{
					preceedingCharacterType = t;
				}
			}

			for ( i = start; i < limit; ++i )
			{
				if ( resultTypes[i] == EN )
				{
					for ( j = i - 1; j >= start; --j )
					{
						t = resultTypes[j];

						if ( t == L || t == R || t == AL )
						{
							if ( t == AL )
							{
								resultTypes[i] = AN;
							}
							break;
						}
					}
				}
			}

			for ( i = start; i < limit; ++i )
			{
				if ( resultTypes[i] == AL )
				{
					resultTypes[i] = R;
				}
			}
			var prevSepType: int;
			var succSepType: int;

			for ( i = start + 1; i < limit - 1; ++i )
			{
				if ( resultTypes[i] == ES || resultTypes[i] == CS )
				{
					prevSepType = resultTypes[i - 1];
					succSepType = resultTypes[i + 1];

					if ( prevSepType == EN && succSepType == EN )
					{
						resultTypes[i] = EN;
					} else if ( resultTypes[i] == CS && prevSepType == AN && succSepType == AN )
					{
						resultTypes[i] = AN;
					}
				}
			}
			var runstart: int;
			var runlimit: int;

			for ( i = start; i < limit; ++i )
			{
				if ( resultTypes[i] == ET )
				{
					runstart = i;
					runlimit = findRunLimit( runstart, limit, Vector.<int>( [ET] ) );
					t = runstart == start ? sor : resultTypes[runstart - 1];

					if ( t != EN )
					{
						t = runlimit == limit ? eor : resultTypes[runlimit];
					}

					if ( t == EN )
					{
						setTypes( runstart, runlimit, EN );
					}
					i = runlimit;
				}
			}

			for ( i = start; i < limit; ++i )
			{
				t = resultTypes[i];

				if ( t == ES || t == ET || t == CS )
				{
					resultTypes[i] = ON;
				}
			}
			var prevStrongType: int;

			for ( i = start; i < limit; ++i )
			{
				if ( resultTypes[i] == EN )
				{
					prevStrongType = sor;

					for ( j = i - 1; j >= start; --j )
					{
						t = resultTypes[j];

						if ( t == L || t == R )
						{ // AL's have been removed
							prevStrongType = t;
							break;
						}
					}

					if ( prevStrongType == L )
					{
						resultTypes[i] = L;
					}
				}
			}
		}

		private function runAlgorithm(): void
		{
			textLength = initialTypes.length;
			resultTypes = initialTypes.concat();

			if ( paragraphEmbeddingLevel == -1 )
			{
				determineParagraphEmbeddingLevel();
			}
			resultLevels = new Vector.<int>( textLength, true );
			setLevels( 0, textLength, paragraphEmbeddingLevel );
			determineExplicitEmbeddingLevels();
			textLength = removeExplicitCodes();
			var prevLevel: int = paragraphEmbeddingLevel;
			var start: int = 0;
			var level: int;
			var prevType: int;
			var limit: int;
			var succLevel: int;
			var succType: int;

			while ( start < textLength )
			{
				level = resultLevels[start];
				prevType = typeForLevel( Math.max( prevLevel, level ) );
				limit = start + 1;

				while ( limit < textLength && resultLevels[limit] == level )
				{
					++limit;
				}
				succLevel = limit < textLength ? resultLevels[limit] : paragraphEmbeddingLevel;
				succType = typeForLevel( Math.max( succLevel, level ) );
				resolveWeakTypes( start, limit, level, prevType, succType );
				resolveNeutralTypes( start, limit, level, prevType, succType );
				resolveImplicitLevels( start, limit, level, prevType, succType );
				prevLevel = level;
				start = limit;
			}
			textLength = reinsertExplicitCodes( textLength );
		}

		private function setLevels( start: int, limit: int, newLevel: int ): void
		{
			for ( var i: int = start; i < limit; ++i )
			{
				resultLevels[i] = newLevel;
			}
		}

		private function setTypes( start: int, limit: int, newType: int ): void
		{
			for ( var i: int = start; i < limit; ++i )
			{
				resultTypes[i] = newType;
			}
		}

		static private function isWhitespace( biditype: int ): Boolean
		{
			switch ( biditype )
			{
				case LRE:
				case RLE:
				case LRO:
				case RLO:
				case PDF:
				case BN:
				case WS:
					return true;
				default:
					return false;
			}
		}

		static private function processEmbeddings( resultTypes: Vector.<int>, paragraphEmbeddingLevel: int ): Vector.<int>
		{
			const EXPLICIT_LEVEL_LIMIT: int = 62;
			var textLength: int = resultTypes.length;
			var embeddings: Vector.<int> = new Vector.<int>( textLength, true );
			var embeddingValueStack: Vector.<int> = new Vector.<int>( EXPLICIT_LEVEL_LIMIT, true );
			var stackCounter: int = 0;
			var overflowAlmostCounter: int = 0;
			var overflowCounter: int = 0;
			var currentEmbeddingLevel: int = paragraphEmbeddingLevel;
			var currentEmbeddingValue: int = paragraphEmbeddingLevel;
			var i: int;
			var t: int;
			var newLevel: int;

			for ( i = 0; i < textLength; ++i )
			{
				embeddings[i] = currentEmbeddingValue;
				t = resultTypes[i];

				switch ( t )
				{
					case RLE:
					case LRE:
					case RLO:
					case LRO:
						if ( overflowCounter == 0 )
						{
							if ( t == RLE || t == RLO )
							{
								newLevel = ByteBuffer.intToByte( ( currentEmbeddingLevel + 1 ) | 1 );
							} else
							{
								newLevel = ByteBuffer.intToByte( ( currentEmbeddingLevel + 2 ) & ~1 );
							}

							if ( newLevel < EXPLICIT_LEVEL_LIMIT )
							{
								embeddingValueStack[stackCounter] = currentEmbeddingValue;
								stackCounter++;
								currentEmbeddingLevel = newLevel;

								if ( t == LRO || t == RLO )
								{ // override
									currentEmbeddingValue = ByteBuffer.intToByte( newLevel | 0x80 );
								} else
								{
									currentEmbeddingValue = newLevel;
								}
								embeddings[i] = currentEmbeddingValue;
								break;
							}

							if ( currentEmbeddingLevel == 60 )
							{
								overflowAlmostCounter++;
								break;
							}
						}
						overflowCounter++;
						break;
					
					case PDF:
						if ( overflowCounter > 0 )
						{
							--overflowCounter;
						} else if ( overflowAlmostCounter > 0 && currentEmbeddingLevel != 61 )
						{
							--overflowAlmostCounter;
						} else if ( stackCounter > 0 )
						{
							--stackCounter;
							currentEmbeddingValue = embeddingValueStack[stackCounter];
							currentEmbeddingLevel = ByteBuffer.intToByte( currentEmbeddingValue & 0x7f );
						}
						break;

					case B:
						stackCounter = 0;
						overflowCounter = 0;
						overflowAlmostCounter = 0;
						currentEmbeddingLevel = paragraphEmbeddingLevel;
						currentEmbeddingValue = paragraphEmbeddingLevel;
						embeddings[i] = paragraphEmbeddingLevel;
						break;
					default:
						break;
				}
			}
			return embeddings;
		}

		static private function typeForLevel( level: int ): int
		{
			return ( ( level & 0x1 ) == 0 ) ? L : R;
		}

		static private function validateLineBreaks( linebreaks: Vector.<int>, textLength: int ): void
		{
			var prev: int = 0;
			var i: int;
			var next: int;

			for ( i = 0; i < linebreaks.length; ++i )
			{
				next = linebreaks[i];

				if ( next <= prev )
				{
					throw new ArgumentError( "bad linebreak at index " + i );
				}
				prev = next;
			}

			if ( prev != textLength )
			{
				throw new ArgumentError( "last linebreak must be at " + textLength );
			}
		}

		static private function validateParagraphEmbeddingLevel( paragraphEmbeddingLevel: int ): void
		{
			if ( paragraphEmbeddingLevel != -1 && paragraphEmbeddingLevel != 0 && paragraphEmbeddingLevel != 1 )
			{
				throw new ArgumentError( "illegal paragraph embedding" );
			}
		}
	}
}