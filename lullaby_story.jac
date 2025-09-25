"""Bedtime Lullaby Story Generator"""

import from byllm.llm { Model }

# Seting up Gemini model
glob llm = Model(model_name="gemini/gemini-1.5-flash", verbose=False);

"""Generate a lullaby story based on a keyword"""
def create_lullaby(keyword: str) -> str by llm();

walker LullabyGame {
    has keyword: str;

    can start with `root entry;
    can tell_story with lullaby entry;
}

# story is optional at creation now
node lullaby {
    has story: str = "";
}

# --- Implementations ---

impl LullabyGame.start {
    next = root ++> lullaby();
    visit next;
}

impl LullabyGame.tell_story {
    here.story = create_lullaby(self.keyword);
    print("✨ Here’s your lullaby story:");
    print(here.story);
    disengage;
}

# --- Entry point (for CLI use) ---

with entry:__main__ {
    word = input("🌙 Enter a word to inspire the lullaby: ");
    root spawn LullabyGame(word);
}
