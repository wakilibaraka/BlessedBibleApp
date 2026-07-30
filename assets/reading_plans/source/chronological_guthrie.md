# Chronological Bible in a Year — Source Plan
# Framework: Dr. George H. Guthrie, "Read the Bible for Life"
# 52 weeks x 6 reading days = 312 readings. Day 7 each week is rest/catch-up (no reading, not numbered).
#
# FORMAT (read by tool/generate_reading_plan.dart):
#   - Each week is one block starting with "Week: N".
#   - "Theme:" is the week's Historical Focus; every day in the week inherits it as its title (for now).
#   - "D1:" ... "D6:" hold the raw scripture string exactly as Guthrie lists it.
#   - Within a day, multiple passage groups are separated by ";" (parser splits on ";").
#   - Book abbreviations are Guthrie's; the generator expands them to the app's full book names.
#   - Lines starting with "#" and blank lines are ignored.
#   - NOTE: Guthrie's original table split Week 40 across two half-rows (OT close D1-D3, NT open D4-D6).
#     They are merged here into a single Week 40 with all 6 days.

# ============================================================
# ACT I: Creation to the Kingdom (Weeks 1-13)
# ============================================================

Week: 1
Theme: Creation to Babel
D1: Gen 1-2
D2: John 1:1-3; Psa 8, 104
D3: Gen 3-5
D4: Gen 6-7
D5: Gen 8-9; Psa 12
D6: Gen 10-11

Week: 2
Theme: Patriarchs: Abraham & Isaac
D1: Gen 12-13
D2: Gen 14-16
D3: Gen 17-19
D4: Gen 20-23
D5: Gen 24-26
D6: Gen 27-29

Week: 3
Theme: Jacob & Joseph in Egypt
D1: Gen 30-33
D2: Gen 34-37
D3: Gen 38-40
D4: Gen 41-43
D5: Gen 44-46
D6: Gen 47-50

Week: 4
Theme: The Patriarchal Era (Job)
D1: Job 1-5
D2: Job 6-9
D3: Job 10-13
D4: Job 14-17
D5: Job 18-21
D6: Job 22-24

Week: 5
Theme: End of Job; Slavery in Egypt
D1: Job 25-28
D2: Job 29-32
D3: Job 33-36
D4: Job 37:1-40:5; Psa 19
D5: Job 40:6-42:17; Psa 29
D6: Exo 1-4

Week: 6
Theme: Plagues, Exodus, Law at Sinai
D1: Exo 5-9
D2: Exo 10-13
D3: Exo 14-18
D4: Exo 19-21
D5: Exo 22-24
D6: Exo 25-28

Week: 7
Theme: Tabernacle & Priesthood
D1: Exo 29-32
D2: Exo 33-36
D3: Exo 37-40
D4: Lev 1-4
D5: Lev 5-7
D6: Lev 8-10

Week: 8
Theme: Holiness Code & Census
D1: Lev 11-14
D2: Lev 15-18
D3: Lev 19-22
D4: Lev 23-25
D5: Lev 26-27
D6: Num 1-2

Week: 9
Theme: Wilderness Wanderings
D1: Num 3-5
D2: Num 6-9
D3: Num 10-13; Psa 90
D4: Num 14-16; Psa 95
D5: Num 17-20
D6: Num 21-24

Week: 10
Theme: Preparing for Canaan
D1: Num 25-28
D2: Num 29-32
D3: Num 33-36
D4: Deu 1-3
D5: Deu 4-7
D6: Deu 8-11

Week: 11
Theme: Moses' Final Sermons & Death
D1: Deu 12-15
D2: Deu 16-19
D3: Deu 20-23
D4: Deu 24-27
D5: Deu 28-30
D6: Deu 31-34

Week: 12
Theme: Conquest of Canaan
D1: Jos 1-2; Psa 105
D2: Jos 3-6
D3: Jos 7-10
D4: Jos 11-14
D5: Jos 15-18
D6: Jos 19-22

Week: 13
Theme: Period of the Judges
D1: Jos 23-24; Jdg 1
D2: Jdg 2-5
D3: Jdg 6-9
D4: Jdg 10-13
D5: Jdg 14-18
D6: Jdg 19-21

# ============================================================
# ACT II: The United & Divided Monarchy (Weeks 14-31)
# ============================================================

Week: 14
Theme: Ruth, Samuel, Saul's Rise
D1: Ruth 1-4
D2: 1 Sam 1-3
D3: 1 Sam 4-8
D4: 1 Sam 9-12
D5: 1 Sam 13-16
D6: 1 Sam 17-20

