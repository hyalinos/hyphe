Class {
	#name : 'HypheIcebergEventHandler',
	#superclass : 'Object',
	#classVars : [
		'Subscriptions'
	],
	#category : 'Hyphe-Injection',
	#package : 'Hyphe',
	#tag : 'Injection'
}

{ #category : 'initialization' }
HypheIcebergEventHandler class >> initialize [
   self subscribe.

	
]

{ #category : 'event handlers' }
HypheIcebergEventHandler class >> onRepositoryChange: anIceLibGitRepository packages: anArrayOfIcePackage loadedPackages: anArrayOfIcePackageLoaded [
	"anArrayOfIcePackage contains all the packages (IcePackage) in the repository. 
	anArrayOfIcePackageLoaded contains only the packages (IcePackage) loaded after the repository change"
"Example code"	
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
self onRepositoryChange: ann repository packages: ann repository workingCopy packages loadedPackages: ann repository loadedPackages 
]

{ #category : 'event handlers' }
HypheIcebergEventHandler class >> onRepositoryModified: ann [
"ann -> is a IceRepositoryModified
ann repository -> is a IceLibGitRepository
ann repository loadedPackages -> an Array of IcePackage

"
   " Transcript 
        show: '[Hyphe] Repository modified: ', (ann repository ifNotNil: #name ifNil: ['(unknown)']);
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
self onRepositoryChange: ann repository packages: ann repository workingCopy packages loadedPackages: ann repository loadedPackages 
]

{ #category : 'event handlers' }
HypheIcebergEventHandler class >> onRepositoryPushed: ann [
"
    Transcript 
        show: '[Hyphe] Repository pushed: ', ann repository name;
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
self onRepositoryChange: ann repository packages: ann repository workingCopy packages loadedPackages: ann repository loadedPackages 
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
        when: IcePushed
        send: #onRepositoryPushed:
        to: self)
]

{ #category : 'subscribing' }
HypheIcebergEventHandler class >> unsubscribe [
    Subscriptions ifNotNil: [
        Subscriptions do: [ :sub | 
            sub announcer removeSubscription: sub ].
        Subscriptions := nil ]
]
