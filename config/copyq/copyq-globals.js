const _print = global.print;
global.print = function (arg) {
    popup(arg);
    _print(arg + "\n");
}

//global.popup = function (title, message) {
//    var commandArgs = ["notify-send", "-t", "50", "-i", "copyq", "-a", "Clipboard", "-e"];
//    commandArgs.push(title)
//    if (message) { commandArgs.push(message) };
//    var out = execute.apply(null, commandArgs);
//}

const clipboardTab = '&Clipboard';
const selectionTab = '&Primary Selection';
const imageTab = '&Images';
const timeFormat = 'MM-dd hh:mm:ss'
const tagsMime = 'application/x-copyq-tags';
const imageMime = 'image/png';
const mimeHtml = 'text/html';
const mimeText = 'text/plain';
const mimeClipboardMode = 'application/x-copyq-clipboard-mode';
const mimeOutputTab = 'application/x-copyq-output-tab';

var paste_ = global.paste;
global.paste = function () {
    paste_();
}

const _onClipboardChanged = onClipboardChanged
onClipboardChanged = function () {
    // If there's no meaningful data, do nothing and prevent the engine from saving an empty item.
    if (!hasData()) {
        removeData('application/x-copyq-output-tab');
        return;
    }

    // --- 1. Add common metadata to every new item ---
    var time = Date.now();
    setData('application/x-copyq-user-copy-time', time);
    var tags = dateString(timeFormat);

    const formats = dataFormats();
    const imageClipboard = clipboard(imageMime);
    // --- 2. Determine the correct tab and apply specific logic ---
    if (isClipboard() && (hasImageFormat(formats) || imageClipboard.length > 0)) {
        // popup("Image detected in clipboard. Length: " + imageClipboard.length);
        // --- Image Logic ---
        setData(mimeOwner);
        setData(tagsMime, tags);
        // Activate the Images tab in the UI.
        setData(imageMime, imageClipboard);
        setData(mimeOutputTab, imageTab);
        setCurrentTab(imageTab);
        saveData();
        removeData(mimeOutputTab);
        removeData(imageMime);
    } else if (data(mimeClipboardMode) == "selection") {
        // popup("Primary Selection detected in clipboard.");
        // --- Primary Selection Logic ---
        // Set the target tab to '&Primary Selection'.
        setData(mimeOutputTab, selectionTab);

        const clipboardText = str(data(mimeText));
        const numLines = clipboardText ? (clipboardText.match(/\n/g) || []).length + 1 : 0;
        if (numLines > 1) {
            tags = "Lines: " + numLines + ',' + tags;
        }

        const languageDetected = detectLanguage(clipboardText);
        if (languageDetected) {
            tags = languageDetected + ',' + tags;
            var htmlCode = highlightCode(clipboardText, languageDetected);
            if (htmlCode) {
                setData(mimeHtml, htmlCode);
            }
        }
        setData(tagsMime, tags);
        saveData();
    } else {
        // popup("Standard Clipboard detected in clipboard.");
        // --- Standard Clipboard Logic ---
        // Set the target tab to '&Clipboard'.
        setData(mimeOutputTab, clipboardTab);

        const clipboardText = str(data(mimeText));
        const numLines = clipboardText ? (clipboardText.match(/\n/g) || []).length + 1 : 0;
        if (numLines > 1) {
            tags = 'Lines: ' + numLines + ',' + tags;
        }

        const languageDetected = detectLanguage(clipboardText);
        if (languageDetected) {
            tags = languageDetected + ',' + tags;
            var htmlCode = highlightCode(clipboardText, languageDetected);
            if (htmlCode) {
                setData(mimeHtml, htmlCode);
            }
        }
        setData(tagsMime, tags);

        // Activate the Clipboard tab in the UI.
        setCurrentTab(clipboardTab);
        saveData();
    }
}


global.hasImageFormat = function (formats) {
    for (const format of formats.values()) {
        if (format.startsWith('image/'))
            return true;
    }
    return false;
}

