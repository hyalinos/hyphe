Class {
	#name : 'BaselineOfHyphe',
	#superclass : 'BaselineOf',
	#instVars : [
		'downloadedLibraryNames',
		'systemName'
	],
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
				with: [
					spec repository: 'github://pharo-contributions/MethodProxies/src' ];
				baseline: 'HypheTools'
				with: [ spec repository: 'github://hyalinos/hyphe-tools:main/src' ];
				baseline: 'TypeInfoTools'
				with: [ spec repository: 'github://lsafina/TypeInfoTools:main'.
					spec loads: 'dev' ].

			spec
				package: #Hyphe with: [
						spec requires:
								#( 'TypeMe' 'MethodProxies' ).
						spec includes: #( 'HypheTools' 'TypeInfoTools' ) ];
				package: #'Hyphe-Tests' with: [ spec requires: #( 'Hyphe' ) ];
				package: #Mycelium
				with: [ spec repository: 'github://hyalinos/mycelium:main' ].

			spec
				group: 'Core' with: #( 'Hyphe' 'Hyphe-Tests' );
				group: 'default' with: #( 'Hyphe' 'Hyphe-Tests' ).

			spec postLoadDoIt: #postload ]
]

{ #category : 'baselines' }
BaselineOfHyphe >> downloadAvailableTypes [

	|globalFolder systemFolder librariesFolder|
	
	globalFolder := 'https://raw.githubusercontent.com/hyalinos/mycelium/refs/heads/main/data/'.
	systemFolder := globalFolder , '/system/'.
	HyDataDownloader downloadFile: systemFolder, systemName saveWithName: systemName .
	
	librariesFolder := globalFolder , '/libraries/'.
	IceRepository registry do: [ :repo | 
		|repoName|
		
		repoName := repo name , '.json'.
		(HyDataDownloader downloadFile: librariesFolder , repoName saveWithName: repoName) ifTrue: [downloadedLibraryNames add: repoName].
	].
]

{ #category : 'baselines' }
BaselineOfHyphe >> initialize [ 

	super initialize.
	downloadedLibraryNames := OrderedCollection new..
	systemName := 'Pharo' , (SystemVersion current major) asString, '.json'.
]

{ #category : 'baselines' }
BaselineOfHyphe >> initializeTypeStorage [

	Mycelium initialize
		systemTypes: (HyDataRepresentation fromJsonFile: FileLocator imageDirectory / 'data' / systemName );
		libraryTypes:  ( downloadedLibraryNames collect: [:name |  name -> (HyDataRepresentation fromJsonFile: FileLocator imageDirectory / 'data' / name)]).
]

{ #category : 'baselines' }
BaselineOfHyphe >> postload [
	[ 
	self downloadAvailableTypes.
	self initializeTypeStorage.
	] on: Error do: [ :ex| Transcript showCr: 'Error on postload baseline: ',ex asString ]
	
]