Week: 15
Theme: David's Wilderness Flight
D1: Psa 59, 91
D2: 1 Sam 21-24
D3: Psa 7, 27, 31, 34, 52
D4: Psa 56, 120, 140-142
D5: 1 Sam 25-27
D6: Psa 17, 73

Week: 16
Theme: Saul's Death & David's Reign
D1: Psa 35, 54, 63, 18
D2: 1 Sam 28-31; 1 Chr 10
D3: Psa 121, 123-125, 128-130
D4: 2 Sam 1-4
D5: Psa 6, 9, 10, 14, 16, 21
D6: 1 Chr 1-2; Psa 43-44

Week: 17
Theme: Davidic Genealogies & Worship
D1: Psa 49, 84, 85, 87
D2: 1 Chr 3-5
D3: 1 Chr 6; Psa 36, 39, 77-78
D4: Psa 81, 88, 92, 93
D5: 1 Chr 7-9
D6: Psa 133, 15, 23, 24-25

Week: 18
Theme: Ark to Jerusalem & Covenant
D1: 2 Sam 5:1-10; 1 Chr 11-12
D2: 2 Sam 5:11-6:23; 1 Chr 13-16
D3: Psa 89, 96, 100, 101, 107
D4: 2 Sam 7; 1 Chr 17; Psa 1-2, 33, 127, 132
D5: 2 Sam 8-9; 1 Chr 18
D6: 2 Sam 10; 1 Chr 19; Psa 20, 53, 60, 75

Week: 19
Theme: David's Fall, Repentance, Absalom
D1: Psa 65-67, 69, 70
D2: 2 Sam 11-12; 1 Chr 20; Psa 51
D3: Psa 32, 86, 102, 103, 122
D4: 2 Sam 13-15
D5: Psa 3, 4, 13, 28, 55
D6: 2 Sam 16-18

Week: 20
Theme: David's Rest and Temple Prep
D1: Psa 26, 40-41, 58, 61-62, 64
D2: 2 Sam 19-21; Psa 5, 38, 42
D3: 2 Sam 22-23; Psa 57
D4: Psa 97-99
D5: 2 Sam 24; 1 Chr 21-22; Psa 30
D6: Psa 108-109

Week: 21
Theme: Transition to Solomon
D1: 1 Chr 23-26
D2: Psa 131, 138-139, 143-145
D3: 1 Chr 27-29; Psa 68
D4: Psa 111-118
D5: 1 Ki 1-2; Psa 37, 71, 94
D6: Psa 119:1-88

Week: 22
Theme: Solomon's Wisdom & Songs
D1: 1 Ki 3-4; 2 Chr 1; Psa 72
D2: Psa 119:89-176
D3: Song 1:1-5:1
D4: Song 5:2-8:14; Psa 45
D5: Pro 1-4
D6: Pro 5-8

Week: 23
Theme: Proverbs & Temple Construction
D1: Pro 9-12
D2: Pro 13-16
D3: Pro 17-20
D4: Pro 21-24
D5: 2 Chr 2-3; 1 Ki 5-6
D6: 1 Ki 7-8; Psa 11

Week: 24
Theme: Temple Dedication & Ecclesiastes
D1: 2 Chr 4-7; Psa 134, 136
D2: Psa 146-150
D3: 1 Ki 9; 2 Chr 8; Pro 25-26
D4: Pro 27-29
D5: Ecc 1-6
D6: Ecc 7-12

Week: 25
Theme: Division of Kingdom & Elijah
D1: 1 Ki 10-11; 2 Chr 9; Pro 30-31
D2: 1 Ki 12; 2 Chr 10
D3: 1 Ki 13-14; 2 Chr 11-12
D4: 1 Ki 15:1-24; 2 Chr 13-16
D5: 1 Ki 15:25-16:34; 2 Chr 17
D6: 1 Ki 17-19

Week: 26
Theme: Elisha & Kings of Israel/Judah
D1: 1 Ki 20-21
D2: 1 Ki 22; 2 Chr 18-20
D3: 2 Ki 1-4
D4: 2 Ki 5:1-8:15
D5: 2 Ki 8:16-29; 2 Chr 21:1-22:9
D6: 2 Ki 9-11; 2 Chr 22:10-23:21

