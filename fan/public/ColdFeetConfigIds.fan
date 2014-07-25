
** [IoC Config]`http://www.fantomfactory.org/pods/afIocConfig` values for 'Cold Feet'.
const class ColdFeetConfigIds {

	** The prefix given to all URIs that are to be served by 'Cold Feet'. 
	** All incoming requests starting with this URI are processed by 'Cold Feet'.
	** Must be a directory URI starting and ending with a '/slash/'.
	** 
	** Defaults to '/coldFeet/'. Boring people may wish to change this to '/assets/'.
	static const Str assetPrefix	:= "afColdFeet.assetPrefix"

	** A 'Duration' specifying how long clients should cache assets for. 
	** 
	** Defaults to an aggressive 1 year: '365day'
	static const Str assetExpiresIn	:= "afColdFeet.assetExpiresIn"
}
