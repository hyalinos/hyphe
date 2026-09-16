Extension { #name : 'CoGlobalEntry' }

{ #category : '*Hyphe' }
CoGlobalEntry class >> new [
    | object |
    (self == NECGlobalEntry)
        ifTrue: [
            object := HypheNECGlobalEntry basicNew.
            object initialize.
            ^ object ].
    object := self basicNew.
    object initialize.
    ^ object
]
