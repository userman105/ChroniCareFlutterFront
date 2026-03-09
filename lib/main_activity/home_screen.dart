import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/components.dart';
import '../personalize_schedule.dart';

class HomeScreen extends StatefulWidget {
  final List<HealthTile> tiles;

  const HomeScreen({
    super.key,
    required this.tiles,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Android icons white
        statusBarBrightness: Brightness.dark, // iOS
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF111111),
        body: SafeArea(
          child: Column(
            children: [

              const TodayDateBar(
                calendarIconAsset: 'assets/icons/calendar.png',
              ),

              const SizedBox(height: 10),

              Container(
                width: 412,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      strokeAlign: BorderSide.strokeAlignCenter,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.3,
                        ),
                        itemCount: widget.tiles.length + 1,
                        itemBuilder: (context, index) {
                          if (index == widget.tiles.length) {
                            // + ADD ENTRY TILE
                            return GestureDetector(
                              onTap: () async {
                                final newTiles = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const PersonalizeSchedule()),
                                );
                                if (newTiles != null) {
                                  setState(() {
                                    widget.tiles
                                      ..clear()
                                      ..addAll(newTiles);
                                  });
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2D2D2D),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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

                          // Only one tile can be selected at a time
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
              ),

            ],
          ),
        ),
        bottomNavigationBar: const BottomNavigationBarCustom(),
      ),
    );
  }
}