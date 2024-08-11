type defaultSteps = 'ORIGIN' | 'PREVIOUS'

export type Pipeline<T> = {
    steps: Step<T>[]
}

export type Step<T> = {
    name: T // Name of step
    prompt: string  // Prompt used to parse files from this step to the next
    source?: T | defaultSteps
    examples?: Example[] // Examples used by prompt
    target?: T // Directory name to place parsed files
    targetExtension?: string // Extension to use for parsed files. Defaults to same as source extension
}

type Example = {
    given: string
    then: string
}