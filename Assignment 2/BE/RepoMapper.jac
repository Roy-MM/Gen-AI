import:py "git.Repo";
import:py "os";
import:py "tempfile";
import:py "shutil";
import:py "pathlib.Path";

walker RepoMapper {
    has repo_url: str;
    has temp_dir: str;
    has file_tree: dict;
    has readme_summary: str;

    can map_repo(repo_url: str) -> dict {
        self.repo_url = repo_url;
        self.temp_dir = tempfile.mkdtemp();
        try {
            Repo.clone_from(repo_url, self.temp_dir);
            self.file_tree = self.generate_file_tree(self.temp_dir);
            self.readme_summary = self.summarize_readme(self.temp_dir);
            return {"file_tree": self.file_tree, "readme_summary": self.readme_summary};
        } catch e {
            return {"error": str(e)};
        }
    }

    can generate_file_tree(root_path: str) -> dict {
        tree = {};
        ignore_dirs = {".git", "node_modules", "__pycache__", ".venv", "venv"};
        for root, dirs, files in os.walk(root_path):
            dirs[:] = [d for d in dirs if d not in ignore_dirs];
            rel_root = os.path.relpath(root, root_path);
            if rel_root == ".":
                rel_root = "";
            tree[rel_root] = {"dirs": dirs, "files": files};
        return tree;
    }

    can summarize_readme(root_path: str) -> str {
        readme_files = ["README.md", "readme.md", "README.txt", "readme.txt"];
        for rf in readme_files:
            readme_path = os.path.join(root_path, rf);
            if os.path.exists(readme_path):
                with open(readme_path, 'r', encoding='utf-8') as f:
                    content = f.read();
                    # Simple summary: first 500 chars
                    return content[:500] + "..." if len(content) > 500 else content;
        return "No README found.";
    }

    can cleanup() {
        if os.path.exists(self.temp_dir):
            shutil.rmtree(self.temp_dir);
    }
}
