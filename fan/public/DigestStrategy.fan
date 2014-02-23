using afIoc
using afIocConfig
using afIocEnv
using afBedSheet::BedSheetMetaData

** Cold Feet's strategy for generating digests from a file. 
const mixin DigestStrategy {
	
	** Return a digest for the given file. The digest must NOT contain the character '/'.
	abstract Str digest(File file)
}



** A `DigestStrategy` that returns a [(url-safe) Base64]`http://tools.ietf.org/html/rfc4648#section-5` encoded CRC calculated with the [Adler32]`http://en.wikipedia.org/wiki/Adler32` algorithm.
** This is the default strategy used by 'Cold Feet'.
** 
** The Adler32 checksum was designed for speed and created for use in the [zlib]`http://en.wikipedia.org/wiki/Zlib` compression library.
const class Adler32Digest : DigestStrategy {
	override Str digest(File file) {
		Buf(4).writeI4(file.readAllBuf.crc("CRC-32-Adler")).toBase64.replace("+", "-").replace("/", "_")
	}
}



** A `DigestStrategy` that returns the application's version number in production, and a random string in development.
** To use, override the default digest strategy in your 'AppModule':
** 
** pre>
** class AppModule {
**     @Contribute { serviceType=ServiceOverride# }
**     static Void contributeOverrides(MappedConfig config) {
**         config[DigestStrategy#] = AppVersionDigest()
**     }
** }
** <pre
const class AppVersionDigest : DigestStrategy {
	private const Str appVersion
	
	new make(IocEnv iocEnv, BedSheetMetaData meta) {
		this.appVersion = iocEnv.isDev ? Int.random.toHex(8)[0..8] : "v" + meta.appPod?.version?.segments?.join("-")
	}

	override Str digest(File file) {
		appVersion
	}
}



** A `DigestStrategy` that returns a constant value - use during testing. 
** To use, override the default digest strategy in your 'AppModule':
** 
** pre>
** class AppModule {
**     @Contribute { serviceType=ServiceOverride# }
**     static Void contributeOverrides(MappedConfig config) {
**         config[DigestStrategy#] = FixedValueDigest("wotever")
**     }
** }
** <pre
const class FixedValueDigest : DigestStrategy {
	private const Str myDigest
	
	new make(Str digest) {
		this.myDigest = digest
	}

	override Str digest(File file) {
		this.myDigest
	}
}

