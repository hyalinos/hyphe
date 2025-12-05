Class {
	#name : 'HypheNECDetailMorph',
	#superclass : 'NECDetailMorph',
	#category : 'Hyphe-Injection',
	#package : 'Hyphe',
	#tag : 'Injection'
}

{ #category : 'accessing' }
HypheNECDetailMorph >> descriptionBounds [
	^ self contentBounds top: self contentBounds top + 30 + self hypheExtraSpacing 
]

{ #category : 'accessing' }
HypheNECDetailMorph >> entryDescription: anECEntryDescription [
"Override to use contentsWrapped: for TextMorph label (preserves text attributes)"
	| entryDescription |
	entryDescription := anECEntryDescription.
	title contents: (entryDescription title
		ifNil: [
			description bounds: self titleBounds.
			String new]
		ifNotNil: [
			description bounds: self descriptionBounds.
			entryDescription title]).
	description contentsWrapped: entryDescription description.
	label contentsWrapped: entryDescription label
]

{ #category : 'as yet unclassified' }
HypheNECDetailMorph >> hypheExtraSpacing [
^15
]

{ #category : 'initialization' }
HypheNECDetailMorph >> initialize [
"Use TextMorph for label instead of StringMorph to support colored text"
	| childBounds |
	super initialize.
	
	"Replace the StringMorph label with a TextMorph that supports text attributes"
	self removeMorph: label.
	label := TextMorph new.
	label autoFit: false.
	childBounds := self contentBounds.
	label bounds: childBounds.
	label font: self messageFont.
	self addMorphFront: label
]

{ #category : 'accessing' }
HypheNECDetailMorph >> titleBounds [
	^ self contentBounds top: self contentBounds top + 10 + self hypheExtraSpacing 
]
