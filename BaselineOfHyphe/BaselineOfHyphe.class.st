Class {
	#name : 'BaselineOfHyphe',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfHyphe',
	#package : 'BaselineOfHyphe'
}

{ #category : 'baselines' }
BaselineOfHyphe >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec
				baseline: 'TypeMe'
					with: [ spec repository: 'github://lsafina/typeMe:main' ];
    			baseline: 'MethodProxies' 
   	 				with: [ spec repository: 'github://pharo-contributions/MethodProxies/src' ];
				baseline: 'TypeInfoTools'
					with: [ spec repository: 'github://lsafina/TypeInfoTools:main'; loads: #(returntypes) ].
			
			spec
				package: #Hyphe
					with: [ spec requires: #( 'TypeMe' 'MethodProxies' 'TypeInfoTools') ];
				package: #'Hyphe-Tests' 
					with: [ spec requires: #( 'Hyphe' ) ];
				package: #Mycelium 
					with: [ spec repository: 'github://hyalinos/mycelium:main' ].
		
			spec
				group: 'Core' with: #( 'Hyphe' 'Hyphe-Tests' );
				group: 'default' with: #( 'Hyphe' 'Hyphe-Tests' ) 
	]
]
