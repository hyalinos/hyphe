Extension { #name : 'NECSymbolEntry' }

{ #category : '*Hyphe' }
NECSymbolEntry class >> new [
|object|
(self == NECSymbolEntry )
	ifTrue: [ 
		object:= HypheNECSymbolEntry basicNew.
		object initialize.
		"Transcript show: self name."
		^object].
"Transcript show: self name."
object:= self basicNew.
object initialize.
^object.
]
