using build

class Build : BuildPod {

	new make() {
		podName = "afColdFeet"
		summary = "(Internal) An asset caching strategy for your Bed App"
		version = Version("0.0.3")

		meta	= [
			"org.name"		: "Alien-Factory",
			"org.uri"		: "http://www.alienfactory.co.uk/",
			"proj.name"		: "Cold Feet",
			"proj.uri"		: "http://repo.status302.com/doc/afColdFeet",
			"vcs.uri"		: "https://bitbucket.org/Alien-Factory/afcoldfeet",
			"license.name"	: "The MIT Licence",	
			"repo.private"	: "true",
			
			"afIoc.module"	: "afColdFeet::ColdFeetModule"
		]

		depends = [
			"sys 1.0", 
			"concurrent 1.0", 
			
			"afIoc 1.5.4+", 
			"afIocConfig 1.0.2+", 
			"afIocEnv 1.0.0+", 
			"afBedSheet 1.3.2+",
			
			"afBounce 0.0.6+",
			"afButter 0.0.4+"
		]
		
		srcDirs = [`test/`, `fan/`, `fan/public/`, `fan/internal/`]
		resDirs = [`doc/`]

		docApi = true
		docSrc = true
	}
	
	@Target { help = "Compile to pod file and associated natives" }
	override Void compile() {
		// exclude test code when building the pod
		srcDirs = srcDirs.exclude { it.toStr.startsWith("test/") }
		resDirs = resDirs.exclude { it.toStr.startsWith("test/") }
		
		super.compile
		
		// copy src to %FAN_HOME% for F4 debugging
		log.indent
		destDir := Env.cur.homeDir.plus(`src/${podName}/`)
		destDir.delete
		destDir.create		
		`fan/`.toFile.copyInto(destDir)		
		log.info("Copied `fan/` to ${destDir.normalize}")
		log.unindent
	}
}
