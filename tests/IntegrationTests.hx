import haxe.Exception;
import deflatex.Inflater;
import haxe.io.Bytes;
import deflatex.Deflater;

class IntegrationTests {
	static public function main():Void {
		
		var test:String = "Test 123 () [];' ,.\"` ęł";
		var uncompressed:Bytes = Bytes.ofString(test);
		var inflater:Deflater = new Deflater();
		var compressed:Bytes = inflater.compress(uncompressed);
		var deflater:Inflater = new Inflater();
		var decompressed:Bytes = deflater.decompress(compressed);
		if( decompressed.length != uncompressed.length ) {
			throw new Exception("Size mismatch! Expected: "+uncompressed.length+" vs result: "+decompressed.length);
		}
		var result:String = decompressed.getString(0, decompressed.length);
		if( test != result ) {
			throw new Exception("Contents mismatch! Expected: "+test+", vs result: "+result);
		}
		
		trace( "Tests completed. Expected: "+test+", got: "+result );
	}
}