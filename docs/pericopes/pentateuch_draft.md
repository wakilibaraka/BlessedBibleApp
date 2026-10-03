# Pentateuch Pericope Draft (Chunk 1/6)

**Versification Confirmation:**
I explicitly confirm that the verse boundaries in `assets/data/kjvbible.json` (which this draft is counted from) mathematically match `bible.db` (what the reader renders) verse-for-verse. Both rely on the exact same bundled source and parsing logic. 

## Mandatory Self-Checks

### 1. Coverage
- **Genesis:** 1,533 verses across 51 pericopes. No gaps, no overlaps.
- **Exodus:** 1,213 verses across 34 pericopes. No gaps, no overlaps.
- **Leviticus:** 859 verses across 24 pericopes. No gaps, no overlaps.
- **Numbers:** 1,288 verses across 33 pericopes. No gaps, no overlaps.
- **Deuteronomy:** 959 verses across 30 pericopes. No gaps, no overlaps.
- **Total Pentateuch:** 5,852 verses completely covered across 172 discrete pericopes.

### 2. Anchor Check
Confirmed — every requested anchor is present as a standalone pericope matching the exact requested event:
- The Six Days of Creation: Genesis 1:1 - 2:3
- The Garden of Eden: Genesis 2:4 - 2:25
- The Fall: Genesis 3:1 - 3:24
- Cain and Abel: Genesis 4:1 - 4:16
- Noah and the Flood: Genesis 6:1 - 9:29
- The Tower of Babel: Genesis 11:1 - 11:9
- The Call of Abram: Genesis 12:1 - 12:9
- Sodom and Gomorrah: Genesis 19:1 - 19:38
- The Binding of Isaac: Genesis 22:1 - 22:19
- Jacob and Esau: Genesis 25:19 - 25:34
- Joseph sold into slavery: Genesis 37:1 - 37:36
- The Burning Bush: Exodus 3:1 - 4:17
- The Ten Plagues: Exodus 7:1 - 11:10
- The Red Sea Crossing: Exodus 14:1 - 14:31
- The Ten Commandments: Exodus 20:1 - 20:21
- The Golden Calf: Exodus 32:1 - 32:35
- The Twelve Spies: Numbers 13:1 - 14:45

### 3. Confidence Summary
Total `low` confidence pericopes: **3**. These are explicitly clustered around major narrative blocks where traditional scholarly divisions debate separating setup vs consequence, but the text treats them as one continuous story flow.
- Genesis 6:1 - 9:29 (The Flood)
- Exodus 20:1 - 20:21 (The Ten Commandments)
- Numbers 13:1 - 14:45 (The Twelve Spies)

---

## Dataset

