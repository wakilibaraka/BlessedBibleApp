import os
import re

files_to_update = [
    'lib/ui/screens/study_screen.dart',
    'lib/ui/screens/main_nav_screen.dart',
    'lib/ui/screens/votd_archive_screen.dart',
    'lib/ui/screens/read_screen.dart',
    'lib/ui/screens/home_screen.dart',
    'lib/ui/widgets/your_space_hero.dart',
    'lib/ui/screens/reading_plans_hub_screen.dart'
]

for filepath in files_to_update:
    if not os.path.exists(filepath):
        continue
    with open(filepath, 'r') as f:
        content = f.read()
    
    original = content
    
    # Replace MaterialPageRoute
    content = content.replace("MaterialPageRoute", "CupertinoPageRoute")
    
    # Replace PageRouteBuilder in study_screen
    if "PageRouteBuilder(" in content and "ReadingPlansHubScreen" in content:
        content = re.sub(
            r'PageRouteBuilder\(\s*pageBuilder:\s*\(context,\s*animation,\s*secondaryAnimation\)\s*=>\s*const\s*ReadingPlansHubScreen\(\),\s*transitionsBuilder:\s*\(context,\s*animation,\s*secondaryAnimation,\s*child\)\s*\{\s*return\s*FadeTransition\(opacity:\s*animation,\s*child:\s*child\);\s*\},\s*transitionDuration:\s*const\s*Duration\(milliseconds:\s*300\),\s*\)',
            r'CupertinoPageRoute(builder: (_) => const ReadingPlansHubScreen())',
            content
        )
        
    # Replace PageRouteBuilder in reading_plans_hub_screen
    if "PageRouteBuilder(" in content and "ReadingPlanBrowser" in content:
        content = re.sub(
            r'PageRouteBuilder\(\s*pageBuilder:\s*\(context,\s*animation,\s*secondaryAnimation\)\s*=>\s*const\s*ReadingPlanBrowser\(\),\s*transitionsBuilder:\s*\(context,\s*animation,\s*secondaryAnimation,\s*child\)\s*\{\s*return\s*FadeTransition\(opacity:\s*animation,\s*child:\s*child\);\s*\},\s*transitionDuration:\s*const\s*Duration\(milliseconds:\s*300\),\s*\)',
            r'CupertinoPageRoute(builder: (_) => const ReadingPlanBrowser())',
            content
        )
        
    if content != original:
        # add cupertino import if missing
        if "import 'package:flutter/cupertino.dart';" not in content:
            content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:flutter/cupertino.dart';")
        with open(filepath, 'w') as f:
            f.write(content)

print("Done replacing routes.")
