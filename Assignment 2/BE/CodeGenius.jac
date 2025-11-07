import:py "os";
import:py "requests";
import:py "urllib.parse";

walker CodeGenius {
    has repo_url: str;
    has repo_name: str;
    has repo_path: str;
    has file_tree: dict;
    has readme_summary: str;
    has ccg: dict;
    has docs_path: str;

    can process_repo(repo_url: str) -> str {
        self.repo_url = repo_url;
        if not self.validate_url(repo_url):
            return "Invalid GitHub URL";

        self.repo_name = self.extract_repo_name(repo_url);

        # Delegate to RepoMapper
        repo_mapper = spawn RepoMapper();
        mapping_result = repo_mapper.map_repo(repo_url);
        if "error" in mapping_result:
            return mapping_result["error"];
        self.file_tree = mapping_result["file_tree"];
        self.readme_summary = mapping_result["readme_summary"];
        self.repo_path = repo_mapper.temp_dir;

        # Plan analysis: prioritize entry points
        entry_points = self.identify_entry_points(self.file_tree);
        analyzed_files = set();

        # Delegate to CodeAnalyzer iteratively
        code_analyzer = spawn CodeAnalyzer();
        for ep in entry_points:
            if ep not in analyzed_files:
                # Analyze entry point and related
                code_analyzer.analyze_code(self.repo_path);  # For simplicity, analyze all, but in real could be selective
                analyzed_files.add(ep);

        self.ccg = code_analyzer.ccg;

        # Delegate to DocGenie
        doc_genie = spawn DocGenie();
        self.docs_path = doc_genie.generate_docs(self.repo_name, self.file_tree, self.readme_summary, self.ccg);

        # Cleanup
        repo_mapper.cleanup();

        return self.docs_path;
    }

    can validate_url(url: str) -> bool {
        parsed = urlparse(url);
        return parsed.scheme in ['http', 'https'] and 'github.com' in parsed.netloc;
    }

    can extract_repo_name(url: str) -> str {
        parsed = urlparse(url);
        return parsed.path.strip('/').split('/')[-1];
    }

    can identify_entry_points(file_tree: dict) -> list {
        entry_files = ['main.py', 'app.py', '__main__.py', 'run.py'];
        entries = [];
        for path, content in file_tree.items():
            for f in content["files"]:
                if f in entry_files:
                    entries.append(os.path.join(path, f));
        return entries;
    }
}