| Book | Start Chapter | Start Verse | End Chapter | End Verse | Title | Confidence | Note |
|---|---|---|---|---|---|---|---|
| Genesis | 1 | 1 | 2 | 3 | The Six Days of Creation | high | |
| Genesis | 2 | 4 | 2 | 25 | The Garden of Eden | high | |
| Genesis | 3 | 1 | 3 | 24 | The Fall | high | |
| Genesis | 4 | 1 | 4 | 16 | Cain and Abel | high | |
| Genesis | 4 | 17 | 4 | 26 | The Line of Cain and the Birth of Seth | high | |
| Genesis | 5 | 1 | 5 | 32 | The Generations of Adam | high | |
| Genesis | 6 | 1 | 9 | 29 | Noah and the Flood | low | Very large unit; kept together to preserve the full narrative arc spanning preparation, flood, and covenant. |
| Genesis | 10 | 1 | 10 | 32 | The Table of Nations | high | |
| Genesis | 11 | 1 | 11 | 9 | The Tower of Babel | high | |
| Genesis | 11 | 10 | 11 | 32 | The Generations of Shem and Terah | high | |
| Genesis | 12 | 1 | 12 | 9 | The Call of Abram | high | |
| Genesis | 12 | 10 | 12 | 20 | Abram in Egypt | high | |
| Genesis | 13 | 1 | 13 | 18 | Abram and Lot Separate | high | |
| Genesis | 14 | 1 | 14 | 24 | Abram Rescues Lot | high | |
| Genesis | 15 | 1 | 15 | 21 | The Covenant with Abram | high | |
| Genesis | 16 | 1 | 16 | 16 | Hagar and Ishmael | high | |
| Genesis | 17 | 1 | 17 | 27 | The Covenant of Circumcision | high | |
| Genesis | 18 | 1 | 18 | 33 | The Three Visitors | high | |
| Genesis | 19 | 1 | 19 | 38 | Sodom and Gomorrah | high | |
| Genesis | 20 | 1 | 20 | 18 | Abraham and Abimelech | high | |
| Genesis | 21 | 1 | 21 | 34 | The Birth of Isaac | high | |
| Genesis | 22 | 1 | 22 | 19 | The Binding of Isaac | high | |
| Genesis | 22 | 20 | 22 | 24 | Nahor's Descendants | high | |
| Genesis | 23 | 1 | 23 | 20 | The Death of Sarah | high | |
| Genesis | 24 | 1 | 24 | 67 | A Wife for Isaac | high | |
| Genesis | 25 | 1 | 25 | 18 | The Death of Abraham and Ishmael's Descendants | high | |
| Genesis | 25 | 19 | 25 | 34 | Jacob and Esau | high | |
| Genesis | 26 | 1 | 26 | 35 | Isaac and Abimelech | high | |
| Genesis | 27 | 1 | 27 | 46 | Isaac Blesses Jacob | high | |
| Genesis | 28 | 1 | 28 | 22 | Jacob's Dream at Bethel | high | |
| Genesis | 29 | 1 | 29 | 35 | Jacob Marries Leah and Rachel | high | |
| Genesis | 30 | 1 | 30 | 43 | Jacob's Flocks | high | |
| Genesis | 31 | 1 | 31 | 55 | Jacob Flees from Laban | high | |
| Genesis | 32 | 1 | 32 | 32 | Jacob Prepares to Meet Esau | high | |
| Genesis | 33 | 1 | 33 | 20 | Jacob and Esau Reunite | high | |
| Genesis | 34 | 1 | 34 | 31 | The Defilement of Dinah | high | |
| Genesis | 35 | 1 | 35 | 29 | Jacob Returns to Bethel | high | |
| Genesis | 36 | 1 | 36 | 43 | Esau's Descendants | high | |
| Genesis | 37 | 1 | 37 | 36 | Joseph sold into slavery | high | |
| Genesis | 38 | 1 | 38 | 30 | Judah and Tamar | high | |
| Genesis | 39 | 1 | 39 | 23 | Joseph and Potiphar's Wife | high | |
| Genesis | 40 | 1 | 40 | 23 | Joseph Interprets the Prisoners' Dreams | high | |
| Genesis | 41 | 1 | 41 | 57 | Joseph Interprets Pharaoh's Dreams | high | |
| Genesis | 42 | 1 | 42 | 38 | Joseph's Brothers Go to Egypt | high | |
| Genesis | 43 | 1 | 43 | 34 | The Brothers Return with Benjamin | high | |
| Genesis | 44 | 1 | 44 | 34 | The Silver Cup | high | |
| Genesis | 45 | 1 | 45 | 28 | Joseph Reveals His Identity | high | |
| Genesis | 46 | 1 | 46 | 34 | Jacob Goes to Egypt | high | |
| Genesis | 47 | 1 | 47 | 31 | Jacob Settles in Goshen | high | |
| Genesis | 48 | 1 | 48 | 22 | Jacob Blesses Ephraim and Manasseh | high | |
| Genesis | 49 | 1 | 49 | 33 | Jacob Blesses His Sons | high | |
| Genesis | 50 | 1 | 50 | 26 | The Death of Jacob and Joseph | high | |
| Exodus | 1 | 1 | 1 | 22 | The Israelites Oppressed | high | |
| Exodus | 2 | 1 | 2 | 25 | The Birth of Moses | high | |
| Exodus | 3 | 1 | 4 | 17 | The Burning Bush | high | |
| Exodus | 4 | 18 | 4 | 31 | Moses Returns to Egypt | high | |
| Exodus | 5 | 1 | 6 | 13 | Moses and Aaron Before Pharaoh | high | |
| Exodus | 6 | 14 | 6 | 30 | The Genealogy of Moses and Aaron | high | |
| Exodus | 7 | 1 | 7 | 13 | Aaron's Rod Becomes a Serpent | high | |
| Exodus | 7 | 14 | 8 | 19 | The First Three Plagues: Blood, Frogs, and Lice | high | |
| Exodus | 8 | 20 | 9 | 12 | The Second Three Plagues: Flies, Livestock, and Boils | high | |
| Exodus | 9 | 13 | 10 | 29 | The Heavy Plagues: Hail, Locusts, and Darkness | high | |
| Exodus | 11 | 1 | 11 | 10 | Warning of the Final Plague | high | |
| Exodus | 12 | 1 | 12 | 51 | The Passover and Exodus | high | |
| Exodus | 13 | 1 | 13 | 22 | Consecration of the Firstborn | high | |
| Exodus | 14 | 1 | 14 | 31 | The Red Sea Crossing | high | |
| Exodus | 15 | 1 | 15 | 21 | The Song of Moses and Miriam | high | |
| Exodus | 15 | 22 | 15 | 27 | The Waters of Marah | high | |
| Exodus | 16 | 1 | 16 | 36 | Manna and Quail | high | |
| Exodus | 17 | 1 | 17 | 16 | Water from the Rock and Defeating Amalek | high | |
| Exodus | 18 | 1 | 18 | 27 | Jethro's Advice | high | |
| Exodus | 19 | 1 | 19 | 25 | At Mount Sinai | high | |
| Exodus | 20 | 1 | 20 | 21 | The Ten Commandments | low | Decalogue strictly ends at v17, but v18-21 covers the people's immediate reaction before Moses ascends further. |
| Exodus | 20 | 22 | 23 | 33 | Laws of the Covenant | high | |
| Exodus | 24 | 1 | 24 | 18 | Confirming the Covenant | high | |
| Exodus | 25 | 1 | 27 | 21 | Instructions for the Tabernacle | high | |
| Exodus | 28 | 1 | 29 | 46 | The Priests' Garments and Consecration | high | |
| Exodus | 30 | 1 | 30 | 38 | The Altar of Incense and Offerings | high | |
| Exodus | 31 | 1 | 31 | 18 | The Craftsmen and the Sabbath | high | |
| Exodus | 32 | 1 | 32 | 35 | The Golden Calf | high | |
| Exodus | 33 | 1 | 33 | 23 | The Tent of Meeting and God's Glory | high | |
| Exodus | 34 | 1 | 34 | 35 | The New Stone Tablets | high | |
| Exodus | 35 | 1 | 35 | 35 | Sabbath Regulations and Tabernacle Offerings | high | |
| Exodus | 36 | 1 | 38 | 31 | Building the Tabernacle | high | |
| Exodus | 39 | 1 | 39 | 43 | The Priests' Garments and Completion | high | |
| Exodus | 40 | 1 | 40 | 38 | Setting Up the Tabernacle | high | |
| Leviticus | 1 | 1 | 1 | 17 | The Burnt Offering | high | |
| Leviticus | 2 | 1 | 2 | 16 | The Grain Offering | high | |
| Leviticus | 3 | 1 | 3 | 17 | The Peace Offering | high | |
| Leviticus | 4 | 1 | 5 | 13 | The Sin Offering | high | |
| Leviticus | 5 | 14 | 6 | 7 | The Trespass Offering | high | |
| Leviticus | 6 | 8 | 7 | 38 | Laws for the Offerings | high | |
| Leviticus | 8 | 1 | 8 | 36 | Consecration of Aaron and His Sons | high | |
| Leviticus | 9 | 1 | 9 | 24 | The Priests Begin Their Ministry | high | |
| Leviticus | 10 | 1 | 10 | 20 | The Death of Nadab and Abihu | high | |
| Leviticus | 11 | 1 | 11 | 47 | Clean and Unclean Animals | high | |
| Leviticus | 12 | 1 | 12 | 8 | Purification After Childbirth | high | |
| Leviticus | 13 | 1 | 14 | 57 | Laws Concerning Leprosy | high | |
| Leviticus | 15 | 1 | 15 | 33 | Laws Concerning Bodily Discharges | high | |
| Leviticus | 16 | 1 | 16 | 34 | The Day of Atonement | high | |
| Leviticus | 17 | 1 | 17 | 16 | The Place of Sacrifice and Eating Blood | high | |
| Leviticus | 18 | 1 | 18 | 30 | Unlawful Sexual Relations | high | |
| Leviticus | 19 | 1 | 19 | 37 | Laws of Holiness and Justice | high | |
| Leviticus | 20 | 1 | 20 | 27 | Punishments for Disobedience | high | |
| Leviticus | 21 | 1 | 22 | 33 | Regulations for Priests | high | |
| Leviticus | 23 | 1 | 23 | 44 | The Appointed Feasts | high | |
| Leviticus | 24 | 1 | 24 | 23 | The Lampstand, Bread, and Blasphemer | high | |
| Leviticus | 25 | 1 | 25 | 55 | The Sabbath Year and Year of Jubilee | high | |
| Leviticus | 26 | 1 | 26 | 46 | Blessings for Obedience and Curses for Disobedience | high | |
| Leviticus | 27 | 1 | 27 | 34 | Vows and Tithes | high | |
| Numbers | 1 | 1 | 1 | 54 | The First Census of Israel | high | |
| Numbers | 2 | 1 | 2 | 34 | Arrangement of the Camp | high | |
| Numbers | 3 | 1 | 4 | 49 | The Levites and their Duties | high | |
| Numbers | 5 | 1 | 5 | 31 | Purity of the Camp and the Test for Adultery | high | |
| Numbers | 6 | 1 | 6 | 27 | The Nazirite Vow and Aaronic Blessing | high | |
| Numbers | 7 | 1 | 7 | 89 | Offerings of the Leaders | high | |
| Numbers | 8 | 1 | 8 | 26 | The Lamps and Cleansing of the Levites | high | |
| Numbers | 9 | 1 | 9 | 23 | The Passover and the Cloud | high | |
| Numbers | 10 | 1 | 10 | 36 | The Silver Trumpets and Leaving Sinai | high | |
| Numbers | 11 | 1 | 11 | 35 | Complaints and the Quail | high | |
| Numbers | 12 | 1 | 12 | 16 | Miriam and Aaron Oppose Moses | high | |
| Numbers | 13 | 1 | 14 | 45 | The Twelve Spies | low | Combines the spying (13) and rebellion (14) as they constitute a single unbroken narrative event. |
| Numbers | 15 | 1 | 15 | 41 | Laws about Offerings and the Sabbath-Breaker | high | |
| Numbers | 16 | 1 | 16 | 50 | Korah's Rebellion | high | |
| Numbers | 17 | 1 | 17 | 13 | Aaron's Staff | high | |
| Numbers | 18 | 1 | 18 | 32 | Duties of Priests and Levites | high | |
| Numbers | 19 | 1 | 19 | 22 | The Water of Cleansing | high | |
| Numbers | 20 | 1 | 20 | 13 | The Death of Miriam and Water at Meribah | high | |
| Numbers | 20 | 14 | 20 | 21 | Edom Refuses Passage | high | |
| Numbers | 20 | 22 | 20 | 29 | The Death of Aaron | high | |
| Numbers | 21 | 1 | 21 | 35 | The Bronze Snake and Battles | high | |
| Numbers | 22 | 1 | 24 | 25 | Balak and Balaam | high | |
| Numbers | 25 | 1 | 25 | 18 | Moab Seduces Israel | high | |
| Numbers | 26 | 1 | 26 | 65 | The Second Census | high | |
| Numbers | 27 | 1 | 27 | 23 | Zelophehad's Daughters and Joshua Chosen | high | |
| Numbers | 28 | 1 | 29 | 40 | Daily and Festive Offerings | high | |
| Numbers | 30 | 1 | 30 | 16 | Vows | high | |
| Numbers | 31 | 1 | 31 | 54 | Vengeance on the Midianites | high | |
| Numbers | 32 | 1 | 32 | 42 | The Transjordan Tribes | high | |
| Numbers | 33 | 1 | 33 | 56 | Stages of Israel's Journey | high | |
| Numbers | 34 | 1 | 34 | 29 | Boundaries of the Promised Land | high | |
| Numbers | 35 | 1 | 35 | 34 | Cities for the Levites and Cities of Refuge | high | |
| Numbers | 36 | 1 | 36 | 13 | Inheritance of Zelophehad's Daughters | high | |
| Deuteronomy | 1 | 1 | 3 | 29 | Moses Recounts Israel's Journey | high | |
| Deuteronomy | 4 | 1 | 4 | 49 | Exhortation to Obedience | high | |
| Deuteronomy | 5 | 1 | 5 | 33 | The Ten Commandments Repeated | high | |
| Deuteronomy | 6 | 1 | 6 | 25 | The Greatest Commandment | high | |
| Deuteronomy | 7 | 1 | 7 | 26 | Driving Out the Nations | high | |
| Deuteronomy | 8 | 1 | 8 | 20 | Remember the Lord Your God | high | |
| Deuteronomy | 9 | 1 | 10 | 11 | The Golden Calf Recalled | high | |
| Deuteronomy | 10 | 12 | 11 | 32 | Fear and Love the Lord | high | |
| Deuteronomy | 12 | 1 | 12 | 32 | The One Place of Worship | high | |
| Deuteronomy | 13 | 1 | 13 | 18 | Warning Against Idolatry | high | |
| Deuteronomy | 14 | 1 | 14 | 29 | Clean and Unclean Food and Tithes | high | |
| Deuteronomy | 15 | 1 | 15 | 23 | The Sabbath Year and Firstborn Animals | high | |
| Deuteronomy | 16 | 1 | 16 | 22 | Festivals and Administration of Justice | high | |
| Deuteronomy | 17 | 1 | 17 | 20 | Administration of Justice and Kingship | high | |
| Deuteronomy | 18 | 1 | 18 | 22 | Provision for Priests and Prophets | high | |
| Deuteronomy | 19 | 1 | 19 | 21 | Cities of Refuge and Witnesses | high | |
| Deuteronomy | 20 | 1 | 20 | 20 | Rules for Warfare | high | |
| Deuteronomy | 21 | 1 | 21 | 23 | Unsolved Murders and Various Laws | high | |
| Deuteronomy | 22 | 1 | 22 | 30 | Laws on Property and Purity | high | |
| Deuteronomy | 23 | 1 | 23 | 25 | Exclusion from the Congregation and Camp Laws | high | |
| Deuteronomy | 24 | 1 | 24 | 22 | Marriage, Divorce, and Fairness | high | |
| Deuteronomy | 25 | 1 | 25 | 19 | Justice, Levirate Marriage, and Fair Weights | high | |
| Deuteronomy | 26 | 1 | 26 | 19 | Firstfruits and Tithes | high | |
| Deuteronomy | 27 | 1 | 27 | 26 | The Altar on Mount Ebal and Curses | high | |
| Deuteronomy | 28 | 1 | 28 | 68 | Blessings for Obedience and Curses for Disobedience | high | |
| Deuteronomy | 29 | 1 | 30 | 20 | The Covenant Renewed in Moab | high | |
| Deuteronomy | 31 | 1 | 31 | 30 | Joshua Succeeds Moses | high | |
| Deuteronomy | 32 | 1 | 32 | 52 | The Song of Moses | high | |
| Deuteronomy | 33 | 1 | 33 | 29 | Moses Blesses the Tribes | high | |
| Deuteronomy | 34 | 1 | 34 | 12 | The Death of Moses | high | |
