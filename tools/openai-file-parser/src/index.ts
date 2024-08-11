import * as fs from 'fs';
import * as path from 'path';
import {watch} from 'chokidar';
import OpenAI from "openai";
import {configDotenv} from "dotenv";
import {Pipeline, Step} from "./types";

configDotenv();

const client = new OpenAI({
    apiKey: process.env["OPENAI_API_KEY"],
});

const pipelinesDir = path.join(__dirname, '..', 'test', 'pipelines', 'strollers');

const pipeline = require (`${pipelinesDir}/pipeline.ts`).default;

function getCurrentSteps(directoryPath: string): Step<any>[] {
    const directoryName = path.basename(directoryPath);

    if (directoryName == 'origin') {
        return pipeline.steps.filter((step: Step<any>) => step.source === 'ORIGIN')
    }

    const stepsMatchingSource = pipeline.steps.filter((step: Step<any>) => step.source == directoryName);

    const directoryStepIndex = pipeline.steps.indexOf((step: Step<any>) => step.name === directoryName);
    if (directoryStepIndex < 0) {
        return stepsMatchingSource
    }

    const stepInFront = pipeline.steps[directoryStepIndex - 1];
    if (Object.hasOwn(stepInFront, "source")) {
        return stepsMatchingSource
    }

    return stepsMatchingSource.concat([stepInFront])

}

async function getNewFileContent(fileData: string, step: Step<any>): Promise<string> {
    const examples = step.examples ? `Examples: ${JSON.stringify(step.examples)}` : ""
    const systemPrompt = `${step.prompt}\n${examples}`;
    console.debug(`using system prompt: ${systemPrompt}`)
    const body: OpenAI.ChatCompletionCreateParamsNonStreaming = {
        messages: [
            {
                content: systemPrompt,
                role: "system"
            },
            {
                "content": fileData,
                "role": "user"
            }
        ],
        model: "gpt-4o-2024-08-06"
    }
    // return 'test'

    const res = await client.chat.completions.create(body);

    return res.choices[0].message.content || "" //TODO: handle no message
}

async function processStep(step: Step<any>, pipelineDirectoryPath: string, filePath: string, file: string) {
    const targetDirectoryName = step.name
    const targetDirectoryPath = path.join(pipelineDirectoryPath, targetDirectoryName);
    if (!fs.existsSync(targetDirectoryPath)) {
        fs.mkdirSync(targetDirectoryPath);
    }

    const sourceExtension = path.extname(filePath);
    const sourceFileName = path.basename(filePath, sourceExtension);
    const targetExtension = '.' + step.targetExtension || sourceExtension;
    const targetFileName = `${sourceFileName}-result` + targetExtension;

    const outputFile = path.join(pipelineDirectoryPath, targetDirectoryName, targetFileName);

    fs.writeFileSync(outputFile, await getNewFileContent(file, step));
    console.debug(`Output written to ${outputFile}`);
}

// Function to process step.txt and execute its instructions
const processSteps = async (pipelineDirectoryPath: string, filePath: string) => {
    const file = fs.readFileSync(filePath, 'utf-8');

    const steps = getCurrentSteps(path.dirname(filePath));

    await Promise.all(steps.map((step: Step<any>) => {
        return processStep(step, pipelineDirectoryPath, filePath, file);
    }))
};

// Watch the pipelines directory for changes
const watcher = watch(pipelinesDir, {ignored: /^\./, persistent: true});

async function processFile(filePath: string) {
    if (path.basename(filePath) === 'pipeline.ts') return;
    if (path.dirname(filePath) !== path.join(pipelinesDir, 'origin')) return;

    console.log(`processing file: ${filePath}`);
    await processSteps(pipelinesDir, filePath);
}

watcher
    .on('add', async filePath => {
        console.debug(`File ${filePath} has been added`);
        await processFile(filePath)
    })
    .on('change', async filePath => {
        console.debug(`File ${filePath} has been changed`);
        await processFile(filePath);
    })
    .on('error', error => console.log(`Watcher error: ${error}`));

console.log(`Watching for file changes in the pipeline ${pipelinesDir}`)