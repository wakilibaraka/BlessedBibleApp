.[0] as $ct | .[1][] | select(.startVerse == 1) | 
  (.book) as $b |
  (.startChapter) as $c |
  ($ct[$b][$c|tostring]) as $ctitle |
  (.title) as $ptitle |
  (if ($ctitle | ascii_downcase) == ($ptitle | ascii_downcase) then
    {decision: "KEEP_PERICOPE", reason: "Exact match"}
  elif (($ctitle | ascii_downcase | test("^[a-z0-9 ]+$")) and ($ctitle | ascii_downcase | index($ptitle | ascii_downcase)) != null) then
    {decision: "KEEP_PERICOPE", reason: "Pericope is concise substring"}
  elif (($ptitle | ascii_downcase | test("^[a-z0-9 ]+$")) and ($ptitle | ascii_downcase | index($ctitle | ascii_downcase)) != null) then
    {decision: "KEEP_PERICOPE", reason: "Pericope is more comprehensive"}
  else
    {decision: "FLAG", reason: "Requires human review"}
  end) as $eval |
  {
    book: $b,
    chapter: $c,
    chapter_title: $ctitle,
    pericope_title: $ptitle,
    decision: $eval.decision,
    merged_text: "",
    reason: $eval.reason
  }
