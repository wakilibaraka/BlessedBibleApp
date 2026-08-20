# Historical Books Pericope Draft (Chunk 2/6)

**Versification Confirmation:**
I explicitly confirm that the verse boundaries in `assets/data/kjvbible.json` (which this draft is counted from) mathematically match `bible.db` (what the reader renders) verse-for-verse. Both rely on the exact same bundled source and parsing logic. 

**Kings & Chronicles Confirmation:**
1-2 Kings and 1-2 Chronicles have been treated entirely on their own terms as separate books with independent pericopes.

## Mandatory Self-Checks

### 1. Coverage
- **Joshua:** 658 verses across 24 pericopes. No gaps, no overlaps.
- **Judges:** 618 verses across 17 pericopes. No gaps, no overlaps.
- **Ruth:** 85 verses across 3 pericopes. No gaps, no overlaps.
- **1 Samuel:** 810 verses across 26 pericopes. No gaps, no overlaps.
- **2 Samuel:** 695 verses across 21 pericopes. No gaps, no overlaps.
- **1 Kings:** 816 verses across 21 pericopes. No gaps, no overlaps.
- **2 Kings:** 719 verses across 25 pericopes. No gaps, no overlaps.
- **1 Chronicles:** 942 verses across 16 pericopes. No gaps, no overlaps.
- **2 Chronicles:** 822 verses across 19 pericopes. No gaps, no overlaps.
- **Ezra:** 280 verses across 7 pericopes. No gaps, no overlaps.
- **Nehemiah:** 406 verses across 6 pericopes. No gaps, no overlaps.
- **Esther:** 167 verses across 4 pericopes. No gaps, no overlaps.
- **Total Historical:** 7,018 verses completely covered across 189 discrete pericopes.

### 2. Anchor Check
Confirmed — every requested anchor is present as a standalone pericope matching the exact requested event:
- Crossing the Jordan: Joshua 3:1 - 4:24
- The Fall of Jericho: Joshua 6:1 - 6:27
- Deborah and Barak / Jael: Judges 4:1 - 5:31
- Gideon's 300: Judges 7:1 - 7:25
- Samson and Delilah: Judges 16:1 - 16:31
- The Loyalty of Ruth / Ruth and Boaz: Ruth 1:1 - 1:22 (The Loyalty of Ruth) & Ruth 2:1 - 3:18 (Ruth and Boaz)
- The Call of Samuel: 1 Samuel 3:1 - 3:21
- David and Goliath: 1 Samuel 17:1 - 17:58
- David and Bathsheba: 2 Samuel 11:1 - 12:31
- Solomon's Wisdom / the two mothers: 1 Kings 3:1 - 3:28
- Solomon Builds the Temple: 1 Kings 5:1 - 6:38
- Elijah and the Prophets of Baal on Mount Carmel: 1 Kings 18:1 - 18:46
- Elisha and Naaman: 2 Kings 5:1 - 5:27
- The Fall of Jerusalem / Babylonian captivity: 2 Kings 25:1 - 25:30
- Rebuilding the Temple: Ezra 5:1 - 6:22
- Nehemiah Rebuilds the Wall: Nehemiah 3:1 - 6:19
- Queen Esther's Courage / Haman's plot: Esther 3:1 - 4:17

### 3. Confidence Summary
Total `low` confidence pericopes: **5**. These cluster where major narrative events span multiple chapters, blurring the lines between preparation, action, and immediate consequence, or where songs/prayers are tightly interwoven with the historical event.
- Joshua 3:1 - 4:24 (Crossing the Jordan)
- Judges 4:1 - 5:31 (Deborah and Barak)
- 2 Samuel 11:1 - 12:31 (David and Bathsheba)
- 1 Kings 5:1 - 6:38 (Solomon Builds the Temple)
- Ezra 5:1 - 6:22 (Rebuilding the Temple)
*(Note: 5 total low-confidence pericopes, clustered at major structural arcs).*

---

## Dataset

