--!strict

return {
    batch = require(`@self/core/batch`),
    signal = require(`@self/core/signal`),
    effect = require(`@self/core/effect`),
    untrack = require(`@self/core/untrack`),
    computed = require(`@self/core/computed`),
    onCleanup = require(`@self/core/onCleanup`),
}