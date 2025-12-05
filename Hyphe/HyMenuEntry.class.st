Class {
	#name : 'HyMenuEntry',
	#superclass : 'Object',
	#category : 'Hyphe-UI',
	#package : 'Hyphe',
	#tag : 'UI'
}

{ #category : 'world menu' }
HyMenuEntry class >> hyalinosIcon [
	| form canvas color |
	
	form := Form extent: 16 @ 16 depth: 32.
	form fillColor: Color transparent.
	canvas := form getCanvas. 
	color := Color r: 0.29 g: 0.59 b: 0.82.
	canvas
		drawPolygon: {
				(8 @ 2).
				(14 @ 8).
				(8 @ 14).
				(2 @ 8).
				(8 @ 2) }
		color: color
		borderWidth: 1
		borderColor: color darker.

	^ form

]

{ #category : 'world menu' }
HyMenuEntry class >> initialize [
   
    self installKeymap.
]

{ #category : 'world menu' }
HyMenuEntry class >> installKeymap [

	(KMRepository default addCategory: 'MyTool Shortcuts') addKeymapEntry:
		(KMKeymap named: #Hyalinos shortcut: $o meta asKeyCombination , $h asKeyCombination action: [ HyMainPresenter new open ])
]

{ #category : 'world menu' }
HyMenuEntry class >> menuCommandOn: aBuilder [

	<worldMenu>
	(aBuilder item: #Hyalinos)
		parent: #Testing;
		action: [ HyMainPresenter new open ];
		order: 3;
		keyText: 'o, h';
		icon: (self hyalinosIcon);
		withSeparatorAfter
]
