import {defineConfig} from "vitest/dist/config";

export default defineConfig({
    test: {
        poolOptions: {
            forks: {
                singleFork: true,
            },
        },
        maxWorkers: 1,
    },
});