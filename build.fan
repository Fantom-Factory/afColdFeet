using build

class Build : BuildPod {

	new make() {
		podName = "afColdFeet"
		summary = "An asset caching strategy for your Bed Application"
		version = Version("1.3.4")

		meta = [
			"proj.name"		: "Cold Feet",
			"afIoc.module"	: "afColdFeet::ColdFeetModule",
			"tags"			: "web",
			"repo.private"	: "false"
		]

		depends = [
			"sys 1.0", 
			"concurrent 1.0", 
			
			// ---- Core ------------------------
			"afConcurrent 1.0.8  - 1.0", 
			"afIoc        2.0.6  - 2.0", 
			"afIocConfig  1.0.16 - 1.0", 
			"afIocEnv     1.0.18 - 1.0",
			
			// ---- Web -------------------------
			"afBedSheet   1.4.10 - 1.4",
			
			// ---- Test ------------------------
			"afBounce     1.0.20 - 1.0",
			"afButter     1.1.2  - 1.1"
		]
		
		srcDirs = [`test/`, `fan/`, `fan/public/`, `fan/internal/`]
		resDirs = [,]
	}
	
	@Target
	override Void compile() {
		// remove test pods from final build
		testPods := "afBounce afButter".split
		depends = depends.exclude { testPods.contains(it.split.first) }
		super.compile
	}
}
