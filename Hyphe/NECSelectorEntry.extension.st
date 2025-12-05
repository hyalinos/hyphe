Extension { #name : 'NECSelectorEntry' }

{ #category : '*Hyphe' }
NECSelectorEntry class >> new [
|object|
(self == NECSelectorEntry )
	ifTrue: [ 
		object:= HypheNECSelectorEntry basicNew.
		object initialize.
		^object].
object:= self basicNew.
object initialize.
^object.
]
