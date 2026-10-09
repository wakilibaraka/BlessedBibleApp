#!/usr/bin/env python3
"""Fetch public-domain Gustave Dore Bible engravings from Wikimedia Commons.

Uses a hand-curated mapping of plate slug -> exact Commons filenames
(discovered via the Doré categories on Commons). Filenames are tried in
order until one resolves. Thumbnail downloads are batched and cached.

Writes:
  assets/devotional/art/<slug>.webp       - processed engravings
  assets/devotional/art/artwork_map.json  - book prefix -> artwork mapping
  tools/data/dore_credits.json            - source URLs + credits

Run:  python3 tools/fetch_dore_art.py
"""

import io
import json
import os
import sys
import time
import urllib.parse
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from devotional_common import ART_DIR, TOOLS_DATA_DIR, ensure_dirs, http_get, log, save_json  # noqa: E402

from PIL import Image, ImageEnhance  # noqa: E402

TARGET_WIDTH = 960  # Wikimedia standard thumbnail bucket (1024 is not an allowed size)
WEBP_QUALITY = 72
API = "https://commons.wikimedia.org/w/api.php"
UA = {"User-Agent": "BlessedBibleApp-port/1.0 (contact: developer)"}
TITLE_CACHE = os.path.join(TOOLS_DATA_DIR, "dore_category_files.json")

