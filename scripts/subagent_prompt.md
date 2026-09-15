Your task is to map paragraphs of a verse-by-verse commentary to their corresponding Bible verses.
You will be provided with the text of one chapter of E.J. Waggoner's "The Glad Tidings" on the book of Galatians.
The text quotes Galatians verses (often in all caps or quotes) and then follows with paragraphs of commentary on those verses.

Rules for mapping:
1. Identify the Galatians verse or range of verses being quoted or referenced.
2. For every paragraph that follows, attribute it to the FIRST verse of that range, until a new verse is quoted or referenced.
3. If a paragraph is an introduction and occurs before any verse is quoted, map it to verse 1.
4. Output a JSON array of objects. Each object should have:
   - "verse": the verse number (integer)
   - "text": the exact verbatim text of the paragraph (string)
5. Ignore short headings. Only include actual commentary paragraphs (length > 20 chars).
6. Do not include the ALL CAPS bible quotes themselves in the output JSON, only the commentary paragraphs.
7. Return ONLY valid JSON, starting with `[` and ending with `]`. No markdown formatting.

Example output:
[
  { "verse": 1, "text": "The first five verses form a greeting..." },
  { "verse": 1, "text": "Another paragraph about verse 1..." },
  { "verse": 6, "text": "This paragraph comments on verse 6..." }
]
