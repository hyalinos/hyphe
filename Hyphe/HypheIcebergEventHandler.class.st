Class {
	#name : 'HypheIcebergEventHandler',
	#superclass : 'Object',
	#classVars : [
		'Subscriptions'
	],
	#classInstVars : [
		'subscribed',
		'onNew'
	],
	#category : 'Hyphe-Injection',
	#package : 'Hyphe',
	#tag : 'Injection'
}

{ #category : 'subscribing' }
HypheIcebergEventHandler class >> addRepositories: dict [

	dict do: [:r | subscribed at: (r key) put: (r value) ].
]

{ #category : 'adding' }
HypheIcebergEventHandler class >> generateBasicSettingsAndAdd: anIceLibgitRepository [ 

	| config |
	
	config := Dictionary new.
	config at: #onPull put: true.
	config at: #onCommit put: true.
	config at: #onPush put: true.
	config at: #onPackageAdded put: true.
	config at: #onPackageRemoved put: true.
	
	subscribed at: anIceLibgitRepository put: config.
]

{ #category : 'initialization' }
HypheIcebergEventHandler class >> initialize [

	subscribed := Dictionary new.
	onNew := false.
   self subscribe.

	
]

{ #category : 'testing' }
HypheIcebergEventHandler class >> isObservedRepository: aReposir [
	
	^ subscribed contains: (aReposir key)
]

{ #category : 'subscribing' }
HypheIcebergEventHandler class >> monitorAllNewRepositories [

	onNew := true.
]

{ #category : 'accessing' }
HypheIcebergEventHandler class >> onNew [

	^ onNew
]

{ #category : 'accessing' }
HypheIcebergEventHandler class >> onNew: anObject [

	onNew := anObject
]

{ #category : 'as yet unclassified' }
HypheIcebergEventHandler class >> onPackageLoaded: ann [ 
	
self onRepositoryChange: ann repository packages: ann repository workingCopy packages loadedPackages: ann repository loadedPackages
]

{ #category : 'as yet unclassified' }
HypheIcebergEventHandler class >> onPackageUnloaded: ann [

	
self onRepositoryChange: ann repository packages: ann repository workingCopy packages loadedPackages: ann repository loadedPackages
]

{ #category : 'event handlers' }
HypheIcebergEventHandler class >> onRepositoryChange: anIceLibGitRepository packages: anArrayOfIcePackage loadedPackages: anArrayOfIcePackageLoaded [
	"anArrayOfIcePackage contains all the packages (IcePackage) in the repository. 
	anArrayOfIcePackageLoaded contains only the packages (IcePackage) loaded after the repository change"

Transcript showCr: '[Hyphe] Repository change ', anIceLibGitRepository name.
Transcript show: '[Hyphe] Repository packages: '.
        anArrayOfIcePackage isEmpty 
            ifTrue: [ Transcript show: '(none)' ]
            ifFalse: [
                anArrayOfIcePackage do: [ :pkg | 
                    Transcript show: pkg name ]
                    separatedBy: [ Transcript show: ', ' ] ].
        Transcript cr.
Transcript show: '[Hyphe] Repository packages loaded: '.
        anArrayOfIcePackageLoaded isEmpty 
            ifTrue: [ Transcript show: '(none)' ]
            ifFalse: [
                anArrayOfIcePackageLoaded do: [ :pkg | 
                    Transcript show: pkg name ]
                    separatedBy: [ Transcript show: ', ' ] ].
        Transcript cr.
]

{ #category : 'event handlers' }
HypheIcebergEventHandler class >> onRepositoryCommited: ann [

	| repo results|
	
	self onRepositoryChange: ann repository packages: ann repository workingCopy packages loadedPackages: ann repository loadedPackages.
	repo := ann repository.
	((subscribed at: repo ifAbsent: [ ]) at: #onCommit) ifTrue: [
		results := InferenceExecutor executeWithPackages: (repo loadedPackages) tools: (InferenceSettings toolNameToClass values)  mergeStrategy: (InferenceSettings defaultMergeStrategy).
		Mycelium libraryTypes: results.
		].
	
]

{ #category : 'event handlers' }
HypheIcebergEventHandler class >> onRepositoryCreated: ann [
"ann -> is a IceRepositoryModified
ann repository -> is a IceLibGitRepository
ann repository loadedPackages -> an Array of IcePackage"

    "Transcript 
        show: '[Hyphe] Repository created: ', ann repository name;
        cr.
ann repository ifNotNil: [
        | loadedPkgs |
        loadedPkgs := ann repository loadedPackages.
        Transcript show: '[Hyphe] Loaded packages: '.
        loadedPkgs isEmpty 
            ifTrue: [ Transcript show: '(none)' ]
            ifFalse: [
                loadedPkgs do: [ :pkg | 
                    Transcript show: pkg name ]
                    separatedBy: [ Transcript show: ', ' ] ].
        Transcript cr ]"


InferenceSettings addSubscribedRepository: (ann repository).
self generateBasicSettingsAndAdd: (ann repository).

self onRepositoryChange: ann repository packages: ann repository workingCopy packages loadedPackages: ann repository loadedPackages 
]

{ #category : 'event handlers' }
HypheIcebergEventHandler class >> onRepositoryForgotten: ann [
"ann repository -> is a IceLibGitRepository
ann repository workingCopy -> IceWorkingCopy
ann repository workingCopy packages -> array of IcePackage  with all the packages of the repo (loaded or not)
"
   " Transcript 
        show: '[Hyphe] Repository forgotten: ', (ann repository ifNotNil: #name ifNil: ['(all)']);
        cr.
ann repository ifNotNil: [
        | repoPackages |
        repoPackages := ann repository workingCopy packages ""array or IcePackage"".
        Transcript show: '[Hyphe] Packages of the repository: '.
        repoPackages isEmpty 
            ifTrue: [ Transcript show: '(none)' ]
            ifFalse: [
                repoPackages do: [ :pkg | 
                    Transcript show: pkg name ]
                    separatedBy: [ Transcript show: ', ' ] ].
        Transcript cr ]"

subscribed removeKey: (ann repository) ifAbsent: [  ].
InferenceSettings subscribedRepositories remove: (ann repository).

self onRepositoryChange: ann repository packages: ann repository workingCopy packages loadedPackages: ann repository loadedPackages 
]

{ #category : 'event handlers' }
HypheIcebergEventHandler class >> onRepositoryModified: ann [
	
self onRepositoryChange: ann repository packages: ann repository workingCopy packages loadedPackages: ann repository loadedPackages 

]

{ #category : 'event handlers' }
HypheIcebergEventHandler class >> onRepositoryPushed: ann [

	| repo results|

	self onRepositoryChange: ann repository packages: ann repository workingCopy packages loadedPackages: ann repository loadedPackages.
	
	repo := ann repository.
	((subscribed at: repo ifAbsent: [ ]) at: #onPush) ifTrue: [ 
		results := InferenceExecutor executeWithPackages: (repo loadedPackages) tools: (InferenceSettings toolNameToClass values)  mergeStrategy: (InferenceSettings defaultMergeStrategy).
		Mycelium libraryTypes: results.
	]. 
]

{ #category : 'subscribing' }
HypheIcebergEventHandler class >> removeRepositories: repos [

	repos do: [:r | subscribed removeKey: r ifAbsent: [ nil ]] 
]

{ #category : 'event handlers' }
HypheIcebergEventHandler class >> runInference: packages [

	
]

{ #category : 'subscribing' }
HypheIcebergEventHandler class >> subscribe [
    self unsubscribe.
    Subscriptions := OrderedCollection new.
    
    "Iceberg announcements"
    Subscriptions add: (Iceberg announcer weak
        when: IceRepositoryCreated
        send: #onRepositoryCreated:
        to: self).
    
    Subscriptions add: (Iceberg announcer weak
        when: IceRepositoryForgotten
        send: #onRepositoryForgotten:
        to: self).
    
    Subscriptions add: (Iceberg announcer weak
        when: IceRepositoryModified
        send: #onRepositoryModified:
        to: self).

	Subscriptions add: (Iceberg announcer weak
        when: IceCommited 
        send: #onRepositoryCommited:
        to: self).

	Subscriptions add: (Iceberg announcer weak
        when: IcePushed 
        send: #onRepositoryPushed:
        to: self).
    
    Subscriptions add: (Iceberg announcer weak
        when: IcePackageLoaded 
        send: #onPackageLoaded:
        to: self).

	Subscriptions add: (Iceberg announcer weak
        when: IcePackageUnloaded 
        send: #onPackageUnloaded:
        to: self).
]

{ #category : 'accessing' }
HypheIcebergEventHandler class >> subscribed [

	^ subscribed
]

{ #category : 'accessing' }
HypheIcebergEventHandler class >> subscribed: anObject [

	subscribed := anObject
]

{ #category : 'subscribing' }
HypheIcebergEventHandler class >> unsubscribe [
    Subscriptions ifNotNil: [
        Subscriptions do: [ :sub | 
            sub announcer removeSubscription: sub ].
        Subscriptions := nil ]
]