# slug -> (caption, [book prefixes], [Commons filenames to try, in order])
PLATES = {
    "creation": ("The Creation of Light", ["GEN"], ["001.The Creation of Light.jpg", "Creation of Light (89392244).jpg", "Creation of Light.png", "Dore light.jpg"]),
    "garden-of-eden": ("The Garden of Eden", ["GEN"], ["Formation of Eve.png", "Adamandevesin.jpg"]),
    "eden-expulsion": ("Expulsion from Eden", ["GEN"], ["Adam and Eve Driven out of Eden (89392756).jpg", "Adam and Eve Driven out of Eden.png", "Adam and Eve expelled from Paradise.png"]),
    "cain-abel": ("Cain and Abel", ["GEN"], ["Cain kills Abel.png", "Cain and Abel Offering their Sacrifices.png", "DescendantsOfCain.jpg"]),
    "flood": ("The Deluge", ["GEN"], ["Deluge gustave dore.jpg", "Gustave Doré - The Holy Bible - Plate I, The Deluge.jpg", "Deluge retouched.png", "Gustave dure holy bible deluge edited.jpg"]),
    "noah-ark": ("The Dove Sent Forth from the Ark", ["GEN"], ["Dove Sent Forth from the Ark (89393604).jpg", "Dove Sent Forth from the Ark.png"]),
    "babel": ("The Tower of Babel", ["GEN"], ["Gustave Dore Bible The Tower of Babel.jpg", "Confusion of Tongues (89393754).jpg", "Confusion of Tongues.png"]),
    "abraham-journey": ("Abraham Journeying to Canaan", ["GEN"], ["Abraham Journeying into the Land of Canaan (89393798).jpg", "Abraham Journeying into the Land of Canaan.png"]),
    "abraham-angels": ("Abraham and the Three Angels", ["GEN"], ["Abraham and the Three Angels (89393872).jpg", "Abraham and the Three Angels.png"]),
    "sodom": ("The Destruction of Sodom", ["GEN"], ["Sodoma (89393948).jpg", "Sodoma Doré2.jpg", "Sodoma - Doré.jpg"]),
    "sacrifice-isaac": ("The Sacrifice of Isaac", ["GEN"], ["DoreHagar.jpg"]),  # placeholder replaced below
    "isaac-jacob": ("Isaac Blessing Jacob", ["GEN"], ["Isaac Blessing Jacob (89394529).jpg", "Isaac blessing Jacob.png"]),
    "jacob-dream": ("Jacob's Dream", ["GEN"], ["Gustave Doré - Study for \"Jacob's Dream\" - Walters 371319.jpg"]),
    "jacob-wrestles": ("Jacob Wrestling the Angel", ["GEN"], ["Jacob Wrestling with the Angel.jpg", "Jacob-angel.jpg", "Jacob Wrestling with the Angel (cropped).jpg"]),
    "joseph-betrayed": ("Joseph Makes Himself Known", ["GEN"], ["Dore Bible Joseph Makes Himself Known to His Brethren.jpg"]),
    "moses-burning-bush": ("Moses at the Burning Rock of Horeb", ["EXO"], ["Dore Moses Striking the Rock in Horeb (93215417).jpg", "Dore Moses Striking the Rock in Horeb.jpg", "Moses dore.jpg"]),
    "passover-plague": ("The Death of the Firstborn", ["EXO"], ["Dore Death of Korah, Dathan and Abiram.jpg"]),
    "crossing-red-sea": ("Crossing the Red Sea", ["EXO"], ["Dore joshua crossing.jpg"]),
    "ten-commandments": ("Moses Radiant with the Law", ["EXO", "DEU", "LEV", "NUM"], ["Moses radiant.jpg", "Moses dore.jpg"]),
    "wilderness-rock": ("Water from the Rock", ["EXO", "NUM"], ["Dore Moses Striking the Rock in Horeb.jpg"]),
    "spies-canaan": ("Return of the Spies", ["NUM", "DEU"], ["Dore Return of the Spies From the Land of Promise.jpg"]),
    "jericho": ("Rahab and the Fall of Jericho", ["JOS"], ["The walls of Jericho falling down — Doré Bible illustration (Cassell, c.1870).jpg", "Rahab dore.jpg"]),
    "joshua-sun": ("Joshua Commanding the Sun", ["JOS"], ["Joshua Commanding the Sun to Stand Still (89397274).jpg", "Dore joshua sun.jpg"]),
    "judge-samson": ("Samson Slaying the Lion", ["JDG"], ["Dore-SamsonSlayingTheLion.jpg", "Samson tue un lion.jpg"]),
    "ruth-boaz": ("Ruth and Boaz", ["RUT"], ["Dore 084.jpg", "The Gleaners"]),  # fallback below
    "david-goliath": ("David and Goliath", ["1SA"], ["David-goliath28.jpg"]),
    "witch-endor": ("Saul and the Witch of Endor", ["1SA"], ["Witch of Endor. Dore 1866.jpg", "Dore SaulAndTheWitchOfEndor.jpg"]),
    "david-king": ("The Death of Absalom", ["2SA"], ["Death of Absalom (89400023).jpg", "Gustave dore bibel death of absalom.jpg"]),
    "david-michal": ("Michal Lets David Escape", ["1SA", "2SA", "PSA"], ["Michal lets David escape (89398919).jpg", "Michal Gustave Doré.jpg"]),
    "solomon-judgement": ("The Judgement of Solomon", ["1KI"], ["Judgement of Solomon (89400418).jpg", "Judgement of Solomon.jpg"]),
    "solomon-temple": ("The Ark of the Covenant", ["1KI", "2CH"], ["Gustave Doré - Ark of the Covenant.jpg"]),
    "queen-sheba": ("King Solomon in Old Age", ["1KI", "PRO", "ECC", "SNG"], ["King Solomon in Old Age higher-contrast version.png"]),
    "elijah-carmel": ("Elijah Taken Up to Heaven", ["1KI", "2KI"], ["Elijah taken up into heaven (89401747).jpg", "Gustave Doré - 2 Kings 2 - 11.jpg"]),
    "jezebel": ("The Death of Jezebel", ["1KI", "2KI"], ["The Death of Jezebel (89401984).jpg", "The Death of Jezebel.jpg"]),
    "job-suffering": ("Job in Affliction", ["JOB"], ["Рицпа отгоняет птиц. Географ.png", "Michal Gustave Doré.jpg"]),
    "psalm-shepherd": ("David, the Psalmist", ["PSA"], ["David-goliath28.jpg"]),
    "wisdom-solomon": ("Solomon's Wisdom", ["PRO", "ECC", "SNG"], ["King Solomon in Old Age higher-contrast version.png", "Dore Solomon Proverbs.png"]),
    "isaiah-vision": ("A Prophet's Vision", ["ISA"], ["Gustave Doré (1832-1883) - The Bible (1865) - Zechariah 6-5.jpg", "127.Ezekiel’s Vision of the Valley of Dry Bones.jpg"]),
    "jeremiah-lament": ("Jeremiah the Prophet", ["JER", "LAM"], ["123.The Prophet Jeremiah (retusche).jpg", "Le prophète Jérémie à la dictée, par Gustave Doré.jpg", "Baruch Writing Jeremiah's Prophecies (89467495).jpg"]),
    "ezekiel-valley": ("Ezekiel's Vision of the Valley of Dry Bones", ["EZK"], ["127.Ezekiel’s Vision of the Valley of Dry Bones.jpg", "Ezekiel’s Vision of the Valley of Dry Bones.jpg", "The Vision of The Valley of The Dry Bones.jpg", "Ezekiel Prophesying — Doré Bible illustration (Cassell, c.1870).jpg"]),
    "daniel-lions": ("Daniel in the Lions' Den", ["DAN"], ["La Vision de Daniel.jpg", "Le Prophète Daniel.jpg", "Le Prophète Ezechiel.jpg"]),
    "jonah-whale": ("Jonah and the Great Fish", ["JON", "OBA", "JOE", "AMO", "HOS", "MIC", "NAH", "HAB", "ZEP", "HAG", "ZEC", "MAL"], ["Jonah and the whale (89471723).jpg", "Dore jonah whale.jpg", "Dore jonah.jpg"]),
    "minor-prophets": ("The Prophet Amos", ["AMO", "HOS", "MIC", "NAH", "HAB", "ZEP", "HAG", "ZEC", "MAL", "JOE", "OBA"], ["Prophet Amos (89471482).jpg", "Prophet amos.jpg", "Zechariah's Vision of Four Chariots (89472609).jpg"]),
    "annunciation": ("The Annunciation", ["GSP"], ["Gustave Dore - The Annunciation.jpg"]),
    "nativity": ("The Birth of Jesus", ["GSP"], ["The Birth of Jesus.jpg", "Dore - Flight into Egypt.jpg"]),
    "john-baptist": ("John the Baptist Preaching", ["GSP"], ["DoreJohntheBaptistPreachingintheWilderness.jpg", "Gustave Dore - John the Baptist baptizes Jesus.jpg"]),
    "tempest": ("Jesus Calming the Tempest", ["GSP"], ["Jesus walks on the sea.jpg", "JesusCalmingtheTempestDore.jpg"]),
    "healing": ("Jesus Healing the Sick", ["GSP"], ["HealingGustaveDore.jpg", "Jésus guérit les malades, par Gustave Doré.jpg", "Jesus healing the sick (89476181).jpg", "Gustave Dore - Jesus raises the daughter of Jairus from the dead.jpg"]),
    "feeding-multitude": ("Feeding the Multitude", ["GSP"], ["JesusFeedingMultitude.jpg", "La pêche miraculeuse de Gustave Doré.jpg"]),
    "good-samaritan": ("The Good Samaritan", ["GSP"], ["Gustave Dore Lazarus and the Rich Man.jpg"]),
    "prodigal-son": ("The Prodigal Son", ["GSP"], ["Gustave Dore - The prodigal son decides to return to his father.jpg", "Le retour de l'enfant prodigue, par Gustave Doré.jpg"]),
    "lazarus": ("Lazarus and the Rich Man", ["GSP"], ["The beggar Lazarus begs at the gate of the rich man.jpg", "Gustave Dore Lazarus and the Rich Man.jpg"]),
    "palm-sunday": ("Christ's Entry into Jerusalem", ["GSP"], ["Gustave Doré - Christ's Entry into Jerusalem.jpg", "Gustave Dore - Jesus rides into Jerusalem on a donkey on Palm Sunday.jpg"]),
    "last-supper": ("The Last Supper", ["GSP"], ["Jesus and the disciples at the Last Supper.jpg"]),
    "gethsemane": ("Gethsemane", ["GSP"], ["Jesus Praying in the Garden (1878) (14577654100).jpg", "Jesus suffers agony in the garden of Gethseman.jpg", "DoreJesusPrayingintheGarden.jpg"]),
    "judas-kiss": ("The Judas Kiss", ["GSP"], ["Gustave Dore - Judas betrays Jesus with a kiss.jpg", "Gustave Doré - The Holy Bible - Plate CXLI, The Judas Kiss.jpg"]),
    "trial-caiaphas": ("Christ Before Caiaphas", ["GSP"], ["Gustave Doré - The House of Caiaphas - Google Art Project.jpg", "Doré, Le Christ condamné.jpg"]),
    "crucifixion": ("The Crucifixion", ["GSP"], ["Gustave Doré - Christ on the Cross - Google Art Project.jpg", "Crucifixion-dore.jpg", "Gustave Doré - Crucifixion of Jesus.jpg"]),
    "resurrection": ("The Ascension", ["GSP"], ["Gusta Dore - The Ascension.jpg", "Gustave Doré - L'Ascension.jpg"]),
    "peter-denial": ("Peter Denying Christ", ["GSP"], ["Gustave Doré, St Peter Denying Christ.jpg", "Peter denies that he is one of Jesus’ disciples.jpg"]),
    "pentecost-church": ("Peter's Escape from Prison", ["ACT"], ["Peter'sEscapefromPrison.jpg", "StPeterattheHouseofCornelius.jpg"]),
    "stephen-martyr": ("The Death of Stephen", ["ACT"], ["The Death of Stephen by Gustave Doré.jpg", "The Death of Stephen (89485178).jpg"]),
    "paul-ministry": ("Paul Preaching at Thessalonica", ["ACT", "ROM", "1CO", "2CO", "GAL", "EPH", "PHP", "COL", "1TH", "2TH", "1TI", "2TI", "TIT", "PHM", "HEB"], ["DoreStPaulPreachingtotheThessalonians.jpg", "Paul Addresses the Crowd After His Arrest by Gustave Doré.jpg", "St Paul in prison.jpg"]),
    "revelation-throne": ("St. John's Vision", ["REV", "JAS", "1PE", "2PE", "1JO", "2JO", "3JO", "JUD"], ["Gustave Doré - St. John's vision of death.jpg", "Gustave Doré (1832-1883) - The Bible (1865) - Zechariah 6-5.jpg"]),
}

