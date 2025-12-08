Class {
	#name : 'InferenceExecutor',
	#superclass : 'Object',
	#instVars : [
		'packages',
		'tools',
		'confidenceMap',
		'results',
		'merger'
	],
	#category : 'Hyphe-Inference',
	#package : 'Hyphe',
	#tag : 'Inference'
}

{ #category : 'as yet unclassified' }
InferenceExecutor class >> buildConfidenceMap [
    | map settings |
    map := Dictionary new.
    settings := InferenceSettings inferenceTools.
    
    settings do: [:pair |
        map at: pair first put: pair second asNumber
    ].
    
    ^ map
]

{ #category : 'as yet unclassified' }
InferenceExecutor class >> executeWithPackages: packageNames tools: selectedTools mergeStrategy: aStrategy [


  	 ^ self new
		packages:	packageNames;
		tools: selectedTools;
		confidenceMap: self buildConfidenceMap;
	   merger: (HyTypeMerger newWithStrategy: aStrategy);
	   results: Dictionary new;
		execute.
    
]

{ #category : 'as yet unclassified' }
InferenceExecutor class >> groupForPresenter: aCollection [ 
	
	aCollection flatCollect: [ :d |  d hyData packages flatCollect: [:p | p classes flatCollect: [ :c | c methods flatCollect: [ :m |
					1 halt.
					m
					
					 ] ]  ] ]
]

{ #category : 'accessing' }
InferenceExecutor >> confidenceMap [

	^ confidenceMap
]

{ #category : 'accessing' }
InferenceExecutor >> confidenceMap: anObject [

	confidenceMap := anObject
]

{ #category : 'as yet unclassified' }
InferenceExecutor >> execute [

    | repoGroups |

    repoGroups := self groupPackagesByRepository: (packages collect: #name).
    repoGroups keysAndValuesDo: [:repoName :repoPackages |
        results at: repoName put: (self processRepository: repoName packages: repoPackages)
    ].

    ^ results
]

{ #category : 'as yet unclassified' }
InferenceExecutor >> findRepositoryForPackage: packageName [

    | package workingCopy |
    package := PackageOrganizer default packageNamed: packageName ifAbsent: [nil].
    package ifNil: [^ 'system'].
    
    "Try to find Iceberg repository"
    workingCopy := package mcWorkingCopy.
    workingCopy ifNotNil: [
        | repository |
        repository := IceRepository registeredRepositoryIncludingPackage: package.
        repository ifNotNil: [^ repository name]
    ].
    
    "If no git repository found, it's a system package"
    ^ 'system'
]

{ #category : 'as yet unclassified' }
InferenceExecutor >> groupPackagesByRepository: packageNames [
    | groups |
    groups := Dictionary new.
    
    packageNames do: [:packageName |
        | repo |
        repo := self findRepositoryForPackage: packageName.
        (groups at: repo ifAbsentPut: [OrderedCollection new]) add: packageName
    ].
    
    ^ groups
]

{ #category : 'accessing' }
InferenceExecutor >> merger [

	^ merger
]

{ #category : 'accessing' }
InferenceExecutor >> merger: anObject [

	merger := anObject
]

{ #category : 'accessing' }
InferenceExecutor >> packages [

	^ packages
]

{ #category : 'accessing' }
InferenceExecutor >> packages: anObject [

	packages := anObject
]

{ #category : 'as yet unclassified' }
InferenceExecutor >> processRepository: repoName packages: packageNames [
    | inferenceResults  |
    
	inferenceResults := HyDataRepresentation new.
    
    tools do: [:toolClass |
        | result rawResult |
        rawResult := toolClass runHypheInference: packageNames. 
		  toolClass hypheExporter export: rawResult to: inferenceResults .
		].

	 ^ merger mergeHyTypes: inferenceResults.
]

{ #category : 'accessing' }
InferenceExecutor >> results [

	^ results
]

{ #category : 'accessing' }
InferenceExecutor >> results: anObject [

	results := anObject
]

{ #category : 'accessing' }
InferenceExecutor >> tools [

	^ tools
]

{ #category : 'accessing' }
InferenceExecutor >> tools: anObject [

	tools := anObject
]