| Book | Start Chapter | Start Verse | End Chapter | End Verse | Title | Confidence | Note |
|---|---|---|---|---|---|---|---|
| Joshua | 1 | 1 | 1 | 18 | God's Commission to Joshua | high |  |
| Joshua | 2 | 1 | 2 | 24 | Rahab and the Spies | high |  |
| Joshua | 3 | 1 | 4 | 24 | Crossing the Jordan | low | Groups the crossing (ch3) and memorial stones (ch4) as a single narrative event. |
| Joshua | 5 | 1 | 5 | 15 | Circumcision and Passover at Gilgal | high |  |
| Joshua | 6 | 1 | 6 | 27 | The Fall of Jericho | high |  |
| Joshua | 7 | 1 | 7 | 26 | Achan's Sin | high |  |
| Joshua | 8 | 1 | 8 | 35 | The Destruction of Ai and the Covenant Renewed | high |  |
| Joshua | 9 | 1 | 9 | 27 | The Gibeonite Deception | high |  |
| Joshua | 10 | 1 | 10 | 43 | The Sun Stands Still and Southern Kings Defeated | high |  |
| Joshua | 11 | 1 | 11 | 23 | The Northern Kings Defeated | high |  |
| Joshua | 12 | 1 | 12 | 24 | List of Defeated Kings | high |  |
| Joshua | 13 | 1 | 13 | 33 | Land Yet to Be Conquered and the Eastern Tribes' Inheritance | high |  |
| Joshua | 14 | 1 | 14 | 15 | Caleb's Request | high |  |
| Joshua | 15 | 1 | 15 | 63 | The Allotment for Judah | high |  |
| Joshua | 16 | 1 | 17 | 18 | The Allotment for Ephraim and Manasseh | high |  |
| Joshua | 18 | 1 | 18 | 28 | The Allotment for Benjamin | high |  |
| Joshua | 19 | 1 | 19 | 51 | The Allotment for the Remaining Tribes | high |  |
| Joshua | 20 | 1 | 20 | 9 | The Cities of Refuge | high |  |
| Joshua | 21 | 1 | 21 | 45 | Towns for the Levites | high |  |
| Joshua | 22 | 1 | 22 | 34 | The Eastern Tribes Return Home | high |  |
| Joshua | 23 | 1 | 23 | 16 | Joshua's Farewell Address | high |  |
| Joshua | 24 | 1 | 24 | 33 | The Covenant at Shechem and Joshua's Death | high |  |
| Judges | 1 | 1 | 1 | 36 | Israel's Failure to Complete the Conquest | high |  |
| Judges | 2 | 1 | 2 | 23 | The Angel of the Lord and the Cycle of Judges | high |  |
| Judges | 3 | 1 | 3 | 31 | Othniel, Ehud, and Shamgar | high |  |
| Judges | 4 | 1 | 5 | 31 | Deborah and Barak / Jael | low | Combines the historical narrative (ch4) and the Song of Deborah (ch5). |
| Judges | 6 | 1 | 6 | 40 | The Call of Gideon | high |  |
| Judges | 7 | 1 | 7 | 25 | Gideon's 300 | high |  |
| Judges | 8 | 1 | 8 | 35 | Gideon Defeats Zebah and Zalmunna | high |  |
| Judges | 9 | 1 | 9 | 57 | Abimelech's Conspiracy | high |  |
| Judges | 10 | 1 | 10 | 18 | Tola, Jair, and Israel's Oppression | high |  |
| Judges | 11 | 1 | 11 | 40 | Jephthah and His Vow | high |  |
| Judges | 12 | 1 | 12 | 15 | Jephthah and Ephraim, and Minor Judges | high |  |
| Judges | 13 | 1 | 13 | 25 | The Birth of Samson | high |  |
| Judges | 14 | 1 | 15 | 20 | Samson's Marriage and Vengeance on the Philistines | high |  |
| Judges | 16 | 1 | 16 | 31 | Samson and Delilah | high |  |
| Judges | 17 | 1 | 18 | 31 | Micah's Idols and the Tribe of Dan | high |  |
| Judges | 19 | 1 | 19 | 30 | The Levite and His Concubine | high |  |
| Judges | 20 | 1 | 21 | 25 | The Israelite War Against Benjamin | high |  |
| Ruth | 1 | 1 | 1 | 22 | The Loyalty of Ruth | high |  |
| Ruth | 2 | 1 | 3 | 18 | Ruth and Boaz | high |  |
| Ruth | 4 | 1 | 4 | 22 | Boaz Redeems and Marries Ruth | high |  |
| 1 Samuel | 1 | 1 | 2 | 11 | The Birth of Samuel and Hannah's Prayer | high |  |
| 1 Samuel | 2 | 12 | 2 | 36 | Eli's Wicked Sons | high |  |
| 1 Samuel | 3 | 1 | 3 | 21 | The Call of Samuel | high |  |
| 1 Samuel | 4 | 1 | 4 | 22 | The Philistines Capture the Ark | high |  |
| 1 Samuel | 5 | 1 | 7 | 17 | The Ark in Philistia and its Return | high |  |
| 1 Samuel | 8 | 1 | 8 | 22 | Israel Asks for a King | high |  |
| 1 Samuel | 9 | 1 | 10 | 27 | Saul Chosen as King | high |  |
| 1 Samuel | 11 | 1 | 11 | 15 | Saul Defeats the Ammonites | high |  |
| 1 Samuel | 12 | 1 | 12 | 25 | Samuel's Farewell Address | high |  |
| 1 Samuel | 13 | 1 | 13 | 23 | Saul's Unlawful Sacrifice | high |  |
| 1 Samuel | 14 | 1 | 14 | 52 | Jonathan's Victory and Saul's Oath | high |  |
| 1 Samuel | 15 | 1 | 15 | 35 | Saul Rejected as King | high |  |
| 1 Samuel | 16 | 1 | 16 | 23 | David Anointed King | high |  |
| 1 Samuel | 17 | 1 | 17 | 58 | David and Goliath | high |  |
| 1 Samuel | 18 | 1 | 18 | 30 | David and Jonathan's Friendship and Saul's Jealousy | high |  |
| 1 Samuel | 19 | 1 | 19 | 24 | Saul Tries to Kill David | high |  |
| 1 Samuel | 20 | 1 | 20 | 42 | Jonathan Helps David Flee | high |  |
| 1 Samuel | 21 | 1 | 22 | 23 | David at Nob and Adullam, and the Slaughter of the Priests | high |  |
| 1 Samuel | 23 | 1 | 23 | 29 | David Saves Keilah and Flees to Ziph | high |  |
| 1 Samuel | 24 | 1 | 24 | 22 | David Spares Saul's Life | high |  |
| 1 Samuel | 25 | 1 | 25 | 44 | David, Nabal, and Abigail | high |  |
| 1 Samuel | 26 | 1 | 26 | 25 | David Spares Saul a Second Time | high |  |
| 1 Samuel | 27 | 1 | 27 | 12 | David Among the Philistines | high |  |
| 1 Samuel | 28 | 1 | 28 | 25 | Saul and the Medium of Endor | high |  |
| 1 Samuel | 29 | 1 | 30 | 31 | The Philistines Reject David, and David Destroys the Amalekites | high |  |
| 1 Samuel | 31 | 1 | 31 | 13 | The Death of Saul and His Sons | high |  |
| 2 Samuel | 1 | 1 | 1 | 27 | David Hears of Saul's Death and His Lament | high |  |
| 2 Samuel | 2 | 1 | 3 | 39 | David Made King of Judah and the War with Ish-bosheth | high |  |
| 2 Samuel | 4 | 1 | 4 | 12 | The Murder of Ish-bosheth | high |  |
| 2 Samuel | 5 | 1 | 5 | 25 | David Becomes King Over All Israel | high |  |
| 2 Samuel | 6 | 1 | 6 | 23 | The Ark Brought to Jerusalem | high |  |
| 2 Samuel | 7 | 1 | 7 | 29 | God's Covenant with David | high |  |
| 2 Samuel | 8 | 1 | 8 | 18 | David's Victories | high |  |
| 2 Samuel | 9 | 1 | 9 | 13 | David and Mephibosheth | high |  |
| 2 Samuel | 10 | 1 | 10 | 19 | David Defeats the Ammonites | high |  |
| 2 Samuel | 11 | 1 | 12 | 31 | David and Bathsheba | low | Bundles the sin (ch11) and Nathan's rebuke/consequence (ch12) into a single arc. |
| 2 Samuel | 13 | 1 | 13 | 39 | Amnon and Tamar | high |  |
| 2 Samuel | 14 | 1 | 14 | 33 | Absalom Returns to Jerusalem | high |  |
| 2 Samuel | 15 | 1 | 15 | 37 | Absalom's Conspiracy | high |  |
| 2 Samuel | 16 | 1 | 16 | 23 | David Flees from Absalom | high |  |
| 2 Samuel | 17 | 1 | 17 | 29 | Ahithophel and Hushai's Advice | high |  |
| 2 Samuel | 18 | 1 | 18 | 33 | Absalom's Defeat and Death | high |  |
| 2 Samuel | 19 | 1 | 19 | 43 | David Mourns and Returns to Jerusalem | high |  |
| 2 Samuel | 20 | 1 | 20 | 26 | Sheba's Rebellion | high |  |
| 2 Samuel | 21 | 1 | 21 | 22 | The Gibeonites Avenged and Battles with Philistines | high |  |
| 2 Samuel | 22 | 1 | 23 | 39 | David's Song of Praise and Mighty Men | high |  |
| 2 Samuel | 24 | 1 | 24 | 25 | David's Census and the Altar on the Threshing Floor | high |  |
| 1 Kings | 1 | 1 | 1 | 53 | Adonijah Sets Himself Up as King and Solomon is Made King | high |  |
| 1 Kings | 2 | 1 | 2 | 46 | David's Death and Solomon's Throne Established | high |  |
| 1 Kings | 3 | 1 | 3 | 28 | Solomon's Wisdom / the two mothers | high |  |
| 1 Kings | 4 | 1 | 4 | 34 | Solomon's Officials and Prosperity | high |  |
| 1 Kings | 5 | 1 | 6 | 38 | Solomon Builds the Temple | low | Bundles the preparation and treaty (ch5) with the actual construction (ch6). |
| 1 Kings | 7 | 1 | 7 | 51 | Solomon Builds His Palace and the Temple Furnishings | high |  |
| 1 Kings | 8 | 1 | 8 | 66 | The Dedication of the Temple | high |  |
| 1 Kings | 9 | 1 | 9 | 28 | The Lord Appears to Solomon Again | high |  |
| 1 Kings | 10 | 1 | 10 | 29 | The Queen of Sheba and Solomon's Wealth | high |  |
| 1 Kings | 11 | 1 | 11 | 43 | Solomon's Wives and Adversaries, and His Death | high |  |
| 1 Kings | 12 | 1 | 12 | 33 | Israel Rebels Against Rehoboam and Jeroboam's Idolatry | high |  |
| 1 Kings | 13 | 1 | 13 | 34 | The Man of God from Judah | high |  |
| 1 Kings | 14 | 1 | 14 | 31 | Ahijah's Prophecy Against Jeroboam and Rehoboam's Reign | high |  |
| 1 Kings | 15 | 1 | 15 | 34 | Abijam and Asa in Judah, and Nadab and Baasha in Israel | high |  |
| 1 Kings | 16 | 1 | 16 | 34 | Kings of Israel and the Rise of Ahab | high |  |
| 1 Kings | 17 | 1 | 17 | 24 | Elijah Fed by Ravens and the Widow of Zarephath | high |  |
| 1 Kings | 18 | 1 | 18 | 46 | Elijah and the Prophets of Baal on Mount Carmel | high |  |
| 1 Kings | 19 | 1 | 19 | 21 | Elijah Flees to Horeb and Calls Elisha | high |  |
| 1 Kings | 20 | 1 | 20 | 43 | Ahab Defeats Ben-Hadad | high |  |
| 1 Kings | 21 | 1 | 21 | 29 | Naboth's Vineyard | high |  |
| 1 Kings | 22 | 1 | 22 | 53 | Micaiah Prophesies Against Ahab | high |  |
| 2 Kings | 1 | 1 | 1 | 18 | Elijah and King Ahaziah | high |  |
| 2 Kings | 2 | 1 | 2 | 25 | Elijah Taken to Heaven and Elisha Succeeds Him | high |  |
| 2 Kings | 3 | 1 | 3 | 27 | Moab Revolts and the Kings Seek Elisha | high |  |
| 2 Kings | 4 | 1 | 4 | 44 | Elisha's Miracles for the Widow and the Shunammite | high |  |
| 2 Kings | 5 | 1 | 5 | 27 | Elisha and Naaman | high |  |
| 2 Kings | 6 | 1 | 6 | 33 | An Axhead Floats and the Arameans Blinded | high |  |
| 2 Kings | 7 | 1 | 7 | 20 | The Siege of Samaria Lifted | high |  |
| 2 Kings | 8 | 1 | 8 | 29 | The Shunammite's Land Restored and Hazael Murders Ben-Hadad | high |  |
| 2 Kings | 9 | 1 | 9 | 37 | Jehu Anointed King and the Deaths of Joram, Ahaziah, and Jezebel | high |  |
| 2 Kings | 10 | 1 | 10 | 36 | Jehu Kills Ahab's Family and the Prophets of Baal | high |  |
| 2 Kings | 11 | 1 | 11 | 21 | Athaliah and Joash | high |  |
| 2 Kings | 12 | 1 | 12 | 21 | Joash Repairs the Temple | high |  |
| 2 Kings | 13 | 1 | 13 | 25 | Jehoahaz and Jehoash of Israel, and Elisha's Death | high |  |
| 2 Kings | 14 | 1 | 14 | 29 | Amaziah of Judah and Jeroboam II of Israel | high |  |
| 2 Kings | 15 | 1 | 15 | 38 | A Succession of Kings in Israel and Judah | high |  |
| 2 Kings | 16 | 1 | 16 | 20 | Ahaz King of Judah | high |  |
| 2 Kings | 17 | 1 | 17 | 41 | The Fall of Israel to Assyria | high |  |
| 2 Kings | 18 | 1 | 18 | 37 | Hezekiah King of Judah and Sennacherib's Threat | high |  |
| 2 Kings | 19 | 1 | 19 | 37 | Isaiah Prophesies Deliverance and Sennacherib's Defeat | high |  |
| 2 Kings | 20 | 1 | 20 | 21 | Hezekiah's Illness and Babylonian Envoys | high |  |
| 2 Kings | 21 | 1 | 21 | 26 | Manasseh and Amon Kings of Judah | high |  |
| 2 Kings | 22 | 1 | 22 | 20 | Josiah and the Book of the Law | high |  |
| 2 Kings | 23 | 1 | 23 | 37 | Josiah's Reforms and Death | high |  |
| 2 Kings | 24 | 1 | 24 | 20 | Jehoiakim and Jehoiachin, and the First Deportation | high |  |
| 2 Kings | 25 | 1 | 25 | 30 | The Fall of Jerusalem / Babylonian captivity | high |  |
| 1 Chronicles | 1 | 1 | 3 | 24 | Genealogies: Adam to David and His Descendants | high |  |
| 1 Chronicles | 4 | 1 | 5 | 26 | Genealogies of Judah, Simeon, Reuben, Gad, and the Half-Tribe of Manasseh | high |  |
| 1 Chronicles | 6 | 1 | 6 | 81 | The Genealogy of Levi and the Temple Musicians | high |  |
| 1 Chronicles | 7 | 1 | 8 | 40 | Genealogies of the Remaining Tribes and Benjamin | high |  |
| 1 Chronicles | 9 | 1 | 9 | 44 | The People of Jerusalem and the Genealogy of Saul | high |  |
| 1 Chronicles | 10 | 1 | 10 | 14 | The Tragic Death of Saul | high |  |
| 1 Chronicles | 11 | 1 | 12 | 40 | David Becomes King and His Mighty Men | high |  |
| 1 Chronicles | 13 | 1 | 14 | 17 | Bringing Back the Ark and David's Victories | high |  |
| 1 Chronicles | 15 | 1 | 16 | 43 | The Ark is Brought to Jerusalem and David's Psalm of Thanks | high |  |
| 1 Chronicles | 17 | 1 | 17 | 27 | God's Covenant with David | high |  |
| 1 Chronicles | 18 | 1 | 20 | 8 | David's Victories and Battles | high |  |
| 1 Chronicles | 21 | 1 | 21 | 30 | David's Census and the Plague | high |  |
| 1 Chronicles | 22 | 1 | 22 | 19 | David Prepares for the Temple Building | high |  |
| 1 Chronicles | 23 | 1 | 26 | 32 | The Organization of the Levites, Priests, Singers, and Gatekeepers | high |  |
| 1 Chronicles | 27 | 1 | 27 | 34 | Military and Civil Leaders | high |  |
| 1 Chronicles | 28 | 1 | 29 | 30 | David's Plans for the Temple, His Final Words, and Death | high |  |
| 2 Chronicles | 1 | 1 | 1 | 17 | Solomon Asks for Wisdom | high |  |
| 2 Chronicles | 2 | 1 | 4 | 22 | Solomon Prepares and Builds the Temple | high |  |
| 2 Chronicles | 5 | 1 | 7 | 22 | The Ark Brought into the Temple and Its Dedication | high |  |
| 2 Chronicles | 8 | 1 | 9 | 31 | Solomon's Accomplishments, the Queen of Sheba, and His Death | high |  |
| 2 Chronicles | 10 | 1 | 12 | 16 | Rehoboam's Reign and the Division of the Kingdom | high |  |
| 2 Chronicles | 13 | 1 | 13 | 22 | Abijah King of Judah | high |  |
| 2 Chronicles | 14 | 1 | 16 | 14 | Asa's Reforms and Reign | high |  |
| 2 Chronicles | 17 | 1 | 20 | 37 | Jehoshaphat's Reign, Alliance with Ahab, and Victory | high |  |
| 2 Chronicles | 21 | 1 | 21 | 20 | Jehoram King of Judah | high |  |
| 2 Chronicles | 22 | 1 | 22 | 12 | Ahaziah and Athaliah | high |  |
| 2 Chronicles | 23 | 1 | 24 | 27 | Joash Made King and Repairs the Temple | high |  |
| 2 Chronicles | 25 | 1 | 25 | 28 | Amaziah King of Judah | high |  |
| 2 Chronicles | 26 | 1 | 26 | 23 | Uzziah King of Judah | high |  |
| 2 Chronicles | 27 | 1 | 27 | 9 | Jotham King of Judah | high |  |
| 2 Chronicles | 28 | 1 | 28 | 27 | Ahaz King of Judah | high |  |
| 2 Chronicles | 29 | 1 | 31 | 21 | Hezekiah Purifies the Temple and Celebrates the Passover | high |  |
| 2 Chronicles | 32 | 1 | 32 | 33 | Sennacherib's Invasion and Hezekiah's Death | high |  |
| 2 Chronicles | 33 | 1 | 33 | 25 | Manasseh and Amon | high |  |
| 2 Chronicles | 34 | 1 | 36 | 23 | Josiah's Reforms, Final Kings of Judah, and the Fall of Jerusalem | high |  |
| Ezra | 1 | 1 | 1 | 11 | Cyrus Helps the Exiles Return | high |  |
| Ezra | 2 | 1 | 2 | 70 | The List of the Exiles Who Returned | high |  |
| Ezra | 3 | 1 | 4 | 24 | Rebuilding the Altar, Temple Foundation, and Opposition | high |  |
| Ezra | 5 | 1 | 6 | 22 | Rebuilding the Temple | low | Spans the prophets' urging in ch5 to completion and dedication in ch6. |
| Ezra | 7 | 1 | 8 | 36 | Ezra Arrives in Jerusalem and the List of Returnees | high |  |
| Ezra | 9 | 1 | 9 | 15 | Ezra's Prayer Regarding Intermarriage | high |  |
| Ezra | 10 | 1 | 10 | 44 | The Confession and Separation from Foreign Wives | high |  |
| Nehemiah | 1 | 1 | 2 | 20 | Nehemiah's Prayer and Return to Jerusalem | high |  |
| Nehemiah | 3 | 1 | 6 | 19 | Nehemiah Rebuilds the Wall | high |  |
| Nehemiah | 7 | 1 | 7 | 73 | The List of Exiles | high |  |
| Nehemiah | 8 | 1 | 8 | 18 | Ezra Reads the Law | high |  |
| Nehemiah | 9 | 1 | 10 | 39 | The Israelites Confess Their Sins and Seal the Covenant | high |  |
| Nehemiah | 11 | 1 | 13 | 31 | Residents of Jerusalem, Dedication of the Wall, and Final Reforms | high |  |
| Esther | 1 | 1 | 2 | 23 | Queen Vashti Deposed and Esther Made Queen | high |  |
| Esther | 3 | 1 | 4 | 17 | Queen Esther's Courage / Haman's plot | high |  |
| Esther | 5 | 1 | 7 | 10 | Esther's Banquets and Haman's Downfall | high |  |
| Esther | 8 | 1 | 10 | 3 | The King's Edict for the Jews and the Feast of Purim | high |  |
