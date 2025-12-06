Class {
	#name : 'HypheNECSelectorEntry',
	#superclass : 'NECSelectorEntry',
	#category : 'Hyphe-Injection',
	#package : 'Hyphe',
	#tag : 'Injection'
}

{ #category : 'private' }
HypheNECSelectorEntry >> methodSourceDescription: aClass method: aCompiledMethod [
	^ HypheNECSymbolEntry overrideFor: self methodSourceDescription: aClass method: aCompiledMethod
]
