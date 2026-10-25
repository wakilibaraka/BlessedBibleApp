#!/usr/bin/env python3
"""Repair OCR damage in the legacy commentary pack.

Several of the bundled commentary sources were scanned decades ago: the
Desire of Ages / Patriarchs and Prophets / Daniel and the Revelation text was
captured by OCR, so the pack still carries scanner noise (`&gt;`, `^J`, `\\isit`,
`peo- ple`), Project Gutenberg wrapper text, stray footnote and index pages, and
a handful of pages that are nothing but smeared characters.

This script rewrites assets/commentary/commentary.json in place:

  * decodes HTML entities and removes soft hyphens / zero-width characters,
  * drops Project Gutenberg boilerplate and inline footnote markers,
  * removes scanner noise characters and repairs hyphenated line breaks,
  * strips printing furniture: running heads, plate credits, page ranges, the
    "This chapter is based on ..." note and copyright lines,
  * drops sentences that are still mostly noise,
  * drops entries that hold no readable prose at all (index and plate pages).

Word-level mis-reads from the original scans ("Chnst", "usaith") are left in
place: repairing them needs the published text, not a regex. Re-import the
affected chapter from a clean edition instead.

Run it with no arguments for a report of what would change; pass --write to
rewrite the asset. It is deterministic, so re-running it on a cleaned pack is a
no-op. The run refuses to write if one of its rules would wipe out a whole
entry, which is how the printing-furniture rules were caught deleting too much.
"""

from __future__ import annotations

import argparse
import collections
import difflib
import html
import json
import re
import sys
import unicodedata
from pathlib import Path

ASSET = Path('assets/commentary/commentary.json')

# ---------------------------------------------------------------- text fixes

LIGATURES = {
    '\ufb00': 'ff',
    '\ufb01': 'fi',
    '\ufb02': 'fl',
    '\ufb03': 'ffi',
    '\ufb04': 'ffl',
    '\u00ad': '',  # soft hyphen
    '\u200b': '',  # zero width space
    '\u200c': '',
    '\u200d': '',
    '\ufeff': '',
}

# Characters that only ever appear here as scanner noise. They are replaced by
# a space rather than deleted so neighbouring words do not fuse together.
NOISE_CHARS = '\\|^~`¦●○◆•™©®«»¬*'
NOISE_TABLE = str.maketrans({c: ' ' for c in NOISE_CHARS})

GUTENBERG_LICENSE = re.compile(
    r'\*\*\*\s*(?:END|START) OF (?:THE|THIS) PROJECT GUTENBERG[^\n]*?\*\*\*'
    r'|PROJECT GUTENBERG (?:E)?BOOK[^\n]*'
    r'|Updated editions will replace the previous one[^\n]*'
    r'|Creating the works from (?:public domain )?print editions[^\n]*'
    r'|Those editions [^\n]*'
    r'|Most people do not have access to[^\n]*'
    r'|Produced by [^\n]*'
    r'|Transcriber[’\']?s Notes?:[^\n]*'
    r'|Text that was in (?:italics|bold)[^\n]*',
    re.IGNORECASE,
)

FOOTNOTE_MARKER = re.compile(r'\[\d{1,4}\]')
FOOTNOTE_LABEL = re.compile(r'\bFootnote\s+\d{1,4}\s*:\s*', re.IGNORECASE)
HYPHEN_BREAK = re.compile(r'([A-Za-z])-[ \t\n]+([a-z])')
SPACED_HYPHEN = re.compile(r'([A-Za-z])[ \t]+-[ \t]*([A-Za-z])')
LEADING_DASH = re.compile(r'(^|\s)-\s*(?=[A-Za-z])')
SYMBOL_RUN = re.compile(r'[*_=#<>~^|\\]{2,}')
# The Gutenberg transcriptions mark emphasis with _italics_ and =bold=; the
# markers themselves are not part of the sentence.
ITALIC_MARK = re.compile(r'(?<!\w)_([^_\n]{1,80})_(?!\w)')
BOLD_MARK = re.compile(r'=([^=\n]{1,80})=')
# Printing furniture from the scanned books: page ranges in brackets, the
# "This chapter is based on ..." note above each chapter, copyright lines, and
# running heads / plate captions set in capitals.
PAGE_RANGE = re.compile(r'\[\s*\d{1,4}\s*[-–]\s*\d{1,4}\s*\]')
CHAPTER_BASIS = re.compile(
    r'\bThis chapter is based\s*on[^.!?]*[.!?]', re.IGNORECASE
)
COPYRIGHT = re.compile(
    r'\b(?:Copyright|REVIEW AND HERALD|Pacific Press Publish\w*)\b[^.\n]*[.]?',
    re.IGNORECASE,
)
# Plate credits: "JOHN STEEL, ARTIST", "REVIEW AND HERALD, HARRY ANDERSON, ARTIST".
ARTISTS = re.compile(r'\b(?:[A-Z][A-Z’\'-]{1,}\s*,?\s*)+ARTIST\b')
CAPS_RUN = re.compile(r'(?<!["“])(?:\b[A-Z][A-Z’\'-]{1,}\b[\s,:;\'"-]*){3,}')
MULTI_PUNCT = re.compile(r'([,;:])\s*(?:[,.;:])+')
SPACE_RUN = re.compile(r'[ \t]{2,}')

