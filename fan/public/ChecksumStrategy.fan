using afIoc
using afIocConfig
using afIocEnv
using afBedSheet::BedSheetMetaData

** Cold Feet's strategy for generating checksums based on a file. 
const mixin ChecksumStrategy {
	
	** Return a checksum for the given file. The checksum must NOT contain the character '/'.
	abstract Str checksum(File file)
	
}

** A `ChecksumStrategy` that returns the application's version number in production, and a random string in development.
const class ChecksumFromAppVersion : ChecksumStrategy {
	private const Str appVersion
	
	new make(IocEnv iocEnv, BedSheetMetaData meta) {
		this.appVersion = iocEnv.isDev ? Int.random.toHex(8)[0..8] : "v" + meta.appPod?.version?.segments?.join("-")
	}

	override Str checksum(File file) {
		appVersion
	}
}

** A `ChecksumStrategy` that returns a constant value - use during testing.
const class ChecksumFromConstValue : ChecksumStrategy {
	private const Str myChecksum
	
	new make(Str myChecksum) {
		this.myChecksum = myChecksum
	}

	override Str checksum(File file) {
		myChecksum
	}
}
