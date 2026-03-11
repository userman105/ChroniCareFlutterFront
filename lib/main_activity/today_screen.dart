import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/components.dart';


class TodayScreen extends StatefulWidget {
  final List<HealthTile> tiles;

  const TodayScreen({
    super.key,
    required this.tiles,
  });

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.3,
              ),
              itemCount: widget.tiles.length + 1,
              itemBuilder: (context, index) {
                if (index == widget.tiles.length) {
                  return GestureDetector(
                    onTap: () {
                      AddEntryPopup.show(context, widget.tiles);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D2D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/add.png',
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Add Entry",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.arimo(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final tile = widget.tiles[index];

                return HighlightableGridTile(
                  iconAsset: tile.icon,
                  label: tile.label,
                  selected: tile.selected,
                  onTap: () {
                    setState(() {
                      for (var t in widget.tiles) {
                        t.selected = false;
                      }

                      tile.selected = true;
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}