WORD_RE = re.compile(r"[A-Za-z][A-Za-z'’\-]*")
TOKEN_RE = re.compile(r'\S+')
NUMERIC_TOKEN = re.compile(r'^[\d.,:;()\[\]\-–—]+$')
# "a" and "I" are words; any other single letter is a mis-read superscript.
STRAY_LETTER = re.compile(r'^(?![IaA]$)[A-Za-z]$')
# Punctuation on its own, ignoring the marks that legitimately stand alone.
STRAY_SYMBOL = re.compile(r'^[^\w\s…—–“”\'‘’]+$')
# "i-i", "rr-i": two letter fragments glued by a hyphen.
BROKEN_WORD = re.compile(r'^[A-Za-z]{1,2}-[A-Za-z]{1,3}$')
SENTENCE_SPLIT = re.compile(r'(?<=[.!?”"])\s+|\n{2,}')

# A token counts as readable if it is made of letters with optional internal
# punctuation, or a common short numeral such as "3" or "12:4".
READABLE_TOKEN = re.compile(
    r'^[“"‘\'(\[]?[A-Za-z][A-Za-z’\'-]*[.,;:!?”’)\]]*…?$'
    r'|^\d{1,3}(?::\d{1,3})?[.,;:]?$'
)


def normalize_text(raw: str) -> str:
    text = html.unescape(html.unescape(raw))
    text = unicodedata.normalize('NFC', text)
    for bad, good in LIGATURES.items():
        text = text.replace(bad, good)
    text = text.replace('\r\n', '\n').replace('\r', '\n')
    text = GUTENBERG_LICENSE.sub(' ', text)
    text = PAGE_RANGE.sub(' ', text)
    text = CHAPTER_BASIS.sub(' ', text)
    text = COPYRIGHT.sub(' ', text)
    text = ARTISTS.sub(' ', text)
    text = CAPS_RUN.sub(' ', text)
    text = FOOTNOTE_MARKER.sub('', text)
    text = FOOTNOTE_LABEL.sub('', text)
    text = text.translate(NOISE_TABLE)
    text = SYMBOL_RUN.sub(' ', text)
    text = HYPHEN_BREAK.sub(r'\1\2', text)
    text = SPACED_HYPHEN.sub(r'\1 \2', text)
    text = LEADING_DASH.sub(r'\1', text)
    text = re.sub(r'(?<!\w)(?:\s*\.\s*){3,}(?!\w)', ' … ', text)
    text = ITALIC_MARK.sub(r'\1', text)
    text = BOLD_MARK.sub(r'\1', text)
    text = MULTI_PUNCT.sub(r'\1', text)
    text = text.replace(' ,', ',')
    text = SPACE_RUN.sub(' ', text)
    return text


def build_vocabulary(entries: list[dict]) -> set[str]:
    """Tokens that recur across the pack; anything else is a spelling suspect."""
    counts: collections.Counter[str] = collections.Counter()
    for entry in entries:
        for word in WORD_RE.findall(entry['text']):
            counts[word.lower()] += 1
    return {word for word, count in counts.items() if count >= 6}


