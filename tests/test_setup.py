#!/usr/bin/env python3
"""Installer safety checks. Run: python3 -m unittest discover -s tests -v."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


REPO = Path(__file__).resolve().parents[1]
SETUP = Path(os.environ.get("DOTFILES_SETUP_SCRIPT", REPO / "setup.sh")).resolve()
LINKS = {
    "zsh/.zshrc": ".zshrc",
    "zsh/.zprofile": ".zprofile",
    "git/config": ".gitconfig",
    "git/ignore": ".config/git/ignore",
    "starship/starship.toml": ".config/starship.toml",
    "ghostty/config": ".config/ghostty/config",
}


def snapshot(directory):
    """Record files, directories, and symlinks without following links."""
    result = {}
    for root, directories, files in os.walk(directory, followlinks=False):
        for name in directories + files:
            path = Path(root) / name
            relative = str(path.relative_to(directory))
            if path.is_symlink():
                result[relative] = ("link", os.readlink(path))
            elif path.is_dir():
                result[relative] = ("directory",)
            else:
                result[relative] = ("file", path.read_bytes())
    return result


class SetupSafetyTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="dotfiles safety ")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name).resolve()
        self.repo = self.root / "repository with spaces"
        self.home = self.root / "target home with spaces"
        self.repo.mkdir()
        self.home.mkdir()
        shutil.copy2(SETUP, self.repo / "setup.sh")
        for source in LINKS:
            target = self.repo / source
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(REPO / source, target)

    def run_setup(self, *arguments):
        return subprocess.run(
            ["/bin/bash", str(self.repo / "setup.sh"),
             "--target-home", str(self.home), *arguments],
            capture_output=True, text=True, check=False,
        )

    def assert_success(self, result):
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def assert_links(self):
        for source, destination in LINKS.items():
            path = self.home / destination
            self.assertTrue(path.is_symlink(), destination)
            self.assertEqual(os.readlink(path), str(self.repo / source))

    def test_preview_changes_nothing(self):
        (self.home / ".zshrc").write_text("existing shell settings\n")
        before = snapshot(self.root)
        result = self.run_setup()
        self.assert_success(result)
        self.assertEqual(result.stdout.count("Would link:"), len(LINKS))
        self.assertIn("Would back up:", result.stdout)
        self.assertEqual(snapshot(self.root), before)

    def test_apply_preserves_conflicts_and_broken_symlink(self):
        for destination in LINKS.values():
            path = self.home / destination
            path.parent.mkdir(parents=True, exist_ok=True)
            if destination == ".gitconfig":
                path.symlink_to("missing-personal-config")
            elif destination == ".config/ghostty/config":
                path.mkdir()
                (path / "keep.txt").write_text("directory conflict\n")
            else:
                path.write_text("original " + destination)
        originals = snapshot(self.home)
        self.assert_success(self.run_setup("--apply"))
        self.assert_links()
        backups = list((self.home / ".local/state/dotfiles/backups").iterdir())
        self.assertEqual(len(backups), 1)
        self.assertEqual(snapshot(backups[0]), originals)

    def test_apply_is_idempotent(self):
        self.assert_success(self.run_setup("--apply"))
        self.assert_links()
        before = snapshot(self.root)
        result = self.run_setup("--apply")
        self.assert_success(result)
        self.assertEqual(result.stdout.count("Already linked:"), len(LINKS))
        self.assertEqual(snapshot(self.root), before)

    def test_missing_last_source_fails_before_changes(self):
        (self.repo / "ghostty/config").unlink()
        (self.home / ".zshrc").write_text("keep this\n")
        before = snapshot(self.root)
        result = self.run_setup("--apply")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Missing configuration:", result.stderr)
        self.assertEqual(snapshot(self.root), before)

    def test_symlinked_parent_is_rejected_before_changes(self):
        for parent in (".config", ".config/ghostty", ".local/state"):
            with self.subTest(parent=parent):
                shutil.rmtree(self.home)
                self.home.mkdir()
                outside = self.root / "outside"
                outside.mkdir(exist_ok=True)
                link = self.home / parent
                link.parent.mkdir(parents=True, exist_ok=True)
                link.symlink_to(outside, target_is_directory=True)
                before = snapshot(self.root)
                result = self.run_setup("--apply")
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("Parent directory is a symlink:", result.stderr)
                self.assertEqual(snapshot(self.root), before)

    def test_install_apps_requires_apply(self):
        before = snapshot(self.root)
        result = self.run_setup("--install-apps")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("--install-apps requires --apply", result.stderr)
        self.assertEqual(snapshot(self.root), before)

    def test_install_apps_rejects_alternate_home(self):
        before = snapshot(self.root)
        result = self.run_setup("--apply", "--install-apps")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("alternate target home", result.stderr)
        self.assertEqual(snapshot(self.root), before)


if __name__ == "__main__":
    unittest.main()
