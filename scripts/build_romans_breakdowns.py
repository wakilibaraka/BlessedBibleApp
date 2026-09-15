import json
import datetime

breakdowns = {
    1: {
        "title": "The Power of the Gospel and the Guilt of Mankind",
        "themes": "The Power of the Gospel, Righteousness of God, Universal Depravity",
        "outline": "1. Greeting and Introduction (1:1-7)\n2. Paul's Desire to Visit Rome (1:8-15)\n3. The Theme: The Righteousness of God (1:16-17)\n4. God's Wrath Against Gentile Sin (1:18-32)",
        "summary": "Paul introduces himself and declares the theme of his letter: the gospel is the power of God for salvation to everyone who believes, revealing a righteousness from God. He then demonstrates the universal need for this gospel by exposing the deep depravity of humanity. Although God's invisible qualities are clearly seen in creation, people suppressed the truth, exchanging the glory of God for idols. Consequently, God gave them over to the shameful lusts of their hearts and a depraved mind."
    },
    2: {
        "title": "The Righteous Judgment of God",
        "themes": "Hypocrisy, God's Impartiality, Inward Circumcision",
        "outline": "1. God's Righteous Judgment (2:1-16)\n2. The Jews and the Law (2:17-24)\n3. True Circumcision is of the Heart (2:25-29)",
        "summary": "Paul turns his attention to the moralists, particularly Jewish believers, who judge the Gentiles while committing the same sins. He emphasizes that God's judgment is impartial and based on truth; hearing the law is not enough—one must obey it. He powerfully concludes that a true Jew is one inwardly, whose heart is circumcised by the Spirit, not merely by the written code."
    },
    3: {
        "title": "Justification by Faith",
        "themes": "Universal Guilt, Justification, Faith vs. Works",
        "outline": "1. The Advantage of the Jews (3:1-8)\n2. No One is Righteous (3:9-20)\n3. Righteousness Through Faith (3:21-31)",
        "summary": "After acknowledging the historical advantage of the Jews in receiving the oracles of God, Paul concludes that Jews and Gentiles alike are under the power of sin. Quoting the Psalms, he declares, 'There is no one righteous, not even one.' Since the law can only make us conscious of sin, God has provided a different way: righteousness is given through faith in Jesus Christ to all who believe. We are justified freely by His grace through the redemption that came by Christ Jesus."
    },
    4: {
        "title": "Abraham Justified by Faith",
        "themes": "Abraham's Faith, The Promise, Credited as Righteousness",
        "outline": "1. Abraham Justified by Faith, Not Works (4:1-8)\n2. Faith Precedes Circumcision (4:9-12)\n3. The Promise Realized Through Faith (4:13-25)",
        "summary": "Paul uses Abraham as the ultimate proof of justification by faith. Abraham believed God, and it was credited to him as righteousness *before* he was circumcised. Therefore, Abraham is the father of all who believe, both circumcised and uncircumcised. The promise to Abraham and his offspring did not come through the law, but through the righteousness of faith."
    },
    5: {
        "title": "Peace with God and the Two Adams",
        "themes": "Peace, Hope, Adam vs. Christ, Grace Abounding",
        "outline": "1. Peace and Hope (5:1-11)\n2. Death Through Adam, Life Through Christ (5:12-21)",
        "summary": "Having been justified by faith, believers now have peace with God and can rejoice even in suffering, knowing it produces endurance, character, and hope. Paul then contrasts Adam and Christ: just as sin and death entered the world through one man (Adam), grace and the gift of righteousness overflowed to the many through one man (Jesus Christ). Where sin increased, grace abounded all the more."
    },
    6: {
        "title": "Dead to Sin, Alive in Christ",
        "themes": "Baptism, Freedom from Sin, Slaves to Righteousness",
        "outline": "1. Dead to Sin, Alive to God (6:1-14)\n2. Slaves to Righteousness (6:15-23)",
        "summary": "Paul anticipates an objection: if grace abounds where sin increases, should we keep sinning? 'By no means!' he declares. Through baptism, believers were buried with Christ into death and raised to walk in newness of life. We are no longer slaves to sin, but slaves to righteousness. For the wages of sin is death, but the gift of God is eternal life in Christ Jesus our Lord."
    },
    7: {
        "title": "The Struggle with Sin and the Law",
        "themes": "Released from the Law, The Spiritual Nature of the Law, The Inner Conflict",
        "outline": "1. Released from the Law (7:1-6)\n2. The Law and Sin (7:7-13)\n3. The Conflict of Two Natures (7:14-25)",
        "summary": "Using the analogy of marriage, Paul explains that believers have died to the law so they can belong to Christ and bear fruit for God. He defends the law as holy, righteous, and good, but shows how sin hijacked the law to produce death. He vividly describes the agonizing inner conflict of the awakened sinner: 'For what I want to do I do not do, but what I hate I do.' He concludes with a desperate cry for deliverance, which is answered in Jesus Christ."
    },
    8: {
        "title": "Life in the Spirit",
        "themes": "No Condemnation, The Holy Spirit, Future Glory, Inseparable Love",
        "outline": "1. Free from Condemnation (8:1-4)\n2. Life in the Spirit vs. the Flesh (8:5-17)\n3. Future Glory and Groaning Creation (8:18-30)\n4. More Than Conquerors (8:31-39)",
        "summary": "In one of the most triumphant chapters in the Bible, Paul declares there is now no condemnation for those in Christ Jesus. The Spirit of life sets us free from the law of sin and death. Believers are adopted as children of God, crying 'Abba, Father,' and are heirs with Christ. Despite present sufferings and the groaning of creation, we have the intercession of the Spirit and the promise that God works all things for good. Paul concludes that absolutely nothing in all creation can separate us from the love of God in Christ."
    },
    9: {
        "title": "God's Sovereign Choice",
        "themes": "Sorrow for Israel, God's Sovereignty, The Remnant",
        "outline": "1. Paul's Anguish for Israel (9:1-5)\n2. God's Sovereign Choice: Isaac and Jacob (9:6-18)\n3. The Potter and the Clay (9:19-29)\n4. Israel's Unbelief (9:30-33)",
        "summary": "Transitioning to the problem of Jewish unbelief, Paul expresses deep anguish for his people. He explains that not all physical descendants of Israel are true Israel; God's sovereign choice (seen in Isaac vs. Ishmael, and Jacob vs. Esau) stands. Using the analogy of a potter and clay, Paul defends God's right to show mercy to whom He pleases, including the Gentiles, while preserving a faithful remnant of Israel."
    },
    10: {
        "title": "The Message of Salvation to All",
        "themes": "Zeal without Knowledge, Righteousness by Faith, Preaching the Gospel",
        "outline": "1. Christ is the End of the Law (10:1-4)\n2. The Word of Faith is Near You (10:5-13)\n3. The Necessity of Preaching (10:14-21)",
        "summary": "Paul yearns for Israel's salvation, noting they have a zeal for God but lack knowledge, seeking to establish their own righteousness rather than submitting to God's. He declares that Christ is the culmination of the law for righteousness to everyone who believes. Salvation is accessible to all: 'If you declare with your mouth, \"Jesus is Lord,\" and believe in your heart that God raised him from the dead, you will be saved.' Consequently, he emphasizes the urgent need for preachers to bring this good news to the world."
    },
    11: {
        "title": "The Remnant and the Grafted Branches",
        "themes": "The Remnant of Israel, The Olive Tree, The Mystery of Mercy",
        "outline": "1. The Remnant Chosen by Grace (11:1-10)\n2. Ingrafted Branches (Gentiles) (11:11-24)\n3. All Israel Will Be Saved (11:25-32)\n4. Doxology (11:33-36)",
        "summary": "Has God rejected His people? 'By no means!' Paul asserts. There is a remnant chosen by grace. Israel's stumbling brought salvation to the Gentiles, which in turn should provoke Israel to jealousy. Using the metaphor of an olive tree, Paul warns Gentile believers (wild branches) not to be arrogant toward the broken-off Jewish branches, for God is able to graft them back in. He reveals a mystery: a partial hardening has come upon Israel until the full number of Gentiles has come in, leading to the ultimate salvation of Israel. He breaks into a profound doxology praising God's unsearchable wisdom and judgments."
    },
    12: {
        "title": "Living Sacrifices",
        "themes": "Consecration, Spiritual Gifts, Love in Action",
        "outline": "1. A Living Sacrifice (12:1-2)\n2. Humble Service in the Body of Christ (12:3-8)\n3. Love in Action (12:9-21)",
        "summary": "Shifting from theology to practical application, Paul urges believers to offer their bodies as living sacrifices and to be transformed by the renewing of their minds. He encourages them to use their diverse spiritual gifts in humility for the building up of the church. The chapter concludes with a rapid-fire list of ethical commands centered on sincere love, blessing persecutors, living in harmony, and overcoming evil with good."
    },
    13: {
        "title": "Submission to Authorities and the Law of Love",
        "themes": "Government, Love Fulfills the Law, The Day is Near",
        "outline": "1. Submission to Governing Authorities (13:1-7)\n2. Love Fulfills the Law (13:8-10)\n3. The Day is Near (13:11-14)",
        "summary": "Paul instructs Christians to submit to governing authorities, as they are instituted by God to maintain order and punish wrongdoing. He summarizes our obligation to others by stating that loving one's neighbor fulfills the entire law. Finally, he urges believers to wake from their slumber, cast off the works of darkness, and clothe themselves with the Lord Jesus Christ, because the day of salvation is nearer now than when they first believed."
    },
    14: {
        "title": "The Weak and the Strong",
        "themes": "Judging Others, Stumbling Blocks, Christian Liberty",
        "outline": "1. Do Not Judge One Another (14:1-12)\n2. Do Not Cause Another to Stumble (14:13-23)",
        "summary": "Addressing disputes over disputable matters (like eating meat or observing certain days), Paul commands believers to accept those whose faith is weak without quarreling over opinions. We are not to judge the servant of another, for everyone will stand before God's judgment seat. The overarching principle is love: we must never use our freedom in Christ as a stumbling block that destroys a brother or sister for whom Christ died."
    },
    15: {
        "title": "Pleasing Others and Paul's Ministry",
        "themes": "Unity, Paul's Mission to the Gentiles, Future Plans",
        "outline": "1. Pleasing Others, Not Ourselves (15:1-13)\n2. Paul's Ministry to the Gentiles (15:14-22)\n3. Paul's Plan to Visit Rome (15:23-33)",
        "summary": "Concluding the discussion on the weak and strong, Paul urges believers to follow Christ's example of bearing the failings of others to bring about unity and praise to God. He reflects on his own pioneering ministry as an apostle to the Gentiles, boasting only in what Christ has accomplished through him. Having fulfilled his mission from Jerusalem to Illyricum, Paul shares his travel plans: he hopes to visit Rome on his way to Spain, after delivering a contribution to the poor believers in Jerusalem."
    },
    16: {
        "title": "Personal Greetings and Benediction",
        "themes": "Commendations, Warnings, Final Doxology",
        "outline": "1. Personal Greetings (16:1-16)\n2. Final Instructions and Warnings (16:17-24)\n3. Doxology (16:25-27)",
        "summary": "Paul commends Phoebe, a servant of the church in Cenchreae, and lists a long series of warm, personal greetings to various believers in Rome, highlighting the diversity and affection within the early church. He inserts a brief but stern warning to watch out for those who cause divisions and create obstacles contrary to the doctrine they have been taught. He concludes this magnificent epistle with a majestic doxology, praising the only wise God through Jesus Christ."
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
            "book": "Romans",
            "chapter": ch,
            "verse": None,
            "topic": None,
            "custom": None
        },
        "text": text,
        "id": f"c_breakdown_rom_{ch}"
    }
    entries.append(entry)

with open('assets/commentary/commentary.json', 'r') as f:
    commentary_db = json.load(f)

# Remove any existing breakdowns for Romans to avoid duplicates
commentary_db['entries'] = [e for e in commentary_db['entries'] if not (e['source'] == 'Chapter Breakdown' and e['scope'].get('book') == 'Romans')]
commentary_db['entries'].extend(entries)
commentary_db['count'] = len(commentary_db['entries'])
commentary_db['exportedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat().replace('+00:00', 'Z')

with open('assets/commentary/commentary.json', 'w') as f:
    json.dump(commentary_db, f, indent=2, ensure_ascii=False)

print(f"Added {len(entries)} chapter breakdowns for Romans.")
