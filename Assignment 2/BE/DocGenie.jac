import:py "dotenv.load_dotenv";
import:py "os";
import:py "json";

walker DocGenie {
    has output_dir: str = "./outputs";

    can generate_docs(repo_name: str, file_tree: dict, readme_summary: str, ccg: dict) -> str {
        os.makedirs(os.path.join(self.output_dir, repo_name), exist_ok=True);
        docs_path = os.path.join(self.output_dir, repo_name, "docs.md");
        with open(docs_path, 'w', encoding='utf-8') as f:
            f.write(self.build_markdown(repo_name, file_tree, readme_summary, ccg));
        return docs_path;
    }

    can build_markdown(repo_name: str, file_tree: dict, readme_summary: str, ccg: dict) -> str {
        md = f"# {repo_name} Documentation\n\n";
        md += "## Project Overview\n\n";
        md += readme_summary + "\n\n";
        md += "## File Structure\n\n";
        md += self.render_file_tree(file_tree) + "\n\n";
        md += "## Installation\n\n";
        md += "Clone the repository and install dependencies.\n\n";
        md += "## Usage\n\n";
        md += "Refer to the README for usage instructions.\n\n";
        md += "## API Reference\n\n";
        md += self.render_api(ccg) + "\n\n";
        md += "## Code Relationships\n\n";
        md += self.render_diagram(ccg) + "\n\n";
        return md;
    }

    can render_file_tree(tree: dict) -> str {
        md = "";
        for path, content in tree.items():
            md += f"- {path}/\n";
            for d in content["dirs"]:
                md += f"  - {d}/\n";
            for f in content["files"]:
                md += f"  - {f}\n";
        return md;
    }

    can render_api(ccg: dict) -> str {
        md = "";
        for name, info in ccg.items():
            md += f"### {name} ({info['type']})\n";
            md += f"File: {info['file']}\n";
            if info["calls"]:
                md += f"Calls: {', '.join(info['calls'])}\n";
            if info["inherits"]:
                md += f"Inherits: {', '.join(info['inherits'])}\n";
            md += "\n";
        return md;
    }

    can render_diagram(ccg: dict) -> str {
        # Simple text-based diagram
        md = "```\n";
        for name, info in ccg.items():
            md += f"{name}\n";
            for call in info["calls"]:
                md += f"  -> {call}\n";
        md += "```\n";
        return md;
    }
}
