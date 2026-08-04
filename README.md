<div align="center">
<h1>🧹 ServerCleaner Toolkit</h1>
<p>
An interactive, self-contained <strong>PowerShell</strong> CLI tool for Windows Server 2016+ that finds and safely deletes files across every local drive, mapped network drive, and common web-server cache (IIS, ASP.NET, XAMPP/WAMP/Laragon).
<br/><br/>
Built for tolerant name matching, full transparency (colorized, replayable session logs), and safe, confirm-before-delete operations — with a menu-driven UI available in 6 languages.
</p>
<div align="center">
  <a href="http://paypal.me/R0mb0">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://github.com/R0mb0/Support_the_dev_badge/blob/main/Badge/SVG/Support_the_dev_badge_Dark.svg">
      <source media="(prefers-color-scheme: light)" srcset="https://github.com/R0mb0/Support_the_dev_badge/blob/main/Badge/SVG/Support_the_dev_badge_Light.svg">
      <img alt="Saved you time? Support the dev" src="https://github.com/R0mb0/Support_the_dev_badge/blob/main/Badge/SVG/Support_the_dev_badge_Default.svg">
    </picture>
  </a>
</div>

---

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/license/mit)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white)](https://learn.microsoft.com/powershell/)
[![Windows Server](https://img.shields.io/badge/Windows%20Server-2016%2B-0078D6?logo=windows&logoColor=white)](https://learn.microsoft.com/windows-server/)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/R0mb0/server-cleaner-toolkit)

</div>

<hr>

<h2>🚀 Why this project exists</h2>
<p>
On a Windows Server, "deleting a file" is rarely as simple as it sounds. The same file can quietly survive as a leftover in an IIS or ASP.NET temp cache, inside a XAMPP/WAMP web root, as a hidden copy, as a numbered duplicate ("file (1)"), or as a stale shortcut in Recent Items — so a file you're sure you removed keeps reappearing online or on disk.
</p>
<p>
ServerCleaner Toolkit was built to make that investigation fast and safe: give it a name (even a partial one, even with different spacing or punctuation), and it searches every drive and every known cache location, shows you exactly what it finds, and only deletes what you explicitly confirm — with a full, readable log of everything it did.
</p>

<h2>✨ Features</h2>
<ul>
<li><strong>Menu-driven, numbers-only interface</strong>: every screen is a short numbered list, no typing full commands, no PowerShell knowledge required to operate it.</li>
<li><strong>Auto-detected UI language</strong>, switchable at any time between <strong>English, Italian, French, German, Spanish, and Portuguese</strong>.</li>
<li><strong>Self-elevating</strong>: prompts for UAC and relaunches itself as Administrator automatically, since most cache locations require elevated access.</li>
<li><strong>Tolerant name matching</strong>: ignores case and treats spaces, dashes, underscores, and dots as equivalent; strips Windows auto-generated copy suffixes ("(1)", "- Copy", "copia", "kopie"...); matches partial names.</li>
<li><strong>Wide-coverage scanning</strong>: every fixed and mapped network drive, plus IIS wwwroot &amp; compressed cache, ASP.NET temporary files, Windows Temp, every user profile's Temp folder, and XAMPP/WAMP/Laragon web roots.</li>
<li><strong>Flags hidden files and symlinks/junctions</strong> found among the matches.</li>
<li><strong>Two logging modes per search</strong>: a full transcript of every file observed, or a lighter "matches only" mode — plus an optional maximum log file size.</li>
<li><strong>Every search gets its own timestamped log file</strong>, saved as plain text next to the script; reopening it from the built-in log viewer re-applies colors automatically and paginates long files.</li>
<li><strong>Delete one match, several, or all of them</strong> from a single numbered results list, always with an explicit yes/no confirmation first.</li>
<li><strong>Resilient scanning</strong>: a single inaccessible or vanishing file (very common in a live Temp folder) is logged and skipped, it never aborts the whole scan.</li>
<li><strong>Two distribution forms</strong>: a modular source tree for development, and a single portable <code>.ps1</code> file with all modules and translations embedded — no external files needed to run it elsewhere.</li>
</ul>

<h2>🔧 Requirements</h2>
<ul>
<li><strong>Windows Server 2016 or later</strong> (Windows 10/11 works too, e.g. for testing)</li>
<li><strong>Windows PowerShell 5.1+</strong> (built in) — no external modules or internet access needed to run the tool itself</li>
<li><strong>Administrator rights</strong> (the script elevates itself via UAC automatically if not already running elevated)</li>
</ul>

<h2>▶️ Quick start</h2>

<h3>1) Get the script</h3>
<p>Clone the whole repo if you want the modular source, or just download <code>ServerCleaner-Portable.ps1</code> on its own — it has no dependencies.</p>
<pre><code>git clone https://github.com/R0mb0/server-cleaner-toolkit.git
cd server-cleaner-toolkit</code></pre>

<h3>2) Run it</h3>
<pre><code>powershell -ExecutionPolicy Bypass -File ".\ServerCleaner-Portable.ps1"</code></pre>
<p>(or, from an already open PowerShell prompt, simply <code>.\ServerCleaner-Portable.ps1</code>). On first run it will ask for elevation via UAC if it isn't already running as Administrator.</p>

<h2>🧠 How it works (technical flow)</h2>
<ol>
<li>Detects the OS UI culture at startup and loads the matching translation (falls back to English); the language can be changed at any time from the main menu.</li>
<li>Checks for Administrator privileges and relaunches itself elevated via UAC if needed.</li>
<li>Main menu: change language, search &amp; purge a file, or browse previous logs.</li>
<li>On "purge": asks for a (partial) filename, then a short numbered wizard — full vs. matches-only logging, an optional log size cap, and whether to skip heavy OS folders (WinSxS, System32, Defender cache). A dedicated log file is opened immediately, before scanning starts.</li>
<li>Scans, in order: known cache locations (IIS, ASP.NET temp, Windows Temp, every user's Temp folder, XAMPP/WAMP/Laragon), then every fixed and mapped network drive — using an explicit stack-based walk (no recursive function calls, so folder depth is never a limit) with per-item error isolation.</li>
<li>Name comparison normalizes spacing/punctuation, strips Windows copy-suffixes, and matches when the search term is contained in the candidate's name — not the other way round, to avoid false positives on short, generic filenames.</li>
<li>Matches are listed and numbered from 1, with a final "delete all" option; every deletion (single or bulk) requires an explicit yes/no confirmation and is written to the log.</li>
<li>Logs are plain text with no color codes, so they stay readable anywhere; reopening one from the built-in viewer re-applies colors per entry type and pages through long files.</li>
</ol>

<h2>🌍 Supported languages</h2>
<table>
<tr><th>Code</th><th>Language</th></tr>
<tr><td><code>it</code></td><td>Italiano</td></tr>
<tr><td><code>en</code></td><td>English</td></tr>
<tr><td><code>fr</code></td><td>Français</td></tr>
<tr><td><code>de</code></td><td>Deutsch</td></tr>
<tr><td><code>es</code></td><td>Español</td></tr>
<tr><td><code>pt</code></td><td>Português</td></tr>
</table>

<h2>⚠️ Safety notes</h2>
<ul>
<li>Deletions are <strong>permanent</strong> — files are removed directly, not sent to the Recycle Bin. Always review the numbered results list carefully before confirming, especially before using "delete all".</li>
<li>Run your first searches with the "full" logging mode and without excluding system folders, so you can verify the tool's behavior on your specific server before relying on the lighter/faster settings.</li>
<li>Test on a non-critical path or a non-production server first if you're not yet familiar with the tool.</li>
</ul>

<h2>🧪 Troubleshooting</h2>
<ul>
<li><strong>Numbered menu rejects your input</strong> → type only the digit (e.g. <code>2</code>), with no trailing punctuation.</li>
<li><strong>"Cartella saltata"/"Elemento saltato" entries in the log</strong> → expected on live folders like Temp, where files can be created/removed by other processes mid-scan; the entry is skipped and the scan continues.</li>
<li><strong>Very deep folder paths reported as inaccessible</strong> → Windows PowerShell 5.1 can hit the classic ~260-character path limit on some systems; affected folders are logged and skipped.</li>
<li><strong><code>ps2exe</code> fails with a <code>UseShellExecute</code> / process-launch error</strong> → you're running it from PowerShell 7 (<code>pwsh</code>). Reopen a plain <strong>Windows PowerShell</strong> (5.1) window and rerun both the <code>Install-Module</code> and <code>Invoke-ps2exe</code> commands from there.</li>
<li><strong>Script won't run at all / execution policy error</strong> → launch it with <code>powershell -ExecutionPolicy Bypass -File ".\ServerCleaner-Portable.ps1"</code>.</li>
</ul>