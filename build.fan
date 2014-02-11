using build

class Build : BuildPod {

	new make() {
		podName = "afColdFeet"
		summary = "(Internal) An asset caching strategy for your Bed App"
		version = Version("0.0.1")

		meta	= [
			"org.name"		: "Alien-Factory",
			"org.uri"		: "http://www.alienfactory.co.uk/",
			"proj.name"		: "Cold Feet",
			"proj.uri"		: "http://repo.status302.com/doc/afColdFeet",
			"vcs.uri"		: "https://bitbucket.org/Alien-Factory/afcoldfeet",
			"license.name"	: "The MIT Licence",	
			"repo.private"	: "true"
		]

		depends = [
			"sys 1.0", 
			
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
}
