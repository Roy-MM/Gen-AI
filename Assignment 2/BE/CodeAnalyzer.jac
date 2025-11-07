import:py "os";
import:py "ast";
import:py "inspect";

walker CodeAnalyzer {
    has ccg: dict;  # Code Context Graph: {node: {calls: [], inherits: [], composes: []}}

    can analyze_code(repo_path: str) -> dict {
        self.ccg = {};
        self.parse_repo(repo_path);
        return self.ccg;
    }

    can parse_repo(repo_path: str) {
        for root, dirs, files in os.walk(repo_path):
            dirs[:] = [d for d in dirs if not d.startswith('.') and d not in ['node_modules', '__pycache__']];
            for file in files:
                if file.endswith('.py'):
                    file_path = os.path.join(root, file);
                    self.parse_file(file_path);
    }

    can parse_file(file_path: str) {
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                code = f.read();
            tree = ast.parse(code);
            self.extract_relationships(tree, file_path);
        except SyntaxError:
            pass;  # Skip files with syntax errors
    }

    can extract_relationships(node, file_path: str) {
        if isinstance(node, ast.ClassDef):
            class_name = node.name;
            self.ccg[class_name] = {"type": "class", "file": file_path, "calls": [], "inherits": [], "composes": []};
            # Inheritance
            for base in node.bases:
                if isinstance(base, ast.Name):
                    self.ccg[class_name]["inherits"].append(base.id);
        elif isinstance(node, ast.FunctionDef):
            func_name = node.name;
            self.ccg[func_name] = {"type": "function", "file": file_path, "calls": [], "inherits": [], "composes": []};
            # Calls
            for child in ast.walk(node):
                if isinstance(child, ast.Call):
                    if isinstance(child.func, ast.Name):
                        self.ccg[func_name]["calls"].append(child.func.id);
        for child in ast.iter_child_nodes(node):
            self.extract_relationships(child, file_path);
    }

    can query_relationships(query: str) -> dict {
        # Simple query: "Which functions call train_model?"
        if "call" in query:
            target = query.split("call ")[-1].strip('?');
            callers = [k for k, v in self.ccg.items() if target in v["calls"]];
            return {"callers": callers};
        return {};
    }
}
