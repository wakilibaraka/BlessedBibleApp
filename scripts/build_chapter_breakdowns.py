import json
import datetime

breakdowns = {
    1: {
        "title": "The Ascension and the Waiting Church",
        "themes": "Promise of the Spirit, Ascension of Christ, Apostolic Succession",
        "outline": "1. Prologue and Promise (1:1-5)\n2. The Ascension (1:6-11)\n3. Waiting in the Upper Room (1:12-14)\n4. Choosing Matthias (1:15-26)",
        "summary": "Acts begins where Luke's gospel ends. Jesus spends 40 days offering infallible proofs of His resurrection and instructing the apostles about the kingdom of God. He commands them not to leave Jerusalem but to wait for the baptism of the Holy Spirit. After Jesus ascends to heaven in a cloud, two angels promise His return in the same manner. The disciples return to the Upper Room for united prayer. Peter leads the 120 believers to select Matthias by lot to replace Judas Iscariot, restoring the foundation of the twelve apostles before the Spirit's outpouring."
    },
    2: {
        "title": "The Day of Pentecost",
        "themes": "Outpouring of the Holy Spirit, First Gospel Sermon, Birth of the Church",
        "outline": "1. The Coming of the Holy Spirit (2:1-4)\n2. The Multitude's Reaction (2:5-13)\n3. Peter's Sermon (2:14-36)\n4. The Response and First Converts (2:37-41)\n5. The Fellowship of the Believers (2:42-47)",
        "summary": "On the Jewish feast of Pentecost, the Holy Spirit falls upon the disciples with the sound of a rushing wind and tongues of fire. They speak in unlearned foreign languages, astonishing the international Jewish pilgrims. Peter stands up and delivers the first great sermon of the church age, proving from Joel and Psalms that Jesus is the prophesied Messiah who poured out this Spirit. Cut to the heart, 3,000 people repent and are baptized. The new community devotes itself to the apostles' teaching, prayer, miraculous signs, and radical generosity, experiencing explosive growth."
    },
    3: {
        "title": "Healing at the Beautiful Gate",
        "themes": "Apostolic Miracles, Power of Jesus' Name, Call to Repentance",
        "outline": "1. Healing of the Lame Man (3:1-11)\n2. Peter's Sermon in Solomon's Portico (3:12-26)",
        "summary": "Peter and John go to the temple for afternoon prayer and encounter a man crippled from birth begging at the Beautiful Gate. Having no money, Peter heals him in the name of Jesus Christ of Nazareth. The man's leaping and praising draws a massive crowd to Solomon's Portico. Peter seizes the moment to preach his second sermon, clarifying that the healing power came from the resurrected Jesus, whom they had crucified. He urges them to repent and turn to God so their sins may be wiped out and times of refreshing may come."
    },
    4: {
        "title": "First Persecution and the Unified Church",
        "themes": "Opposition, Boldness in Prayer, Radical Generosity",
        "outline": "1. Arrest and Trial of Peter and John (4:1-12)\n2. The Sanhedrin's Threat (4:13-22)\n3. The Believers Pray for Boldness (4:23-31)\n4. Sharing of Possessions (4:32-37)",
        "summary": "The Sadducees, angered by the preaching of resurrection, arrest Peter and John. Before the Sanhedrin, Peter boldly declares that salvation is found only in the name of Jesus. Recognizing them as uneducated men who had 'been with Jesus,' the council severely threatens them but releases them due to the undeniable miracle. The apostles return to the church, and rather than praying for safety, they pray for boldness to preach. The place shakes, they are filled afresh with the Spirit, and the church continues in absolute unity and selfless sharing of property, exemplified by Barnabas."
    },
    5: {
        "title": "Purity and Power Amidst Persecution",
        "themes": "Church Discipline, Miraculous Deliverance, Unstoppable Witness",
        "outline": "1. Ananias and Sapphira (5:1-11)\n2. Apostolic Miracles (5:12-16)\n3. Second Arrest and Angelic Deliverance (5:17-25)\n4. Trial Before the Sanhedrin and Gamaliel's Advice (5:26-42)",
        "summary": "The church's internal purity is tested when Ananias and Sapphira lie to the Holy Spirit about a financial gift; both fall dead, bringing great fear upon the church. Externally, the apostles' healing ministry grows so powerful that people bring the sick into the streets for Peter's shadow to fall on them. The jealous high priest imprisons the twelve, but an angel frees them overnight, commanding them to preach in the temple. Arrested again, they declare, 'We must obey God rather than men.' The Pharisee Gamaliel advises caution, and after being beaten, the apostles rejoice in suffering for Christ's name."
    },
    6: {
        "title": "Choosing the Seven and Stephen's Ministry",
        "themes": "Church Administration, Delegation, Rise of Stephen",
        "outline": "1. The Daily Distribution Dispute (6:1-7)\n2. Stephen's Ministry and Arrest (6:8-15)",
        "summary": "As the church multiplies, Hellenistic (Greek-speaking) Jews complain that their widows are neglected in the daily food distribution. The apostles, unwilling to neglect prayer and the word, instruct the church to select seven men full of the Spirit and wisdom to manage this duty. This early form of diaconal ministry solves the dispute and leads to further growth, even among the priests. Stephen, one of the seven, performs great wonders and debates brilliantly with Hellenistic synagogue members. Unable to defeat his wisdom, they use false witnesses to arrest him and bring him before the Sanhedrin."
    },
    7: {
        "title": "Stephen's Defense and Martyrdom",
        "themes": "Israel's History of Rejection, The First Martyr, Saul's Introduction",
        "outline": "1. Stephen's Speech: The Patriarchs (7:1-16)\n2. Stephen's Speech: Moses and the Law (7:17-43)\n3. Stephen's Speech: The Tabernacle and Temple (7:44-50)\n4. Stephen's Indictment of the Council (7:51-53)\n5. The Stoning of Stephen (7:54-60)",
        "summary": "Instead of defending himself, Stephen preaches a masterful summary of Israelite history, demonstrating that God's presence was never confined to a temple and that Israel has a consistent pattern of rejecting God's chosen deliverers (like Joseph and Moses). He climaxes by accusing the Sanhedrin of being 'stiff-necked' resisters of the Holy Spirit who murdered the Righteous One. Enraged, the council drags him out of the city and stones him. Stephen dies with a vision of Jesus standing at God's right hand, praying for his executioners' forgiveness. A young man named Saul guards the garments of those stoning him."
    },
    8: {
        "title": "The Gospel Reaches Samaria and Africa",
        "themes": "Scattering of the Church, Overcoming Prejudice, Individual Evangelism",
        "outline": "1. Saul's Persecution and the Church's Dispersion (8:1-3)\n2. Philip in Samaria (8:4-13)\n3. Peter and John in Samaria (8:14-25)\n4. Philip and the Ethiopian Eunuch (8:26-40)",
        "summary": "Severe persecution led by Saul scatters the Jerusalem church, but this fulfills Acts 1:8 as believers preach wherever they go. Philip goes to Samaria, a region despised by Jews, and brings great joy through the gospel and healings. Simon the Sorcerer believes, but later tries to buy the power to impart the Holy Spirit from Peter and John, resulting in a severe rebuke. An angel then directs Philip to a desert road to intercept an Ethiopian court official reading Isaiah 53. Philip explains the gospel, baptizes the eunuch, and is miraculously transported to Azotus."
    },
    9: {
        "title": "The Conversion of Saul",
        "themes": "Radical Grace, Transformation, Apostolic Preparation",
        "outline": "1. Saul's Encounter on the Damascus Road (9:1-9)\n2. Ananias and Saul's Baptism (9:10-19)\n3. Saul Preaches in Damascus and Escapes (9:20-25)\n4. Saul in Jerusalem (9:26-31)\n5. Peter Heals Aeneas and Raises Dorcas (9:32-43)",
        "summary": "Breathing threats against the church, Saul travels to Damascus but is blinded by a heavenly light and confronted by the risen Jesus. In Damascus, the reluctant disciple Ananias is sent to restore Saul's sight and baptize him. Saul immediately begins preaching that Jesus is the Son of God, baffling the Jews. He later escapes an assassination plot by being lowered in a basket through the city wall. In Jerusalem, Barnabas vouches for the newly converted Saul to the terrified apostles. Meanwhile, Peter ministers in the coastal towns, healing paralyzed Aeneas in Lydda and raising the beloved Dorcas from the dead in Joppa."
    },
    10: {
        "title": "The Gentile Pentecost",
        "themes": "Breaking Ethnic Barriers, God Shows No Partiality",
        "outline": "1. Cornelius's Vision (10:1-8)\n2. Peter's Vision of the Unclean Animals (10:9-23)\n3. Peter Meets Cornelius (10:24-33)\n4. Peter's Sermon to the Gentiles (10:34-43)\n5. The Holy Spirit Falls on the Gentiles (10:44-48)",
        "summary": "A major turning point in church history occurs when Cornelius, a devout Roman centurion in Caesarea, receives an angelic vision to send for Peter. Simultaneously in Joppa, Peter receives a vision of unclean animals and a heavenly voice commanding, 'What God has cleansed, no longer consider unholy.' Understanding this refers to people, Peter visits the Gentile's home. As Peter preaches the gospel, the Holy Spirit falls upon the Gentiles exactly as He did on the Jews at Pentecost. Recognizing God's clear acceptance, Peter orders them to be baptized, shattering the Jewish-Gentile barrier."
    },
    11: {
        "title": "Vindication and the Antioch Church",
        "themes": "Defending Gentile Inclusion, Rise of Antioch, Christian Identity",
        "outline": "1. Peter Defends His Actions in Jerusalem (11:1-18)\n2. The Church at Antioch (11:19-26)\n3. Agabus's Prophecy and Antioch's Relief Gift (11:27-30)",
        "summary": "Jewish believers in Jerusalem heavily criticize Peter for eating with uncircumcised Gentiles. Peter recounts the visions and the undeniable outpouring of the Spirit. The church marvels and glorifies God that He has granted repentance leading to life to the Gentiles. Meanwhile, scattered believers reach Antioch and begin preaching to Greeks. A large number believe, prompting Jerusalem to send Barnabas. Barnabas rejoices, recruits Saul from Tarsus to help teach, and in Antioch the disciples are first called 'Christians.' The chapter ends with the Antioch church demonstrating its love by sending famine relief to Judea."
    },
    12: {
        "title": "Martyrdom, Deliverance, and Divine Judgment",
        "themes": "Political Oppression, Power of Intercessory Prayer, Sovereignty of God",
        "outline": "1. James Killed and Peter Arrested (12:1-4)\n2. Peter's Miraculous Rescue (12:5-19)\n3. The Death of Herod Agrippa I (12:20-23)\n4. The Word of God Continues to Grow (12:24-25)",
        "summary": "King Herod Agrippa I launches a violent persecution, executing the apostle James (John's brother) and imprisoning Peter to please the Jewish leaders. While the church prays fervently, an angel awakens Peter, whose chains fall off, and leads him past guards and through an iron gate. Peter goes to the house of Mary (Mark's mother) where the praying believers are so shocked they initially think it's his angel. Herod executes the guards and travels to Caesarea, where he accepts the crowd's worship as a god. He is immediately struck down by an angel and eaten by worms, while the word of God multiplies."
    },
    13: {
        "title": "The First Missionary Journey Begins",
        "themes": "Holy Spirit's Guidance, Confronting Spiritual Blindness, Turning to the Gentiles",
        "outline": "1. Barnabas and Saul Sent Off from Antioch (13:1-3)\n2. Ministry in Cyprus and Elymas the Sorcerer (13:4-12)\n3. Arrival in Pisidian Antioch (13:13-15)\n4. Paul's Sermon in the Synagogue (13:16-41)\n5. Rejection by Jews and Turning to Gentiles (13:42-52)",
        "summary": "The church at Antioch becomes the launching pad for world missions when the Holy Spirit instructs them to set apart Barnabas and Saul. They sail to Cyprus, where Paul (formerly Saul) strikes Elymas the sorcerer blind, leading the proconsul to faith. John Mark abandons them as they travel to Antioch in Pisidia. Paul preaches a masterful sermon linking Israel's history to Jesus' death and resurrection. The following Sabbath, massive crowds gather, provoking jealousy from the Jewish leaders. Paul and Barnabas boldly declare they are turning to the Gentiles, bringing immense joy to the non-Jews."
    },
    14: {
        "title": "Triumph and Tribulation in Galatia",
        "themes": "Mistaken Identity, Suffering for the Gospel, Establishing Churches",
        "outline": "1. Success and Opposition in Iconium (14:1-7)\n2. Healing in Lystra and Mistaken for Gods (14:8-18)\n3. Paul Stoned and Left for Dead (14:19-20)\n4. Strengthening the Disciples and Return to Antioch (14:21-28)",
        "summary": "In Iconium, Paul and Barnabas face a divided city and flee a stoning plot. In Lystra, Paul heals a man crippled from birth. The pagan crowd mistakes Barnabas for Zeus and Paul for Hermes, attempting to offer sacrifices to them. The apostles frantically stop them, preaching about the living Creator God. Shortly after, antagonistic Jews arrive from Antioch and Iconium, persuading the crowds to stone Paul. Dragged out of the city and left for dead, Paul miraculously rises and continues his journey. They bravely retrace their steps, appointing elders in every new church before returning to Syrian Antioch."
    },
    15: {
        "title": "The Jerusalem Council",
        "themes": "Theological Conflict, Salvation by Grace, Church Unity",
        "outline": "1. The Dispute over Circumcision (15:1-5)\n2. The Council Convenes: Peter's Defense (15:6-11)\n3. Barnabas, Paul, and James Speak (15:12-21)\n4. The Council's Letter to Gentile Believers (15:22-35)\n5. The Division of Paul and Barnabas (15:36-41)",
        "summary": "A theological crisis erupts when men from Judea teach that Gentiles must be circumcised to be saved. Paul and Barnabas travel to Jerusalem to settle the issue with the apostles and elders. Peter powerfully argues that God gave the Spirit to Gentiles and that salvation is by grace alone for all. James, quoting the prophets, issues a unifying decree: Gentiles do not need to keep the law of Moses, but should abstain from idolatry, sexual immorality, and blood to maintain fellowship with Jewish believers. Later, Paul and Barnabas sharply disagree over taking John Mark on the next journey and part ways."
    },
    16: {
        "title": "The Gospel Enters Europe",
        "themes": "Divine Direction, Women in the Church, Songs in the Night",
        "outline": "1. Timothy Joins Paul (16:1-5)\n2. The Macedonian Call (16:6-10)\n3. Conversion of Lydia in Philippi (16:11-15)\n4. The Slave Girl and Imprisonment (16:16-24)\n5. The Philippian Jailer (16:25-40)",
        "summary": "Paul recruits Timothy in Lystra. The Holy Spirit redirects their journey away from Asia, giving Paul a vision of a Macedonian man begging for help. Crossing into Europe, they preach in Philippi where Lydia, a wealthy businesswoman, is converted. Paul casts a demon out of a fortune-telling slave girl, angering her owners who have Paul and Silas beaten and imprisoned. At midnight, while they sing hymns, an earthquake opens the prison. The suicidal jailer asks, 'What must I do to be saved?' He and his household believe and are baptized, and the magistrates are forced to release the apostles."
    },
    17: {
        "title": "Turning the World Upside Down",
        "themes": "Reasoning from Scripture, Engaging Pagan Culture",
        "outline": "1. Riot in Thessalonica (17:1-9)\n2. The Noble Bereans (17:10-15)\n3. Paul in Athens (17:16-21)\n4. The Sermon on Mars Hill (Areopagus) (17:22-34)",
        "summary": "In Thessalonica, Paul reasons in the synagogue for three weeks, winning many converts but triggering a mob that accuses the Christians of defying Caesar. Escaping to Berea, Paul finds a noble Jewish community that eagerly examines the Scriptures daily to verify his message. Pursued by Thessalonian agitators, Paul flees to Athens. Distressed by the city's idols, he engages philosophers at the Areopagus. He masterfully uses their altar 'To an Unknown God' and their own poets to introduce the Creator God, culminating in the call to repent before the resurrected Judge. A few believe, including Dionysius."
    },
    18: {
        "title": "Corinthian Ministry and the Third Journey",
        "themes": "Endurance in Ministry, Tentmaking, Accurate Teaching",
        "outline": "1. Paul in Corinth with Aquila and Priscilla (18:1-11)\n2. Before the Judgment Seat of Gallio (18:12-17)\n3. Return to Antioch and Start of Third Journey (18:18-23)\n4. Apollos in Ephesus (18:24-28)",
        "summary": "Paul arrives in Corinth and works as a tentmaker with Aquila and Priscilla. Facing fierce Jewish opposition, he turns to the Gentiles and is encouraged by a vision from the Lord promising protection. He stays 18 months. When the Jews bring Paul before the Roman proconsul Gallio, Gallio dismisses the case as an internal religious dispute, establishing legal protection for the young church. Paul returns to Antioch, completing his second journey. As he begins his third journey in Galatia, an eloquent preacher named Apollos arrives in Ephesus and is gently instructed in the full truth by Aquila and Priscilla."
    },
    19: {
        "title": "The Ephesian Revival and Riot",
        "themes": "Power Encounters, Spiritual Warfare, Economic Impact of the Gospel",
        "outline": "1. Disciples of John Baptized (19:1-7)\n2. Teaching in the Hall of Tyrannus (19:8-10)\n3. Miracles and the Sons of Sceva (19:11-20)\n4. The Riot of the Silversmiths (19:21-41)",
        "summary": "Returning to Ephesus, Paul finds twelve disciples of John the Baptist, baptizes them in Jesus' name, and they receive the Holy Spirit. He teaches daily in the hall of Tyrannus for two years, spreading the word throughout all Asia. Extraordinary miracles occur, and when the Jewish exorcists (sons of Sceva) misuse Jesus' name, a demon beats them severely. This creates massive reverence for Christ, prompting new believers to publicly burn their expensive magic books. The gospel's success threatens the idol-making business of Demetrius, who incites a massive riot in the theater, eventually quelled by the city clerk."
    },
    20: {
        "title": "Farewell to Ephesus",
        "themes": "Eutychus, Pastoral Leadership, Guarding the Flock",
        "outline": "1. Journey through Macedonia and Greece (20:1-6)\n2. Eutychus Raised from the Dead at Troas (20:7-12)\n3. Paul's Farewell Address to the Ephesian Elders (20:13-38)",
        "summary": "After the riot, Paul travels through Macedonia and Greece to encourage the churches. In Troas, during a long late-night sermon, a young man named Eutychus falls from a third-story window and dies, but Paul miraculously restores him to life. Journeying toward Jerusalem, Paul bypasses Ephesus to save time but summons the Ephesian elders to Miletus. He delivers a deeply emotional and instructive farewell address, recounting his faithful, tearful ministry. He warns them of 'savage wolves' that will arise to distort the truth, commends them to God's grace, and shares a tearful parting, knowing they will not see his face again."
    },
    21: {
        "title": "Arrest in Jerusalem",
        "themes": "Prophetic Warnings, Misunderstanding, Mob Violence",
        "outline": "1. Journey to Jerusalem and Agabus's Warning (21:1-16)\n2. Paul Meets James and the Elders (21:17-26)\n3. Riot in the Temple (21:27-30)\n4. Arrest by the Roman Commander (21:31-40)",
        "summary": "En route to Jerusalem, believers in Tyre and the prophet Agabus in Caesarea warn Paul through the Spirit of impending imprisonment, but Paul insists he is ready to die for Jesus. In Jerusalem, James advises Paul to participate in a Jewish purification vow to dispel rumors that he teaches Jews to forsake the Law of Moses. However, Asian Jews spot Paul in the temple, falsely accuse him of bringing a Gentile into the inner courts, and incite a murderous riot. Roman soldiers rescue Paul from the mob, and as he is carried up the fortress stairs, he asks permission to address the crowd."
    },
    22: {
        "title": "Paul's Defense to the Jewish Mob",
        "themes": "Personal Testimony, The Offense of the Gentiles, Roman Citizenship",
        "outline": "1. Paul's Address: His Jewish Zeal (22:1-5)\n2. Paul's Address: His Conversion (22:6-16)\n3. Paul's Address: His Commission to the Gentiles (22:17-21)\n4. The Crowd's Reaction and Paul's Citizenship (22:22-30)",
        "summary": "Speaking in Aramaic, Paul captivates the hostile crowd with his impeccable Jewish credentials and intense former zeal as a persecutor. He recounts his life-changing encounter with the risen Jesus on the road to Damascus and his subsequent healing by Ananias. The crowd listens intently until Paul mentions his divine commission to preach to the Gentiles. The mob erupts, demanding his death. The Roman commander orders Paul to be flogged to extract the truth, but halts immediately when Paul reveals he is a Roman citizen by birth. The commander then unbinds him and convenes the Sanhedrin to understand the charges."
    },
    23: {
        "title": "The Sanhedrin and the Assassination Plot",
        "themes": "Divine Encouragement, Theological Division, Providential Protection",
        "outline": "1. Paul Before the Sanhedrin (23:1-10)\n2. The Lord Encourages Paul (23:11)\n3. The Plot to Kill Paul (23:12-22)\n4. Paul Transferred to Caesarea (23:23-35)",
        "summary": "Standing before the Sanhedrin, Paul cleverly exploits the theological divide between the Pharisees (who believe in resurrection) and the Sadducees (who do not) by claiming he is on trial for the hope of the resurrection. A violent argument ensues, and the Romans extract him. That night, Jesus stands by Paul, promising he will testify in Rome. The next day, forty Jews take an oath not to eat or drink until they kill Paul. Paul's nephew discovers the ambush plot and informs the Roman commander, who heavily guards Paul and secretly transfers him by night to Governor Felix in Caesarea."
    },
    24: {
        "title": "Trial Before Felix",
        "themes": "Legal Defense, Procrastination, Judgment to Come",
        "outline": "1. Tertullus Accuses Paul (24:1-9)\n2. Paul's Defense (24:10-21)\n3. Felix Procrastinates (24:22-27)",
        "summary": "The high priest Ananias and a lawyer named Tertullus travel to Caesarea to formally accuse Paul before Governor Felix, framing him as a plague and a leader of the Nazarene sect. Paul skillfully defends himself, pointing out the lack of evidence and asserting that he merely follows the 'Way' according to the Law and the Prophets, believing in the resurrection. Felix, well acquainted with Christianity, delays the verdict. He frequently speaks with Paul, hoping for a bribe. When Paul preaches on righteousness, self-control, and coming judgment, Felix becomes terrified and sends him away. Paul remains imprisoned for two years until Festus succeeds Felix."
    },
    25: {
        "title": "Trial Before Festus and Appeal to Caesar",
        "themes": "Political Expediency, Roman Justice, Appeal to the Highest Court",
        "outline": "1. The Jews Petition Festus (25:1-5)\n2. Paul's Trial and Appeal to Caesar (25:6-12)\n3. Festus Consults King Agrippa (25:13-22)\n4. Paul Brought Before Agrippa (25:23-27)",
        "summary": "The new governor, Festus, travels to Jerusalem where Jewish leaders renew their efforts to have Paul transferred (intending to ambush him). Festus refuses and holds trial in Caesarea. Realizing Festus might hand him over to the Jews as a political favor, Paul exercises his right as a Roman citizen and appeals to Caesar. Festus agrees: 'To Caesar you shall go!' Later, King Herod Agrippa II and Bernice visit Festus. Festus presents Paul's perplexing case to Agrippa, needing to draft a formal charge for the Emperor. Agrippa asks to hear Paul, setting the stage for Paul's greatest defense."
    },
    26: {
        "title": "Paul's Defense Before Agrippa",
        "themes": "Vindication, The Heavenly Vision, Evangelistic Zeal",
        "outline": "1. Paul's Introduction and Jewish Upbringing (26:1-11)\n2. The Damascus Road Encounter (26:12-18)\n3. Paul's Obedience and Summary of the Gospel (26:19-23)\n4. The Reactions of Festus and Agrippa (26:24-32)",
        "summary": "Before the pomp and pageantry of Agrippa's court, Paul delivers his most polished defense. He outlines his strict Pharisaic background and aggressive persecution of Christians. He vividly describes the blinding light on the Damascus road and Jesus' commission to open the eyes of Jews and Gentiles to receive forgiveness. Paul asserts he was not disobedient to the heavenly vision and is only teaching what Moses and the Prophets predicted. Festus interrupts, calling Paul insane, but Paul respectfully appeals to Agrippa's belief in the prophets. Agrippa quips that Paul almost persuades him to become a Christian. They conclude Paul is innocent but must be sent to Rome due to his appeal."
    },
    27: {
        "title": "The Storm and the Shipwreck",
        "themes": "Faith in Crisis, Divine Preservation, Human Despair",
        "outline": "1. Setting Sail for Rome (27:1-8)\n2. Paul's Ignored Warning (27:9-12)\n3. The Euroclydon Storm (27:13-20)\n4. Paul's Reassurance (27:21-26)\n5. The Shipwreck at Malta (27:27-44)",
        "summary": "Handed over to a centurion named Julius, Paul sets sail for Rome. Despite Paul's prophetic warning of disaster, the crew pushes forward late in the season and is caught in a violent hurricane-force wind called the Euroclydon. For two weeks, the ship is battered and all hope is lost. Paul steps forward, recounting an angelic visitation promising that everyone's life will be spared, though the ship will be lost. He encourages the starving crew to eat. The ship finally strikes a reef near the island of Malta and breaks apart. Soldiers plan to kill the prisoners, but Julius spares them to protect Paul. Miraculously, all 276 people make it safely to land."
    },
    28: {
        "title": "Malta to Rome: The Unhindered Gospel",
        "themes": "Hospitality, Miracles, Final Rejection by Jews, Gospel to Gentiles",
        "outline": "1. Miracles on Malta (28:1-10)\n2. Arrival in Rome (28:11-16)\n3. Paul Meets with Roman Jews (28:17-29)\n4. Paul Preaches Unhindered in Rome (28:30-31)",
        "summary": "Stranded on Malta, the locals show unusual kindness. When a venomous viper bites Paul while gathering firewood, the natives expect him to die, but he shakes it into the fire unharmed. Paul subsequently heals the father of Publius (the island's chief official) and many others. After three months, they sail to Rome, where local believers travel out to meet Paul, greatly encouraging him. Placed under house arrest, Paul calls for the Jewish leaders. Some believe, but many reject his message. Quoting Isaiah, Paul declares the gospel is now sent to the Gentiles. The book ends triumphantly with Paul spending two years preaching the kingdom of God and teaching about Jesus Christ with all boldness and without hindrance."
    }
}

entries = []
for ch, data in breakdowns.items():
    text = f"**{data['title']}**\n\n**Themes:** {data['themes']}\n\n**Outline:**\n{data['outline']}\n\n**Summary:**\n{data['summary']}"
    entry = {
        "author": "The Blessed Bible Study Guide",
        "source": "Chapter Breakdown",
        "scope": {
            "type": "chapter",
            "book": "Acts",
            "chapter": ch,
            "verse": None,
            "topic": None,
            "custom": None
        },
        "text": text,
        "id": f"c_breakdown_acts_{ch}"
    }
    entries.append(entry)

with open('assets/commentary/commentary.json', 'r') as f:
    commentary_db = json.load(f)

# Remove any existing breakdowns to avoid duplicates if re-run
commentary_db['entries'] = [e for e in commentary_db['entries'] if e['source'] != 'Chapter Breakdown']
commentary_db['entries'].extend(entries)
commentary_db['count'] = len(commentary_db['entries'])
commentary_db['exportedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat().replace('+00:00', 'Z')

with open('assets/commentary/commentary.json', 'w') as f:
    json.dump(commentary_db, f, indent=2, ensure_ascii=False)

print(f"Added {len(entries)} chapter breakdowns for Acts.")
