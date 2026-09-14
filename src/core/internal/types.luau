--!strict

export type Source = {
    subscribers: { [Observer]: boolean },
}

export type Observer = {
    dependencies: { [Source]: boolean },
    invalidate: () -> (),
}

export type Owner = {
    disposables: { () -> () },
    disposed: boolean,
}

return {}