# Corrections applied after review of ambiguous matches:
PLATES["sacrifice-isaac"] = ("The Sacrifice of Isaac", ["GEN"], ["Abraham,God and two angels (89393872).jpg", "Abraham,God and two angels.png"])
PLATES["ruth-boaz"] = ("Ruth Gleaning in the Field", ["RUT"], ["Dore Bible The Gleaners.jpg", "Dore 084.jpg"])

# Plates whose cached file is wrong or too small - force re-download even if cached.
# (populated after reviewing first-run results)
FORCE_REDOWNLOAD = {
    "creation",           # old run grabbed a penguin photo via search fallback
    "crossing-red-sea",   # wrong subject (Jesus on Galilee); use joshua-crossing-jordan instead
    "paul-ministry",      # wrong subject (Saul & witch); proper file exists
    "ruth-boaz",          # 330px fragment; The Gleaners is the proper plate
    "proverbs-wisdom",    # 300px thumbnail
    "job-suffering",      # 1024x195 crop, too extreme
    "david-king",         # 795px original-ish; want thumb render
    "jacob-wrestles",
    "judge-samson",
    "wilderness-rock",
    "spies-canaan",
    "tempest",
    "stephen-martyr",
    "ten-commandments",
    "jericho",
    "ezekiel-valley",
}
PLATES["crossing-red-sea"] = ("Crossing the Jordan into Canaan", ["EXO", "JOS"], ["Dore joshua crossing.jpg", "Joshua Crossing Jordan (89396850).jpg"])
# Books with no exact plate get the nearest thematic engraving:
PLATES["solomon-temple"] = ("The Ark of the Covenant", ["1KI", "2CH", "EZR", "NEH"], ["Gustave Doré - Ark of the Covenant.jpg"])
PLATES["david-king"] = ("The Death of Absalom", ["2SA", "1CH"], ["Death of Absalom (89400023).jpg", "Gustave dore bibel death of absalom.jpg"])
PLATES["solomon-judgement"] = ("The Judgement of Solomon", ["1KI", "EST"], ["Judgement of Solomon (89400418).jpg", "Judgement of Solomon.jpg"])
PLATES["paul-ministry"] = ("Paul Preaching at Thessalonica", ["ACT", "ROM", "1CO", "2CO", "GAL", "EPH", "PHP", "COL", "1TH", "2TH", "1TI", "2TI", "TIT", "PHM", "HEB", "JAS", "1PE", "2PE", "1JO", "2JO", "3JO", "JUD"], ["DoreStPaulPreachingtotheThessalonians.jpg", "Paul Addresses the Crowd After His Arrest by Gustave Doré.jpg", "St Paul in prison.jpg"])


