package;

import deflatex.utils.Math;
import haxe.Exception;
import deflatex.*;
import utest.Assert;
import haxe.io.Bytes;
import haxe.ds.Vector;

class DeflateXTests extends utest.Test {
	public static function main() {
		utest.UTest.run([new DeflateXTests()]);
	}

	public function new() {
		super();
	}
	
	public function testGZCompressor() {
		try {
			var test:String = "Test data 123 *() ;'\"` śł";
			var compressed:Bytes = GZCompressor.compress( "test", Bytes.ofString(test) );
			var decompressed:Bytes = GZCompressor.decompress( compressed );
			Assert.equals( test, decompressed.getString(0, decompressed.length) );
		}
		catch(ex:Exception) {
			Assert.fail(ex.details());
		}
	}
	
	public function testCompression() {
		try {
			var deflate:Deflater = new Deflater();
			var test:String = "Test data 123 *() ;'\"` śł";
			var test_bytes:Bytes = Bytes.ofString(test);
			Assert.equals(test, test_bytes.getString(0, test_bytes.length));
			var compressed:Bytes = deflate.compress( test_bytes );
			var inflate:Inflater = new Inflater();
			var decompressed:Bytes = inflate.decompress( compressed );
			Assert.equals(test_bytes.length, decompressed.length);
			Assert.equals(test, decompressed.getString(0, decompressed.length));
		}
		catch(ex:Exception) {
			Assert.fail(ex.details());
		}
	}

	public function testCRC32() {
		checkCRC32Case("", 0);
		checkCRC32Case("a", 0xe8b7be43);
		checkCRC32Case("abc", 0x352441c2);
		checkCRC32Case("message digest", 0x20159d7f);
		checkCRC32Case("abcdefghijklmnopqrstuvwxyz", 0x4c2750bd);
		checkCRC32Case("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", 0x1fc2e6d2);
		var buffer:StringBuf = new StringBuf();
		for (i in 0...8) {
			buffer.add("1234567890");
		}
		checkCRC32Case(buffer.toString(), 0x7ca94a72);
		checkCRC32Case("-", 0x97ddb3f8);
		checkCRC32Case("--", 0x242c1465);
	}

	private function checkCRC32Case(input:String, expected:Int) {
		var crc:CRC32 = new CRC32();
		crc.updateAllBytes(Bytes.ofString(input));
		Assert.equals(expected, crc.value);
	}

	public function testHuffmanBalancing() {
		var n:Int = 21;

		var fib:Vector<Int> = new Vector<Int>(n);
		fib[0] = 1;
		fib[1] = 1;
		for (i in 2...fib.length) {
			fib[i] = fib[i - 1] + fib[i - 2];
		}

		try {
			var tree:HuffmanTree = new HuffmanTree(fib, 15);

			var table:HuffmanTable = tree.getTable();
			var litCode:Vector<Int> = table.code;
			var litCodeLen:Vector<Int> = table.codeLen;
			
			var test:Vector<String> = new Vector<String>(21);
			test[0] = "111111111111000";
			test[1] = "111111111111001";
			test[2] = "111111111111010";
			test[3] = "111111111111011";
			test[4] = "111111111111100";
			test[5] = "1111111111100";
			test[6] = "111111111111101";
			test[7] = "111111111111110";
			test[8] = "111111111111111";
			test[9] = "1111111111101";
			test[10] = "11111111110";
			test[11] = "1111111110";
			test[12] = "111111110";
			test[13] = "11111110";
			test[14] = "1111110";
			test[15] = "111110";
			test[16] = "11110";
			test[17] = "1110";
			test[18] = "110";
			test[19] = "10";
			test[20] = "0";

			for (i in 0...n) {
				if (litCodeLen[i] > 0) {
					var binary:String = Math.toBinary(litCode[i], litCodeLen[i]);
					Assert.equals(test[i], binary);
				}
			}
		} catch (e:Exception) {
			Assert.fail();
		}
	}

	public function testLZ77() {
		checkLZ77Case("abcdefghijAabcdefBCDdefEFG", "abcdefghijA<11,6>BCD<6,3>EFG");
		checkLZ77Case("abcde bcde bcde bcde bcde 123", "abcde <5,20>123");
		checkLZ77Case("abcdebcdef", "abcde<4,4>f");
		checkLZ77Case("Blah blah blah blah blah!", "Blah b<5,18>!");
		checkLZ77Case("This is a string with multiple strings within it", "This <3,3>a string with multiple<21,7>s<22,5>in it");
		checkLZ77Case("This is a string of text, whereherehereherehe parts of the string have text that is in other parts of the string",
			"This <3,3>a string of text, where<4,14> parts<35,5><13,3><49,7>have<51,5><21,3>at<76,4>in o<33,3>r<47,20>");
		var buffer:StringBuf = new StringBuf();
		for (i in 0...25) {
			buffer.add("0123456789");
		}
		checkLZ77Case("abcdefghij" + buffer.toString() + "0123abcdefg", "abcdefghij0123456789<10,244><264,7>");
		checkLZ77Case("These blah is blah blah blah!", "These blah is<8,6><5,9>!");
	}

	private function checkLZ77Case(input:String, expected:String) {
		var buffer:Bytes = Bytes.ofString(input);
		var output:StringBuf = new StringBuf();
		var window:LZWindow = new LZWindow(32768);

		var i:Int = 0;
		while (i < input.length) {
			var pair:LZPair = window.find(buffer, i, buffer.length);
			if (pair != null) {
				window.addBytes(buffer, i, pair.len);
				i += (pair.len - 1);
				output.add("<" + pair.dist + "," + pair.len + ">");
			} else {
				window.addByte(buffer.get(i));
				output.addChar(buffer.get(i));
			}
			i++;
		}

		Assert.equals(expected, output.toString());
	}
}
