DeflateX is a Haxe port of the deflate/inflate implementation written by [RidgeX](https://github.com/RidgeX/deflate-impl) (hence the "X" in the name). Written purely in Haxe without any additional dependencies, it compiles to all available targets, but was tested only for JS, Flash, C++ (Windows), C# (Windows), PHP, Java, and HashLink.  
  
# Usage  
DeflateX provides not only the standard *deflate* and *inflate* algorithms, but also is able to compress and decompress gzip files.  
Using DeflateX is pretty straightforward. If you want to compress a byte array simply pass it into the static `Deflater.apply` method.  
`var test:String = "Test data 123";`  
`var test_bytes:Bytes = Bytes.ofString(test);`  
`var compressed:Bytes = Deflater.apply(test_bytes);`  
However, in case you're working in a multi-threaded environment and want to run multiple deflate operations in parallel, you can also instantiate an unique `Deflater` object and call `compress` method instead:  
`var deflater:Deflater = new Deflater();`  
`var compressed:Bytes = deflater.compress(test_bytes);`  
  
Once a byte array is deflated you can proceed to decompress it using the static `Inflater.apply` method:  
`var decompressed:Bytes = Inflater.apply(compressed);`  
`var result:String = decompressed.getString(0, decompressed.length);`  
`trace(result); //following the Usage steps this should output "Test data 123"`  
Or alternatively, as with `Deflater`, by instating the `Inflater` object and calling the `decompress` method:  
`var inflater:Inflater = new Inflater();`  
`var decompressed:Bytes = inflater.decompress(compressed);`  
  
As for gzip files, those can be compressed and decompress using the static `compress` and `decompress` methods available in the `GZCompressor` class. Both are multi-thread safe.  
  
# Installation  
DeflateX can be installed by simply downloading the zipped source code from the Releases sub-page and extracting it into your project, or by using *haxelib*:  
1. Install by executing command: `haxelib install deflatex`.  
2. Add to your project by including `-lib deflatex` in your *hxml* file. Or `<haxelib name="deflatex" />` if you're using OpenFL's `project.xml`.  

Once installed `Deflater` and `Inflater` classes should become available by importing the `deflatex` package.

# Disclaimer  
DeflateX was tested by sending the deflated data to PHP's native [inflate method](https://www.php.net/manual/en/function.gzinflate.php) and verifying the correctness of the uncompressed data. However the algorithms were ported without any deeper considerations of the inner workings. If something doesn't match the official DEFLATE specification I probably won't be able to help with that.
