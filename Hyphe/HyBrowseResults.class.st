"
A presenter for showing inference results: package, class, method name, types, confidence level and sources

"
Class {
	#name : 'HyBrowseResults',
	#superclass : 'SpPresenter',
	#instVars : [
		'table',
		'data'
	],
	#category : 'Hyphe-UI',
	#package : 'Hyphe',
	#tag : 'UI'
}

{ #category : 'as yet unclassified' }
HyBrowseResults class >> openWithData: data [

	^ self new
		  setModelBeforeInitialization: data;
		  open
]

{ #category : 'accessing' }
HyBrowseResults >> data [

	^ data
]

{ #category : 'accessing' }
HyBrowseResults >> data: anObject [

	data := anObject
]

{ #category : 'layout' }
HyBrowseResults >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: table;
		  yourself
]

{ #category : 'initialization' }
HyBrowseResults >> initializePresenters [

	super initializePresenters.

	table := self newTable.
	table
		addColumn: (SpStringTableColumn
				 title: 'Package'
				 evaluated: [ :item | item at: 'packageName' ]) beSortable;
		addColumn: (SpStringTableColumn
				 title: 'Class'
				 evaluated: [ :item | item at: #className ]) beSortable;
		addColumn: (SpStringTableColumn
				 title: 'Method'
				 evaluated: [ :item | item at: #methodName ]) beSortable;
		addColumn: (SpStringTableColumn
				 title: 'Types'
				 evaluated: [ :item | (item at: #type) asArray joinUsing: ', ' ]) beSortable;
		""addColumn: (SpStringTableColumn
				 title: 'Confidence Level'
				 evaluated: [ :item | item at: #level ]) beSortable;
		""addColumn: (SpStringTableColumn
				 title: 'Score'
				 evaluated: [ :item | (item at: #confidence) asString ])
				beSortable;
		addColumn: (SpStringTableColumn
				 title: 'Sources'
				 evaluated: [ :item | (item at: #sources) asArray joinUsing: ', ' ]) beSortable
]

{ #category : 'initialization' }
HyBrowseResults >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: 'Confidence level configuration';
		initialExtent: 800 @ 300.
	table items: data
]

{ #category : 'layout' }
HyBrowseResults >> setModelBeforeInitialization: aCollection [
    
	data := aCollection
]

{ #category : 'accessing' }
HyBrowseResults >> table [

	^ table
]

{ #category : 'accessing' }
HyBrowseResults >> table: anObject [

	table := anObject
]