Week: 27
Theme: Early Prophets (Jonah, Amos, Hosea)
D1: 2 Ki 12-13; 2 Chr 24
D2: 2 Ki 14-15; 2 Chr 25-27
D3: Jon 1-4
D4: Amo 1-5
D5: Amo 6-9
D6: Hos 1-5

Week: 28
Theme: Hosea, Early Isaiah, Micah
D1: Hos 6-9
D2: Hos 10-14
D3: Isa 1-4
D4: Isa 5-8
D5: Isa 9-12
D6: Mic 1-4

Week: 29
Theme: Fall of Israel (Northern Kingdom)
D1: Mic 5-7
D2: 2 Ki 16-17; 2 Chr 28
D3: Isa 13-17
D4: Joel 1-3
D5: Isa 18-22
D6: Isa 23-26

Week: 30
Theme: Reign of Hezekiah & Isaiah
D1: 2 Ki 18:1-8; 2 Chr 29-31; Psa 48
D2: Isa 27-30
D3: Isa 31-35
D4: Isa 36-37; 2 Ki 18:9-19:37; 2 Chr 32:1-23; Psa 76
D5: Isa 38-39; 2 Ki 20; 2 Chr 32:24-33
D6: Isa 40-42; Psa 46

Week: 31
Theme: Isaiah's Comfort & Prophecies
D1: Isa 43-45; Psa 80
D2: Isa 46-49; Psa 135
D3: Isa 50-53
D4: Isa 54-58
D5: Isa 59-63
D6: Isa 64-66

# ============================================================
# ACT III: Exile & Return (Weeks 32-39)
# ============================================================

Week: 32
Theme: Josiah's Reform & Nahum/Zephaniah
D1: 2 Ki 21; 2 Chr 33
D2: Nah 1-3
D3: Zep 1-3
D4: 2 Ki 22-23; 2 Chr 34-35
D5: Jer 1-4
D6: Jer 5-8

Week: 33
Theme: Jeremiah Warns Judah
D1: Jer 9-12
D2: Jer 13-16
D3: Jer 17-20
D4: Jer 21-24
D5: Jer 25-28
D6: Jer 29-32

Week: 34
Theme: Fall of Jerusalem & Dispersion
D1: Jer 33-37
D2: Jer 38-40; Psa 74, 79
D3: 2 Ki 24-25; 2 Chr 36:1-21; Jer 52
D4: Jer 41-44
D5: Jer 45-48
D6: Jer 49-50

Week: 35
Theme: Lamentations & Ezekiel's Visions
D1: Jer 51; Psa 137
D2: Lam 1:1-3:36
D3: Lam 3:37-5:22
D4: Eze 1-4
D5: Eze 5-8
D6: Eze 9-12

Week: 36
Theme: Ezekiel in Babylon
D1: Eze 13-16
D2: Eze 17-20
D3: Eze 21-24
D4: Eze 25-28
D5: Eze 29-32
D6: Eze 33-36

Week: 37
Theme: Daniel in Babylon & Temple Vision
D1: Eze 37-40
D2: Eze 41-44
D3: Eze 45-48
D4: Dan 1-3
D5: Dan 4-6
D6: Dan 7-9

Week: 38
Theme: Cyrus' Decree & Return to Jerusalem
D1: Dan 10-12
D2: Oba; Psa 82, 83
D3: Ezr 1-3; 2 Chr 36:22-23
D4: Ezr 4-6; Hag 1-2
D5: Zec 1-7
D6: Zec 8-14

Week: 39
Theme: Esther, Ezra, Nehemiah
D1: Est 1-5
D2: Est 6-10
D3: Mal 1-4; Psa 50
D4: Ezr 7-10
D5: Neh 1-4
D6: Neh 5-7

# ============================================================
# ACT IV: The Life of Christ & Early Church (Weeks 40-52)
# NOTE: Week 40 merges Guthrie's split row (OT close D1-D3, NT open D4-D6).
# ============================================================

Week: 40
Theme: End of OT Era; Birth & Preparation of Christ
D1: Neh 8-10
D2: Neh 11-13; Psa 126
D3: Psa 106; Joh 1:4-14
D4: Mat 1; Luk 1:1-2:38
D5: Mat 2; Luk 2:39-52
D6: Mat 3; Mar 1:1-11; Luk 3; Joh 1:15-34

