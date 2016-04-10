using build

class Build : BuildPod {

	new make() {
		podName = "afColdFeet"
		summary = "An asset caching strategy for your Bed Application"
		version = Version("1.4.0")

		meta = [
			"proj.name"		: "Cold Feet",
			"afIoc.module"	: "afColdFeet::ColdFeetModule",
			"repo.tags"		: "web",
			"repo.public"	: "true"
		]

		index = [
			"afIoc.module"	: "afColdFeet::ColdFeetModule" 
		]

		depends = [
			"sys        1.0.68 - 1.0", 
			"concurrent 1.0.68 - 1.0", 
			
			// ---- Core ------------------------
			"afConcurrent 1.0.12 - 1.0", 
			"afIoc        3.0.0  - 3.0", 
			"afIocConfig  1.1.0  - 1.1", 
			"afIocEnv     1.1.0  - 1.1",
			
			// ---- Web -------------------------
			"afBedSheet   1.5.0  - 1.5",
			
			// ---- Test ------------------------
			"afBounce     1.1.0  - 1.1",
			"afButter     1.1.10 - 1.1"
		]
		
		srcDirs = [`fan/`, `fan/internal/`, `fan/public/`, `test/`]
		resDirs = [`doc/`,]
		
		meta["afBuild.testPods"]	= "afBounce afButter"
	}
}
