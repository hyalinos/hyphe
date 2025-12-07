"
I store and manage all available type information, received from github repository or acquired locally
"
Class {
	#name : 'Mycelium',
	#superclass : 'Object',
	#instVars : [
		'localData'
	],
	#classInstVars : [
		'defaultFolder',
		'systemTypes',
		'libraryTypes'
	],
	#category : 'Hyphe-Mycelium',
	#package : 'Hyphe',
	#tag : 'Mycelium'
}

{ #category : 'accessing' }
Mycelium class >> defaultFolder [

	^ defaultFolder
]

{ #category : 'accessing' }
Mycelium class >> defaultFolder: anObject [

	defaultFolder := anObject
]

{ #category : 'class initialization' }
Mycelium class >> initialize [

	defaultFolder := FileLocator imageDirectory / 'data'.
	systemTypes := HyDataRepresentation new.
	libraryTypes :=HyDataRepresentation new.
	
	
]

{ #category : 'accessing' }
Mycelium class >> libraryTypes [

	^ libraryTypes
]

{ #category : 'accessing' }
Mycelium class >> libraryTypes: anObject [

	libraryTypes := anObject
]

{ #category : 'accessing' }
Mycelium class >> systemTypes [

	^ systemTypes
]

{ #category : 'accessing' }
Mycelium class >> systemTypes: anObject [

	systemTypes := anObject
]

{ #category : 'initialization' }
Mycelium >> initialize [

	super initialize.
	localData := HyDataRepresentation new
]

{ #category : 'as yet unclassified' }
Mycelium >> install [

    Iceberg announcer 
        when: IcePackageLoaded
        do: [ :evt |
            Transcript
                show: 'Загрузился пакет: ';
                show: evt packageName;
                cr ]
		for: self.
]

{ #category : 'as yet unclassified' }
Mycelium >> storeToRepository [

	LibC system: 'cd ' , (IceRepository repositoryNamed: #mycelium) location fullName
		, ' && git add data/* && git commit -m "update data storage" && git push'
]
