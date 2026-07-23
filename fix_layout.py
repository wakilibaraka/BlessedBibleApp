with open('/Users/baraka/the_blessed_bible/lib/ui/screens/main_nav_screen.dart', 'r') as f:
    content = f.read()

# Replace body up to the Builder with a Builder for the whole body
target_body_start = """      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBackground(appThemeMode: appThemeMode),
          ),
          IndexedStack(
            index: currentIndex,
            children: screens,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Builder(
          builder: (context) {"""

replacement_body_start = """      body: Builder(
        builder: (context) {"""

content = content.replace(target_body_start, replacement_body_start)

# Now find the SizedBox that wraps the Stack and replace it with the Stack containing the background, screens, and the dock
target_sized_box = """            return SizedBox(
              height: height + 32.0,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: rightOffset,
                    bottom: 16.0,
                    child: Row("""

replacement_stack = """            return Stack(
              children: [
                Positioned.fill(
                  child: AnimatedBackground(appThemeMode: appThemeMode),
                ),
                IndexedStack(
                  index: currentIndex,
                  children: screens,
                ),
                // ── NAVIGATION OVERLAY LAYER ──
                Positioned(
                  right: rightOffset,
                  bottom: MediaQuery.of(context).padding.bottom + 16.0,
                  child: Row("""

content = content.replace(target_sized_box, replacement_stack)

# Now we need to remove the closing tags of the SizedBox and SafeArea
# The bottomNavigationBar ended with:
#                   ),
#                 ],
#               ),
#             );
#           },
#         ),
#       ),
#     );

target_end = """                  ),
                ],
              ),
            );
          },
        ),
      ),
    );"""

replacement_end = """                  ),
                ],
              ),
            );
          },
        ),
    );"""

content = content.replace(target_end, replacement_end)

with open('/Users/baraka/the_blessed_bible/lib/ui/screens/main_nav_screen.dart', 'w') as f:
    f.write(content)

print("Refactored main_nav_screen.dart layout")