Week: 41
Theme: Early Galilean Ministry & Sermon on Mount
D1: Mat 4:1-22; Mar 1:12-20; Luk 4:1-30, 5:1-11; Joh 1:35-2:12
D2: Mat 4:23-25, 8:14-17; Mar 1:21-39; Luk 4:31-44
D3: Joh 3-5
D4: Mat 8:1-4, 9:1-17, 12:1-21; Mar 1:40-3:21; Luk 5:12-6:19
D5: Mat 5-7; Luk 6:20-49, 11:1-13
D6: Mat 8:5-13, 11:1-30; Luk 7

Week: 42
Theme: Miracles, Parables, Feeding 5000
D1: Mat 12:22-50; Mar 3:22-35; Luk 8:19-21, 11:14-54
D2: Mat 13:1-53; Mar 4:1-34; Luk 8:1-18
D3: Mat 8:18-34, 9:18-38; Mar 4:35-5:43; Luk 8:22-56, 9:57-62
D4: Mat 10, 14; Mar 6:7-56; Luk 9:1-17; Joh 6
D5: Mat 15; Mar 7:1-8:10
D6: Mat 16; Mar 8:11-9:1; Luk 9:18-27

Week: 43
Theme: Transfiguration & Judean Ministry
D1: Mat 17-18; Mar 9:2-50; Luk 9:28-56
D2: Joh 7-9
D3: Luk 10; Joh 10:1-11:54
D4: Luk 12:1-13:30
D5: Luk 14-15
D6: Mat 19; Mar 10:1-31; Luk 16:1-18:30

Week: 44
Theme: Triumphal Entry & Passion Week
D1: Mat 20; Mar 10:32-52; Luk 18:31-19:27
D2: Mat 26:6-13; Mar 14:3-9; Joh 11:55-12:36; Mat 21:1-22; Mar 11:1-26; Luk 19:28-48; Joh 2:13-25
D3: Mat 21:23-22:14; Mar 11:27-12:12; Luk 20:1-19; Joh 12:37-50
D4: Mat 22:15-23:39; Mar 12:13-44; Luk 20:20-21:4, 13:31-35
D5: Mat 24-25; Mar 13; Luk 21:5-38
D6: Mat 26:1-5, 14-35; Mar 14:1-2, 10-31; Luk 22:1-38; Joh 13

Week: 45
Theme: Upper Room, Trial, Cross, & Resurrection
D1: Joh 14-17
D2: Mat 26:36-75; Mar 14:32-72; Luk 22:39-71; Joh 18:1-27
D3: Mat 27:1-31; Mar 15:1-20; Luk 23:1-25; Joh 18:28-19:16
D4: Mat 27:32-66; Mar 15:21-47; Luk 23:26-56; Joh 19:17-42; Psa 22
D5: Mat 28; Mar 16; Luk 24; Joh 20-21
D6: Acts 1-4; Psa 110

Week: 46
Theme: Early Church & First Epistles
D1: Acts 5-8
D2: Acts 9-11
D3: Acts 12-14
D4: Jam 1-5
D5: Gal 1-3
D6: Gal 4-6

Week: 47
Theme: Paul's 2nd & 3rd Journeys
D1: Acts 15-16
D2: Acts 17:1-18:18
D3: 1 Th 1-5
D4: 2 Th 1-3
D5: Acts 18:19-19:41
D6: 1 Cor 1-4

Week: 48
Theme: Corinthian Correspondence
D1: 1 Cor 5-8
D2: 1 Cor 9-11
D3: 1 Cor 12-14
D4: 1 Cor 15-16
D5: 2 Cor 1-4
D6: 2 Cor 5-9

Week: 49
Theme: Romans & Arrest in Jerusalem
D1: 2 Cor 10-13
D2: Rom 1-4; Acts 20:1-3
D3: Rom 5-8
D4: Rom 9-12
D5: Rom 13-16
D6: Acts 20:4-23:35

Week: 50
Theme: Prison Epistles (Rome)
D1: Acts 24-26
D2: Acts 27-28
D3: Phi 1-4
D4: Phm; Col 1-4
D5: Eph 1-4
D6: Eph 5-6; Tit 1-3

Week: 51
Theme: Pastoral Epistles & Hebrews
D1: 1 Tim 1-6
D2: 1 Pe 1-5
D3: Heb 1-4
D4: Heb 5-8
D5: Heb 9-13
D6: 2 Tim 1-4

Week: 52
Theme: Johannine Letters & Revelation
D1: Jude; 2 Pe 1-3
D2: 1 Joh 1-5; 2 Joh; 3 Joh
D3: Rev 1-5
D4: Rev 6-10
D5: Rev 11-13
D6: Rev 14-18; Rev 19-22
