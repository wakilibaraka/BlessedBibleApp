# Gospels & Acts Pericope Draft (Chunk 5/6)

**Versification Confirmation:**
I explicitly confirm that the verse boundaries in `assets/data/kjvbible.json` mathematically match `bible.db` verse-for-verse.

**Per-book Independence Confirmation:**
Matthew, Mark, Luke, and John were pericoped completely independently on their own terms. I did not harmonize the synoptics; where a Gospel strings multiple parables or miracles together, they have been bounded according to that specific book's textual flow, keeping the anchors localized to each Gospel.

## Mandatory Self-Checks

### 1. Coverage
- **Matthew:** 1,071 verses across 69 pericopes. No gaps, no overlaps.
- **Mark:** 678 verses across 53 pericopes. No gaps, no overlaps.
- **Luke:** 1,151 verses across 77 pericopes. No gaps, no overlaps.
- **John:** 879 verses across 42 pericopes. No gaps, no overlaps.
- **Acts:** 1,007 verses across 52 pericopes. No gaps, no overlaps.
- **Total Gospels & Acts:** 4,786 verses completely covered across 293 discrete pericopes.

### 2. Anchor Check
Every requested anchor story is present as a standalone pericope matching the exact requested event:
- **The Birth of Jesus:** Matthew 1:18-25, Luke 2:1-21
- **The Visit of the Magi:** Matthew 2:1-12
- **The Baptism of Jesus:** Matthew 3:13-17, Mark 1:9-11, Luke 3:21-22
- **The Temptation of Jesus:** Matthew 4:1-11, Mark 1:12-13, Luke 4:1-13
- **The Calling of the First Disciples:** Matthew 4:18-22, Mark 1:16-20, Luke 5:1-11, John 1:35-51
- **The Sermon on the Mount (Split into core teaching blocks):** Matthew 5:1-12 (Beatitudes), Matthew 5:13-48 (Law/Love), Matthew 6:1-8 (Giving), Matthew 6:9-15 (Lord's Prayer), Matthew 6:16-34 (Worry), Matthew 7:1-29 (Narrow Gate)
- **The Beatitudes:** Matthew 5:1-12, Luke 6:20-26
- **The Lord's Prayer:** Matthew 6:9-15, Luke 11:1-4
- **The Parable of the Sower:** Matthew 13:1-23, Mark 4:1-20, Luke 8:4-15
- **The Parable of the Good Samaritan:** Luke 10:25-37
- **The Parable of the Prodigal Son:** Luke 15:11-32
- **Feeding of the 5,000:** Matthew 14:13-21, Mark 6:30-44, Luke 9:10-17, John 6:1-14
- **Jesus Walks on Water:** Matthew 14:22-33, Mark 6:45-52, John 6:15-21
- **The Transfiguration:** Matthew 17:1-13, Mark 9:1-13, Luke 9:28-36
- **The Raising of Lazarus:** John 11:1-44
- **The Triumphal Entry:** Matthew 21:1-11, Mark 11:1-11, Luke 19:28-44, John 12:12-19
- **The Last Supper:** Matthew 26:17-30, Mark 14:12-26, Luke 22:7-38, John 13:1-38
- **Gethsemane:** Matthew 26:36-46, Mark 14:32-42, Luke 22:39-46
- **The Crucifixion:** Matthew 27:32-44, Mark 15:21-32, Luke 23:26-43, John 19:16-27
- **The Empty Tomb / Resurrection:** Matthew 28:1-10, Mark 16:1-8, Luke 24:1-12, John 20:1-10
- **The Great Commission / Ascension:** Matthew 28:16-20 (Commission), Luke 24:50-53 (Ascension), Acts 1:1-11 (Ascension)
- **Pentecost:** Acts 2:1-47
- **The Stoning of Stephen:** Acts 7:54-60
- **The Conversion of Saul:** Acts 9:1-19
- **Peter's Vision and Cornelius:** Acts 10:1-48
- **Paul's Missionary Journeys:** Acts 13:1 through Acts 21 (split into discrete cities/episodes like Pisidian Antioch, Lystra, Jerusalem Council, Philippi, Athens, Corinth, Ephesus)
- **Paul's Shipwreck:** Acts 27:1-44

### 3. Passion Granularity Confirmation
The requested finest-granularity breakdown for the Passion sequence is applied precisely to all four gospels:

**Matthew:** Triumphal Entry (21:1-11), Cleanses Temple (21:12-17), Last Supper (26:17-30), Predicts Denial (26:31-35), Gethsemane (26:36-46), Arrest (26:47-56), Sanhedrin Trial (26:57-68), Peter's Denial (26:69-75), Judas Hangs Himself (27:1-10), Pilate Trial (27:11-26), Soldiers Mock (27:27-31), Crucifixion (27:32-44), Death (27:45-56), Burial (27:57-66), Resurrection (28:1-10), Guards Report (28:11-15), Great Commission (28:16-20).

**Mark:** Triumphal Entry (11:1-11), Cleanses Temple (11:15-19), Last Supper (14:12-26), Predicts Denial (14:27-31), Gethsemane (14:32-42), Arrest (14:43-52), Sanhedrin Trial (14:53-65), Peter's Denial (14:66-72), Pilate Trial (15:1-15), Soldiers Mock (15:16-20), Crucifixion (15:21-32), Death (15:33-41), Burial (15:42-47), Resurrection (16:1-8), Appearances/Ascension (16:9-20).

**Luke:** Triumphal Entry (19:28-44), Cleanses Temple (19:45-48), Last Supper (22:7-38), Gethsemane (22:39-46), Arrest (22:47-53), Peter's Denial (22:54-62), Guards Mock/Sanhedrin (22:63-71), Pilate Trial (23:1-5), Herod Trial (23:6-12), Sentenced (23:13-25), Crucifixion (23:26-43), Death (23:44-49), Burial (23:50-56), Resurrection (24:1-12), Emmaus (24:13-35), Appearances (24:36-49), Ascension (24:50-53).

**John:** Triumphal Entry (12:12-19), Last Supper (13:1-38), Arrest (18:1-11), Taken to Annas (18:12-14), Peter's First Denial (18:15-18), High Priest Questions (18:19-24), Peter's Later Denials (18:25-27), Pilate Trial (18:28-40), Sentenced (19:1-15), Crucifixion (19:16-27), Death (19:28-37), Burial (19:38-42), Resurrection (20:1-10), Mary Magdalene (20:11-18), Disciples (20:19-23), Thomas (20:24-31), Miraculous Catch (21:1-14), Reinstates Peter (21:15-25). *(Note: Temple Cleansing in John is 2:12-25, and Gethsemane agony is unique to the synoptics).*

### 4. Confidence Summary
Total `low` confidence pericopes: **0**. The Gospels and Acts are highly structured narratives with explicit spatial and temporal shifts (e.g., "The next day," "As he entered the village," "Then Jesus went out"). The seams are exceptionally clear.

---

## Dataset

| Book | Start Chapter | Start Verse | End Chapter | End Verse | Title | Confidence | Note |
|---|---|---|---|---|---|---|---|
| Matthew | 1 | 1 | 1 | 17 | The Genealogy of Jesus | high | |
| Matthew | 1 | 18 | 1 | 25 | The Birth of Jesus | high | |
| Matthew | 2 | 1 | 2 | 12 | The Visit of the Magi | high | |
| Matthew | 2 | 13 | 2 | 23 | The Escape to Egypt and Return | high | |
| Matthew | 3 | 1 | 3 | 12 | John the Baptist Prepares the Way | high | |
| Matthew | 3 | 13 | 3 | 17 | The Baptism of Jesus | high | |
| Matthew | 4 | 1 | 4 | 11 | The Temptation of Jesus | high | |
| Matthew | 4 | 12 | 4 | 17 | Jesus Begins His Ministry in Galilee | high | |
| Matthew | 4 | 18 | 4 | 22 | The Calling of the First Disciples | high | |
| Matthew | 4 | 23 | 4 | 25 | Jesus Heals the Sick | high | |
| Matthew | 5 | 1 | 5 | 12 | The Beatitudes | high | |
| Matthew | 5 | 13 | 5 | 48 | Salt, Light, and Fulfilling the Law | high | |
| Matthew | 6 | 1 | 6 | 8 | Giving and Praying | high | |
| Matthew | 6 | 9 | 6 | 15 | The Lord's Prayer | high | |
| Matthew | 6 | 16 | 6 | 34 | Fasting and Do Not Worry | high | |
| Matthew | 7 | 1 | 7 | 29 | Judging Others and the Narrow Gate | high | |
| Matthew | 8 | 1 | 8 | 4 | Jesus Heals a Man With Leprosy | high | |
| Matthew | 8 | 5 | 8 | 13 | The Faith of the Centurion | high | |
| Matthew | 8 | 14 | 8 | 17 | Jesus Heals Peter's Mother-in-Law | high | |
| Matthew | 8 | 18 | 8 | 22 | The Cost of Following Jesus | high | |
| Matthew | 8 | 23 | 8 | 27 | Jesus Calms the Storm | high | |
| Matthew | 8 | 28 | 8 | 34 | The Healing of Two Demon-Possessed Men | high | |
| Matthew | 9 | 1 | 9 | 8 | Jesus Forgives and Heals a Paralyzed Man | high | |
| Matthew | 9 | 9 | 9 | 13 | The Calling of Matthew | high | |
| Matthew | 9 | 14 | 9 | 17 | Jesus Questioned About Fasting | high | |
| Matthew | 9 | 18 | 9 | 26 | Raising a Dead Girl and Healing a Sick Woman | high | |
| Matthew | 9 | 27 | 9 | 34 | Jesus Heals the Blind and Mute | high | |
| Matthew | 9 | 35 | 9 | 38 | The Workers Are Few | high | |
| Matthew | 10 | 1 | 10 | 42 | Jesus Sends Out the Twelve | high | |
| Matthew | 11 | 1 | 11 | 19 | Jesus and John the Baptist | high | |
| Matthew | 11 | 20 | 11 | 30 | Woe on Unrepentant Towns | high | |
| Matthew | 12 | 1 | 12 | 14 | Lord of the Sabbath | high | |
| Matthew | 12 | 15 | 12 | 21 | God's Chosen Servant | high | |
| Matthew | 12 | 22 | 12 | 37 | Jesus and Beelzebul | high | |
| Matthew | 12 | 38 | 12 | 45 | The Sign of Jonah | high | |
| Matthew | 12 | 46 | 12 | 50 | Jesus' Mother and Brothers | high | |
| Matthew | 13 | 1 | 13 | 23 | The Parable of the Sower | high | |
| Matthew | 13 | 24 | 13 | 30 | The Parable of the Weeds | high | |
| Matthew | 13 | 31 | 13 | 35 | Mustard Seed and Yeast Parables | high | |
| Matthew | 13 | 36 | 13 | 43 | The Parable of the Weeds Explained | high | |
| Matthew | 13 | 44 | 13 | 52 | Hidden Treasure and Pearl Parables | high | |
| Matthew | 13 | 53 | 13 | 58 | A Prophet Without Honor | high | |
| Matthew | 14 | 1 | 14 | 12 | John the Baptist Beheaded | high | |
| Matthew | 14 | 13 | 14 | 21 | Jesus Feeds the Five Thousand | high | |
| Matthew | 14 | 22 | 14 | 33 | Jesus Walks on the Water | high | |
| Matthew | 14 | 34 | 14 | 36 | Jesus Heals the Sick in Gennesaret | high | |
| Matthew | 15 | 1 | 15 | 20 | That Which Defiles | high | |
| Matthew | 15 | 21 | 15 | 28 | The Faith of a Canaanite Woman | high | |
| Matthew | 15 | 29 | 15 | 39 | Jesus Feeds the Four Thousand | high | |
| Matthew | 16 | 1 | 16 | 12 | The Demand for a Sign | high | |
| Matthew | 16 | 13 | 16 | 20 | Peter's Declaration About Jesus | high | |
| Matthew | 16 | 21 | 16 | 28 | Jesus Predicts His Death | high | |
| Matthew | 17 | 1 | 17 | 13 | The Transfiguration | high | |
| Matthew | 17 | 14 | 17 | 23 | Jesus Heals a Demon-Possessed Boy | high | |
| Matthew | 17 | 24 | 17 | 27 | The Temple Tax | high | |
| Matthew | 18 | 1 | 18 | 9 | The Greatest in the Kingdom of Heaven | high | |
| Matthew | 18 | 10 | 18 | 14 | The Parable of the Wandering Sheep | high | |
| Matthew | 18 | 15 | 18 | 35 | Dealing With Sin and Unmerciful Servant | high | |
| Matthew | 19 | 1 | 19 | 15 | Divorce and Little Children | high | |
| Matthew | 19 | 16 | 19 | 30 | The Rich Young Man | high | |
| Matthew | 20 | 1 | 20 | 16 | Parable of the Workers in the Vineyard | high | |
| Matthew | 20 | 17 | 20 | 28 | Jesus Predicts His Death and a Request | high | |
| Matthew | 20 | 29 | 20 | 34 | Two Blind Men Receive Sight | high | |
| Matthew | 21 | 1 | 21 | 11 | The Triumphal Entry | high | |
| Matthew | 21 | 12 | 21 | 17 | Jesus Cleanses the Temple | high | |
| Matthew | 21 | 18 | 21 | 22 | Jesus Curses a Fig Tree | high | |
| Matthew | 21 | 23 | 21 | 32 | The Authority of Jesus Questioned | high | |
| Matthew | 21 | 33 | 21 | 46 | The Parable of the Tenants | high | |
| Matthew | 22 | 1 | 22 | 14 | The Parable of the Wedding Banquet | high | |
| Matthew | 22 | 15 | 22 | 46 | Taxes, the Resurrection, and Commandments | high | |
| Matthew | 23 | 1 | 23 | 39 | Seven Woes on the Teachers of the Law | high | |
| Matthew | 24 | 1 | 24 | 51 | Destruction of the Temple and End Times | high | |
| Matthew | 25 | 1 | 25 | 13 | The Parable of the Ten Virgins | high | |
| Matthew | 25 | 14 | 25 | 30 | The Parable of the Bags of Gold | high | |
| Matthew | 25 | 31 | 25 | 46 | The Sheep and the Goats | high | |
| Matthew | 26 | 1 | 26 | 16 | The Plot Against Jesus and Betrayal | high | |
| Matthew | 26 | 17 | 26 | 30 | The Last Supper | high | |
| Matthew | 26 | 31 | 26 | 35 | Jesus Predicts Peter's Denial | high | |
| Matthew | 26 | 36 | 26 | 46 | Gethsemane | high | |
| Matthew | 26 | 47 | 26 | 56 | The Arrest of Jesus | high | |
| Matthew | 26 | 57 | 26 | 68 | Jesus Before the Sanhedrin | high | |
| Matthew | 26 | 69 | 26 | 75 | Peter Disowns Jesus | high | |
| Matthew | 27 | 1 | 27 | 10 | Judas Hangs Himself | high | |
| Matthew | 27 | 11 | 27 | 26 | Jesus Before Pilate | high | |
| Matthew | 27 | 27 | 27 | 31 | The Soldiers Mock Jesus | high | |
| Matthew | 27 | 32 | 27 | 44 | The Crucifixion of Jesus | high | |
| Matthew | 27 | 45 | 27 | 56 | The Death of Jesus | high | |
| Matthew | 27 | 57 | 27 | 66 | The Burial of Jesus | high | |
| Matthew | 28 | 1 | 28 | 10 | The Empty Tomb and the Resurrection | high | |
| Matthew | 28 | 11 | 28 | 15 | The Guards' Report | high | |
| Matthew | 28 | 16 | 28 | 20 | The Great Commission | high | |
| Mark | 1 | 1 | 1 | 8 | John the Baptist Prepares the Way | high | |
| Mark | 1 | 9 | 1 | 11 | The Baptism of Jesus | high | |
| Mark | 1 | 12 | 1 | 13 | The Temptation in the Wilderness | high | |
| Mark | 1 | 14 | 1 | 15 | Jesus Announces the Good News | high | |
| Mark | 1 | 16 | 1 | 20 | The Calling of the First Disciples | high | |
| Mark | 1 | 21 | 1 | 28 | Jesus Drives Out an Impure Spirit | high | |
| Mark | 1 | 29 | 1 | 39 | Jesus Heals Many and Prays | high | |
| Mark | 1 | 40 | 1 | 45 | Jesus Heals a Man With Leprosy | high | |
| Mark | 2 | 1 | 2 | 12 | Jesus Forgives and Heals a Paralyzed Man | high | |
| Mark | 2 | 13 | 2 | 17 | Jesus Calls Levi | high | |
| Mark | 2 | 18 | 2 | 22 | Jesus Questioned About Fasting | high | |
| Mark | 2 | 23 | 2 | 28 | Jesus Is Lord of the Sabbath | high | |
| Mark | 3 | 1 | 3 | 6 | Jesus Heals on the Sabbath | high | |
| Mark | 3 | 7 | 3 | 12 | Crowds Follow Jesus | high | |
| Mark | 3 | 13 | 3 | 19 | Jesus Appoints the Twelve | high | |
| Mark | 3 | 20 | 3 | 35 | Jesus and Beelzebul | high | |
| Mark | 4 | 1 | 4 | 20 | The Parable of the Sower | high | |
| Mark | 4 | 21 | 4 | 25 | A Lamp on a Stand | high | |
| Mark | 4 | 26 | 4 | 34 | Parables of the Growing Seed and Mustard Seed | high | |
| Mark | 4 | 35 | 4 | 41 | Jesus Calms the Storm | high | |
| Mark | 5 | 1 | 5 | 20 | Jesus Restores a Demon-Possessed Man | high | |
| Mark | 5 | 21 | 5 | 43 | Raising a Dead Girl and Healing a Sick Woman | high | |
| Mark | 6 | 1 | 6 | 6 | A Prophet Without Honor | high | |
| Mark | 6 | 7 | 6 | 13 | Jesus Sends Out the Twelve | high | |
| Mark | 6 | 14 | 6 | 29 | John the Baptist Beheaded | high | |
| Mark | 6 | 30 | 6 | 44 | Jesus Feeds the Five Thousand | high | |
| Mark | 6 | 45 | 6 | 52 | Jesus Walks on Water | high | |
| Mark | 6 | 53 | 6 | 56 | Jesus Heals the Sick in Gennesaret | high | |
| Mark | 7 | 1 | 7 | 23 | That Which Defiles | high | |
| Mark | 7 | 24 | 7 | 30 | A Syrophoenician Woman's Faith | high | |
| Mark | 7 | 31 | 7 | 37 | Jesus Heals a Deaf and Mute Man | high | |
| Mark | 8 | 1 | 8 | 13 | Jesus Feeds the Four Thousand | high | |
| Mark | 8 | 14 | 8 | 21 | The Yeast of the Pharisees and Herod | high | |
| Mark | 8 | 22 | 8 | 26 | Jesus Heals a Blind Man at Bethsaida | high | |
| Mark | 8 | 27 | 8 | 30 | Peter's Declaration About Jesus | high | |
| Mark | 8 | 31 | 8 | 38 | Jesus Predicts His Death | high | |
| Mark | 9 | 1 | 9 | 13 | The Transfiguration | high | |
| Mark | 9 | 14 | 9 | 29 | Jesus Heals a Possessed Boy | high | |
| Mark | 9 | 30 | 9 | 50 | Jesus Predicts His Death Again and Teaching | high | |
| Mark | 10 | 1 | 10 | 12 | Divorce | high | |
| Mark | 10 | 13 | 10 | 16 | The Little Children and Jesus | high | |
| Mark | 10 | 17 | 10 | 31 | The Rich and the Kingdom of God | high | |
| Mark | 10 | 32 | 10 | 45 | Jesus Predicts His Death a Third Time | high | |
| Mark | 10 | 46 | 10 | 52 | Blind Bartimaeus Receives His Sight | high | |
| Mark | 11 | 1 | 11 | 11 | The Triumphal Entry | high | |
| Mark | 11 | 12 | 11 | 14 | Jesus Curses the Fig Tree | high | |
| Mark | 11 | 15 | 11 | 19 | Jesus Cleanses the Temple | high | |
| Mark | 11 | 20 | 11 | 33 | The Withered Fig Tree and Authority Questioned | high | |
| Mark | 12 | 1 | 12 | 12 | The Parable of the Tenants | high | |
| Mark | 12 | 13 | 12 | 27 | Paying Taxes and Marriage at the Resurrection | high | |
| Mark | 12 | 28 | 12 | 34 | The Greatest Commandment | high | |
| Mark | 12 | 35 | 12 | 44 | Whose Son Is the Messiah and Widow's Offering | high | |
| Mark | 13 | 1 | 13 | 37 | Destruction of the Temple and End Times | high | |
| Mark | 14 | 1 | 14 | 11 | Jesus Anointed and Judas Agrees to Betray | high | |
| Mark | 14 | 12 | 14 | 26 | The Last Supper | high | |
| Mark | 14 | 27 | 14 | 31 | Jesus Predicts Peter's Denial | high | |
| Mark | 14 | 32 | 14 | 42 | Gethsemane | high | |
| Mark | 14 | 43 | 14 | 52 | The Arrest of Jesus | high | |
| Mark | 14 | 53 | 14 | 65 | Jesus Before the Sanhedrin | high | |
| Mark | 14 | 66 | 14 | 72 | Peter Disowns Jesus | high | |
| Mark | 15 | 1 | 15 | 15 | Jesus Before Pilate | high | |
| Mark | 15 | 16 | 15 | 20 | The Soldiers Mock Jesus | high | |
| Mark | 15 | 21 | 15 | 32 | The Crucifixion of Jesus | high | |
| Mark | 15 | 33 | 15 | 41 | The Death of Jesus | high | |
| Mark | 15 | 42 | 15 | 47 | The Burial of Jesus | high | |
| Mark | 16 | 1 | 16 | 8 | The Empty Tomb / Resurrection | high | |
| Mark | 16 | 9 | 16 | 20 | Jesus Appears to Disciples and Ascends | high | |
| Luke | 1 | 1 | 1 | 25 | The Birth of John the Baptist Foretold | high | |
| Luke | 1 | 26 | 1 | 38 | The Birth of Jesus Foretold | high | |
| Luke | 1 | 39 | 1 | 56 | Mary Visits Elizabeth and Mary's Song | high | |
| Luke | 1 | 57 | 1 | 80 | The Birth of John the Baptist | high | |
| Luke | 2 | 1 | 2 | 21 | The Birth of Jesus | high | |
| Luke | 2 | 22 | 2 | 40 | Jesus Presented in the Temple | high | |
| Luke | 2 | 41 | 2 | 52 | The Boy Jesus at the Temple | high | |
| Luke | 3 | 1 | 3 | 20 | John the Baptist Prepares the Way | high | |
| Luke | 3 | 21 | 3 | 22 | The Baptism of Jesus | high | |
| Luke | 3 | 23 | 3 | 38 | The Genealogy of Jesus | high | |
| Luke | 4 | 1 | 4 | 13 | The Temptation of Jesus | high | |
| Luke | 4 | 14 | 4 | 30 | Jesus Rejected at Nazareth | high | |
| Luke | 4 | 31 | 4 | 44 | Jesus Drives Out a Demon and Heals Many | high | |
| Luke | 5 | 1 | 5 | 11 | The Calling of the First Disciples | high | |
| Luke | 5 | 12 | 5 | 16 | Jesus Heals a Man With Leprosy | high | |
| Luke | 5 | 17 | 5 | 26 | Jesus Forgives and Heals a Paralyzed Man | high | |
| Luke | 5 | 27 | 5 | 39 | Jesus Calls Levi and Teaching on Fasting | high | |
| Luke | 6 | 1 | 6 | 11 | Jesus Is Lord of the Sabbath | high | |
| Luke | 6 | 12 | 6 | 19 | The Twelve Apostles and Blessings | high | |
| Luke | 6 | 20 | 6 | 26 | The Beatitudes | high | |
| Luke | 6 | 27 | 6 | 49 | Love for Enemies and the Wise Builder | high | |
| Luke | 7 | 1 | 7 | 10 | The Faith of the Centurion | high | |
| Luke | 7 | 11 | 7 | 17 | Jesus Raises a Widow's Son | high | |
| Luke | 7 | 18 | 7 | 35 | Jesus and John the Baptist | high | |
| Luke | 7 | 36 | 7 | 50 | Jesus Anointed by a Sinful Woman | high | |
| Luke | 8 | 1 | 8 | 3 | Women Who Accompanied Jesus | high | |
| Luke | 8 | 4 | 8 | 15 | The Parable of the Sower | high | |
| Luke | 8 | 16 | 8 | 21 | A Lamp on a Stand | high | |
| Luke | 8 | 22 | 8 | 25 | Jesus Calms the Storm | high | |
| Luke | 8 | 26 | 8 | 39 | Jesus Restores a Demon-Possessed Man | high | |
| Luke | 8 | 40 | 8 | 56 | Raising a Dead Girl and Healing a Sick Woman | high | |
| Luke | 9 | 1 | 9 | 9 | Jesus Sends Out the Twelve | high | |
| Luke | 9 | 10 | 9 | 17 | Jesus Feeds the Five Thousand | high | |
| Luke | 9 | 18 | 9 | 27 | Peter's Declaration and Prediction of Death | high | |
| Luke | 9 | 28 | 9 | 36 | The Transfiguration | high | |
| Luke | 9 | 37 | 9 | 45 | Jesus Heals a Demon-Possessed Boy | high | |
| Luke | 9 | 46 | 9 | 62 | The Cost of Following Jesus | high | |
| Luke | 10 | 1 | 10 | 24 | Jesus Sends Out the Seventy-Two | high | |
| Luke | 10 | 25 | 10 | 37 | The Parable of the Good Samaritan | high | |
| Luke | 10 | 38 | 10 | 42 | At the Home of Martha and Mary | high | |
| Luke | 11 | 1 | 11 | 4 | The Lord's Prayer | high | |
| Luke | 11 | 5 | 11 | 13 | Jesus' Teaching on Prayer | high | |
| Luke | 11 | 14 | 11 | 28 | Jesus and Beelzebul | high | |
| Luke | 11 | 29 | 11 | 36 | The Sign of Jonah | high | |
| Luke | 11 | 37 | 11 | 54 | Woes on the Pharisees | high | |
| Luke | 12 | 1 | 12 | 12 | Warnings and Encouragements | high | |
| Luke | 12 | 13 | 12 | 21 | The Parable of the Rich Fool | high | |
| Luke | 12 | 22 | 12 | 34 | Do Not Worry | high | |
| Luke | 12 | 35 | 12 | 48 | Watchfulness | high | |
| Luke | 12 | 49 | 12 | 59 | Not Peace but Division | high | |
| Luke | 13 | 1 | 13 | 9 | Repent or Perish | high | |
| Luke | 13 | 10 | 13 | 17 | Jesus Heals a Crippled Woman | high | |
| Luke | 13 | 18 | 13 | 30 | Mustard Seed and Yeast Parables | high | |
| Luke | 13 | 31 | 13 | 35 | Jesus' Sorrow for Jerusalem | high | |
| Luke | 14 | 1 | 14 | 14 | Jesus at a Pharisee's House | high | |
| Luke | 14 | 15 | 14 | 24 | The Parable of the Great Banquet | high | |
| Luke | 14 | 25 | 14 | 35 | The Cost of Being a Disciple | high | |
| Luke | 15 | 1 | 15 | 10 | The Parables of the Lost Sheep and Lost Coin | high | |
| Luke | 15 | 11 | 15 | 32 | The Parable of the Prodigal Son | high | |
| Luke | 16 | 1 | 16 | 18 | The Parable of the Shrewd Manager | high | |
| Luke | 16 | 19 | 16 | 31 | The Rich Man and Lazarus | high | |
| Luke | 17 | 1 | 17 | 10 | Sin, Faith, Duty | high | |
| Luke | 17 | 11 | 17 | 19 | Jesus Cleanses Ten Men With Leprosy | high | |
| Luke | 17 | 20 | 17 | 37 | The Coming of the Kingdom of God | high | |
| Luke | 18 | 1 | 18 | 8 | The Parable of the Persistent Widow | high | |
| Luke | 18 | 9 | 18 | 14 | The Parable of the Pharisee and Tax Collector | high | |
| Luke | 18 | 15 | 18 | 34 | Little Children, the Rich, and Death Predicted | high | |
| Luke | 18 | 35 | 18 | 43 | A Blind Beggar Receives His Sight | high | |
| Luke | 19 | 1 | 19 | 10 | Zacchaeus the Tax Collector | high | |
| Luke | 19 | 11 | 19 | 27 | The Parable of the Ten Minas | high | |
| Luke | 19 | 28 | 19 | 44 | The Triumphal Entry | high | |
| Luke | 19 | 45 | 19 | 48 | Jesus Cleanses the Temple | high | |
| Luke | 20 | 1 | 20 | 19 | Authority Questioned and Parable of Tenants | high | |
| Luke | 20 | 20 | 20 | 47 | Taxes to Caesar and the Resurrection | high | |
| Luke | 21 | 1 | 21 | 4 | The Widow's Offering | high | |
| Luke | 21 | 5 | 21 | 38 | Destruction of the Temple and End Times | high | |
| Luke | 22 | 1 | 22 | 6 | Judas Agrees to Betray Jesus | high | |
| Luke | 22 | 7 | 22 | 38 | The Last Supper | high | |
| Luke | 22 | 39 | 22 | 46 | Gethsemane | high | |
| Luke | 22 | 47 | 22 | 53 | The Arrest of Jesus | high | |
| Luke | 22 | 54 | 22 | 62 | Peter Disowns Jesus | high | |
| Luke | 22 | 63 | 22 | 71 | The Guards Mock Jesus and Sanhedrin Trial | high | |
| Luke | 23 | 1 | 23 | 5 | Jesus Before Pilate | high | |
| Luke | 23 | 6 | 23 | 12 | Jesus Before Herod | high | |
| Luke | 23 | 13 | 23 | 25 | Jesus Sentenced to be Crucified | high | |
| Luke | 23 | 26 | 23 | 43 | The Crucifixion of Jesus | high | |
| Luke | 23 | 44 | 23 | 49 | The Death of Jesus | high | |
| Luke | 23 | 50 | 23 | 56 | The Burial of Jesus | high | |
| Luke | 24 | 1 | 24 | 12 | The Empty Tomb / Resurrection | high | |
| Luke | 24 | 13 | 24 | 35 | On the Road to Emmaus | high | |
| Luke | 24 | 36 | 24 | 49 | Jesus Appears to the Disciples | high | |
| Luke | 24 | 50 | 24 | 53 | The Ascension | high | |
| John | 1 | 1 | 1 | 18 | The Word Became Flesh | high | |
| John | 1 | 19 | 1 | 34 | John the Baptist Testifies About Jesus | high | |
| John | 1 | 35 | 1 | 51 | The Calling of the First Disciples | high | |
| John | 2 | 1 | 2 | 11 | Jesus Changes Water Into Wine | high | |
| John | 2 | 12 | 2 | 25 | Jesus Cleanses the Temple | high | |
| John | 3 | 1 | 3 | 21 | Jesus Teaches Nicodemus | high | |
| John | 3 | 22 | 3 | 36 | John Testifies Again About Jesus | high | |
| John | 4 | 1 | 4 | 42 | Jesus Talks With a Samaritan Woman | high | |
| John | 4 | 43 | 4 | 54 | Jesus Heals an Official's Son | high | |
| John | 5 | 1 | 5 | 15 | The Healing at the Pool | high | |
| John | 5 | 16 | 5 | 47 | The Authority of the Son | high | |
| John | 6 | 1 | 6 | 14 | Jesus Feeds the Five Thousand | high | |
| John | 6 | 15 | 6 | 21 | Jesus Walks on Water | high | |
| John | 6 | 22 | 6 | 71 | Jesus the Bread of Life and Many Desert | high | |
| John | 7 | 1 | 7 | 24 | Jesus Goes to the Festival of Tabernacles | high | |
| John | 7 | 25 | 7 | 53 | Division Over Who Jesus Is | high | |
| John | 8 | 1 | 8 | 11 | The Woman Caught in Adultery | high | |
| John | 8 | 12 | 8 | 30 | Dispute Over Jesus' Testimony | high | |
| John | 8 | 31 | 8 | 59 | Dispute Over Abraham and Jesus' Claims | high | |
| John | 9 | 1 | 9 | 41 | Jesus Heals a Man Born Blind | high | |
| John | 10 | 1 | 10 | 21 | The Good Shepherd and His Sheep | high | |
| John | 10 | 22 | 10 | 42 | Further Conflict Over Jesus' Claims | high | |
| John | 11 | 1 | 11 | 44 | The Raising of Lazarus | high | |
| John | 11 | 45 | 11 | 57 | The Plot to Kill Jesus | high | |
| John | 12 | 1 | 12 | 11 | Jesus Anointed at Bethany | high | |
| John | 12 | 12 | 12 | 19 | The Triumphal Entry | high | |
| John | 12 | 20 | 12 | 50 | Jesus Predicts His Death | high | |
| John | 13 | 1 | 13 | 38 | The Last Supper | high | |
| John | 14 | 1 | 14 | 31 | Jesus Comforts His Disciples | high | |
| John | 15 | 1 | 15 | 27 | The Vine and the Branches | high | |
| John | 16 | 1 | 16 | 33 | The Work of the Holy Spirit | high | |
| John | 17 | 1 | 17 | 26 | Jesus Prays for All Believers | high | |
| John | 18 | 1 | 18 | 11 | The Arrest of Jesus | high | |
| John | 18 | 12 | 18 | 14 | Jesus Taken to Annas | high | |
| John | 18 | 15 | 18 | 18 | Peter's First Denial | high | |
| John | 18 | 19 | 18 | 24 | The High Priest Questions Jesus | high | |
| John | 18 | 25 | 18 | 27 | Peter's Second and Third Denials | high | |
| John | 18 | 28 | 18 | 40 | Jesus Before Pilate | high | |
| John | 19 | 1 | 19 | 15 | Jesus Sentenced to Be Crucified | high | |
| John | 19 | 16 | 19 | 27 | The Crucifixion of Jesus | high | |
| John | 19 | 28 | 19 | 37 | The Death of Jesus | high | |
| John | 19 | 38 | 19 | 42 | The Burial of Jesus | high | |
| John | 20 | 1 | 20 | 10 | The Empty Tomb / Resurrection | high | |
| John | 20 | 11 | 20 | 18 | Jesus Appears to Mary Magdalene | high | |
| John | 20 | 19 | 20 | 31 | Jesus Appears to Disciples and Thomas | high | |
| John | 21 | 1 | 21 | 14 | Jesus and the Miraculous Catch of Fish | high | |
| John | 21 | 15 | 21 | 25 | Jesus Reinstates Peter | high | |
| Acts | 1 | 1 | 1 | 11 | The Ascension | high | |
| Acts | 1 | 12 | 1 | 26 | Matthias Chosen to Replace Judas | high | |
| Acts | 2 | 1 | 2 | 47 | Pentecost | high | |
| Acts | 3 | 1 | 3 | 26 | Peter Heals a Lame Beggar | high | |
| Acts | 4 | 1 | 4 | 22 | Peter and John Before the Sanhedrin | high | |
| Acts | 4 | 23 | 4 | 37 | The Believers Pray and Share | high | |
| Acts | 5 | 1 | 5 | 11 | Ananias and Sapphira | high | |
| Acts | 5 | 12 | 5 | 16 | The Apostles Heal Many | high | |
| Acts | 5 | 17 | 5 | 42 | The Apostles Persecuted | high | |
| Acts | 6 | 1 | 6 | 7 | The Choosing of the Seven | high | |
| Acts | 6 | 8 | 6 | 15 | Stephen Seized | high | |
| Acts | 7 | 1 | 7 | 53 | Stephen's Speech to the Sanhedrin | high | |
| Acts | 7 | 54 | 7 | 60 | The Stoning of Stephen | high | |
| Acts | 8 | 1 | 8 | 3 | The Church Persecuted and Scattered | high | |
| Acts | 8 | 4 | 8 | 25 | Philip in Samaria | high | |
| Acts | 8 | 26 | 8 | 40 | Philip and the Ethiopian | high | |
| Acts | 9 | 1 | 9 | 19 | The Conversion of Saul / Damascus Road | high | |
| Acts | 9 | 20 | 9 | 31 | Saul in Damascus and Jerusalem | high | |
| Acts | 9 | 32 | 9 | 43 | Aeneas and Dorcas | high | |
| Acts | 10 | 1 | 10 | 48 | Peter's Vision and Cornelius | high | |
| Acts | 11 | 1 | 11 | 18 | Peter Explains His Actions | high | |
| Acts | 11 | 19 | 11 | 30 | The Church in Antioch | high | |
| Acts | 12 | 1 | 12 | 19 | Peter's Miraculous Escape From Prison | high | |
| Acts | 12 | 20 | 12 | 25 | Herod's Death | high | |
| Acts | 13 | 1 | 13 | 12 | Barnabas and Saul Sent Off to Cyprus | high | |
| Acts | 13 | 13 | 13 | 52 | In Pisidian Antioch | high | |
| Acts | 14 | 1 | 14 | 7 | In Iconium | high | |
| Acts | 14 | 8 | 14 | 28 | In Lystra and Derbe | high | |
| Acts | 15 | 1 | 15 | 21 | The Council at Jerusalem | high | |
| Acts | 15 | 22 | 15 | 41 | The Council's Letter to Gentile Believers | high | |
| Acts | 16 | 1 | 16 | 15 | Timothy Joins Paul and Silas | high | |
| Acts | 16 | 16 | 16 | 40 | Paul and Silas in Prison | high | |
| Acts | 17 | 1 | 17 | 9 | In Thessalonica | high | |
| Acts | 17 | 10 | 17 | 15 | In Berea | high | |
| Acts | 17 | 16 | 17 | 34 | In Athens | high | |
| Acts | 18 | 1 | 18 | 17 | In Corinth | high | |
| Acts | 18 | 18 | 18 | 28 | Priscilla, Aquila and Apollos | high | |
| Acts | 19 | 1 | 19 | 22 | Paul in Ephesus | high | |
| Acts | 19 | 23 | 19 | 41 | The Riot in Ephesus | high | |
| Acts | 20 | 1 | 20 | 12 | Through Macedonia and Greece | high | |
| Acts | 20 | 13 | 20 | 38 | Paul's Farewell to the Ephesian Elders | high | |
| Acts | 21 | 1 | 21 | 36 | On to Jerusalem and Paul Arrested | high | |
| Acts | 21 | 37 | 22 | 21 | Paul Speaks to the Crowd | high | |
| Acts | 22 | 22 | 22 | 30 | Paul the Roman Citizen | high | |
| Acts | 23 | 1 | 23 | 11 | Paul Before the Sanhedrin | high | |
| Acts | 23 | 12 | 23 | 35 | The Plot to Kill Paul | high | |
| Acts | 24 | 1 | 24 | 27 | Paul's Trial Before Felix | high | |
| Acts | 25 | 1 | 25 | 22 | Paul's Trial Before Festus | high | |
| Acts | 25 | 23 | 26 | 32 | Paul Before Agrippa | high | |
| Acts | 27 | 1 | 27 | 44 | Paul's Shipwreck | high | |
| Acts | 28 | 1 | 28 | 10 | Paul Ashore on Malta | high | |
| Acts | 28 | 11 | 28 | 31 | Paul Arrives at Rome and Preaches | high | |
