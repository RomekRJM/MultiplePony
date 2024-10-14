import { defineConfig } from 'vitest/config'

export default defineConfig({
    maxConcurrency: 1,
    sequence: {
        concurrent: false,
    },
    forks: {
        singleFork: true,
    },
})