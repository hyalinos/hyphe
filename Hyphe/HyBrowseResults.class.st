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
		data: data;
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
	"Define the layout of the presenter"
	
	^ SpBoxLayout newTopToBottom
		add: table;
		yourself
]

{ #category : 'initialization' }
HyBrowseResults >> initializePresenters [

	table := self newTable.
	table
		addColumn: (SpStringTableColumn title: 'Package' evaluated: [ :item | item package ]) beSortable;
		addColumn: (SpStringTableColumn title: 'Class' evaluated: [ :item | item className ]) beSortable;
		addColumn: (SpStringTableColumn title: 'Name' evaluated: [ :item | item name ]) beSortable;
		addColumn: (SpStringTableColumn title: 'Type' evaluated: [ :item | item type ]) beSortable;
		addColumn: (SpStringTableColumn title: 'Confidence Level' evaluated: [ :item | item  ]) beSortable;
		addColumn: (SpStringTableColumn title: 'Score' evaluated: [ :item | item score ]) beSortable";
		addColumn: (SpStringTableColumn title: 'Sources' evaluated: [ :item | item sources ]) beSortable". 
		
		table items: data.
]

{ #category : 'accessing' }
HyBrowseResults >> table [

	^ table
]

{ #category : 'accessing' }
HyBrowseResults >> table: anObject [

	table := anObject
]
