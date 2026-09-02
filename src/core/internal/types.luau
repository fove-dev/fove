--!strict

export type Source = {
    subscribers: { [Observer]: boolean },
}

export type Observer = {
    dependencies: { [Source]: boolean },
    invalidate: () -> (),
}

return table.create(0)