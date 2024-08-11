# Description

Simple AI parser for processing files through an AI driven pipeline

# How it works

You create pipelines by adding numbered folders containing `step.txt` files. These files contain instructions for the AI to create the next file in the next numbered folder. If the next numbered folder does not exist or there is no `step.txt` file, a new file will not be created.

The pipeline will watch for any new changes in the `pipelines` directory.

# How to use

1. Create a new directory in the `pipelines` directory.
2. Add another directory called `0`.
3. Add another directory called `1`. This can be anything as long as it starts with 1, such as `1-first-result`
4. Add a file to `pipelines/your-pipeline/start` called step.txt.
5. Add the prompt that the AI will use to create the next file.