def sentence_is_readable(sentence: str, vocabulary: set[str]) -> bool:
    sentence = sentence.strip()
    if not sentence:
        return False
    letters = sum(c.isalpha() for c in sentence.lower() if 'a' <= c.lower() <= 'z')
    if letters < 2:
        return False
    tokens = [t for t in TOKEN_RE.findall(sentence) if t]
    readable = [t for t in tokens if READABLE_TOKEN.match(t)]
    if len(tokens) >= 4 and len(readable) / len(tokens) < 0.6:
        return False

    # Scanner debris inside a sentence: stray single letters ("He V I already
    # been") and free-standing punctuation ("it- < ! i-i nce").
    stray_letters = sum(1 for t in tokens if STRAY_LETTER.match(t))
    stray_symbols = sum(1 for t in tokens if STRAY_SYMBOL.match(t))
    broken_words = sum(1 for t in tokens if BROKEN_WORD.match(t))
    if stray_letters >= 2 or stray_symbols >= 2 or broken_words >= 2:
        return False
    if broken_words >= 1 and len(tokens) <= 10:
        return False

    # Runs of page numbers ("740, 741, 752, 764") are index pages, not prose.
    numeric = sum(1 for t in tokens if NUMERIC_TOKEN.match(t))
    if len(tokens) >= 6 and numeric / len(tokens) > 0.45:
        return False

    # Shouting page headers such as "740 THE BE SIRE OF AGES."
    alpha = [c for c in sentence if c.isalpha()]
    if len(alpha) >= 8 and sum(c.isupper() for c in alpha) / len(alpha) > 0.75:
        return False

    words = [w for w in WORD_RE.findall(sentence)]
    if len(words) >= 8:
        unknown = sum(1 for w in words if w.lower() not in vocabulary)
        if unknown / len(words) > 0.6:
            return False

    return True


ENUMERATOR = re.compile(r'^\d{1,3}[.)]$')
REFERENCE_LIKE = re.compile(
    r'^(?:(?:[1-3]\s?)?[A-Z][a-z]+\.?\s*)?\d+:\d+'
)


def merge_fragments(fragments: list[str]) -> list[str]:
    """Reattach list numbers and scripture references to their sentence.

    Splitting on sentence punctuation tears "Matt. 18:19, 20." apart and leaves
    a bare list number ("1.") as its own fragment. Both belong to a sentence:
    the number introduces the next one, the reference closes the previous one.
    """
    merged: list[str] = []
    pending: list[str] = []
    for fragment in fragments:
        fragment = fragment.strip()
        if not fragment:
            continue
        if REFERENCE_LIKE.match(fragment) or (
            merged and not WORD_RE.search(fragment) and len(fragment) <= 4
        ):
            if merged:
                merged[-1] = f'{merged[-1]} {fragment}'
                continue
        if ENUMERATOR.match(fragment):
            pending.append(fragment)
            continue
        if pending:
            fragment = ' '.join(pending + [fragment])
            pending = []
        merged.append(fragment)
    if pending and merged:
        merged[-1] = f'{merged[-1]} {" ".join(pending)}'
    elif pending:
        merged.extend(pending)
    return merged


def clean_entry_text(raw: str, vocabulary: set[str]) -> str:
    text = normalize_text(raw)
    paragraphs = []
    for block in re.split(r'\n\s*\n', text):
        fragments = merge_fragments(SENTENCE_SPLIT.split(block))
        kept = [
            sentence for sentence in fragments
            if sentence_is_readable(sentence, vocabulary)
        ]
        paragraph = ' '.join(kept)
        # A period with white space on both sides is a leftover of a broken
        # ellipsis, never punctuation.
        paragraph = re.sub(r'(?<=\s)\.(?=\s|$)', '', paragraph)
        paragraph = SPACE_RUN.sub(' ', paragraph).strip()
        # Underscores and equals signs used as emphasis markers from the source
        # scans read as typos once the emphasis is gone.
        paragraph = re.sub(r'(?<=\w)[_=](?=\w)', '', paragraph)
        if paragraph:
            paragraphs.append(paragraph)
    body = '\n\n'.join(paragraphs)
    return body.strip()


PAGE_NUMBER = re.compile(r'^\d{1,4}[,;.:]?$')
# "Aaron, associate of Moses, 254, 313." — a page number directly after a comma
# is the signature of a back-of-the-book index.
PAGE_AFTER_COMMA = re.compile(r',\s+\d{1,3}\b(?![:\-])')


