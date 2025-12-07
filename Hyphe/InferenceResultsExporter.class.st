Class {
	#name : 'InferenceResultsExporter',
	#superclass : 'Object',
	#instVars : [
		'hyDataRepresentation',
		'source',
		'defaultSource',
		'defaultConfidence'
	],
	#category : 'Hyphe-Export',
	#package : 'Hyphe',
	#tag : 'Export'
}

{ #category : 'as yet unclassified' }
InferenceResultsExporter class >> export: results to: aHyDataRepresentation [

    ^ self new
        source: results;
        hyDataRepresentation: aHyDataRepresentation;
        export;
        yourself
]

{ #category : 'as yet unclassified' }
InferenceResultsExporter class >> export: results toFile: aFilePath [

    | hyData |
    hyData := aFilePath asFileReference exists
        ifTrue: [ HyDataRepresentation fromJsonFile: aFilePath ]
        ifFalse: [ 
            HyDataRepresentation new 
                filePath: aFilePath;
                yourself ].
    ^ self export: results to: hyData
]

{ #category : 'initialization' }
InferenceResultsExporter >> addReturnTypes: typeSet toMethod: method [
     
	 ((method returnTypes) anySatisfy: [:t | (typeSet includes: t name) and: (t source = defaultSource)])
	 ifFalse: [
		| newType |
		newType := HyType new
		name: (typeSet anyOne) asSymbol;
 		source: defaultSource asSymbol;
 	   yourself.
      method addReturnType: newType 
	]
]

{ #category : 'accessing' }
InferenceResultsExporter >> defaultConfidence [

	^ defaultConfidence
]

{ #category : 'accessing' }
InferenceResultsExporter >> defaultConfidence: anObject [

	defaultConfidence := anObject
]

{ #category : 'accessing' }
InferenceResultsExporter >> defaultSource [

	^ defaultSource
]

{ #category : 'accessing' }
InferenceResultsExporter >> defaultSource: anObject [

	defaultSource := anObject
]

{ #category : 'initialization' }
InferenceResultsExporter >> doExport [
    "Main export logic - subclasses must implement"
    self subclassResponsibility
]

{ #category : 'initialization' }
InferenceResultsExporter >> export [

	self preExport.
	self doExport.
	self postExport.
	^ hyDataRepresentation
]

{ #category : 'initialization' }
InferenceResultsExporter >> findClass: className inPackage: packageName [
    "Find class by name in package"
    | package |
    package := self findPackage: packageName.
    package ifNil: [ ^ nil ].
    ^ package classes 
        detect: [ :cls | cls name = className ]
        ifNone: [ nil ]
]

{ #category : 'initialization' }
InferenceResultsExporter >> findMethod: methodName inClass: className package: packageName [
	"Find method by name in class"

	| class |
	class := self findClass: className inPackage: packageName.
	class ifNil: [ ^ nil ].
	class methods detect: [ :m | m name = methodName ] ifNone: [ nil ]
]

{ #category : 'initialization' }
InferenceResultsExporter >> findOrCreateClass: className inPackage: package [
    "Find existing class or create new one"
    | class |
    class := package classes 
        detect: [ :cls | cls name = className ]
        ifNone: [ nil ].
    
    class ifNil: [
        class := HyClass new
            name: className;
            superclass: '?';
            yourself.
        package addClass: class ].
    
    ^ class
]

{ #category : 'initialization' }
InferenceResultsExporter >> findOrCreatePackage: packageName [
    "Find existing package or create new one"
    | package |
    package := hyDataRepresentation packages 
        detect: [ :pkg | pkg name = packageName ]
        ifNone: [ nil ].
    
    package ifNil: [
        package := HyPackage new 
            name: packageName;
            yourself.
        hyDataRepresentation addPackage: package ].
    
    ^ package
]

{ #category : 'initialization' }
InferenceResultsExporter >> findPackage: packageName [
    "Find package by name"
    ^ hyDataRepresentation packages 
        detect: [ :pkg | pkg name = packageName ]
        ifNone: [ nil ]
]

{ #category : 'accessing' }
InferenceResultsExporter >> hyDataRepresentation [

	^ hyDataRepresentation
]

{ #category : 'accessing' }
InferenceResultsExporter >> hyDataRepresentation: anObject [

	hyDataRepresentation := anObject
]

{ #category : 'initialization' }
InferenceResultsExporter >> initialize [
    super initialize.
    self initializeDefaults
]

{ #category : 'initialization' }
InferenceResultsExporter >> initializeDefaults [
    "Subclasses override to set their default source and confidence"

    defaultSource := 'Unknown'.
    defaultConfidence := 0.5
]

{ #category : 'initialization' }
InferenceResultsExporter >> postExport [
	"Hook for post-export operations"
	"Subclasses can override"

	
]

{ #category : 'initialization' }
InferenceResultsExporter >> preExport [
	"Hook for pre-export operations"
	"Subclasses can override"

	
]

{ #category : 'initialization' }
InferenceResultsExporter >> save [
    "Save the updated HyDataRepresentation"
    hyDataRepresentation exportToJson
]

{ #category : 'initialization' }
InferenceResultsExporter >> saveToFile: aFilePath [
    "Save the updated HyDataRepresentation to a specific file"
    hyDataRepresentation exportToJsonFile: aFilePath
]

{ #category : 'accessing' }
InferenceResultsExporter >> source [

	^ source
]

{ #category : 'accessing' }
InferenceResultsExporter >> source: anObject [

	source := anObject
]
