using build

class Build : BuildPod {

	new make() {
		podName = "afColdFeet"
		summary = "An asset caching strategy for your Bed App"
		version = Version("1.1.4")

		meta = [
			"proj.name"		: "Cold Feet",
			"afIoc.module"	: "afColdFeet::ColdFeetModule",
			"internal"		: "true",
			"tags"			: "web",
			"repo.private"	: "false"
		]

		depends = [
			"sys 1.0", 
			"concurrent 1.0", 
			
			// ---- Core ------------------------
			"afConcurrent 1.0.6+", 
			"afIoc 1.6.2+", 
			"afIocConfig 1.0.6+", 
			"afIocEnv 1.0.4+",
			
			// ---- Web -------------------------
			"afBedSheet 1.3.8+",
			
			// ---- Test ------------------------
			"afBounce 1.0.2+",
			"afButter 0.0.6+"
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