global.detectLanguage = function (text) {
    // Check for null/undefined/empty text
    if (!text || text.trim().length === 0) {
        return "";
    }
    
    const highConfidencePatterns = {
        "python": /\bdef\s+\w+\s*\(.*\):|\bfrom\s+[^\s]+\s+import\s|import\s+\w+(\s+as\s+\w+)?\s*$|\bclass\s+\w+(\(.*\))?:/gm,
        "javascript": /\b(const|let|var)\s+\w+\s*=\s*.*;|\bfunction\s+\w*\s*\(.*\)\s*\{|\b=>\s*\{|\bimport\s+.+\s+from\s+['"].+['"];?/gm,
        "html": /^\s*<!DOCTYPE\s+html>|<html[\s>]/i,
        "csharp": /^\s*namespace\s+\w+(\.\w+)*\s*\{|\bpublic\s+(class|interface|struct|enum)\s+\w+\s*(?::\s*\w+)?\s*\{|\busing\s+System(\.\w+)*\s*;/gm,
        "cpp": /^\s*#include\s*<[^>]+>|\bint\s+main\s*\(.*\)\s*\{|\bstd::\w+/gm,
        "java": /^\s*public\s+(class|interface|enum)\s+\w+(\s+extends\s+\w+)?(\s+implements\s+[\w,\s]+)?\s*\{|\bimport\s+java\.\w+/gm,
        "go": /^\s*package\s+\w+|\bfunc\s+\w+\s*\(.*\)\s*\{|\btype\s+\w+\s+struct\s*\{/gm,
        "php": /^<\?php|\bfunction\s+\w+\s*\(.*\)\s*\{|\bclass\s+\w+\s*(?:extends\s+\w+)?\s*\{/gm,
    };

    const lowConfidencePatterns = {
        "python": /\bprint\s*\(.*\)\s*$|\bif\s+.*:\s*$|\bfor\s+.*:\s*$|\bwhile\s+.*:\s*$|\btry:\s*$|\bexcept\s+.*:\s*$|\bwith\s+.*:\s*$/gm,
        "javascript": /console\.(log|warn|error)\(.*\);?$|document\.\w+\(.*\);?$|window\.\w+\(.*\);?$/gm,
        "html": /<\/?(div|span|p|a|img|ul|li|table|tr|td|script|style|head|body|meta|link)[\s>]/i,
        "csharp": /Console\.\w+\(.*\);?$|using\s+System(\.\w+)*\s*;/gm,
        "cpp": /\bcout\s*<<.*;?$|\bcin\s*>>.*;?$|#define\s+\w+/gm,
        "java": /System\.out\.print(ln)?\(.*\);?$|\bScanner\s+\w+\s*=\s*new\s+Scanner\(.*\);?$|\bpublic\s+static\s+void\s+main\s*\(.*\)\s*\{/gm,
        "go": /fmt\.\w+\(.*\);?$|\bmake\(\w+\)|\bappend\(\w+,\s*\w+\)/gm,
        "kotlin": /\bprintln\(.+\);?$|\bwhen\s*\(.*\)\s*\{/gm,
    };

    // Attempt to detect JSON by parsing
    try {
        JSON.parse(text);
        return "json";
    } catch (e) {
        // Not JSON, proceed with regex detection.
    }

    // Assign weights
    const highConfidenceWeight = 10;
    const lowConfidenceWeight = 1;

    let scores = {};

    // High confidence patterns
    for (const lang in highConfidencePatterns) {
        const pattern = highConfidencePatterns[lang];
        const matches = (text.match(pattern) || []).length;
        if (matches > 0) {
            scores[lang] = (scores[lang] || 0) + matches * highConfidenceWeight;
        }
    }

    // Low confidence patterns
    for (const lang in lowConfidencePatterns) {
        const pattern = lowConfidencePatterns[lang];
        const matches = (text.match(pattern) || []).length;
        if (matches > 0) {
            scores[lang] = (scores[lang] || 0) + matches * lowConfidenceWeight;
        }
    }

    // Determine the language with the highest score
    const sortedLanguages = Object.keys(scores).sort((a, b) => scores[b] - scores[a]);
    if (sortedLanguages.length === 0) return "";

    const topLanguage = sortedLanguages[0];
    const topScore = scores[topLanguage];
    const secondScore = scores[sortedLanguages[1]] || 0;

    // Check if the top score is significantly higher than the second
    if (topScore > 5 && topScore > secondScore * 1.5) {
        return topLanguage;
    }
    return "";
}

// Function to perform syntax highlighting
global.highlightCode = function (text, language) {
    // Map detected language names to Pygments lexer names
    const languageMap = {
        "python": "python",
        "javascript": "javascript",
        "html": "html",
        "php": "php",
        "csharp": "csharp",
        "cpp": "cpp",
        "java": "java",
        "go": "go",
        "kotlin": "kotlin",
        "json": "json",
        "css": "css",
    };

    const pygmentsLanguage = languageMap[language];
    if (!pygmentsLanguage) {
        // Language not supported by Pygments
        return;
    }

    // Prepare the command to run Pygments
    const pythonCode = `
import sys
from pygments import highlight
from pygments.lexers import get_lexer_by_name
from pygments.formatters import HtmlFormatter

code = sys.stdin.read()
lexer = get_lexer_by_name(sys.argv[1])
formatter = HtmlFormatter(noclasses=True, style='solarized-dark', encoding='utf-8')
formatter.style.background_color = 'none'
print(highlight(code, lexer, formatter).decode())
`;

    // Execute Pygments to get the highlighted HTML
    const result = execute('python3', '-c', pythonCode, pygmentsLanguage, null, text);

    if (result && result.exit_code === 0) {
        const html = result.stdout;
        return html
    } else {
        // Handle error
        print('Error highlighting code: ' + (result ? result.stderr : 'Unknown error'));
    }
}
