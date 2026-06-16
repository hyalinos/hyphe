Class {
	#name : 'J2InfererResultsExporter',
	#superclass : 'HyResultsExporter',
	#category : 'Hyphe-Export',
	#package : 'Hyphe',
	#tag : 'Export'
}

{ #category : 'initialization' }
J2InfererResultsExporter >> initialize [

	super initialize.
	defaultSource := 'J2Inferer'
]

{ #category : 'initialization' }
J2InfererResultsExporter >> preExport [

	| processedSource file |
	
	file := 'debug.txt' asFileReference.
	
	processedSource := OrderedCollection new.
	source do: [ :j2Class |
			| packageName className |
			packageName := j2Class package name.
			className := j2Class name.
	
			j2Class methods do: [ :value |
					| types |
					
					types := (self visitReturnValues: value) flattened.
					types ifNotEmpty: [
							processedSource add: {
									packageName.
									className.
									(value selector).
									types } ]
			]. 
	].
						
	self source: processedSource.
]

{ #category : 'visiting' }
J2InfererResultsExporter >> visirJ2ParameterRelationship: aJ2ParameterRelationship [
"do nothing for the moment, return empty"

	^ OrderedCollection new
		  
]

{ #category : 'visiting' }
J2InfererResultsExporter >> visitJ2Array: aJ2Array [ 
	
	^ OrderedCollection new.
]

{ #category : 'visiting' }
J2InfererResultsExporter >> visitJ2ArrayLiteral: aJ2ArrayLiteral [ 

	^ OrderedCollection new
]

{ #category : 'visiting' }
J2InfererResultsExporter >> visitJ2Block: aJ2Block [ 

	^ OrderedCollection new
]

{ #category : 'visiting' }
J2InfererResultsExporter >> visitJ2BlockParameter: aJ2BlockParameter [ 
"do nothing for the moment, return empty"

	^ OrderedCollection new
]

{ #category : 'visiting' }
J2InfererResultsExporter >> visitJ2Literal: aJ2Literal [ 
	
	^ OrderedCollection new add: aJ2Literal literalClass name; yourself 
]

{ #category : 'visiting' }
J2InfererResultsExporter >> visitJ2Message: aJ2Message [
"do nothing for the moment, return empty"

	^ OrderedCollection new
		  
]

{ #category : 'visiting' }
J2InfererResultsExporter >> visitJ2Self: anObject [
"method returns a receiver or do not return anything"

	^ #r asOrderedCollection
]

{ #category : 'visiting' }
J2InfererResultsExporter >> visitJ2Variable: aVariable [

	^ (aVariable subtypes reject: [:e | aVariable supertypes includes: e]) collect: [ :subtype | subtype accept: self ]
]

{ #category : 'initialization' }
J2InfererResultsExporter >> visitReturnValues: value [

	^ value returnValue accept: self
]
