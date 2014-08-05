using build

class Build : BuildPod {

	new make() {
		podName = "afColdFeet"
		summary = "An asset caching strategy for your Bed Application"
		version = Version("1.2.3")

		meta = [
			"proj.name"		: "Cold Feet",
			"afIoc.module"	: "afColdFeet::ColdFeetModule",
			"internal"		: "true",
			"tags"			: "web",
			"repo.private"	: "true"
		]

		depends = [
			"sys 1.0", 
			"concurrent 1.0", 
			
			// ---- Core ------------------------
			"afConcurrent 1.0.6+", 
			"afIoc 1.7.6+", 
			"afIocConfig 1.0.12.1+", 
			"afIocEnv 1.0.10.1+",
			
			// ---- Web -------------------------
			"afBedSheet 1.3.13+",
			
			// ---- Test ------------------------
			"afBounce 1.0.10+",
			"afButter 1.0.2+"
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
