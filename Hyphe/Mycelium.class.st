"
I store and manage all available type information, received from github repository or acquired locally
"
Class {
	#name : 'Mycelium',
	#superclass : 'Object',
	#classInstVars : [
		'defaultFolder',
		'mycelium'
	],
	#category : 'Hyphe-Mycelium',
	#package : 'Hyphe',
	#tag : 'Mycelium'
}

{ #category : 'class initialization' }
Mycelium class >> addResults: results [

	Mycelium update.
]

{ #category : 'accessing' }
Mycelium class >> defaultFolder [

	^ defaultFolder
]

{ #category : 'accessing' }
Mycelium class >> defaultFolder: anObject [

	defaultFolder := anObject
]

{ #category : 'accessing' }
Mycelium class >> exportFromJson: filePath [

	mycelium fromJsonFile: filePath 
]

{ #category : 'accessing' }
Mycelium class >> exportToCSV [ 

	mycelium exportToCSV
]

{ #category : 'class initialization' }
Mycelium class >> initialize [

	defaultFolder := FileLocator imageDirectory / 'data'.
	mycelium := HyDataRepresentation. 
	
	
]

{ #category : 'accessing' }
Mycelium class >> mycelium [

	^ mycelium
]

{ #category : 'updating' }
Mycelium class >> update [

	HypheTypeInferenceStore reload.
	
	 
]
