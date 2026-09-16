Extension { #name : 'CoLocalEntry' }

{ #category : '*Hyphe' }
CoLocalEntry class >> new [
    | object |
    (self == NECLocalEntry)
        ifTrue: [
            object := HypheNECLocalEntry basicNew.
            object initialize.
            ^ object ].
    object := self basicNew.
    object initialize.
    ^ object
]
