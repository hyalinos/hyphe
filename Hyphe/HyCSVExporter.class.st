Class {
	#name : 'HyCSVExporter',
	#superclass : 'Object',
	#category : 'Hyphe-Mycelium',
	#package : 'Hyphe',
	#tag : 'Mycelium'
}

{ #category : 'as yet unclassified' }
HyCSVExporter class >> collectionAddRow [ 
	
	^ #('add:' 'OrderedCollection' '*t' '0.9' 'High')

]

{ #category : 'as yet unclassified' }
HyCSVExporter class >> collectionCreateRow [ 
	
	^ #('new' 'OrderedCollection' 'OrderedCollection' '0.9' 'High')

]

{ #category : 'as yet unclassified' }
HyCSVExporter class >> exportToFile [ 
	
	|file data|
	file := HypheTypeInferenceStore csvPath.
	file exists ifTrue: [ file delete ].
	data := FlatDataCollector collect.
	 
	 file writeStreamDo: [ :stream |
		self exportToStream: stream data: data]
]

{ #category : 'as yet unclassified' }
HyCSVExporter class >> exportToStream: aStream data: anOrderedCollection [ 
	"Export the ordered collection of dictionaries to a stream as CSV"
	
	| writer |
	writer := (NeoCSVWriter on: aStream)
		fieldWriter: #raw;
		lineEndConvention: #crlf;
		yourself.
	
	writer nextPut: self headerRow.
	writer nextPut: self collectionAddRow.
	writer nextPut: self collectionCreateRow.
	writer nextPut: self yourselfRow.
	anOrderedCollection do: [ :dict |
		writer nextPut: (self rowFromDictionary: dict) ].
	
	^ writer
]

{ #category : 'as yet unclassified' }
HyCSVExporter class >> formatSourcesSet: aSet [ 
	"Format the sources set as a string.
	Multiple sources are separated by '; '"
	
	^ aSet 
		ifEmpty: [ '' ]
		ifNotEmpty: [ '; ' join: aSet asArray sort ]
]

{ #category : 'as yet unclassified' }
HyCSVExporter class >> formatTypeArray: anArray [ 
	"Format the type array as a string.
	Multiple types are separated by ' | ' to represent union types"
	
	^ anArray 
		ifEmpty: [ '' ]
		ifNotEmpty: [ ' | ' join: anArray ]
]

{ #category : 'as yet unclassified' }
HyCSVExporter class >> headerRow [ 
	
	^ #('methodName' 'class' 'inferredType' 'confidence' 'level')

]

{ #category : 'as yet unclassified' }
HyCSVExporter class >> rowFromDictionary: aDictionary [ 
	"Convert a dictionary entry to a CSV row (array of values)"
	
	^ Array 
		with: (aDictionary at: #methodName)
		with: (aDictionary at: #className)
		with: (self formatTypeArray: (aDictionary at: #type))
		with: (aDictionary at: #confidence) asString
		with: (aDictionary at: #level)


]

{ #category : 'as yet unclassified' }
HyCSVExporter class >> yourselfRow [ 
	
	^ #('yourself' '*r' '*r' '1' 'High')

]