def api_json(params: dict, retries: int = 6):
    params = dict(params, format="json")
    url = API + "?" + urllib.parse.urlencode(params)
    for attempt in range(retries):
        try:
            req = urllib.request.Request(url, headers=UA)
            with urllib.request.urlopen(req, timeout=60) as r:
                return json.load(r)
        except Exception as e:  # noqa: BLE001
            wait = 30 * (attempt + 1)
            log(f"    api retry in {wait}s ({e})")
            time.sleep(wait)
    raise RuntimeError("api exhausted retries")


def normalize(title: str) -> str:
    return title[len("File:") :] if title.startswith("File:") else title


CATEGORY_TITLES_CACHE = os.path.join(TOOLS_DATA_DIR, "dore_thumburls.json")
CATEGORIES = [
    "Category:Bible illustrations by Gustave Doré",
    "Category:Art depicting the Old Testament by Gustave Doré",
    "Category:Art depicting the New Testament by Gustave Doré",
    "Category:Creation of Light by Gustave Doré",
]


def category_thumb_urls() -> dict:
    """Page all Doré categories with imageinfo, returning {filename: thumburl}.

    Titles come straight from the API (generator=categorymembers), which avoids
    title-normalization problems with accented/special characters.
    """
    if os.path.exists(CATEGORY_TITLES_CACHE):
        log("  using cached category thumburls")
        return json.load(open(CATEGORY_TITLES_CACHE))
    out = {}
    for cat in CATEGORIES:
        cont = ""
        while True:
            params = {
                "action": "query",
                "prop": "imageinfo",
                "iiprop": "url|size",
                "iiurlwidth": TARGET_WIDTH,
                "generator": "categorymembers",
                "gcmtype": "file",
                "gcmlimit": 50,
                "gcmtitle": cat,
            }
            if cont:
                params["gcmcontinue"] = cont
            data = api_json(params)
            for p in data.get("query", {}).get("pages", {}).values():
                if "imageinfo" in p:
                    info = p["imageinfo"][0]
                    u = info.get("thumburl") or info.get("url")
                    if u:
                        out[normalize(p["title"])] = u
            cont = data.get("continue", {}).get("gcmcontinue", "")
            if not cont:
                break
            time.sleep(1)
        log(f"  {cat.split(':')[1]}: cumulative {len(out)} urls")
    json.dump(out, open(CATEGORY_TITLES_CACHE, "w"))
    return out


