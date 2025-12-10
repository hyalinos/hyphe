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
				baseline: 'TypeInfoTools' with: [
						spec repository: 'github://lsafina/TypeInfoTools:main'.
						spec loads: 'returntypes' ].

			spec
				package: #Hyphe with: [
						spec requires: #( 'TypeMe' ).
						spec includes: #( 'TypeInfoTools' ) ];
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

	Mycelium exportFromDisk. 
	Mycelium exportToCSV.
	Mycelium update. 
	
]

{ #category : 'baselines' }
BaselineOfHyphe >> postload [
	[ 
	self downloadAvailableTypes.
	self initializeTypeStorage.
	] on: Error do: [ :ex| Transcript showCr: 'Error on postload baseline: ',ex asString ]
	
]
