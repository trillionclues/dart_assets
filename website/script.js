
document.addEventListener('DOMContentLoaded', () => {
    initCopy();
    initMobileNav();
    initTerminalDemo();
});

function initCopy() {
    document.querySelectorAll('.copy-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const text = btn.dataset.copy;
            navigator.clipboard.writeText(text).then(() => {
                btn.classList.add('copied');
                btn.innerHTML = '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 6L9 17l-5-5"/></svg>';
                setTimeout(() => {
                    btn.classList.remove('copied');
                    btn.innerHTML = '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg>';
                }, 2000);
            });
        });
    });
}

// --- Mobile nav ---
function initMobileNav() {
    const toggle = document.querySelector('.nav-toggle');
    const links = document.querySelector('.nav-links');
    if (!toggle || !links) return;

    toggle.addEventListener('click', () => {
        links.classList.toggle('open');
    });

    links.querySelectorAll('a').forEach(a => {
        a.addEventListener('click', () => links.classList.remove('open'));
    });
}

// --- Terminal demo ---
function initTerminalDemo() {
    const cmdEl = document.getElementById('typed-cmd');
    const outputEl = document.getElementById('term-output');
    const cursorEl = document.querySelector('.term-cursor');
    if (!cmdEl || !outputEl) return;

    const demos = [
        {
            cmd: 'dart_assets doctor --path .',
            output: [
                { text: '🩺 dart_assets doctor', cls: '' },
                { text: '', cls: '' },
                { text: '  ✓ pubspec.yaml found', cls: 'term-success' },
                { text: '  ✓ assets/ directory found (6 files)', cls: 'term-success' },
                { text: '  ✓ flutter section exists', cls: 'term-success' },
                { text: '  ✓ assets section configured', cls: 'term-success' },
                { text: '  ✓ dart_assets.yaml config valid', cls: 'term-success' },
                { text: '', cls: '' },
                { text: '  No issues found!', cls: 'term-success' },
            ]
        },
        {
            cmd: 'dart_assets gen',
            output: [
                { text: '⠋ Generating asset code...', cls: 'term-info' },
                { text: '✓ Generated lib/gen/assets.dart (6 assets)', cls: 'term-success' },
            ]
        },
        {
            cmd: 'dart_assets unused',
            output: [
                { text: '✓ Found 2 unused assets', cls: 'term-warn' },
                { text: '', cls: '' },
                { text: '  ⚠ assets/images/old_banner.png — 142KB', cls: 'term-warn' },
                { text: '  ⚠ assets/icons/unused_icon.svg — 3KB', cls: 'term-warn' },
                { text: '', cls: '' },
                { text: "  Run 'dart_assets clean' to remove them.", cls: 'term-info' },
            ]
        },
        {
            cmd: 'dart_assets check',
            output: [
                { text: 'Checking asset configuration...', cls: 'term-info' },
                { text: '', cls: '' },
                { text: '  ✓ All declared assets exist on disk', cls: 'term-success' },
                { text: '  ✓ All assets within size limits', cls: 'term-success' },
                { text: '  ✓ Generated code is up-to-date', cls: 'term-success' },
                { text: '', cls: '' },
                { text: '  Asset check passed.', cls: 'term-success' },
            ]
        }
    ];

    let demoIndex = 0;

    function runDemo() {
        const demo = demos[demoIndex % demos.length];
        demoIndex++;

        cmdEl.textContent = '';
        outputEl.innerHTML = '';
        cursorEl.style.display = 'inline';

        let i = 0;
        const typeInterval = setInterval(() => {
            if (i < demo.cmd.length) {
                cmdEl.textContent += demo.cmd[i];
                i++;
            } else {
                clearInterval(typeInterval);
                cursorEl.style.display = 'none';

                setTimeout(() => {
                    let lineIndex = 0;
                    const lineInterval = setInterval(() => {
                        if (lineIndex < demo.output.length) {
                            const line = demo.output[lineIndex];
                            const div = document.createElement('div');
                            if (line.cls) div.className = line.cls;
                            div.textContent = line.text || '\u00A0';
                            outputEl.appendChild(div);
                            lineIndex++;
                        } else {
                            clearInterval(lineInterval);
                            setTimeout(runDemo, 3000);
                        }
                    }, 80);
                }, 300);
            }
        }, 45);
    }

    setTimeout(runDemo, 800);
}
