Class {
	#name : 'HyDataRepresentation',
	#superclass : 'Object',
	#classInstVars : [
		'filePath',
		'metadata',
		'packages'
	],
	#category : 'Hyphe-Data',
	#package : 'Hyphe',
	#tag : 'Data'
}

{ #category : 'visiting' }
HyDataRepresentation class >> accept: visitor [

	packages do: [:p | visitor visitPackage: p ]
]

{ #category : 'adding' }
HyDataRepresentation class >> addPackage: aPackageObj [

	(self hasPackageNamed: aPackageObj name)
		ifFalse: [
				self packages add: aPackageObj.
				^ aPackageObj ]
		ifTrue: [
				^ (self getPackageNamed: aPackageObj name)
					  updateClasses: aPackageObj classes ]
]

{ #category : 'adding' }
HyDataRepresentation class >> addPackageNamed: packageName [


	(self hasPackageNamed: packageName) ifFalse: [
			self packages add: (HyPackage new
					 name: packageName;
					 yourself) ].
	^ packages getPackageNamed: packageName
]

{ #category : 'adding' }
HyDataRepresentation class >> addPackageNamed: packageName withClasses: classesCollection [


	(self hasPackageNamed: packageName)
		ifFalse: [
				packages add: (HyPackage new
						 name: packageName;
						 classes: classesCollection;
						 yourself).
				^ packages getPackageNamed: packageName ]
		ifTrue: [
				^ (packages getPackageNamed: packageName)
					  updateClasses: classesCollection ]
]

{ #category : 'accessing' }
HyDataRepresentation class >> asJsonDictionary [

	^ OrderedCollection new
		  addAll: (packages collect: [ :pkg |
					   pkg asJsonDictionary ]);
		  yourself
]

{ #category : 'adding' }
HyDataRepresentation class >> defaultFilePath [

	^ FileLocator imageDirectory / 'data' / 'mycelium.json'
]

{ #category : 'accessing' }
HyDataRepresentation class >> exportToJson [

	^ self exportToJsonFile: filePath
]

{ #category : 'accessing' }
HyDataRepresentation class >> exportToJsonFile: aPath [

	| jsonDict file  |
	
	jsonDict := self asJsonDictionary.
	aPath asFileReference ensureDelete.
	file := aPath asFileReference.
	file writeStreamDo: [ :stream |
			(NeoJSONWriter on: stream)
				prettyPrint: true;
				nextPut: jsonDict ].
	^ file
]

{ #category : 'accessing' }
HyDataRepresentation class >> exportToJsonString [

	| jsonDict  |

	jsonDict := self asJsonDictionary.
	^ String streamContents: [ :stream |
			  (NeoJSONWriter on: stream)
				  prettyPrint: true;
				  nextPut: jsonDict ]
]

{ #category : 'accessing' }
HyDataRepresentation class >> filePath [

	^ filePath
]

{ #category : 'accessing' }
HyDataRepresentation class >> filePath: anObject [

	filePath := anObject
]

{ #category : 'instance creation' }
HyDataRepresentation class >> fromJsonFile: aPath [

	| data |
	aPath readStreamDo: [ :stream |
		data := (NeoJSONReader on: stream) next ].
	
	data do: [ :packageDict |
		self addPackage: (HyPackage fromJsonDictionary: packageDict) ].

]

{ #category : 'adding' }
HyDataRepresentation class >> getPackageNamed: aPackage [


	^ (packages select: [ :p | p name = aPackage ])
		  first
]

{ #category : 'adding' }
HyDataRepresentation class >> hasPackageNamed: aPackage [

	^ packages anySatisfy: [ :p |
		  p name = aPackage ]
]

{ #category : 'adding' }
HyDataRepresentation class >> initialize [

	packages := OrderedCollection new.
	filePath := self defaultFilePath
]

{ #category : 'accessing' }
HyDataRepresentation class >> metadata [

	^  metadata
]

{ #category : 'accessing' }
HyDataRepresentation class >> metadata: anObject [

  metadata := anObject
]

{ #category : 'adding' }
HyDataRepresentation class >> packages [

	^ packages
]

{ #category : 'accessing' }
HyDataRepresentation class >> packages: anObject [

	packages := anObject
]

{ #category : 'adding' }
HyDataRepresentation class >> removePackageNamed: packageName [

	(self hasPackageNamed: packageName) ifTrue: [
			packages remove:
				(self getPackageNamed: packageName) ]
]

{ #category : 'accessing' }
HyDataRepresentation class >> save [

	^ self exportToJsonFile: filePath
]
