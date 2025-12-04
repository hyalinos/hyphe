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

{ #category : 'as yet unclassified' }
HypheNECDetailMorph >> hypheExtraSpacing [
^10
]

{ #category : 'accessing' }
HypheNECDetailMorph >> titleBounds [
	^ self contentBounds top: self contentBounds top + 10 + self hypheExtraSpacing 
]
