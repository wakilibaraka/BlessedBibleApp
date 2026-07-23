with open('/Users/baraka/the_blessed_bible/lib/ui/screens/read_screen.dart', 'r') as f:
    content = f.read()

content = content.replace("'Saved ${bookName} ${chapter}:${verseNumber} to Notes'", "'Saved $bookName $chapter:$verseNumber to Notes'")
content = content.replace("'${bookName} ${chapter}:${verseNumber}'", "'$bookName $chapter:$verseNumber'")
content = content.replace("'${verseNumber} \"${verseText}\"'", "'$verseNumber \"$verseText\"'")

with open('/Users/baraka/the_blessed_bible/lib/ui/screens/read_screen.dart', 'w') as f:
    f.write(content)

print("Fixed braces")
