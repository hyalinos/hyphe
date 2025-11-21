Class {
	#name : 'HyDataRepresentation',
	#superclass : 'HyEntity',
	#instVars : [
		'sourceFile',
		'meta',
		'packages'
	],
	#category : 'Hyphe-Data',
	#package : 'Hyphe',
	#tag : 'Data'
}

{ #category : 'as yet unclassified' }
HyDataRepresentation class >> createPackage [
	self shouldBeImplemented.
]

{ #category : 'adding' }
HyDataRepresentation >> addPackageNamed: packageName [

	(self hasPackageNamed: packageName) ifFalse: [ packages add: (HyPackage new name: packageName; yourself)].
	^ packages getPackage: packageName
]

{ #category : 'adding' }
HyDataRepresentation >> addPackageNamed: packageName withClasses: classesCollection [

	(self hasPackageNamed: packageName) ifFalse: [ 
		packages add: (HyPackage new name: packageName; classes: classesCollection; yourself).
		^ packages getPackageNamed: packageName
		]
	ifTrue: [ 
		^ (packages getPackageNamed: packageName) updateClasses: classesCollection.
	].
]

{ #category : 'adding' }
HyDataRepresentation >> addPackageObj: aPackageObj [

	(self hasPackageNamed: aPackageObj name) ifFalse: [ 
		packages add: aPackageObj.
		^ aPackageObj
		]
	ifTrue: [ 
		^ (self getPackageNamed: aPackageObj name) updateClasses: (aPackageObj classes)
	].
	 
]

{ #category : 'adding' }
HyDataRepresentation >> getPackageNamed: aPackage [

	^ (packages select: [ :p | p name = aPackage ]) first 
]

{ #category : 'adding' }
HyDataRepresentation >> hasPackageNamed: aPackage [

	^ packages anySatisfy: [ :p | p name = aPackage ] 
]

{ #category : 'adding' }
HyDataRepresentation >> initialize [ 

	packages := OrderedCollection new.
]

{ #category : 'adding' }
HyDataRepresentation >> packages [
	
	^ packages 
]

{ #category : 'adding' }
HyDataRepresentation >> removePackageNamed: packageName [

	(self hasPackageNamed: packageName) ifTrue: [ 
		packages remove: (self getPackageNamed: packageName) 
	] 
]

{ #category : 'adding' }
HyDataRepresentation >> toJSON [
]
