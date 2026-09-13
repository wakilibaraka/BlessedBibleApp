import json
import datetime

breakdowns = {
    1: {
        "title": "No Other Gospel",
        "themes": "Divine Authority, Grace vs. Legalism, Paul's Apostolic Credentials",
        "outline": "1. Greeting and Astonishment (1:1-9)\n2. Paul's Divine Commission (1:10-12)\n3. Paul's Former Life in Judaism (1:13-14)\n4. God's Call and Paul's Independence (1:15-24)",
        "summary": "Paul begins with an abrupt and passionate defense of the gospel. Shocked that the Galatians are so quickly deserting the grace of Christ for a 'different gospel' (which is really no gospel at all), he pronounces a severe curse on anyone—even an angel—who preaches contrary to what they originally received. To prove that his message is not man-made, Paul recounts his dramatic conversion. He emphasizes that he did not receive his gospel from the apostles in Jerusalem, but directly through a revelation of Jesus Christ, demonstrating that his authority and his message of grace are absolutely divine."
    },
    2: {
        "title": "Justification by Faith Alone",
        "themes": "Unity of the Gospel, Confronting Hypocrisy, Crucified with Christ",
        "outline": "1. The Council at Jerusalem (2:1-10)\n2. Paul Confronts Peter in Antioch (2:11-14)\n3. Justified by Faith, Not by Law (2:15-21)",
        "summary": "Fourteen years after his conversion, Paul travels to Jerusalem to privately present his gospel to the leading apostles, who fully endorse his ministry to the Gentiles and add nothing to his message. However, when Peter later comes to Antioch and hypocritically withdraws from eating with Gentile believers out of fear of the circumcision group, Paul confronts him publicly for compromising the truth of the gospel. Paul then lays out the core theological thesis of the letter: a person is not justified by works of the law, but by faith in Jesus Christ. He famously declares, 'I have been crucified with Christ... I do not set aside the grace of God, for if righteousness could be gained through the law, Christ died for nothing!'"
    },
    3: {
        "title": "The Purpose of the Law",
        "themes": "The Spirit and Faith, The Curse of the Law, Children of Abraham",
        "outline": "1. Bewitched by Legalism (3:1-5)\n2. Abraham Justified by Faith (3:6-9)\n3. Christ Redeems from the Curse (3:10-14)\n4. The Law and the Promise (3:15-22)\n5. Children of God Through Faith (3:23-29)",
        "summary": "Paul scolds the 'foolish Galatians' for trying to perfect by human effort what was begun by the Holy Spirit. He uses the ultimate Jewish patriarch, Abraham, to prove that righteousness has always been credited through faith, not works. He explains that the law actually brings a curse on those who fail to keep it perfectly, but Christ redeemed us from this curse by becoming a curse for us on the cross. The law, which came 430 years after God's promise to Abraham, was never meant to impart life; it was a tutor to lead us to Christ. Now that faith has come, we are no longer under a guardian, but are all one in Christ—Abraham's true seed."
    },
    4: {
        "title": "Sons and Heirs",
        "themes": "Adoption, Freedom vs. Slavery, Hagar and Sarah",
        "outline": "1. From Slaves to Sons (4:1-7)\n2. Paul's Concern for the Galatians (4:8-20)\n3. The Allegory of Hagar and Sarah (4:21-31)",
        "summary": "Continuing the theme of inheritance, Paul compares life under the law to a child who is an heir but lives under guardians, functionally no different than a slave. But at the right time, God sent His Son to redeem those under the law so they could receive the full rights of adoption. Because we are sons, God has sent the Spirit of His Son into our hearts, crying, 'Abba, Father.' Paul pleads with the Galatians not to turn back to weak and miserable legalistic principles. He then uses an allegory: Hagar (the slave woman) represents the covenant of law from Mount Sinai, which bears children into slavery, while Sarah (the free woman) represents the heavenly Jerusalem and the covenant of promise, to which true believers belong."
    },
    5: {
        "title": "Freedom in Christ and the Spirit's Fruit",
        "themes": "Stand Firm in Liberty, Faith Working Through Love, Flesh vs. Spirit",
        "outline": "1. Freedom in Christ (5:1-12)\n2. Freedom to Serve in Love (5:13-15)\n3. The Works of the Flesh (5:16-21)\n4. The Fruit of the Spirit (5:22-26)",
        "summary": "Paul declares that Christ has set us free for the purpose of freedom itself; therefore, we must not let ourselves be burdened again by a yoke of slavery like circumcision. In Christ, what matters is not circumcision or uncircumcision, but 'faith expressing itself through love.' However, this freedom is not an excuse for the flesh, but a call to serve one another in love. Paul contrasts the destructive works of the flesh (sexual immorality, idolatry, jealousy, fits of rage) with the beautiful fruit of the Spirit (love, joy, peace, patience, kindness, goodness, faithfulness, gentleness, self-control), urging believers to keep in step with the Spirit."
    },
    6: {
        "title": "Bearing One Another's Burdens",
        "themes": "Restoration, Sowing and Reaping, Boasting Only in the Cross",
        "outline": "1. Restoring the Fallen (6:1-5)\n2. Sowing and Reaping (6:6-10)\n3. Final Warnings and Benediction (6:11-18)",
        "summary": "In the concluding chapter, Paul provides practical instructions for the Spirit-led community. They are to gently restore those caught in sin and carry each other's burdens, thereby fulfilling the law of Christ. He warns them not to be deceived: whatever a person sows, they will reap. Those who sow to the flesh reap destruction, while those who sow to the Spirit reap eternal life. Taking the pen in his own hand for the closing words, Paul exposes the false teachers' true motive—they want to make a good impression outwardly to avoid persecution. He concludes with his famous declaration: 'May I never boast except in the cross of our Lord Jesus Christ, through which the world has been crucified to me, and I to the world.'"
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
            "book": "Galatians",
            "chapter": ch,
            "verse": None,
            "topic": None,
            "custom": None
        },
        "text": text,
        "id": f"c_breakdown_gal_{ch}"
    }
    entries.append(entry)

with open('assets/commentary/commentary.json', 'r') as f:
    commentary_db = json.load(f)

# Remove any existing breakdowns for Galatians to avoid duplicates if re-run
commentary_db['entries'] = [e for e in commentary_db['entries'] if not (e['source'] == 'Chapter Breakdown' and e['scope'].get('book') == 'Galatians')]
commentary_db['entries'].extend(entries)
commentary_db['count'] = len(commentary_db['entries'])
commentary_db['exportedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat().replace('+00:00', 'Z')

with open('assets/commentary/commentary.json', 'w') as f:
    json.dump(commentary_db, f, indent=2, ensure_ascii=False)

print(f"Added {len(entries)} chapter breakdowns for Galatians.")