def junk_reason(body: str, vocabulary: set[str]) -> str | None:
    """Explain why a cleaned entry carries no readable prose, if it does not."""
    if not body.strip():
        return 'nothing readable'
    tokens = [t for t in TOKEN_RE.findall(body) if t]
    readable = sum(1 for t in tokens if READABLE_TOKEN.match(t))
    if tokens and readable / len(tokens) < 0.6:
        return 'scanner noise'

    # A back-of-the-book index: page numbers after every heading, and the entry
    # was filed against whatever chapter happened to precede the index pages.
    page_numbers = sum(1 for t in tokens if PAGE_NUMBER.match(t))
    if len(tokens) >= 15 and page_numbers / len(tokens) > 0.15:
        return 'index page'
    page_refs = len(PAGE_AFTER_COMMA.findall(body))
    if len(tokens) < 60 and page_refs >= 2:
        return 'index page'
    if len(tokens) < 3000 and page_refs >= 3 and page_refs / len(tokens) > 0.08:
        return 'index page'

    words = [w for w in WORD_RE.findall(body)]
    if len(words) >= 5:
        unknown = sum(1 for w in words if w.lower() not in vocabulary)
        if unknown / len(words) > 0.6:
            return 'scanner noise'

    # A scrap torn from a page: a heading and a page number, no real citation.
    if len(words) <= 60 and not re.search(r'\d+:\d+', body) and not re.search(
        r'\bverses?\b|\bchapters?\b', body, re.IGNORECASE
    ):
        bare_numbers = sum(1 for t in tokens if PAGE_NUMBER.match(t))
        if PAGE_AFTER_COMMA.search(body) or (len(words) <= 4 and bare_numbers >= 2):
            return 'page fragment'
    return None


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true', help='rewrite the asset')
    parser.add_argument('--show', type=int, default=0, help='print N repaired entries')
    parser.add_argument(
        '--force', action='store_true', help='write even if an entry collapses'
    )
    args = parser.parse_args()

    if not ASSET.exists():
        print(f'{ASSET} not found; run from the repository root', file=sys.stderr)
        return 1

    data = json.loads(ASSET.read_text(encoding='utf-8'))
    entries = data['entries']
    vocabulary = build_vocabulary(entries)

    kept: list[dict] = []
    dropped: list[tuple[dict, str]] = []
    collapsed: list[tuple[dict, str]] = []
    repaired = 0
    original_chars = 0

    for entry in entries:
        original = entry['text']
        original_chars += len(original)
        # Re-run until the text stops changing: removing a stray fragment can
        # expose the next one, and the asset is expected to be stable.
        body = clean_entry_text(original, vocabulary)
        for _ in range(3):
            shorter = clean_entry_text(body, vocabulary)
            if shorter == body:
                break
            body = shorter
        reason = junk_reason(body, vocabulary)
        if reason is not None:
            dropped.append((entry, reason))
            continue
        original_words = len(WORD_RE.findall(original))
        body_words = len(WORD_RE.findall(body))
        # A page of scan noise can clean down to a stray citation.
        if original_words >= 100 and body_words < 15:
            dropped.append((entry, 'scanner noise'))
            continue
        # A rule that deletes a whole chapter instead of a caption should stop
        # the run rather than silently truncate the pack.
        if original_words >= 100 and body_words < original_words // 10:
            collapsed.append((entry, body))
        if body != original:
            repaired += 1
            if args.show > 0:
                args.show -= 1
                print('-' * 70)
                print(f"{entry['source']} {entry['scope']}")
                before_words = original.split()
                after_words = body.split()
                for line in difflib.unified_diff(
                    before_words, after_words, 'before', 'after', lineterm='', n=3
                ):
                    print(' '.join(line.split()))
        new_entry = dict(entry)
        new_entry['text'] = body
        kept.append(new_entry)

    if collapsed and not args.force:
        print('refusing to write: these entries lost almost all their text', file=sys.stderr)
        for entry, body in collapsed[:20]:
            print(
                f"  {entry['source']} {entry['scope']['book']} "
                f"{entry['scope']['chapter']}:{entry['scope']['verse']} "
                f'({len(WORD_RE.findall(entry["text"]))} words -> '
                f'{len(WORD_RE.findall(body))})',
                file=sys.stderr,
            )
        return 1

    print(f'entries: {len(entries)} -> {len(kept)}')
    print(f'repaired: {repaired}')
    print(f'dropped: {len(dropped)}')
    print(f'characters: {original_chars} -> {sum(len(e["text"]) for e in kept)}')
    print('\ndropped entries by source:')
    for source, count in collections.Counter(
        entry['source'] for entry, _ in dropped
    ).most_common():
        print(f'  {count:4d}  {source}')
    print('\ndropped entries by reason:')
    for reason, count in collections.Counter(
        reason for _, reason in dropped
    ).most_common():
        print(f'  {count:4d}  {reason}')

    if args.write:
        data['entries'] = kept
        data['count'] = len(kept)
        ASSET.write_text(
            json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8'
        )
        print(f'\nwrote {ASSET}')
    else:
        print('\ndry run; pass --write to update the asset')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
