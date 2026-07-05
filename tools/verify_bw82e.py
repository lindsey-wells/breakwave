from pathlib import Path
import sys

path = Path("lib/features/rescue/presentation/widgets/rescue_card_engine.dart")
text = path.read_text(encoding="utf-8")

required = [
    "Notes: BW-82E adds horizontal swipe navigation while keeping button fallback.",
    "static const double _swipeVelocityThreshold = 180;",
    "void _nextCard()",
    "void _previousCard()",
    "_currentIndex = (_currentIndex - 1 + _cards.length) % _cards.length;",
    "void _handleCardSwipe(DragEndDetails details)",
    "details.primaryVelocity ?? 0",
    "velocity <= -_swipeVelocityThreshold",
    "velocity >= _swipeVelocityThreshold",
    "return GestureDetector(",
    "behavior: HitTestBehavior.opaque",
    "onHorizontalDragEnd: _handleCardSwipe",
    "AnimatedSwitcher(",
    "duration: const Duration(milliseconds: 180)",
    "key: ValueKey<String>(card.id)",
    "Swipe left or right for another rescue card.",
    "Show another Christian rescue card",
    "Show another secular rescue card",
    "Christian Rescue Card",
    "Secular Rescue Card",
]

for needle in required:
    if needle not in text:
        print(f"FAIL BW-82E Rescue card swipe missing: {needle}")
        sys.exit(1)

if "onPressed: () {}" in text:
    print("FAIL BW-82E introduced a dead button callback")
    sys.exit(1)

print("PASS: BW-82E swipe Rescue cards verified.")