def thumbify(url: str, width: int = TARGET_WIDTH) -> str:
    """Ensure a thumbnail URL at <=width px, stripping utm query params.

    When the requested thumb width >= original width, imageinfo returns the
    ORIGINAL url (with utm params). Rewrite it into standard /thumb/ form so
    we download a small render instead of a 50MB scan (also avoids 429s).
    Wikimedia only renders fixed size buckets (250/330/500/960/1280/...);
    off-bucket widths return HTTP 400.
    """
    url = url.split("?")[0]
    if "/thumb/" in url:
        return url
    # .../commons/<x>/<xy>/<Filename> -> .../commons/thumb/<x>/<xy>/<Filename>/<width>px-<Filename>
    marker = "/commons/"
    idx = url.find(marker)
    if idx == -1:
        return url
    path = url[idx + len(marker) :].strip("/")  # e.g. e/ef/Name.jpg
    parts = path.split("/")
    if len(parts) != 3:
        return url
    h1, h2, name = parts
    return f"{url[:idx]}/commons/thumb/{h1}/{h2}/{name}/{width}px-{name}"


def process(raw: bytes, slug: str) -> dict:
    img = Image.open(io.BytesIO(raw)).convert("L")
    if img.width > TARGET_WIDTH:
        h = round(img.height * TARGET_WIDTH / img.width)
        img = img.resize((TARGET_WIDTH, h), Image.LANCZOS)
    img = ImageEnhance.Contrast(img).enhance(1.06)
    out = os.path.join(ART_DIR, f"{slug}.webp")
    img.save(out, "WEBP", quality=WEBP_QUALITY, method=6)
    return {"file": f"{slug}.webp", "width": img.width, "height": img.height, "bytes": os.path.getsize(out)}


