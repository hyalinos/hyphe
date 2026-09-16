Extension { #name : 'CoSpecialVariableEntry' }

{ #category : '*Hyphe' }
CoSpecialVariableEntry class >> new [
    | object |
    (self == NECSpecialVariableEntry)
        ifTrue: [
            object := HypheNECSpecialVariableEntry basicNew.
            object initialize.
            ^ object ].
    object := self basicNew.
    object initialize.
    ^ object
]
