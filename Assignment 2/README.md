# Codebase Genius

Codebase Genius is an autonomous system that generates high-quality markdown documentation for public GitHub repositories. It analyzes Python and Jac codebases, producing clear prose with explanatory diagrams.

## Features

- **Multi-Agent Architecture**: Cooperating agents handle specialized tasks.
- **Repository Mapping**: Clones repos, generates file trees, summarizes READMEs.
- **Code Analysis**: Parses code with Tree-sitter, builds Code Context Graphs (CCG) of relationships.
- **Documentation Generation**: Creates organized markdown with sections for overview, installation, usage, API reference, and diagrams.
- **HTTP API**: Expose functionality via a web server for easy integration.

## Agents

1. **Code Genius (Supervisor)**: Orchestrates workflow, delegates tasks, aggregates results.
2. **Repo Mapper**: Clones repository, produces file tree and README summary.
3. **Code Analyzer**: Parses source files, constructs CCG capturing function/class relationships.
4. **DocGenie**: Synthesizes structured data into well-organized markdown documentation.

## Installation

1. Clone this repository.
2. Install dependencies: `pip install -r requirements.txt`
3. Run the Streamlit app: `streamlit run FE/app.py`

## Usage

Enter a GitHub repository URL in the text input field and click "Generate Documentation". The app will process the repository and display the generated markdown documentation directly in the interface.

## Workflow

1. Accept GitHub URL, validate and clone.
2. Map repository structure and summarize README.
3. Analyze code iteratively, prioritizing entry points.
4. Generate final markdown documentation.
5. Save to `./outputs/<repo_name>/docs.md`

## Technologies

- Jac for multi-agent orchestration
- Tree-sitter for code parsing
- GitPython for repository cloning
- Streamlit for the web interface