def main() -> None:
    ensure_dirs()
    map_path = os.path.join(ART_DIR, "artwork_map.json")
    credits_path = os.path.join(TOOLS_DATA_DIR, "dore_credits.json")
    art_map = json.load(open(map_path)) if os.path.exists(map_path) else {}
    credits = {
        "artist": "Gustave Doré (1832-1883)",
        "license": "Public domain",
        "source": "Wikimedia Commons",
        "note": "Bible engravings. Processed: grayscale, <=1024px, WebP q72.",
        "plates": json.load(open(credits_path)).get("plates", {}) if os.path.exists(credits_path) else {},
    }

    todo = {}
    for slug, (caption, topics, candidates) in PLATES.items():
        dest = os.path.join(ART_DIR, f"{slug}.webp")
        cached_ok = (
            os.path.exists(dest)
            and os.path.getsize(dest) > 10_000
            and slug in credits["plates"]
            and slug not in FORCE_REDOWNLOAD
        )
        if cached_ok:
            for prefix in topics:
                art_map.setdefault(prefix, {"plate": slug, "caption": caption})
            continue
        todo[slug] = (caption, topics, candidates)
    if not todo:
        save_json(map_path, art_map)
        save_json(credits_path, credits, sort_keys=True)
        log("All plates cached; map rewritten.")
        return

    # Resolve candidate filenames from the cached category scan.
    url_by_file = category_thumb_urls()
    log(f"  {len(url_by_file)} category files with thumburls")

    ok = fail = 0
    for slug, (caption, topics, candidates) in todo.items():
        chosen_file = next((c for c in candidates if c in url_by_file), None)
        if not chosen_file:
            fail += 1
            log(f"  {slug}: none of {candidates} resolved")
            continue
        url = thumbify(url_by_file[chosen_file])
        try:
            raw = http_get(url, timeout=120, retries=6)
            meta = process(raw, slug)
            credits["plates"][slug] = {"caption": caption, "source": chosen_file, "url": url_by_file[chosen_file], **meta}
            for prefix in topics:
                art_map.setdefault(prefix, {"plate": slug, "caption": caption})
            ok += 1
            log(f"  ok {slug} <- {chosen_file} ({meta['bytes'] // 1024} KB)")
        except Exception as e:  # noqa: BLE001
            fail += 1
            log(f"  FAIL {slug}: {e}")
        time.sleep(6)

    save_json(map_path, art_map)
    save_json(credits_path, credits, sort_keys=True)
    total = sum(p.get("bytes", 0) for p in credits["plates"].values())
    log(f"Done: +{ok} plates, {fail} unresolved, total art {total / 1e6:.1f} MB, prefixes mapped {len(art_map)}/66")


if __name__ == "__main__":
    main()
